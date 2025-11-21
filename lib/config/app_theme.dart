import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF7C4DFF),
    scaffoldBackgroundColor: const Color(0xFF121212), // Darker background
    cardColor: const Color(0xFF1E1E1E), // Slightly lighter card color

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF7C4DFF),    // Purple for buttons, highlights
      secondary: Color(0xFF00BCD4),   // Cyan for accents
      surface: Color(0xFF1E1E1E),     // Card surfaces
      background: Color(0xFF121212), // Main background
      error: Color(0xFFFF5252),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onError: Colors.black,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      elevation: 0,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7C4DFF),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2C2C2E), // Darker input field
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      labelStyle: TextStyle(color: Colors.grey[400]),
      prefixIconColor: Colors.grey[400],
    ),
    
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
  );
}