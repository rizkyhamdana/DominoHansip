import 'package:crownpass/data/models/player_model.dart';

class StoneDropData {
  final String fromPlayerId;
  final StoneType stoneType;

  const StoneDropData({
    required this.fromPlayerId,
    required this.stoneType,
  });
}
