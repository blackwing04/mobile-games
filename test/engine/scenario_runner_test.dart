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

void main() {
  late Scenario demo;

  setUpAll(() {
    final raw = File('assets/scenarios/demo_office.json').readAsStringSync();
    demo = ScenarioLoader.parse(raw);
  });

  group('Scenario JSON parsing', () {
    test('demo_office 載入成功，含必要欄位', () {
      expect(demo.id, 'demo_office');
      expect(demo.title, isNotEmpty);
      expect(demo.scenes, isNotEmpty);
      expect(demo.startScene, isNotEmpty);
      expect(demo.scenes.containsKey(demo.startScene), isTrue);
    });

    test('所有 choice 的 next 都指向實際存在的場景', () {
      for (final scene in demo.scenes.values) {
        for (final choice in scene.choices) {
          if (choice.next != null) {
            expect(
              demo.scenes.containsKey(choice.next),
              isTrue,
              reason: '${scene.id} 的選項 "${choice.label}" 指向不存在場景 ${choice.next}',
            );
          }
          if (choice.skillCheck != null) {
            for (final entry in choice.skillCheck!.outcomes.entries) {
              if (entry.value.next != null) {
                expect(
                  demo.scenes.containsKey(entry.value.next),
                  isTrue,
                  reason:
                      '${scene.id} 的檢定結果 ${entry.key} 指向不存在場景 ${entry.value.next}',
                );
              }
            }
          }
        }
      }
    });

    test('所有 skill_check 引用的 skill 都有定義', () {
      final skillIds = demo.skills.map((s) => s.id).toSet();
      for (final scene in demo.scenes.values) {
        for (final choice in scene.choices) {
          if (choice.skillCheck != null) {
            expect(
              skillIds.contains(choice.skillCheck!.skill),
              isTrue,
              reason: '未定義的技能：${choice.skillCheck!.skill}',
            );
          }
        }
      }
    });

    test('demo_office 至少觸發過 5 種 outcome 的劇本分支', () {
      final touched = <DiceOutcome>{};
      for (final scene in demo.scenes.values) {
        for (final choice in scene.choices) {
          if (choice.skillCheck != null) {
            touched.addAll(choice.skillCheck!.outcomes.keys);
          }
        }
      }
      expect(touched, containsAll(DiceOutcome.values));
    });

    test('至少 3 個結局場景', () {
      final endings = demo.scenes.values.where((s) => s.isEnding).toList();
      expect(endings.length, greaterThanOrEqualTo(3));
    });
  });

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
      final scene = runner.currentScene(state);
      final checkChoice = scene.choices.firstWhere((c) => c.isCheck);
      final expectedNext = checkChoice
          .skillCheck!.outcomes[DiceOutcome.criticalSuccess]!.next;
      state = runner.rollSkillCheck(state, checkChoice);
      expect(state.lastRoll?.outcome, DiceOutcome.criticalSuccess);
      expect(state.currentSceneId, expectedNext);
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
