import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:crownpass/app/theme.dart';
import 'package:crownpass/core/widgets/empty_state_view.dart';
import 'package:crownpass/core/widgets/player_avatar.dart';
import 'package:crownpass/data/models/player_model.dart';
import 'package:crownpass/features/game_table/bloc/game_table_bloc.dart';
import 'package:crownpass/features/game_table/bloc/game_table_state.dart';
import 'package:crownpass/features/sim_table/bloc/sim_table_bloc.dart';
import 'package:crownpass/features/sim_table/bloc/sim_table_state.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<GameTableBloc, GameTableState>(
        builder: (context, vsState) {
          return BlocBuilder<SimTableBloc, SimTableState>(
            builder: (context, simState) {
              final vsPlayers = vsState.session.players;
              final simPlayers = simState.session.players;
              final vsHistory = vsState.session.roundHistory;
              final simHistory = simState.session.roundHistory;

              final totalRounds = vsHistory.length + simHistory.length;

              final Map<String, PlayerModel> aggregated = {};
              void addPlayer(PlayerModel p) {
                final existing = aggregated[p.name];
                if (existing != null) {
                  aggregated[p.name] = existing.copyWith(
                    winCount: existing.winCount + p.winCount,
                    crownCount: existing.crownCount + p.crownCount,
                    hansipCount: existing.hansipCount + p.hansipCount,
                    passCount: existing.passCount + p.passCount,
                    totalDistributedStones: existing.totalDistributedStones + p.totalDistributedStones,
                    totalReceivedStones: existing.totalReceivedStones + p.totalReceivedStones,
                  );
                } else {
                  aggregated[p.name] = p;
                }
              }

              for (final p in vsPlayers) {
                addPlayer(p);
              }
              for (final p in simPlayers) {
                addPlayer(p);
              }
              final players = aggregated.values.toList();

              if (players.isEmpty) {
                return const EmptyStateView(
                  title: 'Belum ada data statistik',
                  subtitle: 'Mulai permainan untuk melihat statistik pemain.',
                  icon: Icons.leaderboard_rounded,
                );
              }

              return ListView(
                padding: const EdgeInsets.all(AppTheme.spaceMD),
                children: [
                  // Total rounds played
                  _RoundsCard(totalRounds: totalRounds),
                  const SizedBox(height: AppTheme.spaceMD),

              // Leaderboards
              _StatSection(
                title: 'Kepala Desa Teladan',
                subtitle: 'Paling sering menjabat Kepala Desa',
                icon: Icons.workspace_premium_rounded,
                color: AppTheme.gold,
                players: _sortedBy(players, (p) => p.crownCount),
                valueFn: (p) => '${p.crownCount}×',
              ),
              const SizedBox(height: AppTheme.spaceMD),

              _StatSection(
                title: 'Hansip Abadi',
                subtitle: 'Paling sering jadi Hansip',
                icon: Icons.shield_rounded,
                color: AppTheme.teal,
                players: _sortedBy(players, (p) => p.hansipCount),
                valueFn: (p) => '${p.hansipCount}×',
              ),
              const SizedBox(height: AppTheme.spaceMD),

              _StatSection(
                title: 'Paling Sering Menang',
                subtitle: 'Jumlah kemenangan game',
                icon: Icons.emoji_events_rounded,
                color: AppTheme.success,
                players: _sortedBy(players, (p) => p.winCount),
                valueFn: (p) => '${p.winCount} menang',
              ),
              const SizedBox(height: AppTheme.spaceMD),

              _StatSection(
                title: 'Tukang Pass',
                subtitle: 'Paling banyak pass',
                icon: Icons.arrow_forward_rounded,
                color: AppTheme.warning,
                players: _sortedBy(players, (p) => p.passCount),
                valueFn: (p) => '${p.passCount}×',
              ),
              const SizedBox(height: AppTheme.spaceMD),

              _StatSection(
                title: 'Paling Banyak Membagi Batu',
                subtitle: 'Total batu yang dibagikan',
                icon: Icons.share_rounded,
                color: AppTheme.textSecondary,
                players: _sortedBy(players, (p) => p.totalDistributedStones),
                valueFn: (p) => '${p.totalDistributedStones} dibagi',
              ),
              const SizedBox(height: AppTheme.spaceMD),

              _StatSection(
                title: 'Paling Banyak Terima Batu',
                subtitle: 'Total batu yang diterima',
                icon: Icons.download_rounded,
                color: AppTheme.bigStoneMaroon,
                players: _sortedBy(players, (p) => p.totalReceivedStones),
                valueFn: (p) => '${p.totalReceivedStones} diterima',
              ),
              const SizedBox(height: AppTheme.spaceXXL),
            ],
          );
        },
      );
    },
  ),
);
  }

  List<PlayerModel> _sortedBy(
      List<PlayerModel> players, int Function(PlayerModel) key) {
    final sorted = List<PlayerModel>.from(players);
    sorted.sort((a, b) => key(b).compareTo(key(a)));
    return sorted;
  }
}

class _RoundsCard extends StatelessWidget {
  final int totalRounds;
  const _RoundsCard({required this.totalRounds});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceLG),
      decoration: AppDecorations.glassCard(
        color: AppTheme.cardSurface,
        radius: AppTheme.radiusLG,
      ),
      child: Row(
        children: [
          const Icon(Icons.loop_rounded, color: AppTheme.goldDark, size: 32),
          const SizedBox(width: AppTheme.spaceMD),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$totalRounds',
                style: GoogleFonts.outfit(
                  color: AppTheme.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Game Dimainkan',
                style: GoogleFonts.inter(
                    color: AppTheme.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<PlayerModel> players;
  final String Function(PlayerModel) valueFn;

  const _StatSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.players,
    required this.valueFn,
  });

  @override
  Widget build(BuildContext context) {
    final nonZero = players.where((p) => _getValue(p) > 0).toList();
    if (nonZero.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppTheme.spaceMD),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.15),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: AppTheme.spaceSM),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                          color: AppTheme.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Player rows
          ...nonZero.asMap().entries.map((entry) {
            final rank = entry.key + 1;
            final player = entry.value;
            final isFirst = rank == 1;

            return Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceMD, vertical: AppTheme.spaceSM),
              decoration: BoxDecoration(
                color: isFirst ? color.withValues(alpha: 0.06) : null,
                border: entry.key < nonZero.length - 1
                    ? const Border(
                        bottom: BorderSide(color: AppTheme.cardBorder))
                    : null,
                borderRadius: rank == nonZero.length
                    ? const BorderRadius.vertical(
                        bottom: Radius.circular(AppTheme.radiusLG))
                    : null,
              ),
              child: Row(
                children: [
                  // Rank
                  SizedBox(
                    width: 28,
                    child: Text(
                      isFirst
                          ? '🥇'
                          : rank == 2
                              ? '🥈'
                              : '$rank.',
                      style: GoogleFonts.outfit(
                        color: isFirst ? color : AppTheme.textMuted,
                        fontSize: isFirst ? 18 : 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  PlayerAvatar(
                    name: player.name,
                    colorValue: player.avatarColorValue,
                    radius: 14,
                    isHighlighted: isFirst,
                  ),
                  const SizedBox(width: AppTheme.spaceSM),
                  Expanded(
                    child: Text(
                      player.name,
                      style: GoogleFonts.outfit(
                        color: isFirst
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                        fontSize: 14,
                        fontWeight: isFirst ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                  Text(
                    valueFn(player),
                    style: GoogleFonts.outfit(
                      color: isFirst ? color : AppTheme.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
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

  int _getValue(PlayerModel p) {
    final val = valueFn(p);
    return int.tryParse(val.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }
}
