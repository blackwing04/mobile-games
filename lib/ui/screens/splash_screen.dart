import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/audio_service.dart';
import 'home_screen.dart';

/// App 啟動 splash 畫面 — 載入 BGM + scene_start 圖，避免進場後才開始 stream 造成卡頓 / 無聲。
///
/// 階段:
///   1. 立即播 home BGM (music engine 開始 buffer)
///   2. precache scene_start 圖 (玩家點劇本第一秒就有圖)
///   3. 至少停留 2 秒給品牌呈現
///   4. 跳 HomeScreen
///
/// 待 user 補 splash 底圖到 assets/images/splash/splash_bg.png 後，
/// 自動取代純文字 placeholder。
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const _splashBgPath = 'assets/images/loading.jpg';
  static const _scene1ImgPath =
      'assets/images/scenarios/demo_office/scene_start.png';
  static const _minSplashDuration = Duration(milliseconds: 2200);

  @override
  void initState() {
    super.initState();
    // 立刻啟動 BGM — audio engine 開始 buffer
    ref.read(audioServiceProvider).playBgm(AudioService.homeBgmPath);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    // 並行: precache 第一場景圖 + 至少 2.2 秒 splash
    await Future.wait([
      precacheImage(const AssetImage(_scene1ImgPath), context).catchError((e) {
        // 圖載入失敗也不卡住啟動
        return;
      }),
      Future.delayed(_minSplashDuration),
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
          // 預留底圖位 — 檔案不存在時 fallback 純黑
          Image.asset(
            _splashBgPath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          // 暗化遮罩，讓文字可讀
          Container(color: Colors.black.withValues(alpha: 0.55)),
          // 標題 + loading
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
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF6B7178),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '載入中⋯⋯',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                    letterSpacing: 4,
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
