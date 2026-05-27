import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:crownpass/app/router.dart';
import 'package:crownpass/app/theme.dart';
import 'package:crownpass/core/constants/app_constants.dart';
import 'package:crownpass/data/models/game_session_model.dart';
import 'package:crownpass/data/models/player_model.dart';
import 'package:crownpass/features/game_table/bloc/game_table_bloc.dart';
import 'package:crownpass/features/game_table/bloc/game_table_event.dart';
import 'package:crownpass/features/game_table/bloc/game_table_state.dart';
import 'package:crownpass/features/game_table/widget/action_bottom_bar.dart';
import 'package:crownpass/features/game_table/widget/distribution_tray.dart';
import 'package:crownpass/features/game_table/widget/game_center_panel.dart';
import 'package:crownpass/features/game_table/widget/player_seat_card.dart';
import 'package:crownpass/features/game_table/widget/stock_pile_widget.dart';

class GameTablePage extends StatelessWidget {
  const GameTablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameTableBloc, GameTableState>(
      listenWhen: (prev, curr) =>
          prev.session.errorMessage != curr.session.errorMessage ||
          prev.session.successMessage != curr.session.successMessage ||
          prev.session.phase != curr.session.phase,
      listener: (context, state) {
        final session = state.session;

        // Auto-dismiss floating top messages after delay
        if (session.errorMessage != null) {
          Future.delayed(const Duration(seconds: 3), () {
            if (context.mounted) {
              context.read<GameTableBloc>().add(const ClearMessage());
            }
          });
        }

        if (session.successMessage != null) {
          Future.delayed(const Duration(seconds: 2), () {
            if (context.mounted) {
              context.read<GameTableBloc>().add(const ClearMessage());
            }
          });
        }

        // Navigate to settlement page
        if (session.phase == GamePhase.roundSettlement) {
          Navigator.pushNamed(context, AppRouter.roundSettlement);
        }

        // Navigate to round finished summary (handled inside settlement page)
      },
      builder: (context, state) {
        final session = state.session;

        if (!session.hasActiveGame) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppTheme.warning, size: 48),
                  const SizedBox(height: 16),
                  Text('Tidak ada permainan aktif.',
                      style: GoogleFonts.outfit(color: AppTheme.textPrimary)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRouter.gameSetup),
                    child: const Text('Mulai Permainan'),
                  ),
                ],
              ),
            ),
          );
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            final shouldExit = await _showExitConfirmationDialog(context);
            if (shouldExit && context.mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.home,
                (route) => false,
              );
            }
          },
          child: Scaffold(
            body: Stack(
              children: [
                // Table background
                _TableBackground(),

                // Main content
                SafeArea(
                  child: Column(
                    children: [
                      // App bar
                      _GameAppBar(session: session),

                      // Circular table area
                      Expanded(
                        child: _CircularTable(state: state),
                      ),

                      // Action bar
                      ActionBottomBar(
                        session: session,
                        selectedPlayerId: session.currentTurnPlayerId,
                        onPass: () => _onPass(context, state),
                        onSettle: () => context
                            .read<GameTableBloc>()
                            .add(const OpenRoundSettlement()),
                        onUndo: () => context
                            .read<GameTableBloc>()
                            .add(const UndoLastAction()),
                        onMenu: () => _showMenu(context, state),
                      ),
                    ],
                  ),
                ),

                // Causer selection overlay
                if (state.isSelectingPassCauser)
                  _PassCauserOverlay(state: state),

                // Floating top message banner
                _TopMessageBanner(state: state),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onPass(BuildContext context, GameTableState state) {
    final playerId = state.session.currentTurnPlayerId;
    if (playerId == null) return;

    if (state.isHapticEnabled) {
      HapticFeedback.lightImpact();
    }

    context.read<GameTableBloc>().add(PlayerPass(playerId));
  }

  void _showMenu(BuildContext context, GameTableState state) {
    showModalBottomSheet(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<GameTableBloc>(),
        child: _GameMenu(state: state),
      ),
    );
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          side: const BorderSide(color: AppTheme.cardBorder),
        ),
        title: Text(
          'Keluar Permainan?',
          style: GoogleFonts.outfit(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Game saat ini sedang berjalan. Progres game ini akan disimpan dan kamu bisa melanjutkannya nanti dari beranda.',
          style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Tetap Main',
              style: GoogleFonts.outfit(
                  color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Keluar',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

// ── Table background ──────────────────────────────────────────────────────────

class _TableBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer 2D drop shadow
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.cardBorder.withOpacity(0.12),
              ),
            ),
            // Outer board outline
            Container(
              width: 290,
              height: 290,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.cardBorder, // Thick outer dark outline
              ),
            ),
            // The board surface
            Container(
              width: 284,
              height: 284,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.tableSurface, // Teal surface
                border: Border.all(
                  color: AppTheme.cardSurface,
                  width: 4,
                ),
              ),
            ),
            // Playful dash track inside the board
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.cardSurface.withOpacity(0.35),
                  width: 3,
                ),
              ),
            ),
            // Inner core ring
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.background.withOpacity(0.15),
                border: Border.all(
                  color: AppTheme.cardSurface.withOpacity(0.2),
                  width: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── App bar ───────────────────────────────────────────────────────────────────

class _GameAppBar extends StatelessWidget {
  final GameSessionModel session;

  const _GameAppBar({required this.session});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceMD, vertical: AppTheme.spaceSM),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppTheme.textSecondary, size: 18),
            onPressed: () => Navigator.maybePop(context),
          ),
          Expanded(
            child: Text(
              '${AppConstants.appName} · Game ${session.currentRoundNumber}',
              style: GoogleFonts.outfit(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

// ── Circular table ────────────────────────────────────────────────────────────

class _CircularTable extends StatelessWidget {
  final GameTableState state;

  const _CircularTable({required this.state});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final center = Offset(size.width / 2, size.height / 2);
        final players = state.session.players;
        final n = players.length;

        // Radius: adjust so cards don't overlap or go off screen
        final radius = math.min(size.width, size.height) * 0.36;
        const cardHalfW = 50.0;
        const cardHalfH = 70.0;

        final isDistributing = state.session.phase == GamePhase.distributing;
        final isStockEmpty = state.session.stockCount == 0;

        final distributorId = isDistributing
            ? state.session.currentDistributorPlayerId
            : (isStockEmpty ? state.session.currentTurnPlayerId : null);

        final distributor = distributorId != null
            ? players.where((p) => p.id == distributorId).firstOrNull
            : null;

        final showTray = distributor != null && distributor.totalStoneCount > 0;

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (state.session.phase == GamePhase.distributing) {
                    context
                        .read<GameTableBloc>()
                        .add(const DismissPassCauserSelection());
                  }
                },
              ),
            ),

            // Game Status Sticker on top-left
            Positioned(
              left: 12,
              top: 8,
              child: GameCenterPanel(session: state.session),
            ),

            // Center element: Distribution Tray or Stock Pile
            Positioned(
              left: center.dx - (showTray ? 70 : 55),
              top: center.dy - (showTray ? 85 : 55),
              child: showTray
                  ? _buildCenterDistributionTray(context, state, distributorId!)
                  : (state.session.stockCount > 0
                      ? StockPileWidget(
                          stockCount: state.session.stockCount,
                          topStoneType: state.session.stockStones.firstOrNull,
                          onTap: () {
                            final playerId = state.session.currentTurnPlayerId;
                            if (playerId != null) {
                              if (state.isHapticEnabled) {
                                HapticFeedback.lightImpact();
                              }
                              context
                                  .read<GameTableBloc>()
                                  .add(PlayerPass(playerId));
                            }
                          },
                        )
                      : const SizedBox.shrink()),
            ),

            // Player seats
            ...List.generate(n, (i) {
              // Start from bottom (270° = -π/2), go clockwise
              final angle = (-math.pi / 2) + (2 * math.pi * i / n);
              final x = center.dx + radius * math.cos(angle) - cardHalfW;
              final y = center.dy + radius * math.sin(angle) - cardHalfH;

              final player = players[i];
              final session = state.session;
              final isDistributor = distributorId == player.id;
              final isCurrentTurn = session.currentTurnPlayerId == player.id;

              final isDragTarget = showTray &&
                  distributorId != null &&
                  distributorId != player.id;

              return Positioned(
                left: x,
                top: y,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    PlayerSeatCard(
                      player: player,
                      isCrownHolder: session.crownPlayerId == player.id,
                      isHansip: session.hansipPlayerId == player.id,
                      isCurrentTurn: isCurrentTurn,
                      isDistributor: isDistributor,
                      isDragTarget: isDragTarget,
                      onTap: () => _onPlayerTap(context, player, state),
                      onStoneDropped: isDragTarget
                          ? (data) {
                              if (state.isHapticEnabled) {
                                HapticFeedback.mediumImpact();
                              }
                              context.read<GameTableBloc>().add(
                                    DropStoneToPlayer(
                                      fromPlayerId: distributorId,
                                      toPlayerId: player.id,
                                      stoneType: data.stoneType,
                                    ),
                                  );
                            }
                          : null,
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildCenterDistributionTray(
      BuildContext context, GameTableState state, String distributorId) {
    final session = state.session;
    final distributor =
        session.players.firstWhere((p) => p.id == distributorId);

    return DistributionTray(
      distributor: distributor,
      targets: session.players,
      isDragEnabled: state.isDragEnabled,
      onDistribute: (toPlayerId, stoneType) {
        if (state.isHapticEnabled) {
          HapticFeedback.mediumImpact();
        }
        if (stoneType == StoneType.small) {
          context.read<GameTableBloc>().add(DistributeSmallStone(
                fromPlayerId: distributorId,
                toPlayerId: toPlayerId,
              ));
        } else {
          context.read<GameTableBloc>().add(DistributeBigStone(
                fromPlayerId: distributorId,
                toPlayerId: toPlayerId,
              ));
        }
      },
    );
  }

  void _onPlayerTap(
      BuildContext context, PlayerModel player, GameTableState state) {
    final session = state.session;

    // Causer selection
    if (state.isSelectingPassCauser) {
      context.read<GameTableBloc>().add(SelectPassCauser(player.id));
      return;
    }

    final isStockEmpty = session.stockCount == 0;
    final isDistributing = session.phase == GamePhase.distributing;
    final distributorId = isDistributing
        ? session.currentDistributorPlayerId
        : (isStockEmpty ? session.currentTurnPlayerId : null);

    final distributor = distributorId != null
        ? session.players.where((p) => p.id == distributorId).firstOrNull
        : null;

    final showTray = distributor != null && distributor.totalStoneCount > 0;

    if (showTray && distributorId != null && distributorId != player.id) {
      if (isDistributing) {
        context.read<GameTableBloc>().add(const DismissPassCauserSelection());
      }
      context.read<GameTableBloc>().add(SelectCurrentPlayer(player.id));
      return;
    }

    // Select current player for pass
    if (session.phase == GamePhase.initialDraw ||
        session.phase == GamePhase.playing) {
      context.read<GameTableBloc>().add(SelectCurrentPlayer(player.id));
    }
  }
}

// ── Pass causer overlay ───────────────────────────────────────────────────────

class _PassCauserOverlay extends StatelessWidget {
  final GameTableState state;
  const _PassCauserOverlay({required this.state});

  @override
  Widget build(BuildContext context) {
    final session = state.session;
    final passedPlayerId = session.pendingPassedPlayerId;
    final passedPlayer = passedPlayerId != null
        ? session.players.firstWhere((p) => p.id == passedPlayerId)
        : null;

    return GestureDetector(
      onTap: () =>
          context.read<GameTableBloc>().add(const DismissPassCauserSelection()),
      child: Container(
        color: AppTheme.cardBorder.withOpacity(0.4),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: GestureDetector(
              onTap: () {}, // prevent dismiss on content tap
              child: Container(
                margin: const EdgeInsets.all(AppTheme.spaceLG),
                padding: const EdgeInsets.all(AppTheme.spaceLG),
                decoration: AppDecorations.glassCard(
                  color: AppTheme.cardSurface,
                  radius: AppTheme.radiusXL,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      // - **Empty Stock Flow** (Phase 2):
                      //   - **Manual/Active Distribution**: Tapping any player seat selects them as active. If a player is selected and they have stones (`totalStoneCount > 0`), their stone box appears in the center `DistributionTray`. They can swipe/drag their stones to **any other player seat** (or tap a seat) to distribute them manually. If they have 0 stones, the center remains empty.
                      //   - **Pass-Caused Distribution**: If a player passes, they tap the bottom "Pass" button which triggers the "Siapa yang bikin pass?" popup. Once selected, the causer's stone box appears in the center showing a target sticker (e.g. `👉 ke Budi`), allowing them to tap a stone to distribute instantly, or drag it exclusively to that target player.
                      // - **Big Stone lock**: Big Stone can only be distributed last (when no small stones remain)
                      decoration: BoxDecoration(
                        color: AppTheme.gold.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppTheme.cardBorder, width: 2),
                      ),
                      child: const Text('❓', style: TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(height: AppTheme.spaceMD),
                    Text(
                      'Siapa yang bikin\n${passedPlayer?.name ?? 'dia'} pass?',
                      style: GoogleFonts.outfit(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spaceSM),
                    Text(
                      'Pilih pemain penyebab pass untuk mencatat statistik',
                      style: GoogleFonts.inter(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spaceLG),
                    Wrap(
                      spacing: AppTheme.spaceSM,
                      runSpacing: AppTheme.spaceSM,
                      alignment: WrapAlignment.center,
                      children: session.players
                          .where((p) => p.id != passedPlayerId)
                          .map((player) {
                        final isSelectable = player.totalStoneCount > 0;
                        return GestureDetector(
                          onTap: () {
                            if (state.isHapticEnabled) {
                              HapticFeedback.mediumImpact();
                            }
                            context
                                .read<GameTableBloc>()
                                .add(SelectPassCauser(player.id));
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelectable
                                  ? AppTheme.gold
                                  : AppTheme.background,
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusMD),
                              border: Border.all(
                                color: AppTheme.cardBorder,
                                width: 2,
                              ),
                              boxShadow: isSelectable
                                  ? [
                                      const BoxShadow(
                                        color: AppTheme.cardBorder,
                                        blurRadius: 0,
                                        offset: Offset(2, 2),
                                      )
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  player.name,
                                  style: GoogleFonts.outfit(
                                    color: isSelectable
                                        ? AppTheme.textPrimary
                                        : AppTheme.textSecondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${player.totalStoneCount} batu',
                                  style: GoogleFonts.inter(
                                    color: isSelectable
                                        ? AppTheme.textSecondary
                                        : AppTheme.textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppTheme.spaceLG),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMD),
                        ),
                      ),
                      onPressed: () => context
                          .read<GameTableBloc>()
                          .add(const DismissPassCauserSelection()),
                      child: Text(
                        'Lewati / Batal',
                        style: GoogleFonts.outfit(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Game menu ─────────────────────────────────────────────────────────────────

class _GameMenu extends StatelessWidget {
  final GameTableState state;
  const _GameMenu({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceLG),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Menu',
              style: GoogleFonts.outfit(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: AppTheme.spaceLG),
          _MenuTile(
            icon: Icons.history_rounded,
            label: 'Riwayat Game',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRouter.history);
            },
          ),
          _MenuTile(
            icon: Icons.refresh_rounded,
            label: 'Reset Game',
            color: AppTheme.warning,
            onTap: () {
              Navigator.pop(context);
              context.read<GameTableBloc>().add(const ResetRound());
            },
          ),
          _MenuTile(
            icon: Icons.home_rounded,
            label: 'Kembali ke Beranda',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRouter.home, (r) => false);
            },
          ),
          const SizedBox(height: AppTheme.spaceMD),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppTheme.textSecondary),
      title: Text(
        label,
        style: GoogleFonts.outfit(
          color: color ?? AppTheme.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMD)),
    );
  }
}

class _TopMessageBanner extends StatelessWidget {
  final GameTableState state;
  const _TopMessageBanner({required this.state});

  @override
  Widget build(BuildContext context) {
    final session = state.session;
    final message = session.errorMessage ?? session.successMessage;
    if (message == null) return const SizedBox.shrink();

    final isError = session.errorMessage != null;
    final color = isError ? AppTheme.error : AppTheme.gold;
    final icon =
        isError ? Icons.error_outline_rounded : Icons.info_outline_rounded;

    return Positioned(
      top: 60,
      left: AppTheme.spaceMD,
      right: AppTheme.spaceMD,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceMD, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.cardSurface.withOpacity(0.95),
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            border: Border.all(color: color.withOpacity(0.4), width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 16,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.inter(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
