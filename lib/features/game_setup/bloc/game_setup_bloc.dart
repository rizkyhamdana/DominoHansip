import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:crownpass/app/theme.dart';
import 'package:crownpass/core/constants/app_constants.dart';
import 'package:crownpass/data/models/player_model.dart';
import 'game_setup_event.dart';
import 'game_setup_state.dart';

const _uuid = Uuid();

class GameSetupBloc extends Bloc<GameSetupEvent, GameSetupState> {
  GameSetupBloc() : super(GameSetupState.initial()) {
    on<SetPlayerCount>(_onSetPlayerCount);
    on<UpdatePlayerName>(_onUpdatePlayerName);
    on<UpdatePlayerColor>(_onUpdatePlayerColor);
    on<SetTotalStones>(_onSetTotalStones);
    on<ToggleDragEnabled>(_onToggleDragEnabled);
    on<ToggleHapticEnabled>(_onToggleHapticEnabled);
    on<SubmitSetup>(_onSubmitSetup);
  }

  void _onSetPlayerCount(SetPlayerCount event, Emitter<GameSetupState> emit) {
    final count =
        event.count.clamp(AppConstants.minPlayers, AppConstants.maxPlayers);
    final currentPlayers = state.players;
    List<SetupPlayerDraft> newPlayers;

    if (count <= currentPlayers.length) {
      newPlayers = currentPlayers.sublist(0, count);
    } else {
      final defaultNames = ['Andi', 'Budi', 'Cika', 'Doni', 'Eka', 'Fani'];
      newPlayers = [
        ...currentPlayers,
        ...List.generate(
          count - currentPlayers.length,
          (i) {
            final idx = currentPlayers.length + i;
            return SetupPlayerDraft(
              name: defaultNames[idx % defaultNames.length],
              colorValue: AppTheme
                  .avatarColors[idx % AppTheme.avatarColors.length].value,
            );
          },
        ),
      ];
    }

    emit(state
        .copyWith(playerCount: count, players: newPlayers)
        .withUpdatedValidation());
  }

  void _onUpdatePlayerName(
      UpdatePlayerName event, Emitter<GameSetupState> emit) {
    final players = List<SetupPlayerDraft>.from(state.players);
    if (event.index < players.length) {
      players[event.index] = players[event.index].copyWith(name: event.name);
    }
    emit(state.copyWith(players: players).withUpdatedValidation());
  }

  void _onUpdatePlayerColor(
      UpdatePlayerColor event, Emitter<GameSetupState> emit) {
    final players = List<SetupPlayerDraft>.from(state.players);
    if (event.index < players.length) {
      final isUsedByOtherPlayer = players.asMap().entries.any((entry) =>
          entry.key != event.index &&
          entry.value.colorValue == event.colorValue);
      if (isUsedByOtherPlayer) return;

      players[event.index] =
          players[event.index].copyWith(colorValue: event.colorValue);
    }
    emit(state.copyWith(players: players).withUpdatedValidation());
  }

  void _onSetTotalStones(SetTotalStones event, Emitter<GameSetupState> emit) {
    final clamped = event.totalStones.clamp(AppConstants.minTotalStones, 100);
    emit(state.copyWith(totalStones: clamped).withUpdatedValidation());
  }

  void _onToggleDragEnabled(
      ToggleDragEnabled event, Emitter<GameSetupState> emit) {
    emit(state.copyWith(isDragEnabled: !state.isDragEnabled));
  }

  void _onToggleHapticEnabled(
      ToggleHapticEnabled event, Emitter<GameSetupState> emit) {
    emit(state.copyWith(isHapticEnabled: !state.isHapticEnabled));
  }

  void _onSubmitSetup(SubmitSetup event, Emitter<GameSetupState> emit) {
    emit(state.copyWith(isSubmitted: true));
  }

  /// Converts draft players to full PlayerModel list for GameTableBloc.
  List<PlayerModel> buildPlayerModels() {
    return state.players.map((draft) {
      return PlayerModel(
        id: _uuid.v4(),
        name: draft.name.trim(),
        avatarColorValue: draft.colorValue,
      );
    }).toList();
  }
}
