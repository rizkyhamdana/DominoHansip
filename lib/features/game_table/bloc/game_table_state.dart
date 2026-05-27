import 'package:equatable/equatable.dart';

import 'package:crownpass/data/models/game_session_model.dart';

class GameTableState extends Equatable {
  final GameSessionModel session;
  final bool isDragEnabled;
  final bool isHapticEnabled;
  final bool isSelectingPassCauser;

  const GameTableState({
    required this.session,
    this.isDragEnabled = true,
    this.isHapticEnabled = true,
    this.isSelectingPassCauser = false,
  });

  factory GameTableState.initial() => GameTableState(
        session: GameSessionModel.initial(),
      );

  GameTableState copyWith({
    GameSessionModel? session,
    bool? isDragEnabled,
    bool? isHapticEnabled,
    bool? isSelectingPassCauser,
  }) {
    return GameTableState(
      session: session ?? this.session,
      isDragEnabled: isDragEnabled ?? this.isDragEnabled,
      isHapticEnabled: isHapticEnabled ?? this.isHapticEnabled,
      isSelectingPassCauser:
          isSelectingPassCauser ?? this.isSelectingPassCauser,
    );
  }

  Map<String, dynamic> toJson() => {
        'session': session.toJson(),
        'isDragEnabled': isDragEnabled,
        'isHapticEnabled': isHapticEnabled,
      };

  factory GameTableState.fromJson(Map<String, dynamic> json) => GameTableState(
        session:
            GameSessionModel.fromJson(json['session'] as Map<String, dynamic>),
        isDragEnabled: (json['isDragEnabled'] as bool?) ?? true,
        isHapticEnabled: (json['isHapticEnabled'] as bool?) ?? true,
      );

  @override
  List<Object?> get props =>
      [session, isDragEnabled, isHapticEnabled, isSelectingPassCauser];
}
