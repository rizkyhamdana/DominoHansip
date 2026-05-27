import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:crownpass/app/theme.dart';
import 'package:crownpass/core/widgets/crown_badge.dart';
import 'package:crownpass/core/widgets/hansip_badge.dart';
import 'package:crownpass/core/widgets/big_stone_badge.dart';
import 'package:crownpass/core/widgets/player_avatar.dart';
import 'package:crownpass/data/models/player_model.dart';
import 'package:crownpass/features/game_table/widget/stone_drop_data.dart';

class PlayerSeatCard extends StatelessWidget {
  final PlayerModel player;
  final bool isCrownHolder;
  final bool isHansip;
  final bool isCurrentTurn;
  final bool isSelected;
  final bool isDragTarget;
  final bool isDistributor;
  final VoidCallback? onTap;
  final Function(StoneDropData)? onStoneDropped;

  const PlayerSeatCard({
    super.key,
    required this.player,
    this.isCrownHolder = false,
    this.isHansip = false,
    this.isCurrentTurn = false,
    this.isSelected = false,
    this.isDragTarget = false,
    this.isDistributor = false,
    this.onTap,
    this.onStoneDropped,
  });

  @override
  Widget build(BuildContext context) {
    final baseCard = _buildCard(context);
    Widget finalCard = baseCard;

    if (onStoneDropped != null) {
      finalCard = DragTarget<StoneDropData>(
        onWillAcceptWithDetails: (details) =>
            details.data.fromPlayerId != player.id,
        onAcceptWithDetails: (details) => onStoneDropped!(details.data),
        builder: (context, candidateData, rejectedData) {
          final isDraggingOver = candidateData.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            transform: isDraggingOver
                ? (Matrix4.identity()..scale(1.05))
                : Matrix4.identity(),
            child: Stack(
              children: [
                baseCard,
                if (isDraggingOver)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        border: Border.all(
                          color: AppTheme.teal,
                          width: 2,
                        ),
                        color: AppTheme.teal.withOpacity(0.15),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      );
    }

    return GestureDetector(onTap: onTap, child: finalCard);
  }

  Widget _buildCard(BuildContext context) {
    Color cardColor = AppTheme.cardSurface;
    Color borderAccentColor = AppTheme.cardBorder;
    double borderWidth = isCurrentTurn ? 3.0 : 1.5;
    Color shadowColor = AppTheme.cardBorder.withOpacity(0.12);
    double shadowOffset = isCurrentTurn ? 4.0 : 2.0;

    if (isDistributor) {
      cardColor = AppTheme.error.withOpacity(0.08);
      borderAccentColor = AppTheme.error;
      shadowColor = AppTheme.error.withOpacity(0.15);
    } else if (isCurrentTurn) {
      cardColor = AppTheme.gold.withOpacity(0.1);
      borderAccentColor = AppTheme.goldDark;
      shadowColor = AppTheme.goldDark.withOpacity(0.2);
    } else if (isSelected) {
      cardColor = AppTheme.gold.withOpacity(0.05);
      borderAccentColor = AppTheme.gold;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 100,
      padding: const EdgeInsets.all(AppTheme.spaceSM),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(
          color: borderAccentColor == AppTheme.cardBorder
              ? AppTheme.cardBorder
              : borderAccentColor,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 0,
            offset: Offset(shadowOffset, shadowOffset),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Badges row
          if (isCrownHolder || isHansip)
            Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spaceXS),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isCrownHolder) const CrownBadge(size: 14),
                  if (isCrownHolder && isHansip) const SizedBox(width: 4),
                  if (isHansip) const HansipBadge(size: 14),
                ],
              ),
            ),

          // Avatar
          PlayerAvatar(
            name: player.name,
            colorValue: player.avatarColorValue,
            radius: 20,
            isHighlighted: isCurrentTurn || isSelected,
          ),
          const SizedBox(height: AppTheme.spaceXS),

          // Name
          Text(
            player.name,
            style: GoogleFonts.outfit(
              color: AppTheme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),

          if (player.totalStoneCount == 0)
            Text(
              '0 batu',
              style: GoogleFonts.inter(
                color: AppTheme.success,
                fontSize: 10,
              ),
            ),

          if (player.totalStoneCount > 0) ...[
            const SizedBox(height: AppTheme.spaceXS),
            _CardStoneStack(
              smallStoneCount: player.smallStoneCount,
              hasBigStone: player.hasBigStone,
            ),
          ],

          // Total point
          const SizedBox(height: AppTheme.spaceXS),
          Text(
            '${player.totalPoint} poin',
            style: GoogleFonts.inter(
              color: AppTheme.textMuted,
              fontSize: 10,
            ),
          ),

          // Pass count (show if > 0)
          if (player.passCount > 0)
            Text(
              'Pass: ${player.passCount}',
              style: GoogleFonts.inter(
                color: AppTheme.textMuted,
                fontSize: 9,
              ),
            ),
        ],
      ),
    );
  }
}

class _CardStoneStack extends StatelessWidget {
  final int smallStoneCount;
  final bool hasBigStone;

  const _CardStoneStack({
    required this.smallStoneCount,
    required this.hasBigStone,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (smallStoneCount > 0) ...[
          Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.smallStoneDark,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            'x$smallStoneCount',
            style: GoogleFonts.outfit(
              color: AppTheme.smallStoneDark,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
        if (smallStoneCount > 0 && hasBigStone) const SizedBox(width: 4),
        if (hasBigStone) const BigStoneBadge(size: 12),
      ],
    );
  }
}
