import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'package:mobile_games/engine/dice/dice_roller.dart';
import 'package:mobile_games/engine/models/game_state.dart';
import 'package:mobile_games/engine/models/scenario.dart';
import 'package:mobile_games/engine/runtime/scenario_loader.dart';
import 'package:mobile_games/engine/runtime/scenario_runner.dart';
import 'dart:convert';

class _Fixed implements DiceRoller {
  final int v;
  _Fixed(this.v);
  @override
  DiceResult roll(int s) => DiceResult(roll: v, skillValue: s, outcome: DiceRoller.classify(v, s));
}

void main() {
  test('每個 scene 的 skill_check 強制 fumble 後，dismissDice 推進到的場景是 fumble.next', () async {
    final json = jsonDecode(File('assets/scenarios/demo_office.json').readAsStringSync()) as Map<String, dynamic>;
    final demo = Scenario.fromJson(json);
    final runner = ScenarioRunner(diceRoller: _Fixed(100)); // 100 = 永遠 fumble

    int checked = 0;
    for (final entry in demo.scenes.entries) {
      final scene = entry.value;
      for (final choice in scene.choices) {
        if (!choice.isCheck) continue;
        final fumbleOutcome = choice.skillCheck!.outcomes[DiceOutcome.fumble];
        if (fumbleOutcome?.next == null) continue;

        var state = GameState(scenario: demo, currentSceneId: entry.key, resources: const {});
        state = runner.rollSkillCheck(state, choice);
        // 擲骰後 currentSceneId 應該還沒推進
        expect(state.currentSceneId, entry.key, reason: '${entry.key} 擲骰後應停留');
        expect(state.lastRoll?.outcome, DiceOutcome.fumble);
        expect(state.pendingNextSceneId, fumbleOutcome!.next);

        // 按繼續才推進
        state = runner.dismissDiceResult(state);
        expect(state.currentSceneId, fumbleOutcome.next, reason: '${entry.key} fumble 應推進到 ${fumbleOutcome.next}');
        checked++;
      }
    }
    print('已驗證 $checked 個 fumble 路徑');
  });
}
