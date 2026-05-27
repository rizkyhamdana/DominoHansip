import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:crownpass/app/theme.dart';
import 'package:crownpass/core/widgets/player_avatar.dart';
import 'package:crownpass/core/widgets/big_stone_badge.dart';
import 'package:crownpass/core/utils/domino_engine.dart';
import 'package:crownpass/data/models/player_model.dart';
import 'package:crownpass/data/models/domino_tile_model.dart';
import 'domino_tile_widget.dart';

class PlayerHandDeck extends StatelessWidget {
  final PlayerModel humanPlayer;
  final List<DominoTileModel> hand;
  final List<DominoTileModel> chain;
  final Function(DominoTileModel, String) onPlay;

  const PlayerHandDeck({
    super.key,
    required this.humanPlayer,
    required this.hand,
    required this.chain,
    required this.onPlay,
  });

  void _handleTileTap(BuildContext context, DominoTileModel tile) {
    final canLeft = DominoEngine.canPlayLeft(tile, chain);
    final canRight = DominoEngine.canPlayRight(tile, chain);

    if (canLeft && canRight && chain.isNotEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusXL),
            side: const BorderSide(color: AppTheme.cardBorder, width: 2),
          ),
          title: Text(
            'Pasang Kartu',
            style: GoogleFonts.outfit(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pilih ujung papan domino untuk meletakkan kartu [${tile.sideA}|${tile.sideB}]',
                style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spaceLG),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.bigStoneMaroon,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      onPlay(tile, 'left');
                    },
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Kiri'),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      onPlay(tile, 'right');
                    },
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('Kanan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else if (canLeft) {
      onPlay(tile, 'left');
    } else if (canRight) {
      onPlay(tile, 'right');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppTheme.spaceMD, bottom: 6),
          child: Text(
            'KARTU KAMU (${hand.length})',
            style: GoogleFonts.outfit(
              color: AppTheme.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Row(
          children: [
            // Human HUD - Compact Player Info Panel
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              margin: const EdgeInsets.only(left: AppTheme.spaceMD),
              constraints: const BoxConstraints(minWidth: 120),
              decoration: BoxDecoration(
                color: AppTheme.cardSurface,
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                border: Border.all(color: AppTheme.cardBorder, width: 2.0),
                boxShadow: const [
                  BoxShadow(
                    color: AppTheme.cardBorder,
                    blurRadius: 0,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PlayerAvatar(
                    name: humanPlayer.name,
                    colorValue: humanPlayer.avatarColorValue,
                    radius: 16,
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 55,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          humanPlayer.name,
                          style: GoogleFonts.outfit(
                            color: AppTheme.textPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${humanPlayer.totalPoint} Poin',
                          style: GoogleFonts.inter(
                            color: AppTheme.textMuted,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  _CardStoneStack(
                    smallStoneCount: humanPlayer.smallStoneCount,
                    hasBigStone: humanPlayer.hasBigStone,
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 10),

            // Horizontal Scrollable Deck List
            Expanded(
              child: SizedBox(
                height: 80,
                child: hand.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada kartu tersisa.',
                          style: GoogleFonts.outfit(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(right: AppTheme.spaceMD),
                        itemCount: hand.length,
                        itemBuilder: (context, index) {
                          final tile = hand[index];
                          final leftPlayable = DominoEngine.canPlayLeft(tile, chain);
                          final rightPlayable = DominoEngine.canPlayRight(tile, chain);
                          final isPlayable = leftPlayable || rightPlayable;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Center(
                              child: DominoTileWidget(
                                tile: tile,
                                scale: 0.65,
                                isPlayable: isPlayable,
                                onTap: isPlayable ? () => _handleTileTap(context, tile) : null,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ],
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
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.smallStoneDark,
            ),
          ),
          const SizedBox(width: 1),
          Text(
            '$smallStoneCount',
            style: GoogleFonts.outfit(
              color: AppTheme.smallStoneDark,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
        if (smallStoneCount > 0 && hasBigStone) const SizedBox(width: 2),
        if (hasBigStone) const BigStoneBadge(size: 8),
      ],
    );
  }
}
