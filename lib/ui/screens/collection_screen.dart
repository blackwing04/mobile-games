import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../engine/models/scenario.dart';
import '../../engine/models/scene.dart';
import '../../providers/game_provider.dart';
import '../../services/unlock_service.dart';
import 'ending_screen.dart';

/// 結局蒐集畫面 — 顯示所有章節 × 所有結局的解鎖狀態。
/// 全解鎖時顯示「23:47 · 起源」super ending 入口。
class CollectionScreen extends ConsumerWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenariosAsync = ref.watch(scenarioListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('結局蒐集')),
      body: scenariosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('載入失敗：$e')),
        data: (scenarios) => _CollectionBody(scenarios: scenarios),
      ),
    );
  }
}

class _CollectionBody extends ConsumerStatefulWidget {
  final List<Scenario> scenarios;
  const _CollectionBody({required this.scenarios});

  @override
  ConsumerState<_CollectionBody> createState() => _CollectionBodyState();
}

class _CollectionBodyState extends ConsumerState<_CollectionBody> {
  Set<String> _unlocked = const {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final unlocked = await ref.read(unlockServiceProvider).getUnlockedKeys();
    if (!mounted) return;
    setState(() {
      _unlocked = unlocked;
      _loaded = true;
    });
  }

  /// 跳過 dev_* prefix scenario (只算正式作品)
  Iterable<Scenario> get _publicScenarios =>
      widget.scenarios.where((s) => !s.id.startsWith('dev_'));

  Iterable<MapEntry<String, Scene>> _endingsOf(Scenario s) =>
      s.scenes.entries.where((e) => e.value.isEnding);

  int get _totalEndings => _publicScenarios.fold(
        0,
        (sum, s) => sum + _endingsOf(s).length,
      );

  int get _unlockedCount {
    var n = 0;
    for (final s in _publicScenarios) {
      for (final e in _endingsOf(s)) {
        if (_unlocked.contains('${s.id}:${e.key}')) n++;
      }
    }
    return n;
  }

  bool get _allUnlocked =>
      _totalEndings > 0 && _unlockedCount == _totalEndings;

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Center(child: CircularProgressIndicator());
    }
    final total = _totalEndings;
    final unlocked = _unlockedCount;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _ProgressBanner(unlocked: unlocked, total: total),
          const SizedBox(height: 16),
          for (final s in _publicScenarios)
            _ScenarioSection(
              scenario: s,
              endings: _endingsOf(s).toList(),
              unlocked: _unlocked,
            ),
          const SizedBox(height: 16),
          _SuperEndingCard(unlocked: _allUnlocked),
        ],
      ),
    );
  }
}

class _ProgressBanner extends StatelessWidget {
  final int unlocked;
  final int total;
  const _ProgressBanner({required this.unlocked, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : unlocked / total;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.menu_book_outlined,
                    size: 18, color: Color(0xFFE0C770)),
                const SizedBox(width: 8),
                const Text('異聞錄收集進度',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFFE0C770),
                      letterSpacing: 2,
                    )),
                const Spacer(),
                Text('$unlocked / $total',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE0C770),
                    )),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 6,
                backgroundColor: const Color(0xFF1C1C1C),
                valueColor:
                    const AlwaysStoppedAnimation(Color(0xFFE0C770)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScenarioSection extends StatelessWidget {
  final Scenario scenario;
  final List<MapEntry<String, Scene>> endings;
  final Set<String> unlocked;

  const _ScenarioSection({
    required this.scenario,
    required this.endings,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    final unlockedHere = endings
        .where((e) => unlocked.contains('${scenario.id}:${e.key}'))
        .length;
    final hasHint = scenario.truthEndingHint != null &&
        scenario.truthEndingHint!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        scenario.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE0C770),
                        ),
                      ),
                    ),
                    Text('$unlockedHere / ${endings.length}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFA0A0A0),
                        )),
                  ],
                ),
                if (scenario.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(scenario.subtitle!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8B1A1A),
                        letterSpacing: 4,
                      )),
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF2A2A2A)),
          // Endings list
          for (final e in endings)
            _EndingTile(
              scene: e.value,
              isUnlocked: unlocked.contains('${scenario.id}:${e.key}'),
              isTruth: scenario.truthEndingId == e.key,
            ),
          // Truth ending hint (collapsed by default)
          if (hasHint) ...[
            const Divider(height: 1, color: Color(0xFF2A2A2A)),
            ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 4),
              leading: const Icon(Icons.lightbulb_outline,
                  size: 18, color: Color(0xFFE0C770)),
              title: const Text('真結局解法提示',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFE0C770),
                    letterSpacing: 2,
                  )),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Text(
                    scenario.truthEndingHint!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFCFCFCF),
                      height: 1.7,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _EndingTile extends StatelessWidget {
  final Scene scene;
  final bool isUnlocked;
  final bool isTruth;

  const _EndingTile({
    required this.scene,
    required this.isUnlocked,
    required this.isTruth,
  });

  Ending get _ending => scene.ending!;

  Color get _accent => switch (_ending.type) {
        'good' => const Color(0xFF81C784),
        'bad' => const Color(0xFF8B0000),
        _ => const Color(0xFFE0C770),
      };

  String get _typeLabel => switch (_ending.type) {
        'good' => '✅',
        'bad' => '❌',
        _ => '⚪',
      };

  void _openPreview(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EndingScreen(
          ending: _ending,
          sceneImage: scene.image,
          viewOnly: true,
          onHome: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isUnlocked) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.lock_outline,
                size: 18, color: Color(0xFF4A4A4A)),
            const SizedBox(width: 12),
            const Text('???',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF666666),
                  letterSpacing: 6,
                )),
            const Spacer(),
            const Text('未解鎖',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF555555),
                  letterSpacing: 2,
                )),
          ],
        ),
      );
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openPreview(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(_typeLabel, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _ending.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _accent,
                      ),
                    ),
                  ),
                  if (isTruth)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.auto_awesome,
                          size: 16, color: Color(0xFFE0C770)),
                    ),
                  const SizedBox(width: 6),
                  Icon(Icons.chevron_right,
                      size: 18, color: Colors.white.withValues(alpha: 0.3)),
                ],
              ),
              if (_ending.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  _ending.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                    height: 1.6,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SuperEndingCard extends StatelessWidget {
  final bool unlocked;
  const _SuperEndingCard({required this.unlocked});

  @override
  Widget build(BuildContext context) {
    if (unlocked) {
      return Card(
        color: const Color(0xFF1A0F0F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF8B1A1A), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, size: 18, color: Color(0xFFE0C770)),
                  SizedBox(width: 8),
                  Text('全結局蒐集完成',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFFE0C770),
                        letterSpacing: 4,
                      )),
                  SizedBox(width: 8),
                  Icon(Icons.star, size: 18, color: Color(0xFFE0C770)),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                '23:47 · 起源',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B1A1A),
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '你拼出了所有故事的碎片。\n那個東西⋯⋯它最初是怎麼出現的？',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFFCFCFCF),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('終章內容開發中⋯⋯'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('進入終章'),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Card(
      color: const Color(0xFF0E0E0E),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.lock_outline,
                size: 32, color: Colors.white.withValues(alpha: 0.2)),
            const SizedBox(height: 12),
            const Text(
              '當你看完所有結局⋯⋯',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
                letterSpacing: 6,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '會有什麼出現？',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF555555),
                letterSpacing: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
