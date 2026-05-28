import 'package:equatable/equatable.dart';

import 'package:crownpass/data/models/player_model.dart';

abstract class SimTableEvent extends Equatable {
  const SimTableEvent();

  @override
  List<Object?> get props => [];
}

class InitializeGame extends SimTableEvent {
  final List<PlayerModel> players;
  final int totalStones;
  final bool isDragEnabled;
  final bool isHapticEnabled;

  const InitializeGame({
    required this.players,
    required this.totalStones,
    this.isDragEnabled = true,
    this.isHapticEnabled = true,
  });

  @override
  List<Object?> get props =>
      [players, totalStones, isDragEnabled, isHapticEnabled];
}

class StartRound extends SimTableEvent {
  const StartRound();
}

class SelectCurrentPlayer extends SimTableEvent {
  final String playerId;
  const SelectCurrentPlayer(this.playerId);

  @override
  List<Object?> get props => [playerId];
}

class PlayerPass extends SimTableEvent {
  final String playerId;
  const PlayerPass(this.playerId);

  @override
  List<Object?> get props => [playerId];
}

class SelectPassCauser extends SimTableEvent {
  final String causerPlayerId;
  const SelectPassCauser(this.causerPlayerId);

  @override
  List<Object?> get props => [causerPlayerId];
}

class SelectStoneForDistribution extends SimTableEvent {
  final StoneType stoneType;
  const SelectStoneForDistribution(this.stoneType);

  @override
  List<Object?> get props => [stoneType];
}

class DistributeSmallStone extends SimTableEvent {
  final String fromPlayerId;
  final String toPlayerId;
  const DistributeSmallStone({
    required this.fromPlayerId,
    required this.toPlayerId,
  });

  @override
  List<Object?> get props => [fromPlayerId, toPlayerId];
}

class DistributeBigStone extends SimTableEvent {
  final String fromPlayerId;
  final String toPlayerId;
  const DistributeBigStone({
    required this.fromPlayerId,
    required this.toPlayerId,
  });

  @override
  List<Object?> get props => [fromPlayerId, toPlayerId];
}

class DropStoneToPlayer extends SimTableEvent {
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

class OpenRoundSettlement extends SimTableEvent {
  const OpenRoundSettlement();
}

class SelectRoundWinner extends SimTableEvent {
  final String winnerPlayerId;
  const SelectRoundWinner(this.winnerPlayerId);

  @override
  List<Object?> get props => [winnerPlayerId];
}

class ConfirmSettlement extends SimTableEvent {
  const ConfirmSettlement();
}

class ResolveHansipTie extends SimTableEvent {
  final String selectedPlayerId;
  const ResolveHansipTie(this.selectedPlayerId);

  @override
  List<Object?> get props => [selectedPlayerId];
}

class StartNextRound extends SimTableEvent {
  const StartNextRound();
}

class UndoLastAction extends SimTableEvent {
  const UndoLastAction();
}

class ResetRound extends SimTableEvent {
  const ResetRound();
}

class ResetGame extends SimTableEvent {
  const ResetGame();
}

class ClearMessage extends SimTableEvent {
  const ClearMessage();
}

class DismissPassCauserSelection extends SimTableEvent {
  const DismissPassCauserSelection();
}

class CancelRoundSettlement extends SimTableEvent {
  const CancelRoundSettlement();
}
