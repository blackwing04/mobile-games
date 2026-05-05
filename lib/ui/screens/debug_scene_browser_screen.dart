import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../engine/models/choice.dart';
import '../../engine/models/conditional_next.dart';
import '../../engine/models/scenario.dart';
import '../../engine/models/scene.dart';
import '../../providers/game_provider.dart';
import '../../services/audio_service.dart';
import '../widgets/debug_scene_id_chip.dart';

const String _kDebugPassword = 'joeyuan';

/// 開發用場景瀏覽器入口。
///
/// 限定 `kDebugMode == true` — release build 一律 return false 不放行。
/// 由 HomeScreen 標題長按觸發，正確密碼才推進 [DebugSceneBrowserScreen]。
Future<void> showDebugSceneBrowser(BuildContext context) async {
  if (!kDebugMode) return;
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => const _DebugPasswordDialog(),
  );
  if (ok != true) return;
  if (!context.mounted) return;
  await Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const DebugSceneBrowserScreen()),
  );
}

class _DebugPasswordDialog extends StatefulWidget {
  const _DebugPasswordDialog();

  @override
  State<_DebugPasswordDialog> createState() => _DebugPasswordDialogState();
}

class _DebugPasswordDialogState extends State<_DebugPasswordDialog> {
  final _ctrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_ctrl.text.trim() == _kDebugPassword) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _error = '密碼錯誤');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Debug 模式'),
      content: TextField(
        controller: _ctrl,
        obscureText: true,
        autofocus: true,
        decoration: InputDecoration(
          labelText: '密碼',
          errorText: _error,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('取消'),
        ),
        FilledButton(onPressed: _submit, child: const Text('進入')),
      ],
    );
  }
}

class DebugSceneBrowserScreen extends ConsumerStatefulWidget {
  const DebugSceneBrowserScreen({super.key});

  @override
  ConsumerState<DebugSceneBrowserScreen> createState() =>
      _DebugSceneBrowserScreenState();
}

class _DebugSceneBrowserScreenState
    extends ConsumerState<DebugSceneBrowserScreen> {
  Scenario? _selected;
  String _filter = '';

  @override
  void dispose() {
    // 離開瀏覽器時還原 home BGM，避免試聽到的曲子卡在 home
    ref.read(audioServiceProvider).playBgm(AudioService.homeBgmPath);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scenariosAsync = ref.watch(scenarioListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Debug — 場景瀏覽器')),
      body: scenariosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('載入失敗：$e')),
        data: (scenarios) {
          if (scenarios.isEmpty) {
            return const Center(child: Text('沒有劇本'));
          }
          _selected ??= scenarios.first;
          final scenes = _selected!.scenes.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key));
          final filtered = _filter.isEmpty
              ? scenes
              : scenes
                  .where((e) =>
                      e.key.toLowerCase().contains(_filter.toLowerCase()))
                  .toList();

          return Column(
            children: [
              _buildHeader(scenarios, scenes.length, filtered.length),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final entry = filtered[i];
                    return _SceneTile(
                      scenario: _selected!,
                      sceneId: entry.key,
                      scene: entry.value,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(List<Scenario> scenarios, int total, int shown) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButton<Scenario>(
            isExpanded: true,
            value: _selected,
            items: [
              for (final s in scenarios)
                DropdownMenuItem(
                  value: s,
                  child: Text('${s.id} — ${s.title}'),
                ),
            ],
            onChanged: (s) => setState(() {
              _selected = s;
              _filter = '';
            }),
          ),
          TextField(
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: const Icon(Icons.search, size: 18),
              hintText: '搜尋 scene id（共 $total，顯示 $shown）',
              border: const OutlineInputBorder(),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
            onChanged: (v) => setState(() => _filter = v),
          ),
        ],
      ),
    );
  }
}

class _SceneTile extends ConsumerWidget {
  final Scenario scenario;
  final String sceneId;
  final Scene scene;

  const _SceneTile({
    required this.scenario,
    required this.sceneId,
    required this.scene,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isStart = scenario.startScene == sceneId;
    final preview = scene.narrative.isEmpty
        ? '(空 narrative — 通常是 router)'
        : scene.narrative.length > 60
            ? '${scene.narrative.substring(0, 60)}…'
            : scene.narrative;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        title: Wrap(
          spacing: 6,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DebugSceneIdChip(
              sceneId: sceneId,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                fontSize: 14,
              ),
              iconSize: 14,
            ),
            if (isStart) _badge('Start', Colors.green),
            if (scene.isRouter) _badge('Router', Colors.blue),
            if (scene.isEnding)
              _badge('Ending · ${scene.ending!.type}', Colors.orange),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            preview,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ),
        children: [_DetailBody(scenario: scenario, scene: scene)],
      ),
    );
  }
}

Widget _badge(String label, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11),
      ),
    );

class _DetailBody extends ConsumerWidget {
  final Scenario scenario;
  final Scene scene;

  const _DetailBody({required this.scenario, required this.scene});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (scene.image != null) _imageBlock(scene.image!),
          if (scene.bgm != null)
            _audioRow(
              icon: Icons.music_note,
              label: 'BGM',
              path: scene.bgm!,
              onPlay: () => ref.read(audioServiceProvider).playBgm(scene.bgm),
              onStop: () => ref.read(audioServiceProvider).stopBgm(),
            ),
          if (scene.ambient != null)
            _audioRow(
              icon: Icons.surround_sound,
              label: 'Ambient (${scene.ambientIntervalMs}ms)',
              path: scene.ambient!,
            ),
          if (scene.sfxOnEnter != null)
            _audioRow(
              icon: Icons.notifications_active,
              label: 'SFX on enter',
              path: scene.sfxOnEnter!,
            ),
          if (scene.narrative.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text('Narrative',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            SelectableText(scene.narrative,
                style: const TextStyle(fontSize: 13, height: 1.5)),
          ],
          if (scene.choices.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('選項 (${scene.choices.length})',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            for (final c in scene.choices) _ChoiceBlock(choice: c),
          ],
          if (scene.conditionalNext.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Conditional Next (${scene.conditionalNext.length})',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            for (final cn in scene.conditionalNext)
              _conditionalRow(cn),
          ],
          if (scene.ending != null) ...[
            const SizedBox(height: 12),
            const Text('Ending',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${scene.ending!.title}（${scene.ending!.type}）'),
            if (scene.ending!.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: SelectableText(
                  scene.ending!.description,
                  style: const TextStyle(fontSize: 13, height: 1.5),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _imageBlock(String path) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(
          path,
          height: 180,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 80,
            color: Colors.grey[850],
            alignment: Alignment.center,
            child: Text(
              'image not found:\n$path',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ),
        ),
      ),
    );
  }

  Widget _audioRow({
    required IconData icon,
    required String label,
    required String path,
    VoidCallback? onPlay,
    VoidCallback? onStop,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 6),
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ),
          Expanded(
            child: SelectableText(
              path,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
          ),
          if (onPlay != null)
            IconButton(
              icon: const Icon(Icons.play_arrow, size: 18),
              tooltip: '試聽',
              onPressed: onPlay,
            ),
          if (onStop != null)
            IconButton(
              icon: const Icon(Icons.stop, size: 18),
              tooltip: '停止',
              onPressed: onStop,
            ),
        ],
      ),
    );
  }

  Widget _conditionalRow(ConditionalNext cn) {
    final parts = <String>[];
    if (cn.isDefault) parts.add('default');
    if (cn.ifResourceAtLeast != null) {
      parts.add(cn.ifResourceAtLeast!.entries
          .map((e) => '${e.key}≥${e.value}')
          .join(' AND '));
    }
    if (cn.ifResourceBelow != null) {
      parts.add(cn.ifResourceBelow!.entries
          .map((e) => '${e.key}<${e.value}')
          .join(' AND '));
    }
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 2),
      child: Text(
        '• ${parts.join(", ")} → ${cn.next}',
        style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
      ),
    );
  }
}

class _ChoiceBlock extends StatelessWidget {
  final Choice choice;

  const _ChoiceBlock({required this.choice});

  @override
  Widget build(BuildContext context) {
    final lines = <String>[];
    if (choice.isCheck) {
      final sc = choice.skillCheck!;
      lines.add('skill: ${sc.skill}');
      sc.outcomes.forEach((outcome, branch) {
        final fx = branch.effects
            .map((e) => '${e.resource}${e.delta >= 0 ? "+" : ""}${e.delta}')
            .join(', ');
        lines.add(
            '  ${outcome.jsonKey} → ${branch.next}${fx.isEmpty ? "" : " [$fx]"}');
      });
    } else {
      final fx = choice.effects
          .map((e) => '${e.resource}${e.delta >= 0 ? "+" : ""}${e.delta}')
          .join(', ');
      lines.add(
          'direct → ${choice.next}${fx.isEmpty ? "" : " [$fx]"}');
    }
    if (choice.requireResourceAtLeast != null) {
      lines.add(
          '  require: ${choice.requireResourceAtLeast!.entries.map((e) => "${e.key}≥${e.value}").join(", ")}');
    }
    if (choice.hideIfResourceAtLeast != null) {
      lines.add(
          '  hide if: ${choice.hideIfResourceAtLeast!.entries.map((e) => "${e.key}≥${e.value}").join(", ")}');
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(choice.label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          for (final line in lines)
            Text(
              line,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
        ],
      ),
    );
  }
}
