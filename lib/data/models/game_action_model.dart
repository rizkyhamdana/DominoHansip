import 'package:equatable/equatable.dart';

import 'package:crownpass/data/models/player_model.dart';

class GameActionModel extends Equatable {
  final String id;
  final String type;
  final String description;
  final String? fromPlayerId;
  final String? toPlayerId;
  final StoneType? stoneType;
  final int? passLeftEnd;
  final int? passRightEnd;
  final DateTime createdAt;

  const GameActionModel({
    required this.id,
    required this.type,
    required this.description,
    this.fromPlayerId,
    this.toPlayerId,
    this.stoneType,
    this.passLeftEnd,
    this.passRightEnd,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'description': description,
        'fromPlayerId': fromPlayerId,
        'toPlayerId': toPlayerId,
        'stoneType': stoneType?.toJson(),
        'passLeftEnd': passLeftEnd,
        'passRightEnd': passRightEnd,
        'createdAt': createdAt.toIso8601String(),
      };

  factory GameActionModel.fromJson(Map<String, dynamic> json) =>
      GameActionModel(
        id: json['id'] as String,
        type: json['type'] as String,
        description: json['description'] as String,
        fromPlayerId: json['fromPlayerId'] as String?,
        toPlayerId: json['toPlayerId'] as String?,
        stoneType: json['stoneType'] != null
            ? StoneType.fromJson(json['stoneType'] as String)
            : null,
        passLeftEnd: json['passLeftEnd'] as int?,
        passRightEnd: json['passRightEnd'] as int?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  @override
  List<Object?> get props => [
        id,
        type,
        description,
        fromPlayerId,
        toPlayerId,
        stoneType,
        passLeftEnd,
        passRightEnd,
        createdAt,
      ];
}
