import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../engine/models/scenario.dart';
import '../../providers/game_provider.dart';
import '../../services/audio_service.dart';
import '../widgets/choice_button.dart';
import '../widgets/dice_overlay.dart';
import '../widgets/narrative_text.dart';
import '../widgets/resource_bar.dart';
import '../widgets/scene_image.dart';
import 'ending_screen.dart';

class ScenarioScreen extends ConsumerStatefulWidget {
  final Scenario scenario;

  const ScenarioScreen({super.key, required this.scenario});

  @override
  ConsumerState<ScenarioScreen> createState() => _ScenarioScreenState();
}

class _ScenarioScreenState extends ConsumerState<ScenarioScreen> {
  @override
  void initState() {
    super.initState();
    final state = ref.read(gameSessionProvider(widget.scenario));
    final scene = widget.scenario.sceneById(state.currentSceneId)!;
    ref.read(audioServiceProvider).playBgm(scene.bgm);
  }

  @override
  void dispose() {
    ref.read(audioServiceProvider).stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scenario = widget.scenario;
    final state = ref.watch(gameSessionProvider(scenario));
    final notifier = ref.read(gameSessionProvider(scenario).notifier);
    final scene = scenario.sceneById(state.currentSceneId)!;

    ref.listen<String>(
      gameSessionProvider(scenario).select((s) => s.currentSceneId),
      (prev, next) {
        final nextScene = scenario.sceneById(next)!;
        ref.read(audioServiceProvider).playBgm(nextScene.bgm);
      },
    );

    if (scene.isEnding) {
      return EndingScreen(
        ending: scene.ending!,
        sceneImage: scene.image,
        onRestart: notifier.restart,
        onHome: () => Navigator.of(context).pop(),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(scenario.title)),
      body: Stack(
        children: [
          Column(
            children: [
              ResourceBar(defs: scenario.resources, values: state.resources),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SceneImage(assetPath: scene.image),
                      NarrativeText(scene.narrative),
                      const SizedBox(height: 8),
                      ...scene.choices.map(
                        (c) => ChoiceButton(
                          choice: c,
                          scenario: scenario,
                          onPressed: () => notifier.selectChoice(c),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (state.lastRoll != null && state.pendingChoiceLabel != null)
            DiceOverlay(
              result: state.lastRoll!,
              triggerLabel: state.pendingChoiceLabel!,
              onContinue: notifier.dismissDice,
            ),
        ],
      ),
    );
  }
}
