import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../engine/models/scenario.dart';
import '../../providers/game_provider.dart';
import '../../services/ad_service.dart';
import '../../services/audio_service.dart';
import 'collection_screen.dart';
import 'credits_screen.dart';
import 'debug_scene_browser_screen.dart';
import 'scenario_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.86);
    ref.read(audioServiceProvider).playBgm(AudioService.homeBgmPath);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openScenario(Scenario scenario) async {
    // 全部章節（含 Ch1）都走 ad gating
    // Premium / Web / cooldown 內 → adService 直接 return true，無感
    // 詳細設計見 docs/MONETIZATION_PLAN.md
    final ok = await ref
        .read(adServiceProvider)
        .ensureAdWatched(context, scenario.id);
    if (!ok || !mounted) return;

    // 強制 invalidate 確保進入劇本時 state 是 fresh GameState.initial
    // (autoDispose family 在某些 timing 下會 race condition 沒釋放)
    ref.invalidate(gameSessionProvider(scenario));
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ScenarioScreen(scenario: scenario)),
    );
    if (mounted) {
      ref.read(audioServiceProvider).playBgm(AudioService.homeBgmPath);
    }
  }

  void _gotoPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scenariosAsync = ref.watch(scenarioListProvider);

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          // Debug: 長按標題開啟場景瀏覽器（release build 直接 noop）
          onLongPress:
              kDebugMode ? () => showDebugSceneBrowser(context) : null,
          child: const Text('異聞錄'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book_outlined),
            tooltip: '結局蒐集',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CollectionScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: '授權與致謝',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CreditsScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: scenariosAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('載入劇本失敗：$e'),
            ),
          ),
          data: (scenarios) {
            if (scenarios.isEmpty) {
              return const Center(child: Text('沒有可玩的劇本'));
            }
            return _buildCarousel(scenarios);
          },
        ),
      ),
    );
  }

  Widget _buildCarousel(List<Scenario> scenarios) {
    final hasPrev = _currentPage > 0;
    final hasNext = _currentPage < scenarios.length - 1;

    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: scenarios.length,
                itemBuilder: (context, index) {
                  return _ScenarioCard(
                    scenario: scenarios[index],
                    onTap: () => _openScenario(scenarios[index]),
                  );
                },
              ),
              if (hasPrev)
                Positioned(
                  left: 0,
                  child: _ArrowButton(
                    icon: Icons.chevron_left,
                    onPressed: () => _gotoPage(_currentPage - 1),
                  ),
                ),
              if (hasNext)
                Positioned(
                  right: 0,
                  child: _ArrowButton(
                    icon: Icons.chevron_right,
                    onPressed: () => _gotoPage(_currentPage + 1),
                  ),
                ),
            ],
          ),
        ),
        if (scenarios.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _PageDots(
              count: scenarios.length,
              current: _currentPage,
            ),
          )
        else
          const SizedBox(height: 16),
      ],
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  final Scenario scenario;
  final VoidCallback onTap;

  const _ScenarioCard({required this.scenario, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _CoverImage(path: scenario.displayCoverImage)),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  children: [
                    Text(
                      scenario.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE0C770),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (scenario.subtitle != null &&
                        scenario.subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        scenario.subtitle!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8B1A1A),
                          letterSpacing: 4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  final String? path;

  const _CoverImage({required this.path});

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty) return const _Placeholder();
    return Image.asset(
      path!,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (_, __, ___) => const _Placeholder(),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C1C1C), Color(0xFF0D0D0D)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.menu_book_outlined,
          size: 48,
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ArrowButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(40),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
          margin: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 32,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  final int count;
  final int current;

  const _PageDots({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFE0C770)
                : const Color(0xFF6B7178),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
