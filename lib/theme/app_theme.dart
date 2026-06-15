// lib/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  static const Color skyBlue = Color(0xFF4FC3F7);
  static const Color deepBlue = Color(0xFF1565C0);
  static const Color midnightBlue = Color(0xFF0D1B2A);
  static const Color cardDark = Color(0xFF1A2A3A);
  static const Color cardMid = Color(0xFF1E3A5F);
  static const Color accent = Color(0xFFFFB74D);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0BEC5);

  static final LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [midnightBlue, const Color(0xFF0A3D62), const Color(0xFF1A1A2E)],
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: midnightBlue,
    colorScheme: const ColorScheme.dark(
      primary: skyBlue,
      secondary: accent,
      surface: cardDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: textPrimary, fontSize: 72, fontWeight: FontWeight.w200),
      headlineMedium: TextStyle(color: textPrimary, fontSize: 28, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
      labelSmall: TextStyle(color: textSecondary, fontSize: 12),
    ),
  );
}
