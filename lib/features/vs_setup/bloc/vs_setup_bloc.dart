import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crownpass/core/constants/app_constants.dart';
import 'vs_setup_event.dart';
import 'vs_setup_state.dart';

class VsSetupBloc extends Bloc<VsSetupEvent, VsSetupState> {
  VsSetupBloc() : super(VsSetupState.initial()) {
    on<UpdateVsPlayerName>(_onUpdatePlayerName);
    on<SetVsTotalStones>(_onSetTotalStones);
    on<SubmitVsSetup>(_onSubmitSetup);
  }

  void _onUpdatePlayerName(
      UpdateVsPlayerName event, Emitter<VsSetupState> emit) {
    emit(state.copyWith(playerName: event.name));
  }

  void _onSetTotalStones(SetVsTotalStones event, Emitter<VsSetupState> emit) {
    final clamped = event.totalStones.clamp(AppConstants.minTotalStones, 100);
    emit(state.copyWith(totalStones: clamped));
  }

  void _onSubmitSetup(SubmitVsSetup event, Emitter<VsSetupState> emit) {
    if (!state.isValid) return;
    emit(state.copyWith(isSubmitted: true));
  }
}
