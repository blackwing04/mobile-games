import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_games/engine/dice/dice_roller.dart';
import 'package:mobile_games/engine/models/game_state.dart';
import 'package:mobile_games/engine/models/scenario.dart';
import 'package:mobile_games/engine/runtime/scenario_loader.dart';
import 'package:mobile_games/engine/runtime/scenario_runner.dart';

/// 固定的擲骰：直接回傳指定 outcome
class _FixedDiceRoller extends DiceRoller {
  final int forcedRoll;
  _FixedDiceRoller(this.forcedRoll) : super(Random(0));

  @override
  DiceResult roll(int skillValue) => DiceResult(
        roll: forcedRoll,
        skillValue: skillValue,
        outcome: DiceRoller.classify(forcedRoll, skillValue),
      );
}

Scenario _loadFromFile(String path) =>
    ScenarioLoader.parse(File(path).readAsStringSync());

/// 對單一 scenario 跑 JSON 完整性檢查 — 場景指針、技能引用、conditional_next 都驗到
void _runScenarioIntegrityChecks(String name, Scenario s) {
  group('$name JSON integrity', () {
    test('$name 載入成功，含必要欄位', () {
      expect(s.id, isNotEmpty);
      expect(s.title, isNotEmpty);
      expect(s.scenes, isNotEmpty);
      expect(s.startScene, isNotEmpty);
      expect(s.scenes.containsKey(s.startScene), isTrue,
          reason: '$name 的 start_scene "${s.startScene}" 不存在於 scenes');
    });

    test('$name 所有 choice / skill_check / conditional_next 的 next 都指向實際存在的場景',
        () {
      for (final scene in s.scenes.values) {
        for (final choice in scene.choices) {
          if (choice.next != null) {
            expect(
              s.scenes.containsKey(choice.next),
              isTrue,
              reason:
                  '$name ${scene.id} 的選項 "${choice.label}" 指向不存在場景 ${choice.next}',
            );
          }
          if (choice.skillCheck != null) {
            for (final entry in choice.skillCheck!.outcomes.entries) {
              if (entry.value.next != null) {
                expect(
                  s.scenes.containsKey(entry.value.next),
                  isTrue,
                  reason:
                      '$name ${scene.id} 的檢定結果 ${entry.key} 指向不存在場景 ${entry.value.next}',
                );
              }
            }
          }
        }
        for (final cn in scene.conditionalNext) {
          expect(
            s.scenes.containsKey(cn.next),
            isTrue,
            reason: '$name ${scene.id} 的 conditional_next 指向不存在場景 ${cn.next}',
          );
        }
      }
    });

    test('$name 所有 skill_check 引用的 skill 都有定義', () {
      final skillIds = s.skills.map((sk) => sk.id).toSet();
      for (final scene in s.scenes.values) {
        for (final choice in scene.choices) {
          if (choice.skillCheck != null) {
            expect(
              skillIds.contains(choice.skillCheck!.skill),
              isTrue,
              reason: '$name 未定義的技能：${choice.skillCheck!.skill}',
            );
          }
        }
      }
    });

    test('$name 至少觸發過 5 種 outcome 的劇本分支', () {
      final touched = <DiceOutcome>{};
      for (final scene in s.scenes.values) {
        for (final choice in scene.choices) {
          if (choice.skillCheck != null) {
            touched.addAll(choice.skillCheck!.outcomes.keys);
          }
        }
      }
      expect(touched, containsAll(DiceOutcome.values));
    });

    test('$name 至少 3 個結局場景', () {
      final endings = s.scenes.values.where((sc) => sc.isEnding).toList();
      expect(endings.length, greaterThanOrEqualTo(3));
    });

    test('$name truth_ending_id (若有) 指向真的存在的結局', () {
      if (s.truthEndingId == null) return;
      final scene = s.scenes[s.truthEndingId];
      expect(scene, isNotNull,
          reason: '$name truth_ending_id "${s.truthEndingId}" 不存在');
      expect(scene!.isEnding, isTrue,
          reason: '$name truth_ending_id "${s.truthEndingId}" 不是結局場景');
    });

    test('$name 所有 conditional_next 都有兜底 default 規則', () {
      for (final scene in s.scenes.values) {
        if (scene.conditionalNext.isEmpty) continue;
        final hasDefault = scene.conditionalNext.any((cn) => cn.isDefault);
        expect(hasDefault, isTrue,
            reason: '$name router 場景 ${scene.id} 缺少 default 規則 (玩家可能卡死)');
      }
    });
  });
}

void main() {
  // 在 main() 同步階段就 load (因為 group()/test() 是 registration-time 立即註冊，
  // setUpAll 會晚於 group registration 執行 → 不能在 setUpAll 裡 load)
  final demo = _loadFromFile('assets/scenarios/demo_office.json');
  final ch02 = _loadFromFile('assets/scenarios/ch02_school.json');

  _runScenarioIntegrityChecks('demo_office', demo);
  _runScenarioIntegrityChecks('ch02_school', ch02);

  group('ScenarioRunner', () {
    test('初始狀態：current = startScene、資源為各自 initial', () {
      final state = GameState.initial(demo);
      expect(state.currentSceneId, demo.startScene);
      for (final r in demo.resources) {
        expect(state.resources[r.id], r.initial);
      }
    });

    test('非檢定型選項：直接前往 next 並套用 effects', () {
      final runner = ScenarioRunner();
      var state = GameState.initial(demo);
      final scene = runner.currentScene(state);
      // 找一個非檢定的選項
      final directChoice = scene.choices.firstWhere((c) => !c.isCheck);
      state = runner.applyDirectChoice(state, directChoice);
      expect(state.currentSceneId, directChoice.next);
    });

    test('檢定型選項用大成功路徑時，會推進到對應 next 場景', () {
      // 強制擲到 1 → 任何 skill 都是 critical_success
      final runner = ScenarioRunner(diceRoller: _FixedDiceRoller(1));
      var state = GameState.initial(demo);
      final startSceneId = state.currentSceneId;
      final scene = runner.currentScene(state);
      final checkChoice = scene.choices.firstWhere((c) => c.isCheck);
      final expectedNext = checkChoice
          .skillCheck!.outcomes[DiceOutcome.criticalSuccess]!.next;
      state = runner.rollSkillCheck(state, checkChoice);
      expect(state.lastRoll?.outcome, DiceOutcome.criticalSuccess);
      // 擲骰後 currentSceneId 暫不變，pendingNextSceneId 暫存目標場景
      expect(state.currentSceneId, startSceneId);
      expect(state.pendingNextSceneId, expectedNext);
      // 玩家按「繼續」(dismissDiceResult) 才推進
      state = runner.dismissDiceResult(state);
      expect(state.currentSceneId, expectedNext);
      expect(state.pendingNextSceneId, isNull);
    });

    test('檢定型選項用大失敗路徑時，會推進並套用負面 effects', () {
      // 強制擲到 100 → 任何 skill 都是 fumble
      final runner = ScenarioRunner(diceRoller: _FixedDiceRoller(100));
      var state = GameState.initial(demo);
      final scene = runner.currentScene(state);
      final checkChoice = scene.choices.firstWhere((c) => c.isCheck);
      final fumble = checkChoice.skillCheck!.outcomes[DiceOutcome.fumble]!;
      final beforeSan = state.resources['san'] ?? 0;
      state = runner.rollSkillCheck(state, checkChoice);
      expect(state.lastRoll?.outcome, DiceOutcome.fumble);
      // 如果 fumble 對 san 有負面效果，state 應反映
      final delta = fumble.effects
          .where((e) => e.resource == 'san')
          .fold<int>(0, (a, e) => a + e.delta);
      expect(state.resources['san'], beforeSan + delta);
    });

    test('dismissDiceResult 會清除 lastRoll 與 pendingChoiceLabel', () {
      final runner = ScenarioRunner(diceRoller: _FixedDiceRoller(50));
      var state = GameState.initial(demo);
      final checkChoice =
          runner.currentScene(state).choices.firstWhere((c) => c.isCheck);
      state = runner.rollSkillCheck(state, checkChoice);
      expect(state.lastRoll, isNotNull);
      state = runner.dismissDiceResult(state);
      expect(state.lastRoll, isNull);
      expect(state.pendingChoiceLabel, isNull);
    });
  });
}
