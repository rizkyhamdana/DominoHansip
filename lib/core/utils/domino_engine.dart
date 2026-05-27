import 'dart:math' as math;

import 'package:crownpass/data/models/domino_tile_model.dart';

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
  static bool hasValidMoves(List<DominoTileModel> hand, List<DominoTileModel> chain) {
    if (chain.isEmpty) return true; // Any tile is playable on empty chain
    final left = getLeftEnd(chain);
    final right = getRightEnd(chain);
    return hand.any((t) => t.sideA == left || t.sideB == left || t.sideA == right || t.sideB == right);
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
  static DominoTileModel placeLeft(DominoTileModel tile, List<DominoTileModel> chain) {
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
  static DominoTileModel placeRight(DominoTileModel tile, List<DominoTileModel> chain) {
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
      final doubleTile = hand.where((t) => t.isDouble && t.sideA == d).firstOrNull;
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

  /// AI decision helper: picks the best valid tile play.
  /// Strategy: Play the playable tile with the highest pip count to make the hand lighter.
  /// Returns a Map containing 'tile', 'side' ('left' or 'right'), or null if no valid moves.
  static Map<String, dynamic>? decideBotPlay({
    required List<DominoTileModel> hand,
    required List<DominoTileModel> chain,
  }) {
    if (hand.isEmpty) return null;

    final List<Map<String, dynamic>> validPlays = [];

    for (final tile in hand) {
      final leftPlayable = canPlayLeft(tile, chain);
      final rightPlayable = canPlayRight(tile, chain);

      if (leftPlayable) {
        validPlays.add({'tile': tile, 'side': 'left'});
      }
      if (rightPlayable) {
        validPlays.add({'tile': tile, 'side': 'right'});
      }
    }

    if (validPlays.isEmpty) return null;

    // Sort by pip value descending
    validPlays.sort((a, b) {
      final tA = a['tile'] as DominoTileModel;
      final tB = b['tile'] as DominoTileModel;
      return tB.totalPips.compareTo(tA.totalPips);
    });

    return validPlays.first;
  }
}
