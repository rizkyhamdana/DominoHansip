import 'package:equatable/equatable.dart';

import 'package:crownpass/app/theme.dart';
import 'package:crownpass/core/constants/app_constants.dart';

class SetupPlayerDraft extends Equatable {
  final String name;
  final int colorValue;

  const SetupPlayerDraft({required this.name, required this.colorValue});

  SetupPlayerDraft copyWith({String? name, int? colorValue}) =>
      SetupPlayerDraft(
        name: name ?? this.name,
        colorValue: colorValue ?? this.colorValue,
      );

  @override
  List<Object?> get props => [name, colorValue];
}

class GameSetupState extends Equatable {
  final int playerCount;
  final List<SetupPlayerDraft> players;
  final int totalStones;
  final bool isDragEnabled;
  final bool isHapticEnabled;
  final bool isValid;
  final bool isSubmitted;

  const GameSetupState({
    required this.playerCount,
    required this.players,
    required this.totalStones,
    this.isDragEnabled = true,
    this.isHapticEnabled = true,
    this.isValid = true,
    this.isSubmitted = false,
  });

  factory GameSetupState.initial() {
    const count = 4;
    return GameSetupState(
      playerCount: count,
      players: _defaultPlayers(count),
      totalStones: AppConstants.defaultTotalStones,
      isValid: true,
    );
  }

  static List<SetupPlayerDraft> _defaultPlayers(int count) {
    final defaultNames = ['Andi', 'Budi', 'Cika', 'Doni', 'Eka', 'Fani'];
    return List.generate(
      count,
      (i) => SetupPlayerDraft(
        name: defaultNames[i],
        colorValue:
            AppTheme.avatarColors[i % AppTheme.avatarColors.length].toARGB32(),
      ),
    );
  }

  bool _checkValid(List<SetupPlayerDraft> pl, int stones) {
    final allNamed = pl.every((p) => p.name.trim().isNotEmpty);
    final uniqueNames =
        pl.map((p) => p.name.trim().toLowerCase()).toSet().length == pl.length;
    final enoughStones = stones >= pl.length + 1;
    return allNamed && uniqueNames && enoughStones;
  }

  GameSetupState withUpdatedValidation() {
    return copyWith(isValid: _checkValid(players, totalStones));
  }

  GameSetupState copyWith({
    int? playerCount,
    List<SetupPlayerDraft>? players,
    int? totalStones,
    bool? isDragEnabled,
    bool? isHapticEnabled,
    bool? isValid,
    bool? isSubmitted,
  }) {
    return GameSetupState(
      playerCount: playerCount ?? this.playerCount,
      players: players ?? this.players,
      totalStones: totalStones ?? this.totalStones,
      isDragEnabled: isDragEnabled ?? this.isDragEnabled,
      isHapticEnabled: isHapticEnabled ?? this.isHapticEnabled,
      isValid: isValid ?? this.isValid,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }

  @override
  List<Object?> get props => [
        playerCount,
        players,
        totalStones,
        isDragEnabled,
        isHapticEnabled,
        isValid,
        isSubmitted,
      ];
}
