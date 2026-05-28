import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:crownpass/app/theme.dart';
import 'package:crownpass/data/models/player_model.dart';

class StockPileWidget extends StatelessWidget {
  final int stockCount;
  final StoneType? topStoneType;
  final VoidCallback? onTap;

  const StockPileWidget({
    super.key,
    required this.stockCount,
    this.topStoneType,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isClickable = onTap != null && stockCount > 0;
    final bool isBigTop = topStoneType == StoneType.big;

    return GestureDetector(
      onTap: isClickable ? onTap : null,
      child: SizedBox(
        width: 110,
        height: 110,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Pile visual effect: three cartoon stone layers stacked offsetted
            if (stockCount > 2)
              Positioned(
                bottom: 12,
                left: 14,
                child: _PileStone(
                  size: 55,
                  face: '•ᴗ•',
                  color: AppTheme.smallStoneIvory.withValues(alpha: 0.85),
                  rotation: -0.2,
                ),
              ),

            if (stockCount > 1)
              Positioned(
                bottom: 16,
                right: 12,
                child: _PileStone(
                  size: 60,
                  face: '•ᴗ•',
                  color: AppTheme.smallStoneIvory.withValues(alpha: 0.95),
                  rotation: 0.15,
                ),
              ),

            // Topmost main stone follows the actual stock order.
            Positioned(
              bottom: 22,
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isBigTop
                      ? AppTheme.bigStoneMaroon
                      : AppTheme.smallStoneIvory,
                  border: Border.all(
                    color: AppTheme.cardBorder,
                    width: 2.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppTheme.cardBorder,
                      blurRadius: 0,
                      offset: Offset(3, 3),
                    )
                  ],
                ),
                child: Stack(
                  children: [
                    // Highlight gloss curve
                    Positioned(
                      top: 6,
                      left: 8,
                      child: Container(
                        width: 20,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius:
                              const BorderRadius.all(Radius.elliptical(10, 5)),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isBigTop ? '◕‿◕' : '•ᴗ•',
                            style: GoogleFonts.outfit(
                              color: isBigTop
                                  ? Colors.white
                                  : AppTheme.smallStoneDark,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isBigTop ? 'BESAR' : 'STOK',
                            style: GoogleFonts.outfit(
                              color: isBigTop
                                  ? AppTheme.gold
                                  : AppTheme.smallStoneDark,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Beautiful Red Balloon count badge
            Positioned(
              top: 2,
              right: 6,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.error,
                  borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                  border: Border.all(
                    color: AppTheme.cardBorder,
                    width: 2.0,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppTheme.cardBorder,
                      blurRadius: 0,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Text(
                  '$stockCount',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PileStone extends StatelessWidget {
  final double size;
  final String face;
  final Color color;
  final double rotation;

  const _PileStone({
    required this.size,
    required this.face,
    required this.color,
    required this.rotation,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: AppTheme.cardBorder,
            width: 2.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppTheme.cardBorder,
              blurRadius: 0,
              offset: Offset(2, 2),
            )
          ],
        ),
        child: Center(
          child: Text(
            face,
            style: GoogleFonts.outfit(
              color: AppTheme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
