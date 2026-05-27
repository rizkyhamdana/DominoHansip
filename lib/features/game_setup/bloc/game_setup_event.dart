import 'package:equatable/equatable.dart';

abstract class GameSetupEvent extends Equatable {
  const GameSetupEvent();

  @override
  List<Object?> get props => [];
}

class SetPlayerCount extends GameSetupEvent {
  final int count;
  const SetPlayerCount(this.count);

  @override
  List<Object?> get props => [count];
}

class UpdatePlayerName extends GameSetupEvent {
  final int index;
  final String name;
  const UpdatePlayerName(this.index, this.name);

  @override
  List<Object?> get props => [index, name];
}

class UpdatePlayerColor extends GameSetupEvent {
  final int index;
  final int colorValue;
  const UpdatePlayerColor(this.index, this.colorValue);

  @override
  List<Object?> get props => [index, colorValue];
}

class SetTotalStones extends GameSetupEvent {
  final int totalStones;
  const SetTotalStones(this.totalStones);

  @override
  List<Object?> get props => [totalStones];
}

class ToggleDragEnabled extends GameSetupEvent {
  const ToggleDragEnabled();
}

class ToggleHapticEnabled extends GameSetupEvent {
  const ToggleHapticEnabled();
}

class SubmitSetup extends GameSetupEvent {
  const SubmitSetup();
}
