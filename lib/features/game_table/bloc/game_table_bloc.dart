import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:crownpass/data/models/player_model.dart';
import 'package:crownpass/data/models/game_session_model.dart';
import 'package:crownpass/data/models/game_action_model.dart';
import 'package:crownpass/data/models/round_result_model.dart';
import 'package:crownpass/data/models/player_snapshot_model.dart';
import 'package:crownpass/core/utils/game_rule_utils.dart';
import 'package:crownpass/core/constants/app_constants.dart';
import 'game_table_event.dart';
import 'game_table_state.dart';

const _uuid = Uuid();

class GameTableBloc extends HydratedBloc<GameTableEvent, GameTableState> {
  GameTableBloc() : super(GameTableState.initial()) {
    on<InitializeGame>(_onInitializeGame);
    on<StartRound>(_onStartRound);
    on<SelectCurrentPlayer>(_onSelectCurrentPlayer);
    on<PlayerPass>(_onPlayerPass);
    on<SelectPassCauser>(_onSelectPassCauser);
    on<DismissPassCauserSelection>(_onDismissPassCauserSelection);
    on<SelectStoneForDistribution>(_onSelectStoneForDistribution);
    on<DistributeSmallStone>(_onDistributeSmallStone);
    on<DistributeBigStone>(_onDistributeBigStone);
    on<DropStoneToPlayer>(_onDropStoneToPlayer);
    on<OpenRoundSettlement>(_onOpenRoundSettlement);
    on<SelectRoundWinner>(_onSelectRoundWinner);
    on<ConfirmSettlement>(_onConfirmSettlement);
    on<ResolveHansipTie>(_onResolveHansipTie);
    on<StartNextRound>(_onStartNextRound);
    on<UndoLastAction>(_onUndoLastAction);
    on<ResetRound>(_onResetRound);
    on<ResetGame>(_onResetGame);
    on<ClearMessage>(_onClearMessage);
    on<CancelRoundSettlement>(_onCancelRoundSettlement);
  }

  // ── HydratedBloc serialization ───────────────────────────────────────────────

  @override
  GameTableState? fromJson(Map<String, dynamic> json) {
    try {
      return GameTableState.fromJson(json);
    } catch (_) {
      return GameTableState.initial();
    }
  }

  @override
  Map<String, dynamic>? toJson(GameTableState state) {
    try {
      return state.toJson();
    } catch (_) {
      return null;
    }
  }

  // ── InitializeGame ───────────────────────────────────────────────────────────

  void _onInitializeGame(InitializeGame event, Emitter<GameTableState> emit) {
    final stock = GameRuleUtils.createInitialStock(event.totalStones);
    final session = GameSessionModel(
      players: event.players,
      currentRoundNumber: 1,
      phase: GamePhase.initialDraw,
      stockStones: stock,
      currentTurnPlayerId: event.players.first.id,
      actionLog: const [],
      roundHistory: const [],
      totalStonesConfig: event.totalStones,
    );
    emit(state.copyWith(
      session: session,
      isDragEnabled: event.isDragEnabled,
      isHapticEnabled: event.isHapticEnabled,
      isSelectingPassCauser: false,
    ));
  }

  // ── StartRound ───────────────────────────────────────────────────────────────

  void _onStartRound(StartRound event, Emitter<GameTableState> emit) {
    final session = state.session;
    final stock = GameRuleUtils.createInitialStock(session.totalStonesConfig);
    final resetPlayers = session.players
        .map((p) => p.copyWith(
              smallStoneCount: 0,
              hasBigStone: false,
              hadZeroStoneThisRound: false,
              passCount: 0,
            ))
        .toList();

    final startPlayerId = session.crownPlayerId ?? session.players.first.id;

    emit(state.copyWith(
      session: session.copyWith(
        players: resetPlayers,
        phase: GamePhase.initialDraw,
        stockStones: stock,
        currentTurnPlayerId: startPlayerId,
        clearDistributor: true,
        clearPendingPassed: true,
        clearSelectedStone: true,
        clearSettlementPreview: true,
        clearError: true,
        clearSuccess: true,
      ),
      isSelectingPassCauser: false,
    ));
  }

  // ── SelectCurrentPlayer ──────────────────────────────────────────────────────

  void _onSelectCurrentPlayer(
      SelectCurrentPlayer event, Emitter<GameTableState> emit) {
    emit(state.copyWith(
      session: state.session.copyWith(
        currentTurnPlayerId: event.playerId,
        clearError: true,
        clearSuccess: true,
      ),
    ));
  }

  // ── PlayerPass ───────────────────────────────────────────────────────────────

  void _onPlayerPass(PlayerPass event, Emitter<GameTableState> emit) {
    final session = state.session;
    final players = session.players;
    final player = GameRuleUtils.getPlayerById(players, event.playerId);

    if (!GameRuleUtils.isStockEmpty(session.stockStones)) {
      // Phase 1: Draw from stock
      final stone = session.stockStones.first;
      final newStock = session.stockStones.sublist(1);

      final PlayerModel updatedPlayer;
      final String message;

      if (stone == StoneType.big) {
        updatedPlayer = player.copyWith(
          hasBigStone: true,
          passCount: player.passCount + 1,
          totalReceivedStones: player.totalReceivedStones + 1,
        );
        message = '${AppConstants.bigStoneFallMessage} ${player.name}!';
      } else {
        updatedPlayer = player.copyWith(
          smallStoneCount: player.smallStoneCount + 1,
          passCount: player.passCount + 1,
          totalReceivedStones: player.totalReceivedStones + 1,
        );
        message = '${player.name} ${AppConstants.smallStonePassMessage}.';
      }

      final updatedPlayers =
          players.map((p) => p.id == player.id ? updatedPlayer : p).toList();

      GamePhase newPhase = session.phase;
      String finalMessage = message;
      if (newStock.isEmpty) {
        newPhase = GamePhase.playing;
        finalMessage = '$message ${AppConstants.allStonesDistributed}';
      }

      final action = GameActionModel(
        id: _uuid.v4(),
        type: stone == StoneType.big ? 'pass_big_stone' : 'pass_small_stone',
        description: finalMessage,
        toPlayerId: player.id,
        stoneType: stone,
        createdAt: DateTime.now(),
      );

      emit(state.copyWith(
        session: session.copyWith(
          players: updatedPlayers,
          stockStones: newStock,
          phase: newPhase,
          successMessage: finalMessage,
          clearError: true,
          actionLog: [...session.actionLog, action],
        ),
      ));
    } else {
      // Phase 2: Stock empty → need to select causer
      emit(state.copyWith(
        session: session.copyWith(
          phase: GamePhase.distributing,
          pendingPassedPlayerId: event.playerId,
          clearError: true,
          clearSuccess: true,
        ),
        isSelectingPassCauser: true,
      ));
    }
  }

  // ── SelectPassCauser ─────────────────────────────────────────────────────────

  void _onSelectPassCauser(
      SelectPassCauser event, Emitter<GameTableState> emit) {
    final session = state.session;
    final causer =
        GameRuleUtils.getPlayerById(session.players, event.causerPlayerId);

    if (causer.totalStoneCount == 0) {
      emit(state.copyWith(
        session: session.copyWith(
          errorMessage: AppConstants.causerNoStoneError,
          clearSuccess: true,
        ),
      ));
      return;
    }

    emit(state.copyWith(
      session: session.copyWith(
        currentDistributorPlayerId: event.causerPlayerId,
        phase: GamePhase.distributing,
        clearError: true,
        clearSuccess: true,
      ),
      isSelectingPassCauser: false,
    ));
  }

  void _onDismissPassCauserSelection(
      DismissPassCauserSelection event, Emitter<GameTableState> emit) {
    emit(state.copyWith(
      session: state.session.copyWith(
        phase: GamePhase.playing,
        clearDistributor: true,
        clearPendingPassed: true,
        clearSelectedStone: true,
        clearError: true,
        clearSuccess: true,
      ),
      isSelectingPassCauser: false,
    ));
  }

  // ── SelectStoneForDistribution ───────────────────────────────────────────────

  void _onSelectStoneForDistribution(
      SelectStoneForDistribution event, Emitter<GameTableState> emit) {
    final session = state.session;
    final distributorId = session.currentDistributorPlayerId;
    if (distributorId == null) return;

    final distributor =
        GameRuleUtils.getPlayerById(session.players, distributorId);

    if (event.stoneType == StoneType.big &&
        !GameRuleUtils.canDistributeBigStone(distributor)) {
      emit(state.copyWith(
        session: session.copyWith(
          errorMessage: AppConstants.bigStoneLockedMessage,
          clearSuccess: true,
        ),
      ));
      return;
    }

    emit(state.copyWith(
      session: session.copyWith(
        selectedStoneType: event.stoneType,
        clearError: true,
      ),
    ));
  }

  // ── DistributeSmallStone ─────────────────────────────────────────────────────

  void _onDistributeSmallStone(
      DistributeSmallStone event, Emitter<GameTableState> emit) {
    _executeDistribution(
        event.fromPlayerId, event.toPlayerId, StoneType.small, emit);
  }

  // ── DistributeBigStone ───────────────────────────────────────────────────────

  void _onDistributeBigStone(
      DistributeBigStone event, Emitter<GameTableState> emit) {
    _executeDistribution(
        event.fromPlayerId, event.toPlayerId, StoneType.big, emit);
  }

  // ── DropStoneToPlayer (drag & drop) ─────────────────────────────────────────

  void _onDropStoneToPlayer(
      DropStoneToPlayer event, Emitter<GameTableState> emit) {
    _executeDistribution(
        event.fromPlayerId, event.toPlayerId, event.stoneType, emit);
  }

  // ── Shared distribution logic ────────────────────────────────────────────────

  void _executeDistribution(
    String fromPlayerId,
    String toPlayerId,
    StoneType stoneType,
    Emitter<GameTableState> emit,
  ) {
    final session = state.session;
    final distributor =
        GameRuleUtils.getPlayerById(session.players, fromPlayerId);
    final target = GameRuleUtils.getPlayerById(session.players, toPlayerId);

    // Validate self-distribution
    if (!GameRuleUtils.canDistributeToSelf() && fromPlayerId == toPlayerId) {
      emit(state.copyWith(
        session: session.copyWith(
          errorMessage: 'Tidak bisa membagi batu ke diri sendiri.',
          clearSuccess: true,
        ),
      ));
      return;
    }

    // Validate stone availability
    if (stoneType == StoneType.big) {
      if (!GameRuleUtils.canDistributeBigStone(distributor)) {
        emit(state.copyWith(
          session: session.copyWith(
            errorMessage: AppConstants.bigStoneLockedMessage,
            clearSuccess: true,
          ),
        ));
        return;
      }
    } else {
      if (!GameRuleUtils.canDistributeSmallStone(distributor)) {
        emit(state.copyWith(
          session: session.copyWith(
            errorMessage: 'Tidak ada Batu Kecil untuk dibagi.',
            clearSuccess: true,
          ),
        ));
        return;
      }
    }

    // Apply distribution
    final PlayerModel updatedDistributor;
    final PlayerModel updatedTarget;
    final String stoneName =
        stoneType == StoneType.big ? 'Batu Besar' : 'Batu Kecil';

    if (stoneType == StoneType.big) {
      updatedDistributor = distributor.copyWith(
        hasBigStone: false,
        totalDistributedStones: distributor.totalDistributedStones + 1,
      );
      updatedTarget = target.copyWith(
        hasBigStone: true,
        totalReceivedStones: target.totalReceivedStones + 1,
      );
    } else {
      updatedDistributor = distributor.copyWith(
        smallStoneCount: distributor.smallStoneCount - 1,
        totalDistributedStones: distributor.totalDistributedStones + 1,
      );
      updatedTarget = target.copyWith(
        smallStoneCount: target.smallStoneCount + 1,
        totalReceivedStones: target.totalReceivedStones + 1,
      );
    }

    final updatedPlayers = session.players.map((p) {
      if (p.id == fromPlayerId) return updatedDistributor;
      if (p.id == toPlayerId) return updatedTarget;
      return p;
    }).toList();

    String message =
        '${distributor.name} membagi $stoneName ke ${target.name}.';

    // Check if distributor now has 0 stones
    bool distributorIsEmpty = updatedDistributor.totalStoneCount == 0;
    final List<PlayerModel> finalPlayers;
    if (distributorIsEmpty) {
      finalPlayers = updatedPlayers.map((p) {
        if (p.id == fromPlayerId) {
          return p.copyWith(hadZeroStoneThisRound: true);
        }
        return p;
      }).toList();
      message = '${distributor.name} ${AppConstants.zeroStoneMessage}';
    } else {
      finalPlayers = updatedPlayers;
    }

    final action = GameActionModel(
      id: _uuid.v4(),
      type: stoneType == StoneType.big ? 'distribute_big' : 'distribute_small',
      description: message,
      fromPlayerId: fromPlayerId,
      toPlayerId: toPlayerId,
      stoneType: stoneType,
      createdAt: DateTime.now(),
    );

    emit(state.copyWith(
      session: session.copyWith(
        players: finalPlayers,
        phase: GamePhase.playing,
        clearDistributor: true,
        clearPendingPassed: true,
        clearSelectedStone: true,
        successMessage: message,
        clearError: true,
        actionLog: [...session.actionLog, action],
      ),
    ));
  }

  // ── OpenRoundSettlement ──────────────────────────────────────────────────────

  void _onOpenRoundSettlement(
      OpenRoundSettlement event, Emitter<GameTableState> emit) {
    emit(state.copyWith(
      session: state.session.copyWith(
        phase: GamePhase.roundSettlement,
        clearSettlementPreview: true,
        clearError: true,
        clearSuccess: true,
      ),
    ));
  }

  // ── SelectRoundWinner ────────────────────────────────────────────────────────

  void _onSelectRoundWinner(
      SelectRoundWinner event, Emitter<GameTableState> emit) {
    final session = state.session;
    final preview = GameRuleUtils.createSettlementPreview(
      players: session.players,
      winnerPlayerId: event.winnerPlayerId,
      currentCrownPlayerId: session.crownPlayerId,
    );

    emit(state.copyWith(
      session: session.copyWith(
        settlementPreview: preview,
        clearError: true,
        clearSuccess: true,
      ),
    ));
  }

  // ── ConfirmSettlement ────────────────────────────────────────────────────────

  void _onConfirmSettlement(
      ConfirmSettlement event, Emitter<GameTableState> emit) {
    final session = state.session;
    final preview = session.settlementPreview;
    if (preview == null) return;

    // If hansip tie and not yet resolved, wait for ResolveHansipTie
    if (preview.hasHansipTie && preview.suggestedHansipPlayerId == null) {
      // Stay in roundSettlement, UI will show tie dialog
      return;
    }

    _applySettlement(emit, preview);
  }

  // ── ResolveHansipTie ─────────────────────────────────────────────────────────

  void _onResolveHansipTie(
      ResolveHansipTie event, Emitter<GameTableState> emit) {
    final session = state.session;
    final preview = session.settlementPreview;
    if (preview == null) return;

    final updatedPreview =
        preview.copyWith(suggestedHansipPlayerId: event.selectedPlayerId);

    emit(state.copyWith(
      session: session.copyWith(settlementPreview: updatedPreview),
    ));

    _applySettlement(emit, updatedPreview);
  }

  void _applySettlement(Emitter<GameTableState> emit, settlementPreview) {
    final session = state.session;
    final preview = settlementPreview as dynamic;

    final String winnerPlayerId = preview.winnerPlayerId as String;
    final String prevPlayerId = preview.previousPlayerBeforeWinnerId as String;
    final List<PlayerModel> playersAfterBonus =
        preview.playersAfterBonusStone as List<PlayerModel>;
    final String? newHansipId = preview.suggestedHansipPlayerId as String?;
    final String? newCrownId = preview.nextCrownPlayerId as String?;
    final bool willCrownMove = preview.willCrownMove as bool;

    // Update stats
    final finalPlayers = playersAfterBonus.map((p) {
      PlayerModel updated = p;
      if (p.id == winnerPlayerId) {
        updated = updated.copyWith(winCount: updated.winCount + 1);
      }
      if (p.id == newHansipId) {
        updated = updated.copyWith(hansipCount: updated.hansipCount + 1);
      }
      if (willCrownMove && p.id == newCrownId) {
        updated = updated.copyWith(crownCount: updated.crownCount + 1);
      }
      return updated;
    }).toList();

    // Build player snapshots
    final snapshots = finalPlayers.map((p) {
      return PlayerSnapshotModel(
        playerId: p.id,
        playerName: p.name,
        smallStoneCount: p.smallStoneCount,
        hasBigStone: p.hasBigStone,
        totalStoneCount: p.totalStoneCount,
        totalPoint: p.totalPoint,
        isWinner: p.id == winnerPlayerId,
        isCrownHolder: p.id == newCrownId,
        isHansip: p.id == newHansipId,
      );
    }).toList();

    // Build round result
    final roundResult = RoundResultModel(
      id: _uuid.v4(),
      roundNumber: session.currentRoundNumber,
      winnerPlayerId: winnerPlayerId,
      previousPlayerBeforeWinnerId: prevPlayerId,
      crownHolderBeforeRound: session.crownPlayerId,
      crownHolderAfterRound: newCrownId,
      hansipBeforeRound: session.hansipPlayerId,
      hansipAfterRound: newHansipId,
      snapshots: snapshots,
      createdAt: DateTime.now(),
    );

    final winner = GameRuleUtils.getPlayerById(finalPlayers, winnerPlayerId);
    final String crownMsg = willCrownMove
        ? '${AppConstants.crownMovedMessage} ${winner.name}.'
        : '${AppConstants.crownStayMessage} ${session.crownPlayer?.name ?? "tidak ada"}.';

    final hansipPlayer = newHansipId != null
        ? GameRuleUtils.getPlayerById(finalPlayers, newHansipId)
        : null;
    final String hansipMsg = hansipPlayer != null
        ? '${AppConstants.newHansipMessage} ${hansipPlayer.name}.'
        : '';

    emit(state.copyWith(
      session: session.copyWith(
        players: finalPlayers,
        phase: GamePhase.roundFinished,
        crownPlayerId: newCrownId,
        hansipPlayerId: newHansipId,
        roundHistory: [...session.roundHistory, roundResult],
        successMessage: '$crownMsg $hansipMsg',
        clearError: true,
      ),
    ));
  }

  // ── StartNextRound ───────────────────────────────────────────────────────────

  void _onStartNextRound(StartNextRound event, Emitter<GameTableState> emit) {
    final session = state.session;
    final stock = GameRuleUtils.createInitialStock(session.totalStonesConfig);
    final resetPlayers = session.players
        .map((p) => p.copyWith(
              smallStoneCount: 0,
              hasBigStone: false,
              hadZeroStoneThisRound: false,
              passCount: 0,
            ))
        .toList();

    final startPlayerId = session.crownPlayerId ?? session.players.first.id;

    final crownPlayer = GameRuleUtils.getPlayerByIdOrNull(
        session.players, session.crownPlayerId);
    final hansipPlayer = GameRuleUtils.getPlayerByIdOrNull(
        session.players, session.hansipPlayerId);

    String msg = AppConstants.newRoundMessage;
    if (hansipPlayer != null) {
      msg += ' ${AppConstants.hansipReadyMessage}';
    }
    if (crownPlayer != null) {
      msg += ' ${crownPlayer.name} keluar duluan.';
    }

    emit(state.copyWith(
      session: session.copyWith(
        players: resetPlayers,
        currentRoundNumber: session.currentRoundNumber + 1,
        phase: GamePhase.initialDraw,
        stockStones: stock,
        currentTurnPlayerId: startPlayerId,
        clearDistributor: true,
        clearPendingPassed: true,
        clearSelectedStone: true,
        clearSettlementPreview: true,
        clearError: true,
        successMessage: msg,
      ),
      isSelectingPassCauser: false,
    ));
  }

  // ── UndoLastAction ───────────────────────────────────────────────────────────

  void _onUndoLastAction(UndoLastAction event, Emitter<GameTableState> emit) {
    final reverted = GameRuleUtils.undoLastAction(state.session);
    if (reverted == null) {
      emit(state.copyWith(
        session: state.session.copyWith(
          errorMessage: 'Tidak ada aksi yang bisa dibatalkan.',
          clearSuccess: true,
        ),
      ));
      return;
    }
    emit(state.copyWith(
      session: reverted,
      isSelectingPassCauser: false,
    ));
  }

  // ── ResetRound ───────────────────────────────────────────────────────────────

  void _onResetRound(ResetRound event, Emitter<GameTableState> emit) {
    final session = state.session;
    final stock = GameRuleUtils.createInitialStock(session.totalStonesConfig);
    final resetPlayers = session.players
        .map((p) => p.copyWith(
              smallStoneCount: 0,
              hasBigStone: false,
              hadZeroStoneThisRound: false,
              passCount: 0,
            ))
        .toList();
    final startPlayerId = session.crownPlayerId ?? session.players.first.id;

    emit(state.copyWith(
      session: session.copyWith(
        players: resetPlayers,
        phase: GamePhase.initialDraw,
        stockStones: stock,
        currentTurnPlayerId: startPlayerId,
        clearDistributor: true,
        clearPendingPassed: true,
        clearSelectedStone: true,
        clearSettlementPreview: true,
        actionLog: const [],
        clearError: true,
        successMessage: 'Game direset.',
      ),
      isSelectingPassCauser: false,
    ));
  }

  // ── ResetGame ────────────────────────────────────────────────────────────────

  void _onResetGame(ResetGame event, Emitter<GameTableState> emit) {
    emit(GameTableState.initial());
  }

  // ── ClearMessage ─────────────────────────────────────────────────────────────

  void _onClearMessage(ClearMessage event, Emitter<GameTableState> emit) {
    emit(state.copyWith(
      session: state.session.copyWith(
        clearError: true,
        clearSuccess: true,
      ),
    ));
  }

  // ── CancelRoundSettlement ────────────────────────────────────────────────────

  void _onCancelRoundSettlement(
      CancelRoundSettlement event, Emitter<GameTableState> emit) {
    final session = state.session;
    final activePhase = GameRuleUtils.isStockEmpty(session.stockStones)
        ? GamePhase.playing
        : GamePhase.initialDraw;

    emit(state.copyWith(
      session: session.copyWith(
        phase: activePhase,
        clearSettlementPreview: true,
        clearError: true,
        clearSuccess: true,
      ),
    ));
  }
}
