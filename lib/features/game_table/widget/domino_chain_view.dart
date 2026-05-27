import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:crownpass/app/theme.dart';
import 'package:crownpass/data/models/domino_tile_model.dart';
import 'domino_tile_widget.dart';

class DominoChainView extends StatefulWidget {
  final List<DominoTileModel> chain;

  const DominoChainView({super.key, required this.chain});

  @override
  State<DominoChainView> createState() => _DominoChainViewState();
}

class _DominoChainViewState extends State<DominoChainView> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Auto-scroll to the end after a short delay on build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToRight();
    });
  }

  @override
  void didUpdateWidget(DominoChainView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.chain.length != oldWidget.chain.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollController.hasClients) return;

        if (oldWidget.chain.isEmpty) {
          _scrollToRight();
        } else if (widget.chain.first != oldWidget.chain.first) {
          // Play on LEFT: Coordinate shift occurs because index 0 changes.
          // To animate smoothly, we instantly jump the scroll offset rightwards by the new item's width,
          // keeping the existing items in the exact same visual position on screen.
          final double itemWidth = widget.chain.first.isDouble ? 36.5 : 62.5;
          final double currentOffset = _scrollController.offset;
          _scrollController.jumpTo(currentOffset + itemWidth);

          // Then, smoothly animate the offset back to 0.0, sliding the new card into view from the left!
          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
          );
        } else {
          // Play on RIGHT: No coordinate shift. Smoothly slide the new card into view from the right.
          _scrollToRight();
        }
      });
    }
  }

  void _scrollToRight() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.chain.isEmpty) {
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMD),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.cardBorder.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(AppTheme.radiusXL),
            border: Border.all(
              color: AppTheme.cardBorder.withValues(alpha: 0.08),
              width: 1.5,
            ),
          ),
          child: SizedBox(
            height: 90,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceXL),
              itemCount: widget.chain.length,
              itemBuilder: (context, index) {
                final tile = widget.chain[index];
                final isLeftEnd = index == 0;
                final isRightEnd = index == widget.chain.length - 1;

                // Doubles are placed crosswise (vertical), non-doubles are placed lengthwise (horizontal)
                final Widget tileWidget = DominoTileWidget(
                  tile: tile,
                  scale: 0.65,
                  isSelected: isLeftEnd || isRightEnd,
                );

                Widget displayWidget;
                if (tile.isDouble) {
                  // Doubles stay vertical
                  displayWidget = Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: tileWidget,
                  );
                } else {
                  // Non-doubles are rotated horizontal
                  displayWidget = Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Center(
                      child: RotatedBox(
                        quarterTurns: 3, // 270 degrees: top becomes left, bottom becomes right
                        child: tileWidget,
                      ),
                    ),
                  );
                }

                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    displayWidget,
                    // endpoint indicator labels
                    if (isLeftEnd && widget.chain.length > 1)
                      Positioned(
                        top: -12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.bigStoneMaroon,
                            borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                          ),
                          child: Text(
                            'KIRI',
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    if (isRightEnd && widget.chain.length > 1)
                      Positioned(
                        top: -12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.teal,
                            borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                          ),
                          child: Text(
                            'KANAN',
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
