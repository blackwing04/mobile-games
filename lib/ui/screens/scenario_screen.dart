import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../engine/models/scenario.dart';
import '../../providers/game_provider.dart';
import '../widgets/choice_button.dart';
import '../widgets/dice_overlay.dart';
import '../widgets/narrative_text.dart';
import '../widgets/resource_bar.dart';
import '../widgets/scene_image.dart';
import 'ending_screen.dart';

class ScenarioScreen extends ConsumerWidget {
  final Scenario scenario;

  const ScenarioScreen({super.key, required this.scenario});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameSessionProvider(scenario));
    final notifier = ref.read(gameSessionProvider(scenario).notifier);
    final scene = scenario.sceneById(state.currentSceneId)!;

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
