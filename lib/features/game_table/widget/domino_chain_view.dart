import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:crownpass/app/theme.dart';
import 'package:crownpass/data/models/domino_tile_model.dart';
import 'domino_tile_widget.dart';

class DominoChainView extends StatelessWidget {
  final List<DominoTileModel> chain;

  const DominoChainView({super.key, required this.chain});

  @override
  Widget build(BuildContext context) {
    if (chain.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: Text(
          'Papan Domino Kosong',
          style: GoogleFonts.outfit(
            color: AppTheme.textMuted,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMD),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardBorder.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        border: Border.all(
          color: AppTheme.cardBorder.withValues(alpha: 0.08),
          width: 1.5,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const maxRows = 4;
          const minScale = 0.36;
          const maxScale = 0.62;
          const boardHeight = 172.0;
          const labelSpace = 10.0;
          const tileVisualWidth = 90.0;
          const tileVisualHeight = 96.0;
          const tileStrideWidth = 70.0;

          final availableWidth =
              constraints.maxWidth.clamp(120.0, double.infinity);
          const naturalTileWidth = tileVisualWidth * maxScale;
          const naturalStrideWidth = tileStrideWidth * maxScale;
          final naturalTilesPerRow = chain.length == 1
              ? 1
              : (((availableWidth - naturalTileWidth) / naturalStrideWidth)
                          .floor() +
                      1)
                  .clamp(1, chain.length);
          final naturalRows = (chain.length / naturalTilesPerRow).ceil();
          final rowCount = naturalRows.clamp(1, maxRows);
          final tilesPerRow = (chain.length / rowCount).ceil();

          final compactRowWidth = tileVisualWidth +
              ((tilesPerRow - 1).clamp(0, chain.length) * tileStrideWidth);
          final scaleFromWidth = availableWidth / compactRowWidth;
          final rowHeight = boardHeight / rowCount;
          final scaleFromHeight =
              (rowHeight - labelSpace).clamp(32.0, tileVisualHeight) /
                  tileVisualHeight;
          final tileScale = scaleFromWidth
              .clamp(minScale, maxScale)
              .clamp(minScale, scaleFromHeight.clamp(minScale, maxScale));

          final visualWidth = tileVisualWidth * tileScale;
          final strideWidth = tileStrideWidth * tileScale;
          final trackWidth = visualWidth +
              ((tilesPerRow - 1).clamp(0, chain.length) * strideWidth);
          final rowCounts = List<int>.generate(rowCount, (rowIndex) {
            final start = rowIndex * tilesPerRow;
            final end = (start + tilesPerRow).clamp(0, chain.length);
            return end - start;
          });

          return SizedBox(
            height: boardHeight,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ChainPathPainter(
                      rowCounts: rowCounts,
                      rowHeight: rowHeight,
                      visualWidth: visualWidth,
                      strideWidth: strideWidth,
                      trackWidth: trackWidth,
                      color: AppTheme.teal.withValues(alpha: 0.18),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(rowCount, (rowIndex) {
                    final start = rowIndex * tilesPerRow;
                    final end = (start + tilesPerRow).clamp(0, chain.length);
                    final rowIndexes = List<int>.generate(
                      end - start,
                      (index) => start + index,
                    );
                    final isReversedRow = rowIndex.isOdd;
                    final visualIndexes = isReversedRow
                        ? rowIndexes.reversed.toList()
                        : rowIndexes;

                    return SizedBox(
                      height: rowHeight,
                      child: Center(
                        child: SizedBox(
                          width: trackWidth,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: List.generate(visualIndexes.length, (i) {
                              final index = visualIndexes[i];
                              final rowVisualWidth = visualWidth +
                                  ((visualIndexes.length - 1)
                                          .clamp(0, chain.length) *
                                      strideWidth);
                              final rowStart = isReversedRow
                                  ? trackWidth - rowVisualWidth
                                  : 0.0;
                              return Positioned(
                                left: rowStart + (i * strideWidth),
                                top: (rowHeight -
                                        (tileVisualHeight * tileScale)) /
                                    2,
                                child: _ChainTile(
                                  tile: chain[index],
                                  scale: tileScale,
                                  visualWidth: visualWidth,
                                  isReversedRow: isReversedRow,
                                  isLeftEnd: index == 0,
                                  isRightEnd: index == chain.length - 1,
                                  showEndpointLabel: chain.length > 1,
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ChainTile extends StatelessWidget {
  final DominoTileModel tile;
  final double scale;
  final double visualWidth;
  final bool isReversedRow;
  final bool isLeftEnd;
  final bool isRightEnd;
  final bool showEndpointLabel;

  const _ChainTile({
    required this.tile,
    required this.scale,
    required this.visualWidth,
    required this.isReversedRow,
    required this.isLeftEnd,
    required this.isRightEnd,
    required this.showEndpointLabel,
  });

  @override
  Widget build(BuildContext context) {
    final tileWidget = DominoTileWidget(
      tile: tile,
      scale: scale,
      isSelected: isLeftEnd || isRightEnd,
    );

    final tileBody = tile.isDouble
        ? tileWidget
        : RotatedBox(
            quarterTurns: isReversedRow ? 1 : 3,
            child: tileWidget,
          );

    return SizedBox(
      width: visualWidth,
      height: 96 * scale,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          tileBody,
          if (showEndpointLabel && isLeftEnd)
            Positioned(
              top: -7,
              child: _EndpointLabel(
                label: 'KIRI',
                color: AppTheme.bigStoneMaroon,
                scale: scale,
              ),
            ),
          if (showEndpointLabel && isRightEnd)
            Positioned(
              top: -7,
              child: _EndpointLabel(
                label: 'KANAN',
                color: AppTheme.teal,
                scale: scale,
              ),
            ),
        ],
      ),
    );
  }
}

class _EndpointLabel extends StatelessWidget {
  final String label;
  final Color color;
  final double scale;

  const _EndpointLabel({
    required this.label,
    required this.color,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 6 * scale,
        vertical: 2 * scale,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppTheme.radiusRound),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 8 * scale.clamp(0.75, 1),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ChainPathPainter extends CustomPainter {
  final List<int> rowCounts;
  final double rowHeight;
  final double visualWidth;
  final double strideWidth;
  final double trackWidth;
  final Color color;

  const _ChainPathPainter({
    required this.rowCounts,
    required this.rowHeight,
    required this.visualWidth,
    required this.strideWidth,
    required this.trackWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (rowCounts.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    Offset? previousEnd;

    for (var rowIndex = 0; rowIndex < rowCounts.length; rowIndex++) {
      final count = rowCounts[rowIndex];
      if (count <= 0) continue;

      final rowWidth = visualWidth + ((count - 1) * strideWidth);
      final trackLeft = (size.width - trackWidth) / 2;
      final trackRight = trackLeft + trackWidth;
      final centerY = (rowIndex * rowHeight) + (rowHeight / 2);
      final isReversedRow = rowIndex.isOdd;
      final rowLeft = isReversedRow ? trackRight - rowWidth : trackLeft;
      final rowRight = rowLeft + rowWidth;
      final start = Offset(isReversedRow ? rowRight : rowLeft, centerY);
      final end = Offset(isReversedRow ? rowLeft : rowRight, centerY);

      if (previousEnd == null) {
        path.moveTo(start.dx, start.dy);
      } else {
        final controlGap = rowHeight * 0.32;
        path.cubicTo(
          previousEnd.dx,
          previousEnd.dy + controlGap,
          start.dx,
          start.dy - controlGap,
          start.dx,
          start.dy,
        );
      }

      path.lineTo(end.dx, end.dy);
      previousEnd = end;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ChainPathPainter oldDelegate) {
    return oldDelegate.rowCounts != rowCounts ||
        oldDelegate.rowHeight != rowHeight ||
        oldDelegate.visualWidth != visualWidth ||
        oldDelegate.strideWidth != strideWidth ||
        oldDelegate.trackWidth != trackWidth ||
        oldDelegate.color != color;
  }
}
