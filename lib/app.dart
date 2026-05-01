import 'package:flutter/material.dart';

import 'ui/screens/home_screen.dart';
import 'ui/theme/app_theme.dart';

class MobileGamesApp extends StatelessWidget {
  const MobileGamesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '異聞錄',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
