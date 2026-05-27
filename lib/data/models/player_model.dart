import 'package:equatable/equatable.dart';

enum StoneType {
  small,
  big;

  String toJson() => name;
  static StoneType fromJson(String value) =>
      StoneType.values.firstWhere((e) => e.name == value);
}

enum GamePhase {
  setup,
  initialDraw,
  playing,
  distributing,
  roundSettlement,
  roundFinished;

  String toJson() => name;
  static GamePhase fromJson(String value) =>
      GamePhase.values.firstWhere((e) => e.name == value);
}

class PlayerModel extends Equatable {
  final String id;
  final String name;
  final int avatarColorValue;
  final int smallStoneCount;
  final bool hasBigStone;
  final int passCount;
  final int winCount;
  final int hansipCount;
  final int crownCount;
  final int totalReceivedStones;
  final int totalDistributedStones;
  final bool hadZeroStoneThisRound;

  const PlayerModel({
    required this.id,
    required this.name,
    required this.avatarColorValue,
    this.smallStoneCount = 0,
    this.hasBigStone = false,
    this.passCount = 0,
    this.winCount = 0,
    this.hansipCount = 0,
    this.crownCount = 0,
    this.totalReceivedStones = 0,
    this.totalDistributedStones = 0,
    this.hadZeroStoneThisRound = false,
  });

  // ── Computed getters ────────────────────────────────────────────────────────
  int get totalStoneCount => smallStoneCount + (hasBigStone ? 1 : 0);
  int get totalPoint => smallStoneCount + (hasBigStone ? 5 : 0);
  bool get hasNoStone => totalStoneCount == 0;

  PlayerModel copyWith({
    String? id,
    String? name,
    int? avatarColorValue,
    int? smallStoneCount,
    bool? hasBigStone,
    int? passCount,
    int? winCount,
    int? hansipCount,
    int? crownCount,
    int? totalReceivedStones,
    int? totalDistributedStones,
    bool? hadZeroStoneThisRound,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarColorValue: avatarColorValue ?? this.avatarColorValue,
      smallStoneCount: smallStoneCount ?? this.smallStoneCount,
      hasBigStone: hasBigStone ?? this.hasBigStone,
      passCount: passCount ?? this.passCount,
      winCount: winCount ?? this.winCount,
      hansipCount: hansipCount ?? this.hansipCount,
      crownCount: crownCount ?? this.crownCount,
      totalReceivedStones: totalReceivedStones ?? this.totalReceivedStones,
      totalDistributedStones:
          totalDistributedStones ?? this.totalDistributedStones,
      hadZeroStoneThisRound:
          hadZeroStoneThisRound ?? this.hadZeroStoneThisRound,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarColorValue': avatarColorValue,
        'smallStoneCount': smallStoneCount,
        'hasBigStone': hasBigStone,
        'passCount': passCount,
        'winCount': winCount,
        'hansipCount': hansipCount,
        'crownCount': crownCount,
        'totalReceivedStones': totalReceivedStones,
        'totalDistributedStones': totalDistributedStones,
        'hadZeroStoneThisRound': hadZeroStoneThisRound,
      };

  factory PlayerModel.fromJson(Map<String, dynamic> json) => PlayerModel(
        id: json['id'] as String,
        name: json['name'] as String,
        avatarColorValue: json['avatarColorValue'] as int,
        smallStoneCount: (json['smallStoneCount'] as int?) ?? 0,
        hasBigStone: (json['hasBigStone'] as bool?) ?? false,
        passCount: (json['passCount'] as int?) ?? 0,
        winCount: (json['winCount'] as int?) ?? 0,
        hansipCount: (json['hansipCount'] as int?) ?? 0,
        crownCount: (json['crownCount'] as int?) ?? 0,
        totalReceivedStones: (json['totalReceivedStones'] as int?) ?? 0,
        totalDistributedStones: (json['totalDistributedStones'] as int?) ?? 0,
        hadZeroStoneThisRound:
            (json['hadZeroStoneThisRound'] as bool?) ?? false,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        avatarColorValue,
        smallStoneCount,
        hasBigStone,
        passCount,
        winCount,
        hansipCount,
        crownCount,
        totalReceivedStones,
        totalDistributedStones,
        hadZeroStoneThisRound,
      ];
}
