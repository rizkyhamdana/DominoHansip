import 'package:equatable/equatable.dart';

import 'package:crownpass/data/models/player_snapshot_model.dart';

class RoundResultModel extends Equatable {
  final String id;
  final int roundNumber;
  final String winnerPlayerId;
  final String previousPlayerBeforeWinnerId;
  final String? crownHolderBeforeRound;
  final String? crownHolderAfterRound;
  final String? hansipBeforeRound;
  final String? hansipAfterRound;
  final List<PlayerSnapshotModel> snapshots;
  final DateTime createdAt;

  const RoundResultModel({
    required this.id,
    required this.roundNumber,
    required this.winnerPlayerId,
    required this.previousPlayerBeforeWinnerId,
    this.crownHolderBeforeRound,
    this.crownHolderAfterRound,
    this.hansipBeforeRound,
    this.hansipAfterRound,
    required this.snapshots,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'roundNumber': roundNumber,
        'winnerPlayerId': winnerPlayerId,
        'previousPlayerBeforeWinnerId': previousPlayerBeforeWinnerId,
        'crownHolderBeforeRound': crownHolderBeforeRound,
        'crownHolderAfterRound': crownHolderAfterRound,
        'hansipBeforeRound': hansipBeforeRound,
        'hansipAfterRound': hansipAfterRound,
        'snapshots': snapshots.map((s) => s.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory RoundResultModel.fromJson(Map<String, dynamic> json) =>
      RoundResultModel(
        id: json['id'] as String,
        roundNumber: json['roundNumber'] as int,
        winnerPlayerId: json['winnerPlayerId'] as String,
        previousPlayerBeforeWinnerId:
            json['previousPlayerBeforeWinnerId'] as String,
        crownHolderBeforeRound: json['crownHolderBeforeRound'] as String?,
        crownHolderAfterRound: json['crownHolderAfterRound'] as String?,
        hansipBeforeRound: json['hansipBeforeRound'] as String?,
        hansipAfterRound: json['hansipAfterRound'] as String?,
        snapshots: (json['snapshots'] as List<dynamic>)
            .map((s) => PlayerSnapshotModel.fromJson(s as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  @override
  List<Object?> get props => [
        id,
        roundNumber,
        winnerPlayerId,
        previousPlayerBeforeWinnerId,
        crownHolderBeforeRound,
        crownHolderAfterRound,
        hansipBeforeRound,
        hansipAfterRound,
        snapshots,
        createdAt,
      ];
}
