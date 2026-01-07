// 应用主题管理
// 语义化颜色层级，支持黑白主题切换

import 'package:flutter/material.dart';

/// 主题模式通知器
class ThemeNotifier extends ChangeNotifier {
  ThemeNotifier() {
    _isDark = false;
  }

  bool _isDark = false;
  bool get isDark => _isDark;

  void toggle() {
    _isDark = !_isDark;
    notifyListeners();
  }

  void setDark(bool value) {
    if (_isDark != value) {
      _isDark = value;
      notifyListeners();
    }
  }
}

/// 语义化颜色
class AppColors {
  AppColors._();

  // 亮色主题
  static const light = _LightColors();
  // 暗色主题
  static const dark = _DarkColors();

  /// 根据主题获取颜色
  static AppColorScheme of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? dark : light;
  }
}

/// 颜色方案抽象
abstract class AppColorScheme {
  // 文字层级
  Color get textPrimary; // 绝对焦点（正文）
  Color get textSecondary; // 身份标识（用户名）
  Color get textTertiary; // 辅助信息（时间、统计）
  Color get textDisabled; // 禁用状态

  // 表面层级
  Color get surfaceBase; // 底层背景
  Color get surfaceElevated; // 浮起层（卡片、抽屉）
  Color get surfaceNav; // 导航栏背景
  Color get surfaceOverlay; // 遮罩层

  // 分割线（亮色模式不显示导航栏边框）
  Color get divider;
  Color get navBorder;

  // 交互状态
  Color get interactive; // 可交互元素
  Color get interactiveHover;

  // 开关组件
  Color get switchActive; // 开关激活色
  Color get switchInactive; // 开关未激活色
  Color get switchThumb; // 开关滑块色

  // 语义色
  Color get like; // 点赞红
  Color get comment; // 评论蓝
  Color get repost; // 转发绿
  Color get warning;
  Color get error;
}

/// 亮色主题
class _LightColors implements AppColorScheme {
  const _LightColors();

  @override
  Color get textPrimary => const Color(0xFF1A1A1A);
  @override
  Color get textSecondary => const Color(0xFF333333);
  @override
  Color get textTertiary => const Color(0xFF888888);
  @override
  Color get textDisabled => const Color(0xFFBBBBBB);

  @override
  Color get surfaceBase => const Color(0xFFF8F8F8); // 柔和灰白
  @override
  Color get surfaceElevated => const Color(0xFFFFFFFF); // 纯白卡片
  @override
  Color get surfaceNav => const Color(0xFFFCFCFC); // 奶白色导航栏
  @override
  Color get surfaceOverlay => const Color(0x33000000);

  @override
  Color get divider => const Color(0xFFEEEEEE);
  @override
  Color get navBorder => Colors.transparent; // 亮色模式无边框

  @override
  Color get interactive => const Color(0xFF333333);
  @override
  Color get interactiveHover => const Color(0xFF666666);

  @override
  Color get switchActive => const Color(0xFF1A1A1A); // 深色激活
  @override
  Color get switchInactive => const Color(0xFFE0E0E0); // 浅灰未激活
  @override
  Color get switchThumb => const Color(0xFFFFFFFF); // 白色滑块

  @override
  Color get like => const Color(0xFFFF1744);
  @override
  Color get comment => const Color(0xFF2196F3);
  @override
  Color get repost => const Color(0xFF4CAF50);
  @override
  Color get warning => const Color(0xFFFF9800);
  @override
  Color get error => const Color(0xFFF44336);
}

/// 暗色主题
class _DarkColors implements AppColorScheme {
  const _DarkColors();

  @override
  Color get textPrimary => const Color(0xFFF5F5F5);
  @override
  Color get textSecondary => const Color(0xFFE0E0E0);
  @override
  Color get textTertiary => const Color(0xFF888888);
  @override
  Color get textDisabled => const Color(0xFF555555);

  @override
  Color get surfaceBase => const Color(0xFF0A0A0A); // 纯黑背景
  @override
  Color get surfaceElevated => const Color(0xFF1A1A1A); // 深灰卡片
  @override
  Color get surfaceNav => const Color(0xFF0A0A0A); // 纯黑导航栏
  @override
  Color get surfaceOverlay => const Color(0x66000000);

  @override
  Color get divider => const Color(0xFF2A2A2A);
  @override
  Color get navBorder => const Color(0xFF1A1A1A); // 暗色模式微弱边框

  @override
  Color get interactive => const Color(0xFFE0E0E0);
  @override
  Color get interactiveHover => const Color(0xFFBBBBBB);

  @override
  Color get switchActive => const Color(0xFFFFFFFF); // 白色激活
  @override
  Color get switchInactive => const Color(0xFF333333); // 深灰未激活
  @override
  Color get switchThumb => const Color(0xFF1A1A1A); // 深色滑块

  @override
  Color get like => const Color(0xFFFF5252);
  @override
  Color get comment => const Color(0xFF64B5F6);
  @override
  Color get repost => const Color(0xFF81C784);
  @override
  Color get warning => const Color(0xFFFFB74D);
  @override
  Color get error => const Color(0xFFEF5350);
}

/// 构建 Flutter ThemeData
ThemeData buildLightTheme() {
  const colors = AppColors.light;
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: colors.surfaceBase,
    cardColor: colors.surfaceElevated,
    dividerColor: colors.divider,
    colorScheme: ColorScheme.light(
      surface: colors.surfaceBase,
      primary: colors.textPrimary,
      secondary: colors.textSecondary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.surfaceBase,
      foregroundColor: colors.textPrimary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: colors.textPrimary),
      bodyMedium: TextStyle(color: colors.textSecondary),
      bodySmall: TextStyle(color: colors.textTertiary),
    ),
  );
}

ThemeData buildDarkTheme() {
  const colors = AppColors.dark;
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: colors.surfaceBase,
    cardColor: colors.surfaceElevated,
    dividerColor: colors.divider,
    colorScheme: ColorScheme.dark(
      surface: colors.surfaceBase,
      primary: colors.textPrimary,
      secondary: colors.textSecondary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.surfaceBase,
      foregroundColor: colors.textPrimary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: colors.textPrimary),
      bodyMedium: TextStyle(color: colors.textSecondary),
      bodySmall: TextStyle(color: colors.textTertiary),
    ),
  );
}
