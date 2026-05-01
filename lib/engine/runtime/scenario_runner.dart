import '../dice/dice_roller.dart';
import '../models/choice.dart';
import '../models/game_state.dart';
import '../models/resource.dart';
import '../models/scene.dart';

/// 純邏輯狀態機：給定 GameState + 玩家動作 → 算出新的 GameState。
/// 不依賴 Flutter（方便單元測試）。
class ScenarioRunner {
  final DiceRoller _diceRoller;

  ScenarioRunner({DiceRoller? diceRoller})
      : _diceRoller = diceRoller ?? DiceRoller();

  Scene currentScene(GameState state) {
    final scene = state.scenario.sceneById(state.currentSceneId);
    if (scene == null) {
      throw StateError('找不到場景：${state.currentSceneId}');
    }
    return scene;
  }

  /// 玩家點選一個非檢定型 choice — 直接前往 next + 套用 effects
  GameState applyDirectChoice(GameState state, Choice choice) {
    if (choice.isCheck) {
      throw ArgumentError('這是檢定型選項，請改用 rollSkillCheck');
    }
    if (choice.next == null) {
      throw ArgumentError('非檢定型選項必須有 next 場景：${choice.label}');
    }
    final newResources = _applyEffects(state.resources, choice.effects);
    return state.copyWith(
      currentSceneId: choice.next,
      resources: newResources,
      clearLastRoll: true,
      clearPendingChoice: true,
    );
  }

  /// 玩家點選檢定型 choice — 擲骰、套用對應結果。
  ///
  /// 場景推進策略：currentSceneId 暫不變，把 outcome.next 存到 pendingNextSceneId；
  /// 等玩家按「繼續」(dismissDiceResult) 才真正推進。這樣骰子動畫期間 UI 還停留在
  /// 當前場景，不會因為 outcome 是 ending 而被 EndingScreen 攔截。
  GameState rollSkillCheck(GameState state, Choice choice) {
    final check = choice.skillCheck;
    if (check == null) {
      throw ArgumentError('此選項沒有 skill_check：${choice.label}');
    }
    final skill = state.scenario.skillById(check.skill);
    if (skill == null) {
      throw StateError('劇本沒有定義技能：${check.skill}');
    }
    final result = _diceRoller.roll(skill.value);
    final outcome = check.outcomeFor(result.outcome);

    final afterChoiceEffects =
        _applyEffects(state.resources, choice.effects);
    final afterOutcomeEffects =
        _applyEffects(afterChoiceEffects, outcome.effects);

    return state.copyWith(
      // currentSceneId 保留當前 — 等玩家按「繼續」才推進
      resources: afterOutcomeEffects,
      lastRoll: result,
      pendingChoiceLabel: choice.label,
      pendingNextSceneId: outcome.next ?? state.currentSceneId,
    );
  }

  /// 玩家按「繼續」結束骰子顯示 — 此時才把場景推進到 pendingNextSceneId
  GameState dismissDiceResult(GameState state) {
    return state.copyWith(
      currentSceneId: state.pendingNextSceneId ?? state.currentSceneId,
      clearLastRoll: true,
      clearPendingChoice: true,
      clearPendingNext: true,
    );
  }

  Map<String, int> _applyEffects(
    Map<String, int> current,
    List<ResourceEffect> effects,
  ) {
    if (effects.isEmpty) return current;
    final next = Map<String, int>.from(current);
    for (final effect in effects) {
      final old = next[effect.resource] ?? 0;
      next[effect.resource] = old + effect.delta;
    }
    return next;
  }
}
