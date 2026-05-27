import 'package:equatable/equatable.dart';

import 'package:crownpass/data/models/player_model.dart';

class SettlementPreviewModel extends Equatable {
  final String winnerPlayerId;
  final String previousPlayerBeforeWinnerId;
  final List<PlayerModel> playersAfterBonusStone;
  final List<String> hansipTiePlayerIds;
  final String? suggestedHansipPlayerId;
  final bool willCrownMove;
  final String? nextCrownPlayerId;

  const SettlementPreviewModel({
    required this.winnerPlayerId,
    required this.previousPlayerBeforeWinnerId,
    required this.playersAfterBonusStone,
    required this.hansipTiePlayerIds,
    this.suggestedHansipPlayerId,
    required this.willCrownMove,
    this.nextCrownPlayerId,
  });

  bool get hasHansipTie => hansipTiePlayerIds.length > 1;

  SettlementPreviewModel copyWith({
    String? winnerPlayerId,
    String? previousPlayerBeforeWinnerId,
    List<PlayerModel>? playersAfterBonusStone,
    List<String>? hansipTiePlayerIds,
    String? suggestedHansipPlayerId,
    bool? willCrownMove,
    String? nextCrownPlayerId,
  }) {
    return SettlementPreviewModel(
      winnerPlayerId: winnerPlayerId ?? this.winnerPlayerId,
      previousPlayerBeforeWinnerId:
          previousPlayerBeforeWinnerId ?? this.previousPlayerBeforeWinnerId,
      playersAfterBonusStone:
          playersAfterBonusStone ?? this.playersAfterBonusStone,
      hansipTiePlayerIds: hansipTiePlayerIds ?? this.hansipTiePlayerIds,
      suggestedHansipPlayerId:
          suggestedHansipPlayerId ?? this.suggestedHansipPlayerId,
      willCrownMove: willCrownMove ?? this.willCrownMove,
      nextCrownPlayerId: nextCrownPlayerId ?? this.nextCrownPlayerId,
    );
  }

  Map<String, dynamic> toJson() => {
        'winnerPlayerId': winnerPlayerId,
        'previousPlayerBeforeWinnerId': previousPlayerBeforeWinnerId,
        'playersAfterBonusStone':
            playersAfterBonusStone.map((p) => p.toJson()).toList(),
        'hansipTiePlayerIds': hansipTiePlayerIds,
        'suggestedHansipPlayerId': suggestedHansipPlayerId,
        'willCrownMove': willCrownMove,
        'nextCrownPlayerId': nextCrownPlayerId,
      };

  factory SettlementPreviewModel.fromJson(Map<String, dynamic> json) =>
      SettlementPreviewModel(
        winnerPlayerId: json['winnerPlayerId'] as String,
        previousPlayerBeforeWinnerId:
            json['previousPlayerBeforeWinnerId'] as String,
        playersAfterBonusStone:
            (json['playersAfterBonusStone'] as List<dynamic>)
                .map((p) => PlayerModel.fromJson(p as Map<String, dynamic>))
                .toList(),
        hansipTiePlayerIds: (json['hansipTiePlayerIds'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        suggestedHansipPlayerId: json['suggestedHansipPlayerId'] as String?,
        willCrownMove: json['willCrownMove'] as bool,
        nextCrownPlayerId: json['nextCrownPlayerId'] as String?,
      );

  @override
  List<Object?> get props => [
        winnerPlayerId,
        previousPlayerBeforeWinnerId,
        playersAfterBonusStone,
        hansipTiePlayerIds,
        suggestedHansipPlayerId,
        willCrownMove,
        nextCrownPlayerId,
      ];
}
