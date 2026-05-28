import 'dart:math' as math;

import 'package:crownpass/data/models/domino_tile_model.dart';
import 'package:crownpass/data/models/game_action_model.dart';

enum BotDifficulty {
  easy,
  normal,
  hard,
  expert,
}

class DominoEngine {
  DominoEngine._();

  /// Create a full set of 28 standard double-six domino tiles.
  static List<DominoTileModel> createFullSet() {
    final List<DominoTileModel> tiles = [];
    for (int i = 0; i <= 6; i++) {
      for (int j = i; j <= 6; j++) {
        tiles.add(DominoTileModel(i, j));
      }
    }
    return tiles;
  }

  /// Shuffle a list of domino tiles.
  static List<DominoTileModel> shuffle(List<DominoTileModel> tiles) {
    final rand = math.Random();
    final shuffled = List<DominoTileModel>.from(tiles);
    for (int i = shuffled.length - 1; i > 0; i--) {
      final j = rand.nextInt(i + 1);
      final temp = shuffled[i];
      shuffled[i] = shuffled[j];
      shuffled[j] = temp;
    }
    return shuffled;
  }

  /// Deals 7 tiles to each player.
  /// players: List of player IDs.
  static Map<String, List<DominoTileModel>> dealHands(
    List<String> playerIds,
    List<DominoTileModel> shuffledTiles,
  ) {
    final Map<String, List<DominoTileModel>> hands = {};
    for (int i = 0; i < playerIds.length; i++) {
      final start = i * 7;
      final end = start + 7;
      hands[playerIds[i]] = shuffledTiles.sublist(start, end);
    }
    return hands;
  }

  /// Get the left-most open end value of the chain.
  static int getLeftEnd(List<DominoTileModel> chain) {
    if (chain.isEmpty) return -1;
    if (chain.length == 1) return chain.first.sideA;
    return chain.first.isFlipped ? chain.first.sideB : chain.first.sideA;
  }

  /// Get the right-most open end value of the chain.
  static int getRightEnd(List<DominoTileModel> chain) {
    if (chain.isEmpty) return -1;
    if (chain.length == 1) return chain.first.sideB;
    return chain.last.isFlipped ? chain.last.sideA : chain.last.sideB;
  }

  /// Determine if a player has any valid moves in their hand.
  static bool hasValidMoves(
      List<DominoTileModel> hand, List<DominoTileModel> chain) {
    if (chain.isEmpty) return true; // Any tile is playable on empty chain
    final left = getLeftEnd(chain);
    final right = getRightEnd(chain);
    return hand.any((t) =>
        t.sideA == left ||
        t.sideB == left ||
        t.sideA == right ||
        t.sideB == right);
  }

  /// Check if a specific tile is playable on the left side of the chain.
  static bool canPlayLeft(DominoTileModel tile, List<DominoTileModel> chain) {
    if (chain.isEmpty) return true;
    final left = getLeftEnd(chain);
    return tile.sideA == left || tile.sideB == left;
  }

  /// Check if a specific tile is playable on the right side of the chain.
  static bool canPlayRight(DominoTileModel tile, List<DominoTileModel> chain) {
    if (chain.isEmpty) return true;
    final right = getRightEnd(chain);
    return tile.sideA == right || tile.sideB == right;
  }

  /// Place a tile to the left side of the chain. Returns the placed tile with updated orientation.
  static DominoTileModel placeLeft(
      DominoTileModel tile, List<DominoTileModel> chain) {
    if (chain.isEmpty) return tile;
    final left = getLeftEnd(chain);
    // If sideB matches leftEnd, we place it normally: [sideA | sideB] -> [leftEnd | ...]
    // Outer end becomes sideA. So isFlipped is false.
    if (tile.sideB == left) {
      return tile.copyWith(isFlipped: false);
    }
    // If sideA matches leftEnd, we must flip it: [sideB | sideA] -> [leftEnd | ...]
    // Outer end becomes sideB. So isFlipped is true.
    return tile.copyWith(isFlipped: true);
  }

  /// Place a tile to the right side of the chain. Returns the placed tile with updated orientation.
  static DominoTileModel placeRight(
      DominoTileModel tile, List<DominoTileModel> chain) {
    if (chain.isEmpty) return tile;
    final right = getRightEnd(chain);
    // If sideA matches rightEnd, we place it normally: [... | rightEnd] -> [sideA | sideB]
    // Outer end becomes sideB. So isFlipped is false.
    if (tile.sideA == right) {
      return tile.copyWith(isFlipped: false);
    }
    // If sideB matches rightEnd, we must flip it: [... | rightEnd] -> [sideB | sideA]
    // Outer end becomes sideA. So isFlipped is true.
    return tile.copyWith(isFlipped: true);
  }

  /// Finds the starting player based on the highest double tile in hands.
  /// If no doubles exist (extremely rare), picks player with highest pip tile.
  static String findStartingPlayer(Map<String, List<DominoTileModel>> hands) {
    // Check doubles from 6 down to 0
    for (int d = 6; d >= 0; d--) {
      for (final playerId in hands.keys) {
        final hand = hands[playerId]!;
        if (hand.any((t) => t.isDouble && t.sideA == d)) {
          return playerId;
        }
      }
    }

    // Fallback: highest single tile
    String bestPlayerId = hands.keys.first;
    int maxPip = -1;
    for (final playerId in hands.keys) {
      for (final tile in hands[playerId]!) {
        if (tile.totalPips > maxPip) {
          maxPip = tile.totalPips;
          bestPlayerId = playerId;
        }
      }
    }
    return bestPlayerId;
  }

  /// Finds the highest double (or highest pip tile) in a hand to play as starting tile.
  static DominoTileModel findStartingTile(List<DominoTileModel> hand) {
    // Look for highest double
    for (int d = 6; d >= 0; d--) {
      final doubleTile =
          hand.where((t) => t.isDouble && t.sideA == d).firstOrNull;
      if (doubleTile != null) return doubleTile;
    }
    // Fallback: highest pip tile
    DominoTileModel best = hand.first;
    for (final t in hand) {
      if (t.totalPips > best.totalPips) {
        best = t;
      }
    }
    return best;
  }

  /// AI decision helper. Defaults to expert scoring, but keeps difficulty
  /// configurable so the UI can expose Easy/Normal/Hard/Expert later.
  static Map<String, dynamic>? decideBotPlay({
    required List<DominoTileModel> hand,
    required List<DominoTileModel> chain,
    BotDifficulty difficulty = BotDifficulty.expert,
    String? botId,
    Map<String, int> opponentTileCounts = const {},
    List<GameActionModel> actionLog = const [],
  }) {
    if (hand.isEmpty) return null;

    final validPlays = <_BotMove>[];
    for (final tile in hand) {
      if (canPlayLeft(tile, chain)) {
        validPlays.add(_BotMove(tile: tile, side: 'left'));
      }
      if (canPlayRight(tile, chain)) {
        validPlays.add(_BotMove(tile: tile, side: 'right'));
      }
    }

    if (validPlays.isEmpty) return null;

    if (difficulty == BotDifficulty.easy) {
      final move = validPlays[math.Random().nextInt(validPlays.length)];
      return move.toDecision();
    }

    if (difficulty == BotDifficulty.normal) {
      validPlays.sort((a, b) => b.tile.totalPips.compareTo(a.tile.totalPips));
      return validPlays.first.toDecision();
    }

    final scores = validPlays.map((move) {
      final score = _scoreBotMove(
        move: move,
        hand: hand,
        chain: chain,
        difficulty: difficulty,
        botId: botId,
        opponentTileCounts: opponentTileCounts,
        actionLog: actionLog,
      );
      return MapEntry(move, score);
    }).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final bestScore = scores.first.value;
    final contenders = scores
        .where((entry) => bestScore - entry.value <= 3.0)
        .map((entry) => entry.key)
        .toList();
    final selected = difficulty == BotDifficulty.expert && contenders.length > 1
        ? contenders[math.Random().nextInt(contenders.length)]
        : scores.first.key;

    return selected.toDecision();
  }

  static double _scoreBotMove({
    required _BotMove move,
    required List<DominoTileModel> hand,
    required List<DominoTileModel> chain,
    required BotDifficulty difficulty,
    required String? botId,
    required Map<String, int> opponentTileCounts,
    required List<GameActionModel> actionLog,
  }) {
    final remainingHand = List<DominoTileModel>.from(hand)..remove(move.tile);
    final simulatedChain = _simulatePlacedChain(move, chain);
    final newLeft = getLeftEnd(simulatedChain);
    final newRight = getRightEnd(simulatedChain);
    final isEndgame = hand.length <= 3;

    var score = 0.0;

    // Dump expensive tiles, especially in endgame or blocked-game scenarios.
    score += move.tile.totalPips * (isEndgame ? 3.2 : 1.35);

    // Prefer moves that keep our own next turn alive.
    score += _matchingTileCount(remainingHand, newLeft) * 7.0;
    score += _matchingTileCount(remainingHand, newRight) * 7.0;
    score += _uniqueMatchingPipCount(remainingHand, newLeft, newRight) * 2.5;

    // Avoid leaving ourselves with no obvious follow-up unless we are nearly out.
    if (remainingHand.isNotEmpty &&
        !hasValidMoves(remainingHand, simulatedChain) &&
        !isEndgame) {
      score -= 11.0;
    }

    // Doubles are useful but can become awkward. Play them when they are heavy,
    // helpful, or late; otherwise do not blindly burn flexibility.
    if (move.tile.isDouble) {
      score += isEndgame ? 8.0 : 2.0;
      score += _matchingTileCount(remainingHand, move.tile.sideA) * 2.0;
    }

    if (difficulty == BotDifficulty.hard ||
        difficulty == BotDifficulty.expert) {
      score += _boardControlScore(remainingHand, newLeft, newRight);
      score += _opponentPressureScore(
        botId: botId,
        opponentTileCounts: opponentTileCounts,
        isEndgame: isEndgame,
      );
    }

    if (difficulty == BotDifficulty.expert) {
      score += _passMemoryScore(
        botId: botId,
        actionLog: actionLog,
        left: newLeft,
        right: newRight,
      );
      score -= _inferenceRiskScore(
        botId: botId,
        opponentTileCounts: opponentTileCounts,
        actionLog: actionLog,
        left: newLeft,
        right: newRight,
      );
    }

    // Stable tie breaker: a slight preference for the side that changes less UI
    // unless scoring says otherwise.
    if (move.side == 'right') score += 0.15;

    return score;
  }

  static List<DominoTileModel> _simulatePlacedChain(
    _BotMove move,
    List<DominoTileModel> chain,
  ) {
    final simulated = List<DominoTileModel>.from(chain);
    if (move.side == 'left') {
      simulated.insert(0, placeLeft(move.tile, simulated));
    } else {
      simulated.add(placeRight(move.tile, simulated));
    }
    return simulated;
  }

  static int _matchingTileCount(List<DominoTileModel> hand, int pip) {
    if (pip < 0) return 0;
    return hand.where((tile) => tile.sideA == pip || tile.sideB == pip).length;
  }

  static int _uniqueMatchingPipCount(
    List<DominoTileModel> hand,
    int left,
    int right,
  ) {
    final pips = <int>{if (left >= 0) left, if (right >= 0) right};
    return pips.fold<int>(0, (sum, pip) => sum + _matchingTileCount(hand, pip));
  }

  static double _boardControlScore(
    List<DominoTileModel> remainingHand,
    int left,
    int right,
  ) {
    final leftCount = _matchingTileCount(remainingHand, left);
    final rightCount = _matchingTileCount(remainingHand, right);
    var score = 0.0;

    if (left == right) {
      score += leftCount >= 2 ? 12.0 : -5.0;
    }

    if (leftCount == 0) score -= 4.0;
    if (rightCount == 0) score -= 4.0;
    if (leftCount >= 2) score += 4.0;
    if (rightCount >= 2) score += 4.0;

    return score;
  }

  static double _opponentPressureScore({
    required String? botId,
    required Map<String, int> opponentTileCounts,
    required bool isEndgame,
  }) {
    if (botId == null || opponentTileCounts.isEmpty) return 0.0;

    var score = 0.0;
    for (final entry in opponentTileCounts.entries) {
      if (entry.key == botId) continue;
      final count = entry.value;
      if (count <= 1) {
        score -= isEndgame ? 12.0 : 7.0;
      } else if (count <= 2) {
        score -= isEndgame ? 7.0 : 3.5;
      }
    }
    return score;
  }

  static double _passMemoryScore({
    required String? botId,
    required List<GameActionModel> actionLog,
    required int left,
    required int right,
  }) {
    if (botId == null || actionLog.isEmpty) return 0.0;

    var score = 0.0;
    for (final action in actionLog.reversed.take(18)) {
      final passedPlayerId = action.toPlayerId;
      if (passedPlayerId == null || passedPlayerId == botId) {
        continue;
      }
      final passLeft = action.passLeftEnd;
      final passRight = action.passRightEnd;
      if (passLeft == null || passRight == null) continue;

      if (left == passLeft || left == passRight) score += 5.0;
      if (right == passLeft || right == passRight) score += 5.0;
    }
    return score;
  }

  static double _inferenceRiskScore({
    required String? botId,
    required Map<String, int> opponentTileCounts,
    required List<GameActionModel> actionLog,
    required int left,
    required int right,
  }) {
    if (botId == null || opponentTileCounts.isEmpty) return 0.0;

    final weakPipsByOpponent = <String, Set<int>>{};
    for (final action in actionLog.reversed.take(18)) {
      final passedPlayerId = action.toPlayerId;
      if (passedPlayerId == null || passedPlayerId == botId) {
        continue;
      }
      final weakPips = weakPipsByOpponent.putIfAbsent(
        passedPlayerId,
        () => <int>{},
      );
      final passLeft = action.passLeftEnd;
      final passRight = action.passRightEnd;
      if (passLeft != null) weakPips.add(passLeft);
      if (passRight != null) weakPips.add(passRight);
    }

    var risk = 0.0;
    final exposed = <int>{if (left >= 0) left, if (right >= 0) right};
    for (final entry in opponentTileCounts.entries) {
      if (entry.key == botId) continue;
      final count = entry.value;
      final weakPips = weakPipsByOpponent[entry.key] ?? const <int>{};
      for (final pip in exposed) {
        if (weakPips.contains(pip)) {
          risk -= count <= 2 ? 4.5 : 2.0;
        } else {
          risk += count <= 2 ? 4.0 : 1.2;
        }
      }
    }
    return risk;
  }
}

class _BotMove {
  final DominoTileModel tile;
  final String side;

  const _BotMove({required this.tile, required this.side});

  Map<String, dynamic> toDecision() => {'tile': tile, 'side': side};
}
