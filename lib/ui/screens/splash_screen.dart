import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/audio_service.dart';
import 'home_screen.dart';

/// App 啟動 splash — 真實 step-based 載入進度條
///
/// 每個 bootstrap task 完成 → progress 跳一格。
/// 跟假的「線性 N 秒動畫」不同，進度條真實反映預載完成度。
/// task 全完成才出現「點擊繼續」(iOS audio 解鎖 + navigate)。
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const _splashBgPath = 'assets/images/loading.jpg';
  static const _scene1ImgPath =
      'assets/images/scenarios/demo_office/scene_start.png';
  static const _scene1BgmPath =
      'assets/audio/bgm/the_mountain-lonely.mp3';

  /// 每個 task 對應一段進度
  late final List<_BootTask> _tasks;
  int _completedSteps = 0;
  double get _progress =>
      _tasks.isEmpty ? 0 : _completedSteps / _tasks.length;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tasks = _buildTasks();
      _bootstrap();
    });
  }

  List<_BootTask> _buildTasks() {
    final audio = ref.read(audioServiceProvider);
    return [
      _BootTask('預載開場圖',
          () => precacheImage(const AssetImage(_scene1ImgPath), context)),
      _BootTask('預載主選單音樂',
          () => audio.preloadSource(AudioService.homeBgmPath)),
      _BootTask('預載第一場景音樂',
          () => audio.preloadSource(_scene1BgmPath)),
    ];
  }

  Future<void> _bootstrap() async {
    // 並行跑所有 task，每個完成 (成功 or 失敗) bump 進度
    await Future.wait(_tasks.map((task) async {
      try {
        await task.run();
      } catch (e) {
        // 載入失敗也算「跑完了」(splash 不能因為單一資源 fail 卡死)
      }
      if (mounted) setState(() => _completedSteps++);
    }));

    if (!mounted) return;
    setState(() => _ready = true);
  }

  Future<void> _enterApp() async {
    if (!_ready) return;
    final audio = ref.read(audioServiceProvider);
    // user tap 觸發 — iOS audio context 解鎖、SoLoud play 立刻發聲
    audio.playBgm(AudioService.homeBgmPath);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _enterApp,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              _splashBgPath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
            Container(color: Colors.black.withValues(alpha: 0.55)),
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  const Text(
                    '異聞錄',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE0C770),
                      letterSpacing: 24,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '─ 卷一 · 23:47 ─',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8B1A1A),
                      letterSpacing: 8,
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: _ready
                          ? const _TapToEnter(key: ValueKey('tap'))
                          : _RealProgressIndicator(
                              key: const ValueKey('progress'),
                              progress: _progress,
                            ),
                    ),
                  ),
                  const SizedBox(height: 64),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BootTask {
  final String label;
  final Future<void> Function() run;
  _BootTask(this.label, this.run);
}

class _RealProgressIndicator extends StatelessWidget {
  final double progress;
  const _RealProgressIndicator({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            tween: Tween(begin: 0, end: progress),
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: value,
                minHeight: 4,
                backgroundColor: const Color(0xFF1C1C1C),
                valueColor:
                    const AlwaysStoppedAnimation(Color(0xFFE0C770)),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '載入中⋯⋯ ${(progress * 100).toInt()}%',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF888888),
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

class _TapToEnter extends StatefulWidget {
  const _TapToEnter({super.key});

  @override
  State<_TapToEnter> createState() => _TapToEnterState();
}

class _TapToEnterState extends State<_TapToEnter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FadeTransition(
          opacity: Tween(begin: 0.45, end: 1.0).animate(
            CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
          ),
          child: const Text(
            '點 擊 任 意 處 繼 續',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFE0C770),
              letterSpacing: 6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '🔇 iPhone 玩家：請確認手機靜音開關未開啟',
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.4),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
