import '../dice/dice_roller.dart';
import 'scenario.dart';

/// 遊戲執行階段的不可變狀態快照（搭 Riverpod 用 immutable 風格）
class GameState {
  final Scenario scenario;
  final String currentSceneId;
  final Map<String, int> resources;
  final DiceResult? lastRoll;
  final String? pendingChoiceLabel;

  const GameState({
    required this.scenario,
    required this.currentSceneId,
    required this.resources,
    this.lastRoll,
    this.pendingChoiceLabel,
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
    bool clearLastRoll = false,
    bool clearPendingChoice = false,
  }) {
    return GameState(
      scenario: scenario,
      currentSceneId: currentSceneId ?? this.currentSceneId,
      resources: resources ?? this.resources,
      lastRoll: clearLastRoll ? null : (lastRoll ?? this.lastRoll),
      pendingChoiceLabel: clearPendingChoice
          ? null
          : (pendingChoiceLabel ?? this.pendingChoiceLabel),
    );
  }
}
