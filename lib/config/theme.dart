import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: Colors.black, // Primary action color
      onPrimary: Colors.white,
      secondary: Colors.grey,
      surface: Colors.white,
      onSurface: Colors.black,
      outline: Color(0xFFE5E7EB), // Javascript border-border color approx
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      elevation: 0,
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey[200],
      thickness: 1,
      space: 1,
    ),
    fontFamily: 'SF Pro Display', // Ideally would load this font, using system default for now
  );
}
