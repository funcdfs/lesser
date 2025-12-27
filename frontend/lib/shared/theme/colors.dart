import 'package:flutter/material.dart';

/// 黑色基调的颜色系统 - 基于 TDesign 规范
///
/// 设计原则：
/// - 使用 gray950 作为主背景色
/// - 使用 gray900 作为表面色/卡片色
/// - 提供完整的语义化颜色令牌
class AppColors {
  AppColors._();

  // ============================================================================
  // 基础色板 - 黑色系 (Gray Scale)
  // ============================================================================

  /// 纯黑色
  static const Color black = Color(0xFF000000);

  /// 极深黑 - 主背景色
  static const Color gray950 = Color(0xFF0A0A0A);

  /// 深黑 - 表面色/卡片色
  static const Color gray900 = Color(0xFF171717);

  /// 深灰 - 悬浮/高亮背景
  static const Color gray800 = Color(0xFF262626);

  /// 中深灰 - 边框/分割线
  static const Color gray700 = Color(0xFF404040);

  /// 中灰 - 禁用状态
  static const Color gray600 = Color(0xFF525252);

  /// 灰色 - 次要文字
  static const Color gray500 = Color(0xFF737373);

  /// 浅灰 - 占位符文字
  static const Color gray400 = Color(0xFFA3A3A3);

  /// 更浅灰
  static const Color gray300 = Color(0xFFD4D4D4);

  /// 极浅灰
  static const Color gray200 = Color(0xFFE5E5E5);

  /// 近白灰
  static const Color gray100 = Color(0xFFF5F5F5);

  /// 纯白色
  static const Color white = Color(0xFFFFFFFF);

  // ============================================================================
  // 语义化颜色 - 深色主题
  // ============================================================================

  /// 主色 - 深黑
  static const Color primary = gray900;

  /// 主色上的前景色（文字/图标）
  static const Color primaryForeground = white;

  /// 次要色 - 用于次要按钮等
  static const Color secondary = gray800;

  /// 次要色上的前景色
  static const Color secondaryForeground = gray100;

  /// 背景色 - 应用主背景
  static const Color background = gray950;

  /// 背景上的前景色
  static const Color foreground = white;

  /// 表面色 - 卡片、弹窗等
  static const Color surface = gray900;

  /// 表面变体 - 略浅的表面色
  static const Color surfaceVariant = gray800;

  /// 表面上的前景色
  static const Color onSurface = white;

  /// 表面上的次要前景色
  static const Color onSurfaceVariant = gray400;

  /// 边框色
  static const Color border = gray700;

  /// 分割线色
  static const Color divider = gray800;

  /// 输入框背景色
  static const Color input = gray800;

  /// 输入框边框色
  static const Color inputBorder = gray700;

  /// 焦点环颜色
  static const Color ring = gray400;

  /// 减弱/静音色
  static const Color muted = gray800;

  /// 减弱前景色
  static const Color mutedForeground = gray500;

  /// 强调色
  static const Color accent = gray800;

  /// 强调前景色
  static const Color accentForeground = gray100;

  // ============================================================================
  // 功能色 - 状态指示
  // ============================================================================

  /// 错误/危险色
  static const Color error = Color(0xFFEF4444);

  /// 错误前景色
  static const Color errorForeground = white;

  /// 成功色
  static const Color success = Color(0xFF22C55E);

  /// 成功前景色
  static const Color successForeground = white;

  /// 警告色
  static const Color warning = Color(0xFFF59E0B);

  /// 警告前景色
  static const Color warningForeground = black;

  /// 信息色
  static const Color info = Color(0xFF3B82F6);

  /// 信息前景色
  static const Color infoForeground = white;

  /// 青色/蓝绿色 - 用于私密/安全相关
  static const Color teal = Color(0xFF14B8A6);

  /// 青色前景色
  static const Color tealForeground = white;

  /// 破坏性操作色（同 error）
  static const Color destructive = error;

  /// 破坏性操作前景色
  static const Color destructiveForeground = white;

  // ============================================================================
  // 特殊用途颜色
  // ============================================================================

  /// 卡片背景色
  static const Color card = gray900;

  /// 卡片前景色
  static const Color cardForeground = white;

  /// 弹窗背景色
  static const Color popover = gray900;

  /// 弹窗前景色
  static const Color popoverForeground = white;

  /// 遮罩层颜色
  static const Color overlay = Color(0x80000000);

  /// 阴影颜色
  static const Color shadow = Color(0x40000000);

  // ============================================================================
  // 品牌色 - 可根据需要自定义
  // ============================================================================

  /// 品牌主色
  static const Color brand = Color(0xFF3B82F6);

  /// 品牌主色前景
  static const Color brandForeground = white;

  // ============================================================================
  // 特殊功能色 - 用于特定 UI 元素
  // ============================================================================

  /// 故事渐变色 - 黄色
  static const Color storyGradientYellow = Color(0xFFFFD600);

  /// 故事渐变色 - 品红
  static const Color storyGradientPink = Color(0xFFFF0169);

  /// 故事渐变色 - 紫色
  static const Color storyGradientPurple = Color(0xFFD300C5);

  /// 排名金色 - 用于前三名
  static const Color rankingGold = Color(0xFFFFD700);

  /// 标签绿色 - 用于热门标签
  static const Color tagGreen = Color(0xFF4CAF50);

  // ============================================================================
  // 强调色 - 紫色系列
  // ============================================================================

  /// 强调紫色
  static const Color accentPurple = Color(0xFFC084FC);

  /// 强调紫色浅色背景
  static const Color accentPurpleLight = Color(0xFFF5F3FF);

  // ============================================================================
  // 交互状态颜色
  // ============================================================================

  /// 悬浮状态背景
  static const Color hoverBackground = gray800;

  /// 按下状态背景
  static const Color pressedBackground = gray700;

  /// 选中状态背景
  static const Color selectedBackground = gray800;

  /// 禁用状态背景
  static const Color disabledBackground = gray800;

  /// 禁用状态前景
  static const Color disabledForeground = gray600;

  // ============================================================================
  // 向后兼容 - 旧版颜色别名
  // ============================================================================

  /// @deprecated 使用 gray950 代替
  @Deprecated('使用 gray950 代替')
  static const Color zinc950 = gray950;

  /// @deprecated 使用 gray900 代替
  @Deprecated('使用 gray900 代替')
  static const Color zinc900 = gray900;

  /// @deprecated 使用 gray800 代替
  @Deprecated('使用 gray800 代替')
  static const Color zinc800 = gray800;

  /// @deprecated 使用 gray700 代替
  @Deprecated('使用 gray700 代替')
  static const Color zinc700 = gray700;

  /// @deprecated 使用 gray600 代替
  @Deprecated('使用 gray600 代替')
  static const Color zinc600 = gray600;

  /// @deprecated 使用 gray500 代替
  @Deprecated('使用 gray500 代替')
  static const Color zinc500 = gray500;

  /// @deprecated 使用 gray400 代替
  @Deprecated('使用 gray400 代替')
  static const Color zinc400 = gray400;

  /// @deprecated 使用 gray300 代替
  @Deprecated('使用 gray300 代替')
  static const Color zinc300 = gray300;

  /// @deprecated 使用 gray200 代替
  @Deprecated('使用 gray200 代替')
  static const Color zinc200 = gray200;

  /// @deprecated 使用 gray100 代替
  @Deprecated('使用 gray100 代替')
  static const Color zinc100 = gray100;

  /// @deprecated 使用 gray50 代替
  @Deprecated('使用 white 代替')
  static const Color zinc50 = white;
}
