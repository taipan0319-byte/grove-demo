import 'package:flutter/material.dart';

/// GROVE brand palette — warm, organic, community-oriented.
class GroveColors {
  GroveColors._();

  // Core brand colors
  static const forest = Color(0xFF1A3C1F); // primary dark forest green
  static const green = Color(0xFF2C5F2D); // secondary green
  static const gold = Color(0xFFD4A017); // accent gold
  static const cream = Color(0xFFF5F0E8); // warm off-white background
  static const bark = Color(0xFF6B4226); // bark brown

  // Supporting tones used by the tree renderer and UI
  static const barkDark = Color(0xFF4E2F17);
  static const canopyDark = Color(0xFF1E4620);
  static const canopyMid = Color(0xFF2C5F2D);
  static const canopyLight = Color(0xFF4A7C3F);
  static const canopyPale = Color(0xFF7BAA5D);
  static const card = Color(0xFFFFFDF6);
  static const textMuted = Color(0xFF6E6A5E);
  static const goldSoft = Color(0xFFF3E3BC);
  static const greenSoft = Color(0xFFDDE8D4);
}

/// Serif style for headings — Georgia with graceful fallbacks.
TextStyle groveSerif({
  double size = 22,
  FontWeight weight = FontWeight.w700,
  Color color = GroveColors.forest,
  double? height,
  double? letterSpacing,
}) {
  return TextStyle(
    fontFamily: 'Georgia',
    fontFamilyFallback: const ['Times New Roman', 'serif'],
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );
}

ThemeData buildGroveTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: GroveColors.green).copyWith(
    primary: GroveColors.forest,
    secondary: GroveColors.gold,
    surface: GroveColors.cream,
  );
  final base = ThemeData(useMaterial3: true, colorScheme: scheme);
  return base.copyWith(
    scaffoldBackgroundColor: GroveColors.cream,
    appBarTheme: const AppBarTheme(
      backgroundColor: GroveColors.cream,
      foregroundColor: GroveColors.forest,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: GroveColors.forest,
        foregroundColor: GroveColors.cream,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: GroveColors.forest,
      contentTextStyle: TextStyle(color: GroveColors.cream, fontSize: 14),
      behavior: SnackBarBehavior.floating,
    ),
    dividerColor: GroveColors.greenSoft,
  );
}
