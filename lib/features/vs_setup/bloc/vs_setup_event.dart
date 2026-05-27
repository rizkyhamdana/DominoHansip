import 'package:equatable/equatable.dart';

abstract class VsSetupEvent extends Equatable {
  const VsSetupEvent();

  @override
  List<Object?> get props => [];
}

class UpdateVsPlayerName extends VsSetupEvent {
  final String name;
  const UpdateVsPlayerName(this.name);

  @override
  List<Object?> get props => [name];
}

class SetVsTotalStones extends VsSetupEvent {
  final int totalStones;
  const SetVsTotalStones(this.totalStones);

  @override
  List<Object?> get props => [totalStones];
}

class SubmitVsSetup extends VsSetupEvent {
  const SubmitVsSetup();
}
