import 'package:flutter/material.dart';

class PrisTheme {
  static const primary = Color(0xFF135BEC);
  static const bgDark = Color(0xFF101622);
  static const cardDark = Color(0xFF1C2433);
  static const onSurface = Color(0xFF92A4C9);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDark,
    primaryColor: primary,
    fontFamily: 'Inter',
    cardTheme: CardThemeData(
      color: cardDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}