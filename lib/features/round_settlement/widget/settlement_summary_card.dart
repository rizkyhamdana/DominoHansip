import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:crownpass/app/theme.dart';
import 'package:crownpass/core/widgets/crown_badge.dart';
import 'package:crownpass/core/widgets/hansip_badge.dart';
import 'package:crownpass/core/widgets/player_avatar.dart';
import 'package:crownpass/data/models/player_model.dart';
import 'package:crownpass/features/game_table/bloc/game_table_state.dart';

class SettlementSummaryCard extends StatelessWidget {
  final GameTableState state;

  const SettlementSummaryCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final session = state.session;
    final history = session.roundHistory;
    if (history.isEmpty) return const SizedBox.shrink();

    final lastResult = history.last;
    final players = session.players;

    final winner = players.firstWhere(
      (p) => p.id == lastResult.winnerPlayerId,
      orElse: () => players.first,
    );
    final crownHolder = lastResult.crownHolderAfterRound != null
        ? players
            .where((p) => p.id == lastResult.crownHolderAfterRound)
            .firstOrNull
        : null;
    final hansip = lastResult.hansipAfterRound != null
        ? players.where((p) => p.id == lastResult.hansipAfterRound).firstOrNull
        : null;

    final crownMoved =
        lastResult.crownHolderBeforeRound != lastResult.crownHolderAfterRound;

    return Container(
      decoration: AppDecorations.glassCard(
        color: AppTheme.cardSurface,
        radius: AppTheme.radiusXL,
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceLG),
            decoration: const BoxDecoration(
              color: AppTheme.gold,
              border: Border(
                bottom: BorderSide(color: AppTheme.cardBorder, width: 2.5),
              ),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppTheme.radiusXL - 2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 28)),
                const SizedBox(width: AppTheme.spaceSM),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Game ${lastResult.roundNumber} Selesai!',
                      style: GoogleFonts.outfit(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Pemenang: ${winner.name}',
                      style: GoogleFonts.inter(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppTheme.spaceLG),
            child: Column(
              children: [
                // Key results
                _SummaryRow(
                  icon: Icons.emoji_events_rounded,
                  color: AppTheme.gold,
                  label: 'Pemenang Game',
                  value: winner.name,
                  player: winner,
                ),
                if (crownHolder != null)
                  _SummaryRow(
                    icon: Icons.workspace_premium_rounded,
                    color: AppTheme.gold,
                    label: crownMoved
                        ? 'Kepala Desa berpindah ke'
                        : 'Kepala Desa tetap di',
                    value: crownHolder.name,
                    player: crownHolder,
                    badge: const CrownBadge(size: 16),
                  ),
                if (hansip != null)
                  _SummaryRow(
                    icon: Icons.shield_rounded,
                    color: AppTheme.teal,
                    label: 'Hansip',
                    value: hansip.name,
                    player: hansip,
                    badge: const HansipBadge(size: 16),
                  ),

                const SizedBox(height: AppTheme.spaceMD),
                const Divider(),
                const SizedBox(height: AppTheme.spaceMD),

                // All players stone counts + points
                Text(
                  'Batu & Poin Tiap Pemain',
                  style: GoogleFonts.outfit(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceSM),

                ...lastResult.snapshots.map((snap) {
                  final player =
                      players.where((p) => p.id == snap.playerId).firstOrNull;
                  if (player == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.spaceSM),
                    child: Row(
                      children: [
                        PlayerAvatar(
                          name: player.name,
                          colorValue: player.avatarColorValue,
                          radius: 14,
                        ),
                        const SizedBox(width: AppTheme.spaceSM),
                        Text(
                          player.name,
                          style: GoogleFonts.inter(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${snap.totalStoneCount} batu · ${snap.totalPoint} poin',
                          style: GoogleFonts.outfit(
                            color: snap.isWinner
                                ? AppTheme.success
                                : AppTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (snap.isCrownHolder) const CrownBadge(size: 12),
                        if (snap.isHansip) const HansipBadge(size: 12),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final PlayerModel? player;
  final Widget? badge;

  const _SummaryRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.player,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceSM),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: AppTheme.spaceSM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                      color: AppTheme.textMuted, fontSize: 11),
                ),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (badge != null) badge!,
        ],
      ),
    );
  }
}
