import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    const accent = Color(0xFF8B0000); // 暗紅
    const surface = Color(0xFF121212);
    const cardBg = Color(0xFF1C1C1C);

    return base.copyWith(
      scaffoldBackgroundColor: surface,
      colorScheme: base.colorScheme.copyWith(
        primary: accent,
        secondary: const Color(0xFFE0C770), // 古卷黃
        surface: surface,
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      textTheme: base.textTheme.copyWith(
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          fontSize: 17,
          height: 1.6,
          color: const Color(0xFFE0E0E0),
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          fontSize: 15,
          height: 1.5,
          color: const Color(0xFFCFCFCF),
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: const Color(0xFFE0C770),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cardBg,
          foregroundColor: const Color(0xFFE0E0E0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: const BorderSide(color: Color(0xFF3A3A3A)),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: Color(0xFFE0C770),
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
