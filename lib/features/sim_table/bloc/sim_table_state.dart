import 'package:equatable/equatable.dart';

import 'package:crownpass/data/models/game_session_model.dart';
import 'package:crownpass/data/models/player_model.dart';

class SimTableState extends Equatable {
  final GameSessionModel session;
  final bool isDragEnabled;
  final bool isHapticEnabled;
  final bool isSelectingPassCauser;

  const SimTableState({
    required this.session,
    this.isDragEnabled = true,
    this.isHapticEnabled = true,
    this.isSelectingPassCauser = false,
  });

  factory SimTableState.initial() => SimTableState(
        session: GameSessionModel.initial(),
      );

  SimTableState copyWith({
    GameSessionModel? session,
    bool? isDragEnabled,
    bool? isHapticEnabled,
    bool? isSelectingPassCauser,
  }) {
    return SimTableState(
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
        'isSelectingPassCauser': isSelectingPassCauser,
      };

  factory SimTableState.fromJson(Map<String, dynamic> json) {
    final session =
        GameSessionModel.fromJson(json['session'] as Map<String, dynamic>);
    final isSelectingPassCauser = (json['isSelectingPassCauser'] as bool?) ??
        (session.phase == GamePhase.distributing &&
            session.pendingPassedPlayerId != null &&
            session.currentDistributorPlayerId == null);

    return SimTableState(
      session: session,
      isDragEnabled: (json['isDragEnabled'] as bool?) ?? true,
      isHapticEnabled: (json['isHapticEnabled'] as bool?) ?? true,
      isSelectingPassCauser: isSelectingPassCauser,
    );
  }

  @override
  List<Object?> get props =>
      [session, isDragEnabled, isHapticEnabled, isSelectingPassCauser];
}
