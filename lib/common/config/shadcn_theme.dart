import 'package:flutter/material.dart';

/// 受到 Shadcn 设计系统启发的主题颜色定义
class ShadcnColors {
  // 完整的 Zinc (锌色) 调色板，用于构建界面的基础色调
  static const Color zinc50 = Color(0xFFFAFAFA);
  static const Color zinc100 = Color(0xFFF4F4F5);
  static const Color zinc200 = Color(0xFFE4E4E7);
  static const Color zinc300 = Color(0xFFD4D4D8);
  static const Color zinc400 = Color(0xFFA1A1AA);
  static const Color zinc500 = Color(0xFF71717A);
  static const Color zinc600 = Color(0xFF52525B);
  static const Color zinc700 = Color(0xFF3F3F46);
  static const Color zinc800 = Color(0xFF27272A);
  static const Color zinc900 = Color(0xFF18181B);
  static const Color zinc950 = Color(0xFF09090B);

  // 语义化颜色，用于描述组件在不同状态下的颜色
  static const Color background = Colors.white; // 背景色
  static const Color foreground = zinc950; // 前景色（文本等）

  static const Color card = Colors.white; // 卡片背景色
  static const Color cardForeground = zinc950; // 卡片前景色

  static const Color popover = Colors.white; // 弹出框背景色
  static const Color popoverForeground = zinc950; // 弹出框前景色

  static const Color primary = zinc900; // 主色调
  static const Color primaryForeground = zinc50; // 主色调上的前景色

  static const Color secondary = zinc100; // 次要色调
  static const Color secondaryForeground = zinc900;

  static const Color muted = zinc100; // 减弱提示色
  static const Color mutedForeground = zinc500;

  static const Color accent = zinc100; // 强调色
  static const Color accentForeground = zinc900;

  static const Color destructive = Color(0xFFEF4444); // 破坏性操作颜色 (Red 500)
  static const Color destructiveForeground = zinc50;

  static const Color border = zinc200; // 边框颜色
  static const Color input = zinc200; // 输入框边框颜色
  static const Color ring = zinc900; // 获取焦点时的环形颜色
}

/// 基于 4px 网格的间距系统
class ShadcnSpacing {
  static const double xxs = 2.0; // 极小
  static const double xs = 4.0; // 很小
  static const double sm = 8.0; // 小
  static const double md = 12.0; // 中
  static const double lg = 16.0; // 大
  static const double xl = 20.0; // 很大
  static const double xl2 = 24.0;
  static const double xl3 = 32.0;
  static const double xl4 = 40.0;
  static const double xl5 = 48.0;
}

/// 圆角系统
class ShadcnRadius {
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double xl2 = 20.0;
  static const double full = 9999.0; // 用于胶囊形状
}

/// 阴影系统
class ShadcnShadows {
  // 微弱阴影
  static List<BoxShadow> get subtle => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.02),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  // 小阴影
  static List<BoxShadow> get sm => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  // 中等阴影
  static List<BoxShadow> get md => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  // 大阴影
  static List<BoxShadow> get lg => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}

/// Shadcn 风格的整体主题配置
class ShadcnThemeData {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: ShadcnColors.background,
      colorScheme: const ColorScheme.light(
        primary: ShadcnColors.primary,
        onPrimary: ShadcnColors.primaryForeground,
        secondary: ShadcnColors.secondary,
        onSecondary: ShadcnColors.secondaryForeground,
        surface: ShadcnColors.card,
        onSurface: ShadcnColors.cardForeground,
        error: ShadcnColors.destructive,
        onError: ShadcnColors.destructiveForeground,
        outline: ShadcnColors.border,
      ),
      // 导航栏主题
      appBarTheme: AppBarTheme(
        backgroundColor: ShadcnColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: ShadcnColors.foreground),
        titleSpacing: ShadcnSpacing.lg,
        titleTextStyle: const TextStyle(
          color: ShadcnColors.foreground,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
      ),
      // 分割线主题
      dividerTheme: const DividerThemeData(
        color: ShadcnColors.border,
        thickness: 1,
      ),
      // 卡片主题
      cardTheme: CardThemeData(
        color: ShadcnColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ShadcnRadius.lg),
          side: const BorderSide(color: ShadcnColors.border, width: 1),
        ),
      ),
      // 文本主题
      textTheme: const TextTheme(
        // H1 - 超大展示文字
        displayLarge: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: ShadcnColors.foreground,
          letterSpacing: -0.8,
          height: 1.2,
        ),
        // H2 - 大展示文字
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: ShadcnColors.foreground,
          letterSpacing: -0.6,
          height: 1.3,
        ),
        // H3 - 小展示文字
        displaySmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ShadcnColors.foreground,
          letterSpacing: -0.4,
          height: 1.4,
        ),
        // 标题文字
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ShadcnColors.foreground,
          letterSpacing: -0.2,
        ),
        // 正文（大）
        bodyLarge: TextStyle(
          fontSize: 16,
          color: ShadcnColors.foreground,
          height: 1.5,
          letterSpacing: 0,
        ),
        // 正文（中）
        bodyMedium: TextStyle(
          fontSize: 14,
          color: ShadcnColors.foreground,
          height: 1.4,
          letterSpacing: 0,
        ),
        // 正文（小）/ 减弱提示文字
        bodySmall: TextStyle(
          fontSize: 13,
          color: ShadcnColors.mutedForeground,
          height: 1.4,
        ),
        // 标签文字
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: ShadcnColors.foreground,
          letterSpacing: 0,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: ShadcnColors.mutedForeground,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
