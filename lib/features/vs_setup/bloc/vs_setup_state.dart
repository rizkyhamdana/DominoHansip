import 'package:equatable/equatable.dart';

import 'package:crownpass/core/constants/app_constants.dart';

class VsSetupState extends Equatable {
  final String playerName;
  final int totalStones;
  final bool isSubmitted;

  const VsSetupState({
    required this.playerName,
    required this.totalStones,
    this.isSubmitted = false,
  });

  factory VsSetupState.initial() => const VsSetupState(
        playerName: 'Rizky',
        totalStones: AppConstants.defaultTotalStones,
      );

  bool get isValid =>
      playerName.trim().isNotEmpty &&
      totalStones >= AppConstants.minTotalStones;

  VsSetupState copyWith({
    String? playerName,
    int? totalStones,
    bool? isSubmitted,
  }) {
    return VsSetupState(
      playerName: playerName ?? this.playerName,
      totalStones: totalStones ?? this.totalStones,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }

  @override
  List<Object?> get props => [playerName, totalStones, isSubmitted];
}
