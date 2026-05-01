import '../dice/dice_roller.dart';
import 'scenario.dart';

/// 遊戲執行階段的不可變狀態快照（搭 Riverpod 用 immutable 風格）
class GameState {
  final Scenario scenario;
  final String currentSceneId;
  final Map<String, int> resources;
  final DiceResult? lastRoll;
  final String? pendingChoiceLabel;

  /// 擲骰結果決定的下一個場景 — 暫存在這，玩家按「繼續」後才推進到 currentSceneId。
  /// 這樣骰子動畫期間 currentSceneId 還是當前場景，不會被 ending screen 攔截。
  final String? pendingNextSceneId;

  /// 本次擲骰造成的資源變動量 (resource id → delta)。
  /// DiceOverlay 用來顯示「🧠 神智 -15」這類提示，按繼續後清空。
  final Map<String, int>? lastRollResourceDeltas;

  const GameState({
    required this.scenario,
    required this.currentSceneId,
    required this.resources,
    this.lastRoll,
    this.pendingChoiceLabel,
    this.pendingNextSceneId,
    this.lastRollResourceDeltas,
  });

  factory GameState.initial(Scenario scenario) {
    return GameState(
      scenario: scenario,
      currentSceneId: scenario.startScene,
      resources: {
        for (final r in scenario.resources) r.id: r.initial,
      },
    );
  }

  GameState copyWith({
    String? currentSceneId,
    Map<String, int>? resources,
    DiceResult? lastRoll,
    String? pendingChoiceLabel,
    String? pendingNextSceneId,
    Map<String, int>? lastRollResourceDeltas,
    bool clearLastRoll = false,
    bool clearPendingChoice = false,
    bool clearPendingNext = false,
    bool clearDeltas = false,
  }) {
    return GameState(
      scenario: scenario,
      currentSceneId: currentSceneId ?? this.currentSceneId,
      resources: resources ?? this.resources,
      lastRoll: clearLastRoll ? null : (lastRoll ?? this.lastRoll),
      pendingChoiceLabel: clearPendingChoice
          ? null
          : (pendingChoiceLabel ?? this.pendingChoiceLabel),
      pendingNextSceneId: clearPendingNext
          ? null
          : (pendingNextSceneId ?? this.pendingNextSceneId),
      lastRollResourceDeltas: clearDeltas
          ? null
          : (lastRollResourceDeltas ?? this.lastRollResourceDeltas),
    );
  }
}
