import 'package:equatable/equatable.dart';

import 'package:crownpass/data/models/player_model.dart';
import 'package:crownpass/data/models/domino_tile_model.dart';

abstract class GameTableEvent extends Equatable {
  const GameTableEvent();

  @override
  List<Object?> get props => [];
}

class InitializeGame extends GameTableEvent {
  final List<PlayerModel> players;
  final int totalStones;
  final bool isDragEnabled;
  final bool isHapticEnabled;
  final bool isVsMode;
  final List<String> botPlayerIds;

  const InitializeGame({
    required this.players,
    required this.totalStones,
    this.isDragEnabled = true,
    this.isHapticEnabled = true,
    this.isVsMode = false,
    this.botPlayerIds = const [],
  });

  @override
  List<Object?> get props => [
        players,
        totalStones,
        isDragEnabled,
        isHapticEnabled,
        isVsMode,
        botPlayerIds
      ];
}

class StartRound extends GameTableEvent {
  const StartRound();
}

class SelectCurrentPlayer extends GameTableEvent {
  final String playerId;
  const SelectCurrentPlayer(this.playerId);

  @override
  List<Object?> get props => [playerId];
}

class PlayerPass extends GameTableEvent {
  final String playerId;
  const PlayerPass(this.playerId);

  @override
  List<Object?> get props => [playerId];
}

class SelectPassCauser extends GameTableEvent {
  final String causerPlayerId;
  const SelectPassCauser(this.causerPlayerId);

  @override
  List<Object?> get props => [causerPlayerId];
}

class SelectStoneForDistribution extends GameTableEvent {
  final StoneType stoneType;
  const SelectStoneForDistribution(this.stoneType);

  @override
  List<Object?> get props => [stoneType];
}

class DistributeSmallStone extends GameTableEvent {
  final String fromPlayerId;
  final String toPlayerId;
  const DistributeSmallStone({
    required this.fromPlayerId,
    required this.toPlayerId,
  });

  @override
  List<Object?> get props => [fromPlayerId, toPlayerId];
}

class DistributeBigStone extends GameTableEvent {
  final String fromPlayerId;
  final String toPlayerId;
  const DistributeBigStone({
    required this.fromPlayerId,
    required this.toPlayerId,
  });

  @override
  List<Object?> get props => [fromPlayerId, toPlayerId];
}

class DropStoneToPlayer extends GameTableEvent {
  final String fromPlayerId;
  final String toPlayerId;
  final StoneType stoneType;
  const DropStoneToPlayer({
    required this.fromPlayerId,
    required this.toPlayerId,
    required this.stoneType,
  });

  @override
  List<Object?> get props => [fromPlayerId, toPlayerId, stoneType];
}

class OpenRoundSettlement extends GameTableEvent {
  const OpenRoundSettlement();
}

class SelectRoundWinner extends GameTableEvent {
  final String winnerPlayerId;
  const SelectRoundWinner(this.winnerPlayerId);

  @override
  List<Object?> get props => [winnerPlayerId];
}

class ConfirmSettlement extends GameTableEvent {
  const ConfirmSettlement();
}

class ResolveHansipTie extends GameTableEvent {
  final String selectedPlayerId;
  const ResolveHansipTie(this.selectedPlayerId);

  @override
  List<Object?> get props => [selectedPlayerId];
}

class StartNextRound extends GameTableEvent {
  const StartNextRound();
}

class UndoLastAction extends GameTableEvent {
  const UndoLastAction();
}

class ResetRound extends GameTableEvent {
  const ResetRound();
}

class ResetGame extends GameTableEvent {
  const ResetGame();
}

class ClearMessage extends GameTableEvent {
  const ClearMessage();
}

class DismissPassCauserSelection extends GameTableEvent {
  const DismissPassCauserSelection();
}

class CancelRoundSettlement extends GameTableEvent {
  const CancelRoundSettlement();
}

class PlayDominoTile extends GameTableEvent {
  final String playerId;
  final DominoTileModel tile;
  final String side; // 'left' or 'right'

  const PlayDominoTile({
    required this.playerId,
    required this.tile,
    required this.side,
  });

  @override
  List<Object?> get props => [playerId, tile, side];
}

