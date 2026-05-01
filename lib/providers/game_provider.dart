import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../engine/ads/ad_hooks.dart';
import '../engine/models/choice.dart';
import '../engine/models/game_state.dart';
import '../engine/models/scenario.dart';
import '../engine/runtime/scenario_loader.dart';
import '../engine/runtime/scenario_runner.dart';

/// 載入 assets/scenarios/*.json — 提供首頁劇本列表
final scenarioListProvider = FutureProvider<List<Scenario>>((ref) async {
  return ScenarioLoader().loadAll();
});

final adHooksProvider = Provider<AdHooks>((ref) => StubAdHooks());

/// 一場遊戲的執行階段狀態 — 進入劇本時建立
class GameSessionNotifier extends StateNotifier<GameState> {
  final ScenarioRunner _runner;
  final AdHooks _ads;

  GameSessionNotifier({
    required Scenario scenario,
    required ScenarioRunner runner,
    required AdHooks ads,
  })  : _runner = runner,
        _ads = ads,
        super(GameState.initial(scenario)) {
    _ads.onScenarioStart(scenario);
  }

  void selectChoice(Choice choice) {
    final next = choice.isCheck
        ? _runner.rollSkillCheck(state, choice)
        : _runner.applyDirectChoice(state, choice);
    // 直接型選項才 follow router (擲骰選項在 dismissDice 才推進場景)
    state = choice.isCheck ? next : _runner.followConditionalNext(next);
  }

  void dismissDice() {
    final dismissed = _runner.dismissDiceResult(state);
    state = _runner.followConditionalNext(dismissed);
  }

  void restart() {
    state = GameState.initial(state.scenario);
    _ads.onScenarioStart(state.scenario);
  }
}

final gameSessionProvider = StateNotifierProvider.family<GameSessionNotifier,
    GameState, Scenario>((ref, scenario) {
  return GameSessionNotifier(
    scenario: scenario,
    runner: ScenarioRunner(),
    ads: ref.read(adHooksProvider),
  );
});
