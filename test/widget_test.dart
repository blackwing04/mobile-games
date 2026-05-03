import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_games/app.dart';
import 'package:mobile_games/services/audio_service.dart';

/// 假 AudioService — test 環境繞過 just_audio platform channel
class _FakeAudioService extends AudioService {
  _FakeAudioService();
  @override
  Future<void> playBgm(String? assetPath) async {}
  @override
  Future<void> preloadBgm(String assetPath) async {}
  @override
  Future<void> preloadSource(String assetPath) async {}
  @override
  Future<void> stopBgm() async {}
  @override
  Future<void> pauseBgm() async {}
  @override
  Future<void> resumeBgm() async {}
  @override
  void playSfx(SfxKey key) {}
  @override
  Future<void> playAmbient(String? assetPath,
      {Duration interval = const Duration(seconds: 3)}) async {}
  @override
  Future<void> stopAmbient() async {}
  @override
  Future<void> stopAll() async {}
  @override
  void dispose() {}
}

Widget _testApp() => ProviderScope(
      overrides: [
        audioServiceProvider.overrideWith((ref) => _FakeAudioService()),
      ],
      child: const MobileGamesApp(),
    );

void main() {
  testWidgets('App 啟動後 Splash 顯示異聞錄標題', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pump();
    expect(find.text('異聞錄'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('App 使用深色 horror 主題', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pump();
    final BuildContext ctx = tester.element(find.byType(Scaffold).first);
    final theme = Theme.of(ctx);
    expect(theme.brightness, Brightness.dark);
    await tester.pumpWidget(const SizedBox());
  });
}
