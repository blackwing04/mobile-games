import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'services/audio_service.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/theme/app_theme.dart';

class MobileGamesApp extends ConsumerStatefulWidget {
  const MobileGamesApp({super.key});

  @override
  ConsumerState<MobileGamesApp> createState() => _MobileGamesAppState();
}

class _MobileGamesAppState extends ConsumerState<MobileGamesApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 恐怖遊戲體驗 — 防止玩家閱讀時螢幕自動鎖屏
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final audio = ref.read(audioServiceProvider);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        audio.pauseBgm();
      case AppLifecycleState.resumed:
        audio.resumeBgm();
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '異聞錄：2347',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      // 桌面瀏覽器寬螢幕限制最大寬度，模擬手機尺寸；手機端 (寬度 < 480dp) 不影響
      builder: (context, child) {
        return ColoredBox(
          color: Colors.black,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: child,
            ),
          ),
        );
      },
      home: const SplashScreen(),
    );
  }
}
