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
import 'package:crownpass/features/game_table/widget/domino_chain_view.dart';
import 'package:crownpass/features/game_table/widget/player_hand_deck.dart';
import 'package:crownpass/core/utils/domino_engine.dart';
import 'package:crownpass/core/services/audio_service.dart';

class GameTablePage extends StatefulWidget {
  const GameTablePage({super.key});

  @override
  State<GameTablePage> createState() => _GameTablePageState();
}

class _GameTablePageState extends State<GameTablePage> {
  bool _hasPushedSettlement = false;

  @override
  void initState() {
    super.initState();
    // Hide system overlays for immersive gameplay experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Start background music
    AudioService.instance.play();

    // Resume bot turns if continuing a persisted state where it is a bot's turn!
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<GameTableBloc>().add(const ResumeGameSession());

        // Check if resumed session is already in roundSettlement phase
        final state = context.read<GameTableBloc>().state;
        if (state.session.phase == GamePhase.roundSettlement &&
            !_hasPushedSettlement) {
          _hasPushedSettlement = true;
          Navigator.pushNamed(context, AppRouter.roundSettlement);
        }
      }
    });
  }

  @override
  void dispose() {
    // Restore normal system UI bars
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // NOTE: Music intentionally NOT paused here — continues across game screens.
    // Music is paused only when navigating back to home.
    super.dispose();
  }

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

        if (session.phase != GamePhase.roundSettlement) {
          _hasPushedSettlement = false;
        }

        // Navigate to settlement page
        if (session.phase == GamePhase.roundSettlement &&
            !_hasPushedSettlement) {
          _hasPushedSettlement = true;
          // Play round end SFX
          AudioService.instance.playSfx('round_end');
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

        final isBotTurn = session.isVsMode &&
            session.botPlayerIds.isNotEmpty &&
            (session.botPlayerIds.contains(session.currentTurnPlayerId) ||
                session.botPlayerIds
                    .contains(session.currentDistributorPlayerId) ||
                (state.isSelectingPassCauser &&
                    session.botPlayerIds
                        .contains(session.pendingPassedPlayerId)));

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

                      // Bot thinking banner (VS mode)
                      if (isBotTurn) _BotThinkingBanner(),

                      // Circular table area
                      Expanded(
                        child: _CircularTable(state: state),
                      ),

                      if (session.isVsMode) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.spaceSM),
                          child: DominoChainView(chain: session.dominoChain),
                        ),
                        Builder(
                          builder: (context) {
                            final humanPlayer = session.players
                                .firstWhere((p) => !session.isBot(p.id));
                            final humanHand =
                                session.playerHands[humanPlayer.id] ?? const [];
                            bool canHumanPlayNow() {
                              final latestSession =
                                  context.read<GameTableBloc>().state.session;
                              return latestSession.phase == GamePhase.playing &&
                                  latestSession.currentTurnPlayerId ==
                                      humanPlayer.id &&
                                  !latestSession.isBot(humanPlayer.id);
                            }

                            return Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppTheme.spaceSM),
                              child: PlayerHandDeck(
                                humanPlayer: humanPlayer,
                                hand: humanHand,
                                chain: session.dominoChain,
                                enabled: !isBotTurn && canHumanPlayNow(),
                                canPlayNow: canHumanPlayNow,
                                onPlay: (tile, side) {
                                  if (!canHumanPlayNow()) return;
                                  // Play tile placement SFX
                                  AudioService.instance.playSfx('tile_place');
                                  context
                                      .read<GameTableBloc>()
                                      .add(PlayDominoTile(
                                        playerId: humanPlayer.id,
                                        tile: tile,
                                        side: side,
                                      ));
                                },
                              ),
                            );
                          },
                        ),
                      ],

                      // Action bar — disabled when bot's turn
                      IgnorePointer(
                        ignoring: isBotTurn,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: isBotTurn ? 0.4 : 1.0,
                          child: ActionBottomBar(
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
                        ),
                      ),
                    ],
                  ),
                ),

                // Causer selection overlay — only show when human is the pending passer
                if (state.isSelectingPassCauser && !isBotTurn)
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

    final hand = state.session.playerHands[playerId] ?? const [];
    final hasMoves =
        DominoEngine.hasValidMoves(hand, state.session.dominoChain);
    if (hasMoves) return; // Block manual pass if they have playable tiles!

    if (state.isHapticEnabled) {
      HapticFeedback.lightImpact();
    }
    AudioService.instance.playSfx('pass');
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
                color: AppTheme.cardBorder.withValues(alpha: 0.12),
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
                  color: AppTheme.cardSurface.withValues(alpha: 0.35),
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
                color: AppTheme.background.withValues(alpha: 0.15),
                border: Border.all(
                  color: AppTheme.cardSurface.withValues(alpha: 0.2),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${AppConstants.appName} · Game ${session.currentRoundNumber}',
                  style: GoogleFonts.outfit(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (session.isVsMode) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.bigStoneMaroon.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                      border: Border.all(
                        color: AppTheme.bigStoneMaroon.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      'VS',
                      style: GoogleFonts.outfit(
                        color: AppTheme.bigStoneMaroon,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

// ── Bot thinking banner ───────────────────────────────────────────────────────

class _BotThinkingBanner extends StatefulWidget {
  @override
  State<_BotThinkingBanner> createState() => _BotThinkingBannerState();
}

class _BotThinkingBannerState extends State<_BotThinkingBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) {
        return Container(
          margin: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceMD, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.bigStoneMaroon
                .withValues(alpha: 0.08 + _pulse.value * 0.06),
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            border: Border.all(
              color: AppTheme.bigStoneMaroon.withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.bigStoneMaroon,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '🤖 Bot sedang berpikir...',
                style: GoogleFonts.outfit(
                  color: AppTheme.bigStoneMaroon,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
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
        final session = state.session;
        final center = Offset(
          size.width / 2,
          (size.height / 2) + (session.isVsMode ? 48.0 : 0.0),
        );
        final players = session.players;
        final displayPlayers = session.isVsMode
            ? players.where((p) => session.isBot(p.id)).toList()
            : players;
        final n = displayPlayers.length;

        // Radius: adjust so cards don't overlap or go off screen
        final radius = math.min(size.width, size.height) *
            (session.isVsMode ? 0.28 : 0.36);
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

        final showTray = !session.isVsMode &&
            distributor != null &&
            distributor.totalStoneCount > 0;

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

            // Real-time scrolling match ticker on top-right (VS Bot mode)
            if (state.session.isVsMode)
              Positioned(
                right: 12,
                top: 8,
                child: _GameTickerPanel(session: state.session),
              ),

            // Center element: Board felt / Stock Pile (if stock is present) / DistributionTray (Co-op Mode empty stock)
            Positioned(
              left: center.dx -
                  (showTray ? 70 : (state.session.stockCount > 0 ? 55 : 45)),
              top: center.dy -
                  (showTray ? 85 : (state.session.stockCount > 0 ? 55 : 45)) +
                  (session.isVsMode && state.session.stockCount > 0
                      ? 70.0
                      : 0.0),
              child: (state.session.stockCount > 0)
                  ? StockPileWidget(
                      stockCount: state.session.stockCount,
                      topStoneType: state.session.stockStones.firstOrNull,
                      onTap: () {
                        final playerId = state.session.currentTurnPlayerId;
                        final isHumanTurn =
                            playerId != null && !state.session.isBot(playerId);
                        if (isHumanTurn) {
                          final hand =
                              state.session.playerHands[playerId] ?? const [];
                          final hasMoves = DominoEngine.hasValidMoves(
                              hand, state.session.dominoChain);
                          if (hasMoves) {
                            return; // Block pass if they have playable tiles!
                          }

                          if (state.isHapticEnabled) {
                            HapticFeedback.lightImpact();
                          }
                          AudioService.instance.playSfx('pass');
                          context
                              .read<GameTableBloc>()
                              .add(PlayerPass(playerId));
                        }
                      },
                    )
                  : (showTray
                      ? _buildCenterDistributionTray(
                          context, state, distributorId!)
                      : Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: AppTheme.tableSurface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  AppTheme.cardSurface.withValues(alpha: 0.35),
                              width: 3.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '🀰',
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.cardSurface
                                        .withValues(alpha: 0.4),
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  'BOARD',
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.cardSurface
                                        .withValues(alpha: 0.4),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
            ),

            // Player seats
            ...List.generate(n, (i) {
              final double angle;
              if (session.isVsMode) {
                // Seating for 3 bots: Left, Top, Right
                if (i == 0) {
                  angle = math.pi; // Left
                } else if (i == 1) {
                  angle = -math.pi / 2; // Top
                } else {
                  angle = 0.0; // Right
                }
              } else {
                angle = (-math.pi / 2) + (2 * math.pi * i / n);
              }

              // VS mode: manual per-seat fine-tuning offsets
              double extraDx = 0.0;
              double extraDy = 0.0;
              if (session.isVsMode) {
                if (i == 0) {
                  // Alpha (left) — geser lebih ke kiri
                  extraDx = -20.0;
                } else if (i == 1) {
                  // Beta (top) — turun sedikit ke bawah
                  extraDy = 24.0;
                } else if (i == 2) {
                  // Gamma (right) — geser lebih ke kanan
                  extraDx = 20.0;
                }
              }

              final x = center.dx + radius * math.cos(angle) - cardHalfW + extraDx;
              final y = center.dy + radius * math.sin(angle) - cardHalfH + extraDy;

              final player = displayPlayers[i];
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
                      dominoTileCount: session.isVsMode
                          ? (session.playerHands[player.id]?.length)
                          : null,
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
      if (session.isVsMode) return; // VS mode uses overlay
      context.read<GameTableBloc>().add(SelectPassCauser(player.id));
      return;
    }

    final isStockEmpty = session.stockCount == 0;
    final isDistributing = session.phase == GamePhase.distributing;
    final distributorId = isDistributing
        ? session.currentDistributorPlayerId
        : (isStockEmpty ? session.currentTurnPlayerId : null);

    // Distribution: Tap target player to distribute selected stone!
    if (isDistributing && distributorId != null) {
      // Distributor must be human
      if (!session.isBot(distributorId)) {
        final selectedStone = session.selectedStoneType;
        if (selectedStone != null && player.id != distributorId) {
          if (state.isHapticEnabled) {
            HapticFeedback.mediumImpact();
          }
          if (selectedStone == StoneType.small) {
            context.read<GameTableBloc>().add(DistributeSmallStone(
                  fromPlayerId: distributorId,
                  toPlayerId: player.id,
                ));
          } else {
            context.read<GameTableBloc>().add(DistributeBigStone(
                  fromPlayerId: distributorId,
                  toPlayerId: player.id,
                ));
          }
          return;
        }
      }
    }

    if (session.isVsMode) {
      // In VS mode, manual player turn selection is disabled.
      return;
    }

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
        color: AppTheme.cardBorder.withValues(alpha: 0.4),
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
                        color: AppTheme.gold.withValues(alpha: 0.2),
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

class _GameMenu extends StatefulWidget {
  final GameTableState state;
  const _GameMenu({required this.state});

  @override
  State<_GameMenu> createState() => _GameMenuState();
}

class _GameMenuState extends State<_GameMenu> {
  bool _isMusicMuted = AudioService.instance.isMusicMuted;
  bool _isSfxMuted = AudioService.instance.isSfxMuted;

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

          // Music toggle
          _MenuTile(
            icon: _isMusicMuted
                ? Icons.music_off_rounded
                : Icons.music_note_rounded,
            label: _isMusicMuted ? 'Musik: Mati' : 'Musik: Aktif',
            onTap: () async {
              final newMuted = await AudioService.instance.toggleMusic();
              if (mounted) setState(() => _isMusicMuted = newMuted);
            },
          ),

          // SFX toggle
          _MenuTile(
            icon: _isSfxMuted
                ? Icons.volume_off_rounded
                : Icons.volume_up_rounded,
            label: _isSfxMuted ? 'Efek Suara: Mati' : 'Efek Suara: Aktif',
            onTap: () {
              final newMuted = AudioService.instance.toggleSfx();
              if (mounted) setState(() => _isSfxMuted = newMuted);
            },
          ),

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
              // Pause music when going back to home
              AudioService.instance.pause();
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
            color: AppTheme.cardSurface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 16,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
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

// ── Game Ticker Panel ──────────────────────────────────────────────────────────
class _GameTickerPanel extends StatefulWidget {
  final GameSessionModel session;

  const _GameTickerPanel({required this.session});

  @override
  State<_GameTickerPanel> createState() => _GameTickerPanelState();
}

class _GameTickerPanelState extends State<_GameTickerPanel> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant _GameTickerPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Automatically scroll to the latest action entry when log updates
    if (widget.session.actionLog.length != oldWidget.session.actionLog.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actions = widget.session.actionLog;

    return Container(
      width: 165,
      height: 90,
      padding: const EdgeInsets.all(AppTheme.spaceXS),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(
          color: AppTheme.cardBorder,
          width: 2.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.cardBorder,
            blurRadius: 0,
            offset: Offset(2.5, 2.5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                '📝 LOG PERMAINAN',
                style: GoogleFonts.outfit(
                  color: AppTheme.goldDark,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          const Divider(height: 1, color: AppTheme.cardBorder),
          const SizedBox(height: 3),
          // Scrollable List of Game Actions
          Expanded(
            child: actions.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada aksi...',
                      style: GoogleFonts.inter(
                        color: AppTheme.textMuted,
                        fontSize: 9.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : Scrollbar(
                    controller: _scrollController,
                    thickness: 2.5,
                    radius: const Radius.circular(10),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(right: 4.0),
                      itemCount: actions.length,
                      itemBuilder: (context, idx) {
                        final action = actions[idx];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 1.0),
                                child: Icon(
                                  Icons.bolt_rounded,
                                  size: 9.5,
                                  color: AppTheme.goldDark,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  action.description,
                                  style: GoogleFonts.inter(
                                    color: AppTheme.textPrimary,
                                    fontSize: 8.0,
                                    fontWeight: FontWeight.w600,
                                    height: 1.25,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
