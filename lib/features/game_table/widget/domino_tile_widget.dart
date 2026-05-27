import 'package:flutter/material.dart';

import 'package:crownpass/app/theme.dart';
import 'package:crownpass/data/models/domino_tile_model.dart';

class DominoTileWidget extends StatelessWidget {
  final DominoTileModel tile;
  final double scale;
  final bool isPlayable;
  final bool isSelected;
  final VoidCallback? onTap;

  const DominoTileWidget({
    super.key,
    required this.tile,
    this.scale = 1.0,
    this.isPlayable = false,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double width = 50 * scale;
    final double height = 90 * scale;
    final double radius = 8 * scale;
    final double borderWidth = 3 * scale;

    final sideA = tile.isFlipped ? tile.sideB : tile.sideA;
    final sideB = tile.isFlipped ? tile.sideA : tile.sideB;

    Widget card = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: isPlayable
              ? AppTheme.goldDark
              : (isSelected ? AppTheme.teal : AppTheme.cardBorder),
          width: borderWidth,
        ),
        boxShadow: [
          if (isPlayable)
            BoxShadow(
              color: AppTheme.gold.withValues(alpha: 0.4),
              blurRadius: 10 * scale,
              spreadRadius: 2 * scale,
            )
          else if (isSelected)
            BoxShadow(
              color: AppTheme.teal.withValues(alpha: 0.3),
              blurRadius: 8 * scale,
            )
          else
            BoxShadow(
              color: AppTheme.cardBorder.withValues(alpha: 0.15),
              blurRadius: 0,
              offset: Offset(3 * scale, 3 * scale),
            ),
        ],
      ),
      child: Column(
        children: [
          // Side A
          Expanded(
            child: Center(
              child: _DominoHalf(pips: sideA, scale: scale),
            ),
          ),

          // Divider
          Container(
            height: borderWidth,
            color: isPlayable
                ? AppTheme.goldDark
                : (isSelected ? AppTheme.teal : AppTheme.cardBorder),
          ),

          // Side B
          Expanded(
            child: Center(
              child: _DominoHalf(pips: sideB, scale: scale),
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      card = GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: card,
        ),
      );
    }

    return card;
  }
}

class _DominoHalf extends StatelessWidget {
  final int pips;
  final double scale;

  const _DominoHalf({required this.pips, required this.scale});

  @override
  Widget build(BuildContext context) {
    final double size = 32 * scale;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: DominoHalfPainter(
          pips: pips,
          dotColor: AppTheme.cardBorder,
        ),
      ),
    );
  }
}

class DominoHalfPainter extends CustomPainter {
  final int pips;
  final Color dotColor;

  DominoHalfPainter({required this.pips, required this.dotColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    final double w = size.width;
    final double h = size.height;
    final double r = w * 0.095; // Dot radius (about 3px when size is 32)

    // Symmetric 3x3 positions
    final double left = w * 0.25;
    final double center = w * 0.5;
    final double right = w * 0.75;

    final double top = h * 0.25;
    final double middle = h * 0.5;
    final double bottom = h * 0.75;

    void drawDot(double x, double y) {
      canvas.drawCircle(Offset(x, y), r, paint);
    }

    switch (pips) {
      case 1:
        drawDot(center, middle);
        break;
      case 2:
        drawDot(left, top);
        drawDot(right, bottom);
        break;
      case 3:
        drawDot(left, top);
        drawDot(center, middle);
        drawDot(right, bottom);
        break;
      case 4:
        drawDot(left, top);
        drawDot(right, top);
        drawDot(left, bottom);
        drawDot(right, bottom);
        break;
      case 5:
        drawDot(left, top);
        drawDot(right, top);
        drawDot(center, middle);
        drawDot(left, bottom);
        drawDot(right, bottom);
        break;
      case 6:
        // Two columns of three dots (standard layout)
        drawDot(left, top);
        drawDot(left, middle);
        drawDot(left, bottom);
        drawDot(right, top);
        drawDot(right, middle);
        drawDot(right, bottom);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant DominoHalfPainter oldDelegate) {
    return oldDelegate.pips != pips || oldDelegate.dotColor != dotColor;
  }
}
