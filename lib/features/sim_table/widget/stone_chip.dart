import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:crownpass/app/theme.dart';
import 'package:crownpass/data/models/player_model.dart';
import 'package:crownpass/features/sim_table/widget/stone_drop_data.dart';

class StoneChip extends StatelessWidget {
  final StoneType type;
  final bool isLocked;
  final bool isDraggable;
  final String? fromPlayerId;
  final VoidCallback? onTap;
  final bool isSelected;

  const StoneChip({
    super.key,
    required this.type,
    this.isLocked = false,
    this.isDraggable = false,
    this.fromPlayerId,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final chip = _buildChip();

    if (isDraggable && !isLocked && fromPlayerId != null) {
      return Draggable<StoneDropData>(
        data: StoneDropData(
          fromPlayerId: fromPlayerId!,
          stoneType: type,
        ),
        feedback: Opacity(opacity: 0.85, child: chip),
        childWhenDragging: Opacity(opacity: 0.3, child: chip),
        child: chip,
      );
    }

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: chip,
    );
  }

  Widget _buildChip() {
    if (type == StoneType.big) {
      return _BigStoneChip(isLocked: isLocked, isSelected: isSelected);
    } else {
      return _SmallStoneChip(isLocked: isLocked, isSelected: isSelected);
    }
  }
}

class _SmallStoneChip extends StatelessWidget {
  final bool isLocked;
  final bool isSelected;
  const _SmallStoneChip({required this.isLocked, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isLocked ? 0.4 : 1.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.smallStoneIvory,
          border: Border.all(
            color: isSelected ? AppTheme.goldDark : AppTheme.cardBorder,
            width: isSelected ? 3.0 : 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppTheme.gold.withValues(alpha: 0.5)
                  : AppTheme.cardBorder.withValues(alpha: 0.15),
              blurRadius: isSelected ? 8 : 0,
              spreadRadius: isSelected ? 1 : 0,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '•ᴗ•',
            style: GoogleFonts.outfit(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

class _BigStoneChip extends StatelessWidget {
  final bool isLocked;
  final bool isSelected;
  const _BigStoneChip({required this.isLocked, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: isLocked ? 0.4 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.bigStoneMaroon,
              border: Border.all(
                color: isSelected ? AppTheme.gold : AppTheme.cardBorder,
                width: isSelected ? 3.0 : 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? AppTheme.gold.withValues(alpha: 0.6)
                      : AppTheme.cardBorder.withValues(alpha: 0.18),
                  blurRadius: isSelected ? 12 : 0,
                  spreadRadius: isSelected ? 2 : 0,
                  offset: const Offset(3, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Shiny glossy curve
                Positioned(
                  top: 4,
                  left: 6,
                  child: Container(
                    width: 14,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.35),
                      borderRadius:
                          const BorderRadius.all(Radius.elliptical(7, 4)),
                    ),
                  ),
                ),

                // Cute eyes and points
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '◕‿◕',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        '5',
                        style: GoogleFonts.outfit(
                          color: AppTheme.gold,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          height: 0.9,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isLocked)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.cardSurface,
                border: Border.all(color: AppTheme.cardBorder, width: 1.5),
              ),
              child: const Icon(
                Icons.lock_rounded,
                color: AppTheme.textMuted,
                size: 10,
              ),
            ),
          ),
      ],
    );
  }
}
