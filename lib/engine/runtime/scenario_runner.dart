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

    // 計算本次擲骰造成的 resource 變動 (僅保留有實際變化的 entry)
    final deltas = <String, int>{};
    for (final key in afterOutcomeEffects.keys) {
      final before = state.resources[key] ?? 0;
      final after = afterOutcomeEffects[key]!;
      if (before != after) deltas[key] = after - before;
    }

    return state.copyWith(
      // currentSceneId 保留當前 — 等玩家按「繼續」才推進
      resources: afterOutcomeEffects,
      lastRoll: result,
      pendingChoiceLabel: choice.label,
      pendingNextSceneId: outcome.next ?? state.currentSceneId,
      lastRollResourceDeltas: deltas.isEmpty ? null : deltas,
    );
  }

  /// 玩家按「繼續」結束骰子顯示 — 此時才把場景推進到 pendingNextSceneId
  GameState dismissDiceResult(GameState state) {
    return state.copyWith(
      currentSceneId: state.pendingNextSceneId ?? state.currentSceneId,
      clearLastRoll: true,
      clearPendingChoice: true,
      clearPendingNext: true,
      clearDeltas: true,
    );
  }

  /// 路由器：若當前場景是 router (含 conditional_next 且無 choices)，依資源條件
  /// 連續跳轉直到落到非 router 場景。在 selectChoice / dismissDice 之後呼叫，
  /// router 場景對玩家透明 (UI 不會閃現)。
  ///
  /// 防迴圈：最多 8 跳，超過視為設定錯誤直接停下。
  GameState followConditionalNext(GameState state) {
    var current = state;
    for (var hop = 0; hop < 8; hop++) {
      final scene = current.scenario.sceneById(current.currentSceneId);
      if (scene == null || !scene.isRouter) return current;
      String? nextId;
      for (final rule in scene.conditionalNext) {
        if (rule.matches(current.resources)) {
          nextId = rule.next;
          break;
        }
      }
      if (nextId == null || nextId == current.currentSceneId) return current;
      current = current.copyWith(currentSceneId: nextId);
    }
    return current;
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
