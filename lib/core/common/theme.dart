import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    const borderColor = Colors.black;

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
      splashFactory: InkRipple.splashFactory,

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor, width: 2),
        ),
      ),

      // Flutter 3.38+: ThemeData.cardTheme expects CardThemeData?
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: borderColor, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
      ),

      dividerTheme: const DividerThemeData(color: Colors.black12),
    );
  }
}
