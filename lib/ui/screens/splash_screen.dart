import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/audio_service.dart';
import 'home_screen.dart';

/// App 啟動 splash 畫面 — 載入 BGM + scene_start 圖，避免進場後才開始 stream 造成卡頓 / 無聲。
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _splashBgPath = 'assets/images/loading.jpg';
  static const _scene1ImgPath =
      'assets/images/scenarios/demo_office/scene_start.png';
  static const _minSplashDuration = Duration(milliseconds: 3000);

  late final AnimationController _progressController;
  bool _ready = false; // bootstrap 完成等 user tap 才 navigate (iOS audio policy)

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: _minSplashDuration,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    _progressController.forward();

    // 並行三條 — 但 audio 不在 bootstrap 內提前觸發 (iOS Safari 會擋)
    // 改為 user tap 「點擊繼續」時才播 BGM
    await Future.wait([
      precacheImage(const AssetImage(_scene1ImgPath), context)
          .catchError((Object _) {}),
      _progressController.forward().orCancel.catchError((Object _) {}),
    ]);

    if (!mounted) return;
    setState(() => _ready = true);
  }

  Future<void> _enterApp() async {
    if (!_ready) return;
    final audio = ref.read(audioServiceProvider);
    // user tap 觸發了 — 此時 audio context 解鎖 (iOS 也能播)
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
            // 底圖 — 檔案不存在時 fallback 純黑
            Image.asset(
              _splashBgPath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
            // 暗化遮罩，讓文字可讀
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
                  // 進度條 / 點擊繼續 (bootstrap 完成後切換)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: _ready
                          ? const _TapToEnter(key: ValueKey('tap'))
                          : _ProgressIndicator(
                              key: const ValueKey('progress'),
                              controller: _progressController,
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

class _ProgressIndicator extends StatelessWidget {
  final AnimationController controller;
  const _ProgressIndicator({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: controller.value,
                minHeight: 4,
                backgroundColor: const Color(0xFF1C1C1C),
                valueColor:
                    const AlwaysStoppedAnimation(Color(0xFFE0C770)),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${(controller.value * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF888888),
                letterSpacing: 2,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// bootstrap 完成後顯示「點擊任意處繼續」+ 微微脈動效果
/// (iOS Safari 必須先有 user gesture 才能解鎖 audio autoplay)
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
    return FadeTransition(
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
    );
  }
}
