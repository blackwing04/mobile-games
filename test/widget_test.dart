import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_games/app.dart';

void main() {
  testWidgets('App 啟動後顯示主選單標題', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MobileGamesApp()));
    await tester.pump();
    expect(find.text('異聞錄'), findsOneWidget);
  });

  testWidgets('App 使用深色 horror 主題', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MobileGamesApp()));
    await tester.pump();
    final BuildContext ctx = tester.element(find.byType(Scaffold));
    final theme = Theme.of(ctx);
    expect(theme.brightness, Brightness.dark);
  });
}
