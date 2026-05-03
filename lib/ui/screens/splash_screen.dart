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
  static const _minSplashDuration = Duration(milliseconds: 2500);

  late final AnimationController _progressController;

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
    final audio = ref.read(audioServiceProvider);

    // 並行三條 — 全部完成才 navigate:
    //   1. precache 第一場景圖
    //   2. 真 await playBgm — 等 setAsset/play 完成才繼續 (不再 fire-and-forget)
    //      加 5 秒 timeout 防 audio engine 卡死整個 splash
    //   3. 進度條動畫至少跑完 (=_minSplashDuration)
    await Future.wait([
      precacheImage(const AssetImage(_scene1ImgPath), context)
          .catchError((Object _) {}),
      audio
          .playBgm(AudioService.homeBgmPath)
          .timeout(const Duration(seconds: 5), onTimeout: () {})
          .catchError((Object _) {}),
      _progressController.forward().orCancel.catchError((Object _) {}),
    ]);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
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
                // 進度條
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, _) {
                      return Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: _progressController.value,
                              minHeight: 4,
                              backgroundColor: const Color(0xFF1C1C1C),
                              valueColor: const AlwaysStoppedAnimation(
                                Color(0xFFE0C770),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${(_progressController.value * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF888888),
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 64),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
