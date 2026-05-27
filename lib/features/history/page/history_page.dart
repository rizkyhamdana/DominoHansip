import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:crownpass/app/theme.dart';
import 'package:crownpass/core/widgets/crown_badge.dart';
import 'package:crownpass/core/widgets/empty_state_view.dart';
import 'package:crownpass/core/widgets/hansip_badge.dart';
import 'package:crownpass/core/widgets/player_avatar.dart';
import 'package:crownpass/data/models/player_model.dart';
import 'package:crownpass/data/models/round_result_model.dart';
import 'package:crownpass/features/game_table/bloc/game_table_bloc.dart';
import 'package:crownpass/features/game_table/bloc/game_table_state.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Game')),
      body: BlocBuilder<GameTableBloc, GameTableState>(
        builder: (context, state) {
          final history = state.session.roundHistory;
          final players = state.session.players;

          if (history.isEmpty) {
            return const EmptyStateView(
              title: 'Belum ada riwayat',
              subtitle: 'Selesaikan minimal 1 game untuk melihat riwayat.',
              icon: Icons.history_rounded,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spaceMD),
            itemCount: history.length,
            itemBuilder: (context, index) {
              // Show newest first
              final result = history[history.length - 1 - index];
              return RoundHistoryTile(result: result, players: players);
            },
          );
        },
      ),
    );
  }
}

class RoundHistoryTile extends StatefulWidget {
  final RoundResultModel result;
  final List<PlayerModel> players;

  const RoundHistoryTile({
    super.key,
    required this.result,
    required this.players,
  });

  @override
  State<RoundHistoryTile> createState() => _RoundHistoryTileState();
}

class _RoundHistoryTileState extends State<RoundHistoryTile> {
  bool _expanded = false;

  PlayerModel? _findPlayer(String? id) {
    if (id == null) return null;
    return widget.players.where((p) => p.id == id).firstOrNull;
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final winner = _findPlayer(result.winnerPlayerId);
    final crownAfter = _findPlayer(result.crownHolderAfterRound);
    final hansipAfter = _findPlayer(result.hansipAfterRound);
    final crownMoved =
        result.crownHolderBeforeRound != result.crownHolderAfterRound;

    final dt = result.createdAt.toLocal();
    final dateStr = '${dt.day.toString().padLeft(2, '0')} '
        '${_monthName(dt.month)} ${dt.year} · '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceSM),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        children: [
          // Header row
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spaceMD),
              child: Row(
                children: [
                  // Round badge
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.gold.withOpacity(0.1),
                      border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Text(
                        '${result.roundNumber}',
                        style: GoogleFonts.outfit(
                          color: AppTheme.gold,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spaceMD),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (winner != null)
                              PlayerAvatar(
                                name: winner.name,
                                colorValue: winner.avatarColorValue,
                                radius: 10,
                              ),
                            const SizedBox(width: 4),
                            Text(
                              winner?.name ?? 'Unknown',
                              style: GoogleFonts.outfit(
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'menang',
                              style: GoogleFonts.inter(
                                  color: AppTheme.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                        Text(
                          dateStr,
                          style: GoogleFonts.inter(
                              color: AppTheme.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),

                  // Badges
                  Row(
                    children: [
                      if (crownAfter != null) const CrownBadge(size: 14),
                      if (hansipAfter != null)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: HansipBadge(size: 14),
                        ),
                      if (crownMoved)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(Icons.moving_rounded,
                              color: AppTheme.gold, size: 14),
                        ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: AppTheme.textMuted,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          // Expanded details
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _expanded
                ? _ExpandedDetails(result: result, players: widget.players)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _ExpandedDetails extends StatelessWidget {
  final RoundResultModel result;
  final List<PlayerModel> players;

  const _ExpandedDetails({
    required this.result,
    required this.players,
  });

  PlayerModel? _findPlayer(String? id) {
    if (id == null) return null;
    return players.where((p) => p.id == id).firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final crownBefore = _findPlayer(result.crownHolderBeforeRound);
    final crownAfter = _findPlayer(result.crownHolderAfterRound);
    final hansipAfter = _findPlayer(result.hansipAfterRound);

    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppTheme.spaceMD, 0, AppTheme.spaceMD, AppTheme.spaceMD),
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (crownBefore != crownAfter) ...[
            if (crownBefore != null)
              _DetailRow(label: 'Kepala Desa sebelum', value: crownBefore.name),
            if (crownAfter != null)
              _DetailRow(
                label: 'Kepala Desa setelah',
                value: crownAfter.name,
                color: AppTheme.gold,
              ),
          ] else ...[
            if (crownAfter != null)
              _DetailRow(
                label: 'Kepala Desa tetap di',
                value: crownAfter.name,
                color: AppTheme.gold,
              ),
          ],
          if (hansipAfter != null)
            _DetailRow(
              label: 'Hansip',
              value: hansipAfter.name,
              color: AppTheme.teal,
            ),
          const Divider(height: 16),
          Text(
            'Snapshot pemain:',
            style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 4),
          ...result.snapshots.map((snap) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                children: [
                  Text(
                    snap.playerName,
                    style: GoogleFonts.inter(
                        color: AppTheme.textSecondary, fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    '${snap.totalStoneCount} batu · ${snap.totalPoint} poin',
                    style: GoogleFonts.outfit(
                      color: snap.isWinner
                          ? AppTheme.success
                          : AppTheme.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DetailRow({
    required this.label,
    required this.value,
    this.color = AppTheme.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('$label: ',
              style:
                  GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 12)),
          Text(value,
              style: GoogleFonts.outfit(
                  color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
