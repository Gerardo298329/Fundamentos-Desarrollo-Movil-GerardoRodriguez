import 'package:flutter/material.dart';

class AppTheme {
  static const Color seed = Color(0xFF00796B);

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: seed),
    appBarTheme: const AppBarTheme(centerTitle: true),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}