import 'package:flutter/material.dart';

/// 深色主题颜色 - 基于 TDesign 规范
class DarkColors {
  DarkColors._();

  // 基础色板
  static const Color black = Color(0xFF000000);
  static const Color gray950 = Color(0xFF0A0A0A);
  static const Color gray900 = Color(0xFF171717);
  static const Color gray800 = Color(0xFF262626);
  static const Color gray700 = Color(0xFF404040);
  static const Color gray600 = Color(0xFF525252);
  static const Color gray500 = Color(0xFF737373);
  static const Color gray400 = Color(0xFFA3A3A3);
  static const Color gray300 = Color(0xFFD4D4D4);
  static const Color gray200 = Color(0xFFE5E5E5);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color white = Color(0xFFFFFFFF);

  // 语义化颜色
  static const Color primary = gray900;
  static const Color primaryForeground = white;
  static const Color secondary = gray800;
  static const Color secondaryForeground = gray100;
  static const Color background = gray950;
  static const Color foreground = white;
  static const Color surface = gray900;
  static const Color surfaceVariant = gray800;
  static const Color onSurface = white;
  static const Color onSurfaceVariant = gray400;
  static const Color border = gray700;
  static const Color divider = gray800;
  static const Color input = gray800;
  static const Color inputBorder = gray700;
  static const Color ring = gray400;
  static const Color muted = gray800;
  static const Color mutedForeground = gray500;
  static const Color accent = gray800;
  static const Color accentForeground = gray100;

  // 特殊用途颜色
  static const Color card = gray900;
  static const Color cardForeground = white;
  static const Color popover = gray900;
  static const Color popoverForeground = white;

  // 交互状态颜色
  static const Color hoverBackground = gray800;
  static const Color pressedBackground = gray700;
  static const Color selectedBackground = gray800;
  static const Color disabledBackground = gray800;
  static const Color disabledForeground = gray600;
}

/// 浅色主题颜色 - 基于 TDesign 规范
class LightColors {
  LightColors._();

  // 基础色板
  static const Color black = Color(0xFF000000);
  static const Color gray950 = Color(0xFF0A0A0A);
  static const Color gray900 = Color(0xFF171717);
  static const Color gray800 = Color(0xFF262626);
  static const Color gray700 = Color(0xFF404040);
  static const Color gray600 = Color(0xFF525252);
  static const Color gray500 = Color(0xFF737373);
  static const Color gray400 = Color(0xFFA3A3A3);
  static const Color gray300 = Color(0xFFD4D4D4);
  static const Color gray200 = Color(0xFFE5E5E5);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color white = Color(0xFFFFFFFF);

  // 语义化颜色
  static const Color primary = gray900;
  static const Color primaryForeground = white;
  static const Color secondary = gray200;
  static const Color secondaryForeground = gray900;
  static const Color background = white;
  static const Color foreground = gray950;
  static const Color surface = gray100;
  static const Color surfaceVariant = gray200;
  static const Color onSurface = gray950;
  static const Color onSurfaceVariant = gray600;
  static const Color border = gray300;
  static const Color divider = gray200;
  static const Color input = gray100;
  static const Color inputBorder = gray300;
  static const Color ring = gray500;
  static const Color muted = gray200;
  static const Color mutedForeground = gray500;
  static const Color accent = gray200;
  static const Color accentForeground = gray900;

  // 特殊用途颜色
  static const Color card = white;
  static const Color cardForeground = gray950;
  static const Color popover = white;
  static const Color popoverForeground = gray950;

  // 交互状态颜色
  static const Color hoverBackground = gray200;
  static const Color pressedBackground = gray300;
  static const Color selectedBackground = gray200;
  static const Color disabledBackground = gray200;
  static const Color disabledForeground = gray400;
}

/// 共享颜色 - 两个主题通用
class SharedColors {
  SharedColors._();

  // 功能色
  static const Color error = Color(0xFFEF4444);
  static const Color errorForeground = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF22C55E);
  static const Color successForeground = Color(0xFFFFFFFF);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningForeground = Color(0xFF000000);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoForeground = Color(0xFFFFFFFF);
  static const Color teal = Color(0xFF14B8A6);
  static const Color tealForeground = Color(0xFFFFFFFF);
  static const Color destructive = Color(0xFFEF4444);
  static const Color destructiveForeground = Color(0xFFFFFFFF);

  // 遮罩和阴影
  static const Color overlay = Color(0x80000000);
  static const Color shadow = Color(0x40000000);

  // 品牌色
  static const Color brand = Color(0xFF3B82F6);
  static const Color brandForeground = Color(0xFFFFFFFF);

  // 特殊功能色
  static const Color storyGradientYellow = Color(0xFFFFD600);
  static const Color storyGradientPink = Color(0xFFFF0169);
  static const Color storyGradientPurple = Color(0xFFD300C5);
  static const Color rankingGold = Color(0xFFFFD700);
  static const Color tagGreen = Color(0xFF4CAF50);
  static const Color accentPurple = Color(0xFFC084FC);
  static const Color accentPurpleLight = Color(0xFFF5F3FF);
}

/// 当前主题颜色入口 - 默认使用浅色主题
/// 
/// 使用方式：AppColors.background, AppColors.foreground 等
class AppColors {
  AppColors._();

  /// 当前是否为深色主题
  static bool _isDark = false;

  /// 设置主题模式
  static void setDarkMode(bool isDark) {
    _isDark = isDark;
  }

  /// 获取当前是否为深色主题
  static bool get isDark => _isDark;

  // 基础色板 - 始终可用
  static const Color black = Color(0xFF000000);
  static const Color gray950 = Color(0xFF0A0A0A);
  static const Color gray900 = Color(0xFF171717);
  static const Color gray800 = Color(0xFF262626);
  static const Color gray700 = Color(0xFF404040);
  static const Color gray600 = Color(0xFF525252);
  static const Color gray500 = Color(0xFF737373);
  static const Color gray400 = Color(0xFFA3A3A3);
  static const Color gray300 = Color(0xFFD4D4D4);
  static const Color gray200 = Color(0xFFE5E5E5);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color white = Color(0xFFFFFFFF);

  // 语义化颜色 - 根据主题切换
  static Color get primary => _isDark ? DarkColors.primary : LightColors.primary;
  static Color get primaryForeground => _isDark ? DarkColors.primaryForeground : LightColors.primaryForeground;
  static Color get secondary => _isDark ? DarkColors.secondary : LightColors.secondary;
  static Color get secondaryForeground => _isDark ? DarkColors.secondaryForeground : LightColors.secondaryForeground;
  static Color get background => _isDark ? DarkColors.background : LightColors.background;
  static Color get foreground => _isDark ? DarkColors.foreground : LightColors.foreground;
  static Color get surface => _isDark ? DarkColors.surface : LightColors.surface;
  static Color get surfaceVariant => _isDark ? DarkColors.surfaceVariant : LightColors.surfaceVariant;
  static Color get onSurface => _isDark ? DarkColors.onSurface : LightColors.onSurface;
  static Color get onSurfaceVariant => _isDark ? DarkColors.onSurfaceVariant : LightColors.onSurfaceVariant;
  static Color get border => _isDark ? DarkColors.border : LightColors.border;
  static Color get divider => _isDark ? DarkColors.divider : LightColors.divider;
  static Color get input => _isDark ? DarkColors.input : LightColors.input;
  static Color get inputBorder => _isDark ? DarkColors.inputBorder : LightColors.inputBorder;
  static Color get ring => _isDark ? DarkColors.ring : LightColors.ring;
  static Color get muted => _isDark ? DarkColors.muted : LightColors.muted;
  static Color get mutedForeground => _isDark ? DarkColors.mutedForeground : LightColors.mutedForeground;
  static Color get accent => _isDark ? DarkColors.accent : LightColors.accent;
  static Color get accentForeground => _isDark ? DarkColors.accentForeground : LightColors.accentForeground;

  // 特殊用途颜色
  static Color get card => _isDark ? DarkColors.card : LightColors.card;
  static Color get cardForeground => _isDark ? DarkColors.cardForeground : LightColors.cardForeground;
  static Color get popover => _isDark ? DarkColors.popover : LightColors.popover;
  static Color get popoverForeground => _isDark ? DarkColors.popoverForeground : LightColors.popoverForeground;

  // 交互状态颜色
  static Color get hoverBackground => _isDark ? DarkColors.hoverBackground : LightColors.hoverBackground;
  static Color get pressedBackground => _isDark ? DarkColors.pressedBackground : LightColors.pressedBackground;
  static Color get selectedBackground => _isDark ? DarkColors.selectedBackground : LightColors.selectedBackground;
  static Color get disabledBackground => _isDark ? DarkColors.disabledBackground : LightColors.disabledBackground;
  static Color get disabledForeground => _isDark ? DarkColors.disabledForeground : LightColors.disabledForeground;

  // 功能色 - 共享
  static const Color error = SharedColors.error;
  static const Color errorForeground = SharedColors.errorForeground;
  static const Color success = SharedColors.success;
  static const Color successForeground = SharedColors.successForeground;
  static const Color warning = SharedColors.warning;
  static const Color warningForeground = SharedColors.warningForeground;
  static const Color info = SharedColors.info;
  static const Color infoForeground = SharedColors.infoForeground;
  static const Color teal = SharedColors.teal;
  static const Color tealForeground = SharedColors.tealForeground;
  static const Color destructive = SharedColors.destructive;
  static const Color destructiveForeground = SharedColors.destructiveForeground;

  // 遮罩和阴影
  static const Color overlay = SharedColors.overlay;
  static const Color shadow = SharedColors.shadow;

  // 品牌色
  static const Color brand = SharedColors.brand;
  static const Color brandForeground = SharedColors.brandForeground;

  // 特殊功能色
  static const Color storyGradientYellow = SharedColors.storyGradientYellow;
  static const Color storyGradientPink = SharedColors.storyGradientPink;
  static const Color storyGradientPurple = SharedColors.storyGradientPurple;
  static const Color rankingGold = SharedColors.rankingGold;
  static const Color tagGreen = SharedColors.tagGreen;
  static const Color accentPurple = SharedColors.accentPurple;
  static const Color accentPurpleLight = SharedColors.accentPurpleLight;

  // 向后兼容 - zinc 别名
  @Deprecated('使用 gray950 代替')
  static const Color zinc950 = gray950;
  @Deprecated('使用 gray900 代替')
  static const Color zinc900 = gray900;
  @Deprecated('使用 gray800 代替')
  static const Color zinc800 = gray800;
  @Deprecated('使用 gray700 代替')
  static const Color zinc700 = gray700;
  @Deprecated('使用 gray600 代替')
  static const Color zinc600 = gray600;
  @Deprecated('使用 gray500 代替')
  static const Color zinc500 = gray500;
  @Deprecated('使用 gray400 代替')
  static const Color zinc400 = gray400;
  @Deprecated('使用 gray300 代替')
  static const Color zinc300 = gray300;
  @Deprecated('使用 gray200 代替')
  static const Color zinc200 = gray200;
  @Deprecated('使用 gray100 代替')
  static const Color zinc100 = gray100;
  @Deprecated('使用 white 代替')
  static const Color zinc50 = white;
}
