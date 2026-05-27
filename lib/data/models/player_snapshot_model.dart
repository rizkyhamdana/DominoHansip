import 'package:equatable/equatable.dart';

class PlayerSnapshotModel extends Equatable {
  final String playerId;
  final String playerName;
  final int smallStoneCount;
  final bool hasBigStone;
  final int totalStoneCount;
  final int totalPoint;
  final bool isWinner;
  final bool isCrownHolder;
  final bool isHansip;

  const PlayerSnapshotModel({
    required this.playerId,
    required this.playerName,
    required this.smallStoneCount,
    required this.hasBigStone,
    required this.totalStoneCount,
    required this.totalPoint,
    this.isWinner = false,
    this.isCrownHolder = false,
    this.isHansip = false,
  });

  Map<String, dynamic> toJson() => {
        'playerId': playerId,
        'playerName': playerName,
        'smallStoneCount': smallStoneCount,
        'hasBigStone': hasBigStone,
        'totalStoneCount': totalStoneCount,
        'totalPoint': totalPoint,
        'isWinner': isWinner,
        'isCrownHolder': isCrownHolder,
        'isHansip': isHansip,
      };

  factory PlayerSnapshotModel.fromJson(Map<String, dynamic> json) =>
      PlayerSnapshotModel(
        playerId: json['playerId'] as String,
        playerName: json['playerName'] as String,
        smallStoneCount: json['smallStoneCount'] as int,
        hasBigStone: json['hasBigStone'] as bool,
        totalStoneCount: json['totalStoneCount'] as int,
        totalPoint: json['totalPoint'] as int,
        isWinner: (json['isWinner'] as bool?) ?? false,
        isCrownHolder: (json['isCrownHolder'] as bool?) ?? false,
        isHansip: (json['isHansip'] as bool?) ?? false,
      );

  @override
  List<Object?> get props => [
        playerId,
        playerName,
        smallStoneCount,
        hasBigStone,
        totalStoneCount,
        totalPoint,
        isWinner,
        isCrownHolder,
        isHansip,
      ];
}
