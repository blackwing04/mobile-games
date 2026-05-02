import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../engine/models/scenario.dart';
import '../../engine/models/scene.dart';
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
  final ScrollController _scrollController = ScrollController();

  void _syncSceneAudio(Scene scene) {
    final audio = ref.read(audioServiceProvider);
    audio.playBgm(scene.bgm);
    audio.playAmbient(
      scene.ambient,
      interval: Duration(milliseconds: scene.ambientIntervalMs),
    );
    final sfxKey =
        scene.sfxOnEnter == null ? null : SfxKey.tryParse(scene.sfxOnEnter!);
    if (sfxKey != null) audio.playSfx(sfxKey);
  }

  /// 場景切換時把 ScrollController 拉回頂部，避免長場景的滾動殘留
  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.jumpTo(0);
  }

  @override
  void initState() {
    super.initState();
    final state = ref.read(gameSessionProvider(widget.scenario));
    final scene = widget.scenario.sceneById(state.currentSceneId)!;
    _syncSceneAudio(scene);
  }

  @override
  void dispose() {
    // BGM 留給接手畫面 (HomeScreen) 接手切換 — 零 gap、idempotent 不重啟
    // Ambient (如哭聲循環) 必須停乾淨
    ref.read(audioServiceProvider).stopAmbient();
    _scrollController.dispose();
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
        _syncSceneAudio(scenario.sceneById(next)!);
        _scrollToTop();
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
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Column(
              children: [
                ResourceBar(defs: scenario.resources, values: state.resources),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SceneImage(assetPath: scene.image),
                        NarrativeText(scene.narrative),
                        const SizedBox(height: 8),
                        ...scene.choices
                            .where((c) => c.isVisibleFor(state.resources))
                            .map(
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
                resourceDeltas: state.lastRollResourceDeltas,
                resources: scenario.resources,
              ),
          ],
        ),
      ),
    );
  }
}
