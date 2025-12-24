import 'package:flutter/material.dart';

/// 应用程序通用主题配置（备用或基础配置）
class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: Colors.black, // 主要动作颜色
      onPrimary: Colors.white,
      secondary: Colors.grey,
      surface: Colors.white,
      onSurface: Colors.black,
      outline: Color(0xFFE5E7EB), // 边框颜色
    ),
    // 导航栏主题
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
    // 底部导航栏主题
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      elevation: 0,
    ),
    // 分割线主题
    dividerTheme: DividerThemeData(
      color: Colors.grey[200],
      thickness: 1,
      space: 1,
    ),
    fontFamily: 'SF Pro Display', // 默认使用系统字体
  );
}
