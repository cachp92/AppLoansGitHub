import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color _primaryNavy = Color(0xFF0F172A); // Deep Navy
  static const Color _secondaryBlue = Color(0xFF3B82F6); // Electric Blue
  static const Color _surfaceLight = Color(0xFFF8FAFC); // Off-white
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: _surfaceLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryNavy,
        primary: _primaryNavy,
        secondary: _secondaryBlue,
        background: _surfaceLight,
        brightness: Brightness.light,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          color: _primaryNavy,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          color: _primaryNavy,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF475569), // Slate 600
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _surfaceLight,
        foregroundColor: _primaryNavy,
        centerTitle: false,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: _primaryNavy,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0)), // Slate 200
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)), // Slate 300
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)), // Slate 200
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _secondaryBlue, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _secondaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
  }

  // Dark Theme can be refined later, focusing on Light first as per requirement to be "clean"
  static ThemeData get darkTheme {
     return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryNavy,
        brightness: Brightness.dark,
        surface: const Color(0xFF0F172A),
      ),
      // Keep similiar structure but dark adjusted
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
      ),
    );
  }
}
