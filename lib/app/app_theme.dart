import 'package:flutter/material.dart';
import '../shared/theme/theme.dart';

/// 应用主题配置
///
/// 负责：
/// - MaterialApp / CupertinoApp 的主题
/// - 全局 ThemeData 和 ColorScheme
/// - 任何 UI 不应直接定义颜色，都应使用这里的主题
class AppTheme {
  AppTheme._();

  /// Light theme
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        surface: AppColors.background,
        onSurface: AppColors.foreground,
        primary: AppColors.primary,
        onPrimary: AppColors.primaryForeground,
        secondary: AppColors.secondary,
        onSecondary: AppColors.secondaryForeground,
        tertiary: AppColors.accent,
        onTertiary: AppColors.accentForeground,
        error: AppColors.destructive,
        onError: AppColors.destructiveForeground,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.foreground,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.card,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.mutedForeground,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.input,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: _displayLarge,
        displayMedium: _displayMedium,
        displaySmall: _displaySmall,
        headlineLarge: _headlineLarge,
        headlineMedium: _headlineMedium,
        headlineSmall: _headlineSmall,
        titleLarge: _titleLarge,
        titleMedium: _titleMedium,
        titleSmall: _titleSmall,
        bodyLarge: _bodyLarge,
        bodyMedium: _bodyMedium,
        bodySmall: _bodySmall,
        labelLarge: _labelLarge,
        labelMedium: _labelMedium,
        labelSmall: _labelSmall,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.primaryForeground,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.md),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
      ),
    );
  }

  /// Dark theme (预留)
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(),
      scaffoldBackgroundColor: AppColors.zinc950,
    );
  }

  // ============================================================================
  // 文本样式定义
  // ============================================================================

  static const TextStyle _displayLarge = TextStyle(
    fontSize: AppFontSize.display,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -1.5,
  );

  static const TextStyle _displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle _displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    height: 1.3,
    letterSpacing: 0,
  );

  static const TextStyle _headlineLarge = TextStyle(
    fontSize: AppFontSize.h1,
    fontWeight: FontWeight.bold,
    height: 1.4,
    letterSpacing: 0.5,
  );

  static const TextStyle _headlineMedium = TextStyle(
    fontSize: AppFontSize.h2,
    fontWeight: FontWeight.bold,
    height: 1.4,
    letterSpacing: 0.25,
  );

  static const TextStyle _headlineSmall = TextStyle(
    fontSize: AppFontSize.h3,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0,
  );

  static const TextStyle _titleLarge = TextStyle(
    fontSize: AppFontSize.large,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static const TextStyle _titleMedium = TextStyle(
    fontSize: AppFontSize.medium,
    fontWeight: FontWeight.w500,
    height: 1.6,
    letterSpacing: 0.1,
  );

  static const TextStyle _titleSmall = TextStyle(
    fontSize: AppFontSize.small,
    fontWeight: FontWeight.w500,
    height: 1.6,
    letterSpacing: 0.1,
  );

  static const TextStyle _bodyLarge = TextStyle(
    fontSize: AppFontSize.base,
    fontWeight: FontWeight.normal,
    height: 1.5,
    letterSpacing: 0.5,
  );

  static const TextStyle _bodyMedium = TextStyle(
    fontSize: AppFontSize.small,
    fontWeight: FontWeight.normal,
    height: 1.5,
    letterSpacing: 0.25,
  );

  static const TextStyle _bodySmall = TextStyle(
    fontSize: AppFontSize.xs,
    fontWeight: FontWeight.normal,
    height: 1.4,
    letterSpacing: 0.4,
  );

  static const TextStyle _labelLarge = TextStyle(
    fontSize: AppFontSize.small,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static const TextStyle _labelMedium = TextStyle(
    fontSize: AppFontSize.xs,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.5,
  );

  static const TextStyle _labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.5,
  );
}

/// 字体尺寸常量
class AppFontSize {
  AppFontSize._();

  // 显示文本
  static const double display = 57;

  // 标题
  static const double h1 = 32;
  static const double h2 = 28;
  static const double h3 = 24;

  // 正文
  static const double large = 18;
  static const double base = 16;
  static const double medium = 14;
  static const double small = 12;
  static const double xs = 11;
}

/// 间距常量
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}
