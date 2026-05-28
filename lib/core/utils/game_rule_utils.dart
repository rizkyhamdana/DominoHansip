import 'dart:math' as math;

import 'package:crownpass/data/models/player_model.dart';
import 'package:crownpass/data/models/game_session_model.dart';
import 'package:crownpass/data/models/settlement_preview_model.dart';

/// All pure game rule functions. No Flutter imports.
/// Each function is isolated so rules can be adjusted independently.
class GameRuleUtils {
  GameRuleUtils._();

  // ── Stock ───────────────────────────────────────────────────────────────────

  /// Creates the initial stock: first stone is Big, rest are Small.
  static List<StoneType> createInitialStock(int totalStones) {
    if (totalStones <= 0) return [];
    return [
      StoneType.big,
      ...List.filled(totalStones - 1, StoneType.small),
    ];
  }

  static bool isStockEmpty(List<StoneType> stock) => stock.isEmpty;

  // ── Player lookup ────────────────────────────────────────────────────────────

  static PlayerModel getPlayerById(List<PlayerModel> players, String id) {
    return players.firstWhere((p) => p.id == id);
  }

  static PlayerModel? getPlayerByIdOrNull(
      List<PlayerModel> players, String? id) {
    if (id == null) return null;
    try {
      return players.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Circular order ───────────────────────────────────────────────────────────

  /// Returns the player seated immediately before the winner in circular order.
  /// Example: players=[A,B,C,D], winner=C → returns B
  /// Example: players=[A,B,C,D], winner=A → returns D
  static PlayerModel getPreviousPlayer(
      List<PlayerModel> players, String winnerId) {
    final index = players.indexWhere((p) => p.id == winnerId);
    if (index == -1) return players.first;
    final prevIndex = (index - 1 + players.length) % players.length;
    return players[prevIndex];
  }

  // ── Distribution rules ───────────────────────────────────────────────────────

  /// Can the player distribute a Small Stone? Must have at least 1.
  static bool canDistributeSmallStone(PlayerModel player) =>
      player.smallStoneCount > 0;

  /// Can the player distribute the Big Stone?
  /// Rule: Big Stone can only be distributed when the player has NO Small Stones.
  /// TODO: Adjust this if the rule changes (e.g. allow big stone first).
  static bool canDistributeBigStone(PlayerModel player) =>
      player.hasBigStone && player.smallStoneCount == 0;

  /// Self-distribution not allowed by default.
  /// TODO: Set to true to allow self-distribution if rules change.
  static bool canDistributeToSelf() => false;

  // ── Hansip determination ─────────────────────────────────────────────────────

  /// Returns the player ID with the highest total points.
  /// Returns null when there is a tie (manual selection required).
  static String? determineHansip(List<PlayerModel> players) {
    if (players.isEmpty) return null;
    final maxPoints = players.map((p) => p.totalPoint).reduce(math.max);
    if (maxPoints == 0) return null;
    final candidates = players.where((p) => p.totalPoint == maxPoints).toList();
    if (candidates.length == 1) return candidates.first.id;
    return null; // Tie
  }

  /// Returns all player IDs tied for highest total points.
  static List<String> getHansipTiePlayers(List<PlayerModel> players) {
    if (players.isEmpty) return [];
    final maxPoints = players.map((p) => p.totalPoint).reduce(math.max);
    if (maxPoints == 0) return [];
    return players
        .where((p) => p.totalPoint == maxPoints)
        .map((p) => p.id)
        .toList();
  }

  // ── Crown determination ──────────────────────────────────────────────────────

  /// MVP crown validation: winner receives Crown only if they have 0 total
  /// stones after settlement.
  /// TODO: Adjust this validation as rules evolve (e.g. first to empty 3 times).
  static bool canWinnerReceiveCrownAfterSettlement(PlayerModel winner) {
    return winner.totalStoneCount == 0;
  }

  /// Returns the new crown holder ID after settlement.
  /// Crown stays if winner doesn't qualify.
  static String? determineCrownHolderAfterSettlement({
    required List<PlayerModel> playersAfterSettlement,
    required String winnerPlayerId,
    required String? currentCrownPlayerId,
  }) {
    final winner = getPlayerById(playersAfterSettlement, winnerPlayerId);
    if (canWinnerReceiveCrownAfterSettlement(winner)) {
      return winnerPlayerId;
    }
    return currentCrownPlayerId;
  }

  // ── Settlement preview ───────────────────────────────────────────────────────

  /// Builds a dry-run preview of what will happen after settlement.
  /// Does NOT modify any state permanently.
  ///
  /// Rule: the player seated immediately BEFORE the winner in turn order
  /// receives 1 bonus stone:
  ///   • If stock is non-empty → take the top stone from the stock.
  ///   • If stock is empty     → take a small stone from the winner
  ///                             (or big stone if winner has no small stones).
  static SettlementPreviewModel createSettlementPreview({
    required List<PlayerModel> players,
    required String winnerPlayerId,
    required String? currentCrownPlayerId,
    required String? currentHansipPlayerId,
    required List<StoneType> stockStones,
    bool isStockEmpty = true,
  }) {
    // 1. Identify the previous player (seated just before the winner).
    final prevPlayer = getPreviousPlayer(players, winnerPlayerId);

    // 2. Apply bonus stone transfer (prev player gets 1 stone).
    List<StoneType> updatedStock = List<StoneType>.from(stockStones);
    List<PlayerModel> playersAfterSettlement = List<PlayerModel>.from(players);

    // Helper: update a player in the list by id.
    PlayerModel updatePlayer(String id, PlayerModel Function(PlayerModel) fn) {
      final idx = playersAfterSettlement.indexWhere((p) => p.id == id);
      if (idx == -1) return playersAfterSettlement.first;
      final updated = fn(playersAfterSettlement[idx]);
      playersAfterSettlement[idx] = updated;
      return updated;
    }

    if (updatedStock.isNotEmpty) {
      // Take the top stone from the stock → give to previous player.
      final stone = updatedStock.removeAt(0);
      updatePlayer(prevPlayer.id, (p) {
        if (stone == StoneType.big) {
          return p.copyWith(hasBigStone: true);
        } else {
          return p.copyWith(smallStoneCount: p.smallStoneCount + 1);
        }
      });
    } else {
      // Stock empty → take a small stone from winner (or big stone if none).
      final winner = getPlayerById(playersAfterSettlement, winnerPlayerId);
      if (winner.smallStoneCount > 0) {
        updatePlayer(winnerPlayerId, (p) => p.copyWith(smallStoneCount: p.smallStoneCount - 1));
        updatePlayer(prevPlayer.id, (p) => p.copyWith(smallStoneCount: p.smallStoneCount + 1));
      } else if (winner.hasBigStone) {
        updatePlayer(winnerPlayerId, (p) => p.copyWith(hasBigStone: false));
        updatePlayer(prevPlayer.id, (p) => p.copyWith(hasBigStone: true));
      }
      // If winner has no stones at all, no transfer happens.
    }

    // 3. Determine Crown.
    final winnerAfterSettlement =
        getPlayerById(playersAfterSettlement, winnerPlayerId);
    final willCrownMove =
        isStockEmpty && canWinnerReceiveCrownAfterSettlement(winnerAfterSettlement);
    final nextCrownPlayerId =
        willCrownMove ? winnerPlayerId : currentCrownPlayerId;

    // 4. Determine Hansip from updated point totals only when a Kades is established (willCrownMove is true).
    final List<String> tiePlayers = willCrownMove
        ? getHansipTiePlayers(playersAfterSettlement)
        : (currentHansipPlayerId != null ? [currentHansipPlayerId] : const []);
    final suggestedHansip = willCrownMove
        ? (tiePlayers.length == 1 ? tiePlayers.first : null)
        : currentHansipPlayerId;

    return SettlementPreviewModel(
      winnerPlayerId: winnerPlayerId,
      previousPlayerBeforeWinnerId: prevPlayer.id,
      playersAfterBonusStone: playersAfterSettlement,
      hansipTiePlayerIds: tiePlayers,
      suggestedHansipPlayerId: suggestedHansip,
      willCrownMove: willCrownMove,
      nextCrownPlayerId: nextCrownPlayerId,
      stockStonesAfterSettlement: updatedStock,
    );
  }

  // ── Action log helpers ───────────────────────────────────────────────────────

  /// Returns the session reverted by the last action in the log.
  /// Supports: pass_big_stone, pass_small_stone, distribute_big, distribute_small.
  /// TODO: Extend for multi-step undo if needed.
  static GameSessionModel? undoLastAction(GameSessionModel session) {
    if (session.actionLog.isEmpty) return null;

    final lastAction = session.actionLog.last;
    final newLog = session.actionLog.sublist(0, session.actionLog.length - 1);

    switch (lastAction.type) {
      case 'pass_big_stone':
        // Return big stone to stock front, remove from player
        final toId = lastAction.toPlayerId;
        if (toId == null) return null;
        final updatedPlayers = session.players.map((p) {
          if (p.id == toId) {
            return p.copyWith(
              hasBigStone: false,
              passCount: p.passCount > 0 ? p.passCount - 1 : 0,
              totalReceivedStones:
                  p.totalReceivedStones > 0 ? p.totalReceivedStones - 1 : 0,
            );
          }
          return p;
        }).toList();
        return session.copyWith(
          players: updatedPlayers,
          stockStones: [StoneType.big, ...session.stockStones],
          phase: GamePhase.initialDraw,
          actionLog: newLog,
          clearError: true,
          clearSuccess: true,
        );

      case 'pass_small_stone':
        final toId = lastAction.toPlayerId;
        if (toId == null) return null;
        final updatedPlayers = session.players.map((p) {
          if (p.id == toId && p.smallStoneCount > 0) {
            return p.copyWith(
              smallStoneCount: p.smallStoneCount - 1,
              passCount: p.passCount > 0 ? p.passCount - 1 : 0,
              totalReceivedStones:
                  p.totalReceivedStones > 0 ? p.totalReceivedStones - 1 : 0,
            );
          }
          return p;
        }).toList();
        // Determine what phase to revert to
        final phaseBefore =
            newLog.isEmpty ? GamePhase.initialDraw : session.phase;
        return session.copyWith(
          players: updatedPlayers,
          stockStones: [StoneType.small, ...session.stockStones],
          phase: phaseBefore,
          actionLog: newLog,
          clearError: true,
          clearSuccess: true,
        );

      case 'distribute_big':
        final fromId = lastAction.fromPlayerId;
        final toId = lastAction.toPlayerId;
        if (fromId == null || toId == null) return null;
        final updatedPlayers = session.players.map((p) {
          if (p.id == fromId) {
            return p.copyWith(
              hasBigStone: true,
              totalDistributedStones: p.totalDistributedStones > 0
                  ? p.totalDistributedStones - 1
                  : 0,
            );
          }
          if (p.id == toId) {
            return p.copyWith(
              hasBigStone: false,
              totalReceivedStones:
                  p.totalReceivedStones > 0 ? p.totalReceivedStones - 1 : 0,
            );
          }
          return p;
        }).toList();
        return session.copyWith(
          players: updatedPlayers,
          phase: GamePhase.distributing,
          currentDistributorPlayerId: fromId,
          actionLog: newLog,
          clearError: true,
          clearSuccess: true,
        );

      case 'distribute_small':
        final fromId = lastAction.fromPlayerId;
        final toId = lastAction.toPlayerId;
        if (fromId == null || toId == null) return null;
        final updatedPlayers = session.players.map((p) {
          if (p.id == fromId) {
            return p.copyWith(
              smallStoneCount: p.smallStoneCount + 1,
              totalDistributedStones: p.totalDistributedStones > 0
                  ? p.totalDistributedStones - 1
                  : 0,
            );
          }
          if (p.id == toId && p.smallStoneCount > 0) {
            return p.copyWith(
              smallStoneCount: p.smallStoneCount - 1,
              totalReceivedStones:
                  p.totalReceivedStones > 0 ? p.totalReceivedStones - 1 : 0,
            );
          }
          return p;
        }).toList();
        return session.copyWith(
          players: updatedPlayers,
          phase: GamePhase.distributing,
          currentDistributorPlayerId: fromId,
          actionLog: newLog,
          clearError: true,
          clearSuccess: true,
        );

      default:
        return null;
    }
  }
}
