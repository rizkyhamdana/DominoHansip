import 'package:crownpass/data/models/player_model.dart';
import 'package:crownpass/data/models/game_session_model.dart';
import 'package:crownpass/core/utils/domino_engine.dart';

/// Possible actions the bot can decide to take this tick.
enum BotTurnAction {
  /// Bot should play a domino tile on the chain
  playDomino,

  /// Bot should call PlayerPass(botId) — draws from stock (initialDraw phase)
  /// or triggers causer selection (playing phase, stock empty)
  pass,

  /// Bot is the distributor: pick stone type + target and call distribute
  distribute,

  /// Bot needs to select pass causer (isSelectingPassCauser = true, bot is
  /// the pending passed player)
  selectCauser,

  /// Nothing to do (e.g. settlement phase or not bot turn)
  idle,
}

/// Result of bot deciding distribution — which stone to give and to whom.
class BotDistributeDecision {
  final StoneType stoneType;
  final String toPlayerId;
  const BotDistributeDecision(this.stoneType, this.toPlayerId);
}

/// Stateless AI engine for the Bot player.
class BotEngine {
  const BotEngine._();

  /// Determine what action the bot should take right now.
  static BotTurnAction decideTurnAction({
    required GameSessionModel session,
    required String botId,
    required bool isSelectingPassCauser,
  }) {
    final phase = session.phase;

    // Bot is selecting the pass causer (after bot passed when stock was empty)
    if (isSelectingPassCauser && session.pendingPassedPlayerId == botId) {
      return BotTurnAction.selectCauser;
    }

    // Bot is the current distributor
    if (phase == GamePhase.distributing &&
        session.currentDistributorPlayerId == botId) {
      return BotTurnAction.distribute;
    }

    // Bot's turn
    final isItBotTurn = session.currentTurnPlayerId == botId;
    if (isItBotTurn &&
        (phase == GamePhase.initialDraw || phase == GamePhase.playing)) {
      if (session.isVsMode) {
        final hand = session.playerHands[botId] ?? const [];
        final hasMoves = DominoEngine.hasValidMoves(hand, session.dominoChain);
        if (hasMoves) {
          return BotTurnAction.playDomino;
        } else {
          return BotTurnAction.pass;
        }
      } else {
        // Fallback for non-VS (coop), bot always passes
        return BotTurnAction.pass;
      }
    }

    return BotTurnAction.idle;
  }

  /// Select which player is the pass causer.
  ///
  /// Rule: prefer a human player with most stones. If only bots have stones,
  /// pick the bot with most stones.
  static String? selectPassCauser({
    required GameSessionModel session,
    required String botId,
  }) {
    final bots = session.botPlayerIds;
    // First try: human candidates (players who are not bots, excluding passer itself)
    final humanCandidates = session.players
        .where((p) => p.id != botId && !bots.contains(p.id) && p.totalStoneCount > 0)
        .toList();

    if (humanCandidates.isNotEmpty) {
      humanCandidates.sort((a, b) => b.totalStoneCount.compareTo(a.totalStoneCount));
      return humanCandidates.first.id;
    }

    // Fallback: any other player (could be another bot) with stones
    final fallback = session.players
        .where((p) => p.id != botId && p.totalStoneCount > 0)
        .toList();
    if (fallback.isEmpty) return null;
    fallback.sort((a, b) => b.totalStoneCount.compareTo(a.totalStoneCount));
    return fallback.first.id;
  }

  /// Decide which stone to distribute and to whom.
  ///
  /// Strategy:
  /// 1. Prioritize distributing small stones first.
  /// 2. Target = opponent with fewest total stones (spread evenly).
  /// 3. If no small stones left and has big stone → distribute big stone.
  ///    Big stone only distributable when distributor has no small stones
  ///    (matches existing GameRuleUtils.canDistributeBigStone logic).
  static BotDistributeDecision? selectDistribution({
    required GameSessionModel session,
    required String botId,
  }) {
    final bot = session.players.where((p) => p.id == botId).firstOrNull;
    if (bot == null) return null;

    // Potential targets: all other players
    final opponents = session.players.where((p) => p.id != botId).toList();
    if (opponents.isEmpty) return null;

    // Sort by fewest stones first (we want to distribute to player with least)
    opponents.sort((a, b) => a.totalStoneCount.compareTo(b.totalStoneCount));

    final target = opponents.first;

    // Try small stone first
    if (bot.smallStoneCount > 0) {
      return BotDistributeDecision(StoneType.small, target.id);
    }

    // Fall back to big stone if no small stones remain
    if (bot.hasBigStone) {
      return BotDistributeDecision(StoneType.big, target.id);
    }

    // Bot has nothing to distribute (should not happen in valid state)
    return null;
  }
}
