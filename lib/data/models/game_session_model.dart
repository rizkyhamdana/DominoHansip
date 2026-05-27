import 'package:equatable/equatable.dart';

import 'package:crownpass/data/models/player_model.dart';
import 'package:crownpass/data/models/game_action_model.dart';
import 'package:crownpass/data/models/round_result_model.dart';
import 'package:crownpass/data/models/settlement_preview_model.dart';
import 'package:crownpass/data/models/domino_tile_model.dart';

class GameSessionModel extends Equatable {
  final List<PlayerModel> players;
  final int currentRoundNumber;
  final GamePhase phase;
  final List<StoneType> stockStones;
  final String? crownPlayerId;
  final String? hansipPlayerId;
  final String? currentTurnPlayerId;
  final String? currentDistributorPlayerId;
  final String? pendingPassedPlayerId;
  final StoneType? selectedStoneType;
  final List<GameActionModel> actionLog;
  final List<RoundResultModel> roundHistory;
  final SettlementPreviewModel? settlementPreview;
  final String? errorMessage;
  final String? successMessage;
  final int totalStonesConfig;

  final bool isVsMode;
  final List<String> botPlayerIds;

  // Domino-specific fields
  final List<DominoTileModel> dominoChain;
  final Map<String, List<DominoTileModel>> playerHands;
  final int consecutivePassCount;

  const GameSessionModel({
    required this.players,
    required this.currentRoundNumber,
    required this.phase,
    required this.stockStones,
    this.crownPlayerId,
    this.hansipPlayerId,
    this.currentTurnPlayerId,
    this.currentDistributorPlayerId,
    this.pendingPassedPlayerId,
    this.selectedStoneType,
    required this.actionLog,
    required this.roundHistory,
    this.settlementPreview,
    this.errorMessage,
    this.successMessage,
    this.totalStonesConfig = 16,
    this.isVsMode = false,
    this.botPlayerIds = const [],
    this.dominoChain = const [],
    this.playerHands = const {},
    this.consecutivePassCount = 0,
  });

  factory GameSessionModel.initial() => const GameSessionModel(
        players: [],
        currentRoundNumber: 0,
        phase: GamePhase.setup,
        stockStones: [],
        actionLog: [],
        roundHistory: [],
        totalStonesConfig: 16,
        isVsMode: false,
        botPlayerIds: [],
        dominoChain: [],
        playerHands: {},
        consecutivePassCount: 0,
      );

  bool get hasActiveGame => phase != GamePhase.setup && players.isNotEmpty;
  bool isBot(String playerId) => botPlayerIds.contains(playerId);

  int get stockCount => stockStones.length;

  PlayerModel? get crownPlayer => crownPlayerId != null
      ? players.where((p) => p.id == crownPlayerId).firstOrNull
      : null;

  PlayerModel? get hansipPlayer => hansipPlayerId != null
      ? players.where((p) => p.id == hansipPlayerId).firstOrNull
      : null;

  PlayerModel? get currentDistributor => currentDistributorPlayerId != null
      ? players.where((p) => p.id == currentDistributorPlayerId).firstOrNull
      : null;

  GameSessionModel copyWith({
    List<PlayerModel>? players,
    int? currentRoundNumber,
    GamePhase? phase,
    List<StoneType>? stockStones,
    String? crownPlayerId,
    bool clearCrownPlayer = false,
    String? hansipPlayerId,
    bool clearHansipPlayer = false,
    String? currentTurnPlayerId,
    bool clearCurrentTurn = false,
    String? currentDistributorPlayerId,
    bool clearDistributor = false,
    String? pendingPassedPlayerId,
    bool clearPendingPassed = false,
    StoneType? selectedStoneType,
    bool clearSelectedStone = false,
    List<GameActionModel>? actionLog,
    List<RoundResultModel>? roundHistory,
    SettlementPreviewModel? settlementPreview,
    bool clearSettlementPreview = false,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
    int? totalStonesConfig,
    bool? isVsMode,
    List<String>? botPlayerIds,
    List<DominoTileModel>? dominoChain,
    Map<String, List<DominoTileModel>>? playerHands,
    int? consecutivePassCount,
  }) {
    return GameSessionModel(
      players: players ?? this.players,
      currentRoundNumber: currentRoundNumber ?? this.currentRoundNumber,
      phase: phase ?? this.phase,
      stockStones: stockStones ?? this.stockStones,
      crownPlayerId:
          clearCrownPlayer ? null : (crownPlayerId ?? this.crownPlayerId),
      hansipPlayerId:
          clearHansipPlayer ? null : (hansipPlayerId ?? this.hansipPlayerId),
      currentTurnPlayerId: clearCurrentTurn
          ? null
          : (currentTurnPlayerId ?? this.currentTurnPlayerId),
      currentDistributorPlayerId: clearDistributor
          ? null
          : (currentDistributorPlayerId ?? this.currentDistributorPlayerId),
      pendingPassedPlayerId: clearPendingPassed
          ? null
          : (pendingPassedPlayerId ?? this.pendingPassedPlayerId),
      selectedStoneType: clearSelectedStone
          ? null
          : (selectedStoneType ?? this.selectedStoneType),
      actionLog: actionLog ?? this.actionLog,
      roundHistory: roundHistory ?? this.roundHistory,
      settlementPreview: clearSettlementPreview
          ? null
          : (settlementPreview ?? this.settlementPreview),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      totalStonesConfig: totalStonesConfig ?? this.totalStonesConfig,
      isVsMode: isVsMode ?? this.isVsMode,
      botPlayerIds: botPlayerIds ?? this.botPlayerIds,
      dominoChain: dominoChain ?? this.dominoChain,
      playerHands: playerHands ?? this.playerHands,
      consecutivePassCount: consecutivePassCount ?? this.consecutivePassCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'players': players.map((p) => p.toJson()).toList(),
        'currentRoundNumber': currentRoundNumber,
        'phase': phase.toJson(),
        'stockStones': stockStones.map((s) => s.toJson()).toList(),
        'crownPlayerId': crownPlayerId,
        'hansipPlayerId': hansipPlayerId,
        'currentTurnPlayerId': currentTurnPlayerId,
        'currentDistributorPlayerId': currentDistributorPlayerId,
        'pendingPassedPlayerId': pendingPassedPlayerId,
        'selectedStoneType': selectedStoneType?.toJson(),
        'actionLog': actionLog.map((a) => a.toJson()).toList(),
        'roundHistory': roundHistory.map((r) => r.toJson()).toList(),
        'settlementPreview': settlementPreview?.toJson(),
        'errorMessage': errorMessage,
        'successMessage': successMessage,
        'totalStonesConfig': totalStonesConfig,
        'isVsMode': isVsMode,
        'botPlayerIds': botPlayerIds,
        'dominoChain': dominoChain.map((t) => t.toJson()).toList(),
        'playerHands': playerHands.map((k, v) => MapEntry(k, v.map((t) => t.toJson()).toList())),
        'consecutivePassCount': consecutivePassCount,
      };

  factory GameSessionModel.fromJson(Map<String, dynamic> json) =>
      GameSessionModel(
        players: (json['players'] as List<dynamic>)
            .map((p) => PlayerModel.fromJson(p as Map<String, dynamic>))
            .toList(),
        currentRoundNumber: json['currentRoundNumber'] as int,
        phase: GamePhase.fromJson(json['phase'] as String),
        stockStones: (json['stockStones'] as List<dynamic>)
            .map((s) => StoneType.fromJson(s as String))
            .toList(),
        crownPlayerId: json['crownPlayerId'] as String?,
        hansipPlayerId: json['hansipPlayerId'] as String?,
        currentTurnPlayerId: json['currentTurnPlayerId'] as String?,
        currentDistributorPlayerId:
            json['currentDistributorPlayerId'] as String?,
        pendingPassedPlayerId: json['pendingPassedPlayerId'] as String?,
        selectedStoneType: json['selectedStoneType'] != null
            ? StoneType.fromJson(json['selectedStoneType'] as String)
            : null,
        actionLog: (json['actionLog'] as List<dynamic>)
            .map((a) => GameActionModel.fromJson(a as Map<String, dynamic>))
            .toList(),
        roundHistory: (json['roundHistory'] as List<dynamic>)
            .map((r) => RoundResultModel.fromJson(r as Map<String, dynamic>))
            .toList(),
        settlementPreview: json['settlementPreview'] != null
            ? SettlementPreviewModel.fromJson(
                json['settlementPreview'] as Map<String, dynamic>)
            : null,
        errorMessage: json['errorMessage'] as String?,
        successMessage: json['successMessage'] as String?,
        totalStonesConfig: (json['totalStonesConfig'] as int?) ?? 16,
        isVsMode: (json['isVsMode'] as bool?) ?? false,
        botPlayerIds:
            (json['botPlayerIds'] as List<dynamic>?)?.cast<String>() ??
            (json['botPlayerId'] != null ? [json['botPlayerId'] as String] : []),
        dominoChain: (json['dominoChain'] as List<dynamic>?)
                ?.map((t) => DominoTileModel.fromJson(t as Map<String, dynamic>))
                .toList() ??
            const [],
        playerHands: (json['playerHands'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(
                k,
                (v as List<dynamic>)
                    .map((t) => DominoTileModel.fromJson(t as Map<String, dynamic>))
                    .toList(),
              ),
            ) ??
            const {},
        consecutivePassCount: (json['consecutivePassCount'] as int?) ?? 0,
      );

  @override
  List<Object?> get props => [
        players,
        currentRoundNumber,
        phase,
        stockStones,
        crownPlayerId,
        hansipPlayerId,
        currentTurnPlayerId,
        currentDistributorPlayerId,
        pendingPassedPlayerId,
        selectedStoneType,
        actionLog,
        roundHistory,
        settlementPreview,
        errorMessage,
        successMessage,
        totalStonesConfig,
        isVsMode,
        botPlayerIds,
        dominoChain,
        playerHands,
        consecutivePassCount,
      ];
}
