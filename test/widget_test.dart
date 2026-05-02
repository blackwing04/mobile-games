import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_games/app.dart';

void main() {
  testWidgets('App 啟動後 Splash 顯示異聞錄標題', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const ProviderScope(child: MobileGamesApp()));
    });
    await tester.pump();
    expect(find.text('異聞錄'), findsOneWidget);
    // 卸載讓 pending timer 對應的 mounted check 變 false，避免 leak
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('App 使用深色 horror 主題', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const ProviderScope(child: MobileGamesApp()));
    });
    await tester.pump();
    final BuildContext ctx = tester.element(find.byType(Scaffold).first);
    final theme = Theme.of(ctx);
    expect(theme.brightness, Brightness.dark);
    await tester.pumpWidget(const SizedBox());
  });
}
