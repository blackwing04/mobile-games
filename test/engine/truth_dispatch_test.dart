import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'dart:convert';
import 'package:mobile_games/engine/dice/dice_roller.dart';
import 'package:mobile_games/engine/models/game_state.dart';
import 'package:mobile_games/engine/models/scenario.dart';
import 'package:mobile_games/engine/runtime/scenario_runner.dart';

class _Fixed implements DiceRoller {
  final int v;
  _Fixed(this.v);
  @override
  DiceResult roll(int s) => DiceResult(roll: v, skillValue: s, outcome: DiceRoller.classify(v, s));
}

void main() {
  test('truth dispatch: clue>=3 AND san>=50 應走 scene_end_truth', () {
    final json = jsonDecode(File('assets/scenarios/ch01_office.json').readAsStringSync()) as Map<String, dynamic>;
    final demo = Scenario.fromJson(json);
    final runner = ScenarioRunner(diceRoller: _Fixed(1)); // 強制 critical

    // 模擬: 玩家走到 scene_approach、clue=3、san=80 (滿足 truth 條件)
    var state = GameState(
      scenario: demo,
      currentSceneId: 'scene_approach',
      resources: {'san': 80, 'clue': 3},
    );

    // 找選項 1 衝電梯
    final scene = demo.sceneById('scene_approach')!;
    final choice1 = scene.choices.firstWhere((c) => c.label.contains('不管三七'));

    // 擲骰 (強制 critical)
    state = runner.rollSkillCheck(state, choice1);

    // dismissDice (推進 currentSceneId 到 pendingNextSceneId)
    state = runner.dismissDiceResult(state);

    // followConditionalNext
    state = runner.followConditionalNext(state);

    expect(state.currentSceneId, 'scene_end_truth',
        reason: 'clue=3 san=80 (套 critical +15 後 95) 應該觸發 truth dispatch');
  });

  test('truth dispatch 邊界: clue=3 san=50 應走 truth', () {
    final json = jsonDecode(File('assets/scenarios/ch01_office.json').readAsStringSync()) as Map<String, dynamic>;
    final demo = Scenario.fromJson(json);
    final runner = ScenarioRunner(diceRoller: _Fixed(1));

    var state = GameState(
      scenario: demo,
      currentSceneId: 'scene_approach',
      resources: {'san': 50, 'clue': 3},
    );
    final choice1 = demo.sceneById('scene_approach')!.choices.firstWhere((c) => c.label.contains('不管三七'));
    state = runner.rollSkillCheck(state, choice1);
    state = runner.dismissDiceResult(state);
    state = runner.followConditionalNext(state);
    expect(state.currentSceneId, 'scene_end_truth');
  });
}
