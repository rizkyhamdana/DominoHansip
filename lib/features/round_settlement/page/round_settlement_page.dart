import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:crownpass/app/router.dart';
import 'package:crownpass/app/theme.dart';
import 'package:crownpass/core/widgets/crown_badge.dart';
import 'package:crownpass/core/widgets/hansip_badge.dart';
import 'package:crownpass/core/widgets/player_avatar.dart';
import 'package:crownpass/data/models/game_session_model.dart';
import 'package:crownpass/data/models/player_model.dart';
import 'package:crownpass/data/models/settlement_preview_model.dart';
import 'package:crownpass/features/game_table/bloc/game_table_bloc.dart';
import 'package:crownpass/features/game_table/bloc/game_table_event.dart';
import 'package:crownpass/features/game_table/bloc/game_table_state.dart';
import 'package:crownpass/features/round_settlement/widget/settlement_summary_card.dart';

class RoundSettlementPage extends StatelessWidget {
  const RoundSettlementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameTableBloc, GameTableState>(
      listenWhen: (prev, curr) => prev.session.phase != curr.session.phase,
      listener: (context, state) {
        if (state.session.phase == GamePhase.roundFinished) {
          // Dismiss any open dialog
          Navigator.of(context).popUntil(
              (route) => route.settings.name == AppRouter.roundSettlement);
        }
      },
      builder: (context, state) {
        final session = state.session;

        return PopScope(
          canPop: !session.isVsMode && session.phase != GamePhase.roundFinished,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              context.read<GameTableBloc>().add(const CancelRoundSettlement());
            } else {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.home,
                (route) => false,
              );
            }
          },
          child: session.phase == GamePhase.roundFinished
              ? _RoundFinishedView(state: state)
              : _RoundSettlementView(state: state),
        );
      },
    );
  }
}

// ── Settlement selection view ─────────────────────────────────────────────────

class _RoundSettlementView extends StatelessWidget {
  final GameTableState state;
  const _RoundSettlementView({required this.state});

  @override
  Widget build(BuildContext context) {
    final session = state.session;
    final preview = session.settlementPreview;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selesaikan Game'),
        leading: session.isVsMode
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.maybePop(context),
              ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instruction sticker
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spaceMD),
              decoration: AppDecorations.glassCard(
                color: AppTheme.gold.withValues(alpha: 0.2),
                radius: AppTheme.radiusMD,
              ),
              child: Row(
                children: [
                  Text(session.isVsMode ? '🤖' : '🏆',
                      style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: AppTheme.spaceSM),
                  Expanded(
                    child: Text(
                      session.isVsMode
                          ? 'Hasil ronde telah dikalkulasi secara otomatis oleh sistem.'
                          : 'Pilih pemain yang memenangkan game ini.',
                      style: GoogleFonts.outfit(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spaceLG),

            if (!session.isVsMode) ...[
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                child: Text(
                  'PILIH PEMENANG',
                  style: GoogleFonts.outfit(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spaceSM),

              // Player selection list
              ...session.players.map((player) {
                final isSelected = preview?.winnerPlayerId == player.id;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context
                        .read<GameTableBloc>()
                        .add(SelectRoundWinner(player.id));
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(bottom: AppTheme.spaceMD),
                    padding: const EdgeInsets.all(AppTheme.spaceMD),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.gold : AppTheme.cardSurface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                      border: Border.all(
                        color: AppTheme.cardBorder,
                        width: 2.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              const BoxShadow(
                                color: AppTheme.cardBorder,
                                blurRadius: 0,
                                offset: Offset(2.5, 2.5),
                              )
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        PlayerAvatar(
                          name: player.name,
                          colorValue: player.avatarColorValue,
                          radius: 20,
                          isHighlighted: isSelected,
                        ),
                        const SizedBox(width: AppTheme.spaceMD),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                player.name,
                                style: GoogleFonts.outfit(
                                  color: AppTheme.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '${player.totalStoneCount} batu · ${player.totalPoint} poin',
                                style: GoogleFonts.inter(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (session.crownPlayerId == player.id) ...[
                          const CrownBadge(size: 16),
                          const SizedBox(width: 4),
                        ],
                        if (session.hansipPlayerId == player.id) ...[
                          const HansipBadge(size: 16),
                          const SizedBox(width: 4),
                        ],
                        if (isSelected)
                          const Text('🥇', style: TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),
                );
              }),
            ],

            // Preview section
            if (preview != null) ...[
              const SizedBox(height: AppTheme.spaceLG),
              _SettlementPreviewCard(preview: preview, session: session),

              const SizedBox(height: AppTheme.spaceLG),

              // Hansip tie warning
              if (preview.hasHansipTie) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTheme.spaceMD),
                  decoration: AppDecorations.glassCard(
                    color: AppTheme.warning.withValues(alpha: 0.2),
                    radius: AppTheme.radiusMD,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: AppTheme.warning, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ada seri Hansip! Kamu akan diminta memilih Hansip secara manual setelah konfirmasi.',
                          style: GoogleFonts.inter(
                            color: AppTheme.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spaceMD),
              ],

              // Confirm button
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  key: const Key('btn_confirm_settlement'),
                  onTap: () => _confirmSettlement(context, preview),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.gold,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                      border:
                          Border.all(color: AppTheme.cardBorder, width: 2.5),
                      boxShadow: const [
                        BoxShadow(
                          color: AppTheme.cardBorder,
                          blurRadius: 0,
                          offset: Offset(3, 3),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_rounded,
                            color: AppTheme.textPrimary),
                        const SizedBox(width: 8),
                        Text(
                          'Konfirmasi Hasil Game',
                          style: GoogleFonts.outfit(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppTheme.spaceXXL),
          ],
        ),
      ),
    );
  }

  void _confirmSettlement(
      BuildContext context, SettlementPreviewModel preview) {
    if (preview.hasHansipTie) {
      _showHansipTieDialog(context, preview);
    } else {
      HapticFeedback.heavyImpact();
      context.read<GameTableBloc>().add(const ConfirmSettlement());
    }
  }

  void _showHansipTieDialog(
      BuildContext context, SettlementPreviewModel preview) {
    final state = context.read<GameTableBloc>().state;
    final session = state.session;
    final tiePlayers = preview.hansipTiePlayerIds
        .map((id) => session.players.firstWhere((p) => p.id == id))
        .toList();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          side: const BorderSide(color: AppTheme.cardBorder),
        ),
        title: Row(
          children: [
            const HansipBadge(size: 20),
            const SizedBox(width: 8),
            Text(
              'Pilih Hansip',
              style: GoogleFonts.outfit(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ada seri poin tertinggi. Pilih siapa yang menjadi Hansip:',
              style: GoogleFonts.inter(
                  color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: AppTheme.spaceMD),
            ...tiePlayers.map((player) {
              return ListTile(
                leading: PlayerAvatar(
                  name: player.name,
                  colorValue: player.avatarColorValue,
                  radius: 18,
                ),
                title: Text(player.name,
                    style: GoogleFonts.outfit(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500)),
                subtitle: Text(
                  '${player.totalPoint} poin',
                  style: GoogleFonts.inter(
                      color: AppTheme.textSecondary, fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  context
                      .read<GameTableBloc>()
                      .add(ResolveHansipTie(player.id));
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── Preview card ──────────────────────────────────────────────────────────────

class _SettlementPreviewCard extends StatelessWidget {
  final SettlementPreviewModel preview;
  final GameSessionModel session;

  const _SettlementPreviewCard({
    required this.preview,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final winner = preview.playersAfterBonusStone
        .firstWhere((p) => p.id == preview.winnerPlayerId);
    final prevPlayer = preview.playersAfterBonusStone
        .firstWhere((p) => p.id == preview.previousPlayerBeforeWinnerId);
    final suggestedHansip = preview.suggestedHansipPlayerId != null
        ? preview.playersAfterBonusStone
            .firstWhere((p) => p.id == preview.suggestedHansipPlayerId)
        : null;

    // Determine if the stone came from stock or from the winner
    // (stock is considered empty if stockStonesAfterSettlement has same length as original,
    //  but we check the winner — if winner == prevPlayer no bonus happens)
    final bonusFromWinner =
        preview.previousPlayerBeforeWinnerId != preview.winnerPlayerId;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: AppDecorations.glassCard(
        color: AppTheme.cardSurface,
        radius: AppTheme.radiusLG,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PRATINJAU HASIL',
            style: GoogleFonts.outfit(
              color: AppTheme.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: AppTheme.spaceMD),
          _PreviewRow(
            icon: Icons.emoji_events_rounded,
            color: AppTheme.gold,
            label: 'Pemenang',
            value: winner.name,
          ),
          if (bonusFromWinner)
            _PreviewRow(
              icon: Icons.add_circle_outline_rounded,
              color: AppTheme.warning,
              label: '+1 batu untuk',
              value: '${prevPlayer.name} (giliran sebelum pemenang)',
            ),
          if (preview.nextCrownPlayerId != null) ...[
            if (suggestedHansip != null)
              _PreviewRow(
                icon: Icons.shield_rounded,
                color: AppTheme.teal,
                label: 'Hansip',
                value:
                    '${suggestedHansip.name} (${suggestedHansip.totalPoint} poin)',
              )
            else
              const _PreviewRow(
                icon: Icons.shield_outlined,
                color: AppTheme.warning,
                label: 'Hansip',
                value: 'Seri — pilih manual',
              ),
          ] else ...[
            const _PreviewRow(
              icon: Icons.shield_outlined,
              color: AppTheme.textSecondary,
              label: 'Hansip',
              value: 'Belum ada (Menunggu Kades)',
            ),
          ],
          _PreviewRow(
            icon: Icons.workspace_premium_rounded,
            color: AppTheme.gold,
            label: 'Kepala Desa',
            value: preview.willCrownMove
                ? 'Berpindah ke ${winner.name}'
                : 'Tetap di ${session.crownPlayer?.name ?? "tidak ada"}',
          ),
          const SizedBox(height: AppTheme.spaceMD),
          const Divider(height: 1),
          const SizedBox(height: AppTheme.spaceMD),
          Text(
            'Batu setelah game selesai:',
            style: GoogleFonts.outfit(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spaceSM),
          ...preview.playersAfterBonusStone.map((p) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Text(
                    p.name,
                    style: GoogleFonts.inter(
                        color: AppTheme.textSecondary, fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    '${p.totalStoneCount} batu (${p.totalPoint} poin)',
                    style: GoogleFonts.outfit(
                      color: p.id == preview.winnerPlayerId
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

class _PreviewRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _PreviewRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceSM),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 12),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.outfit(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Round finished view ───────────────────────────────────────────────────────

class _RoundFinishedView extends StatelessWidget {
  final GameTableState state;
  const _RoundFinishedView({required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Selesai')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        child: Column(
          children: [
            // Summary card
            SettlementSummaryCard(state: state),

            const SizedBox(height: AppTheme.spaceLG),

            // Next round button
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                key: const Key('btn_next_round'),
                onTap: () {
                  HapticFeedback.heavyImpact();
                  context.read<GameTableBloc>().add(const StartNextRound());
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRouter.gameTable,
                    (route) => route.settings.name == AppRouter.home,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.gold,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                    border: Border.all(color: AppTheme.cardBorder, width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                        color: AppTheme.cardBorder,
                        blurRadius: 0,
                        offset: Offset(3, 3),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.arrow_forward_rounded,
                          color: AppTheme.textPrimary),
                      const SizedBox(width: 8),
                      Text(
                        'Mulai Game Berikutnya',
                        style: GoogleFonts.outfit(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceLG),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamedAndRemoveUntil(
                      context, AppRouter.home, (r) => false);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardSurface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                    border: Border.all(color: AppTheme.cardBorder, width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                        color: AppTheme.cardBorder,
                        blurRadius: 0,
                        offset: Offset(3, 3),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.home_rounded,
                          color: AppTheme.textPrimary),
                      const SizedBox(width: 8),
                      Text(
                        'Kembali ke Beranda',
                        style: GoogleFonts.outfit(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceXXL),
          ],
        ),
      ),
    );
  }
}
