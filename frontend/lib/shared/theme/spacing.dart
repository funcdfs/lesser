import 'package:flutter/material.dart';

/// 间距系统 - 基于 4px 网格
///
/// 设计原则：
/// - 所有间距值都是 4 的倍数
/// - 提供语义化的间距命名
/// - 支持 EdgeInsets 快捷方法
class AppSpacing {
  AppSpacing._();

  // ============================================================================
  // 基础间距值
  // ============================================================================

  /// 极小间距 - 4px
  static const double xs = 4.0;

  /// 小间距 - 8px
  static const double sm = 8.0;

  /// 中等间距 - 12px
  static const double md = 12.0;

  /// 大间距 - 16px
  static const double lg = 16.0;

  /// 超大间距 - 24px
  static const double xl = 24.0;

  /// 特大间距 - 32px
  static const double xxl = 32.0;

  /// 巨大间距 - 48px
  static const double xxxl = 48.0;

  // ============================================================================
  // 扩展间距值（用于特殊场景）
  // ============================================================================

  /// 2px - 极微小间距
  static const double xxs = 2.0;

  /// 20px
  static const double xl2 = 20.0;

  /// 40px
  static const double xl3 = 40.0;

  /// 56px
  static const double xl4 = 56.0;

  /// 64px
  static const double xl5 = 64.0;

  /// 80px
  static const double xl6 = 80.0;

  // ============================================================================
  // 常用 EdgeInsets 快捷方法
  // ============================================================================

  /// 所有方向相同间距
  static EdgeInsets all(double value) => EdgeInsets.all(value);

  /// 水平方向间距
  static EdgeInsets horizontal(double value) =>
      EdgeInsets.symmetric(horizontal: value);

  /// 垂直方向间距
  static EdgeInsets vertical(double value) =>
      EdgeInsets.symmetric(vertical: value);

  /// 对称间距
  static EdgeInsets symmetric({double horizontal = 0, double vertical = 0}) =>
      EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);

  /// 仅左侧间距
  static EdgeInsets left(double value) => EdgeInsets.only(left: value);

  /// 仅右侧间距
  static EdgeInsets right(double value) => EdgeInsets.only(right: value);

  /// 仅顶部间距
  static EdgeInsets top(double value) => EdgeInsets.only(top: value);

  /// 仅底部间距
  static EdgeInsets bottom(double value) => EdgeInsets.only(bottom: value);

  // ============================================================================
  // 预定义的常用 EdgeInsets
  // ============================================================================

  /// 无间距
  static const EdgeInsets zero = EdgeInsets.zero;

  /// 极小间距 - 所有方向 4px
  static const EdgeInsets allXs = EdgeInsets.all(xs);

  /// 小间距 - 所有方向 8px
  static const EdgeInsets allSm = EdgeInsets.all(sm);

  /// 中等间距 - 所有方向 12px
  static const EdgeInsets allMd = EdgeInsets.all(md);

  /// 大间距 - 所有方向 16px
  static const EdgeInsets allLg = EdgeInsets.all(lg);

  /// 超大间距 - 所有方向 24px
  static const EdgeInsets allXl = EdgeInsets.all(xl);

  /// 水平小间距
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);

  /// 水平中等间距
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);

  /// 水平大间距
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);

  /// 水平超大间距
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  /// 垂直小间距
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);

  /// 垂直中等间距
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);

  /// 垂直大间距
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);

  /// 垂直超大间距
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);

  /// 页面内边距 - 水平 16px
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: lg);

  /// 卡片内边距 - 所有方向 16px
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);

  /// 列表项内边距 - 水平 16px, 垂直 12px
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  /// 按钮内边距 - 水平 16px, 垂直 12px
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  /// 输入框内边距 - 水平 12px, 垂直 8px
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );
}

/// 圆角系统
///
/// 设计原则：
/// - 提供一致的圆角值
/// - 支持 BorderRadius 快捷方法
class AppRadius {
  AppRadius._();

  // ============================================================================
  // 基础圆角值
  // ============================================================================

  /// 无圆角
  static const double none = 0.0;

  /// 极小圆角 - 2px
  static const double xs = 2.0;

  /// 小圆角 - 4px
  static const double sm = 4.0;

  /// 中等圆角 - 8px
  static const double md = 8.0;

  /// 大圆角 - 12px
  static const double lg = 12.0;

  /// 超大圆角 - 16px
  static const double xl = 16.0;

  /// 特大圆角 - 20px
  static const double xl2 = 20.0;

  /// 超特大圆角 - 24px
  static const double xl3 = 24.0;

  /// 巨大圆角 - 24px
  static const double xxl = 24.0;

  /// 完全圆角（胶囊形状）
  static const double full = 9999.0;

  // ============================================================================
  // 预定义的 BorderRadius
  // ============================================================================

  /// 无圆角
  static const BorderRadius borderNone = BorderRadius.zero;

  /// 极小圆角
  static const BorderRadius borderXs = BorderRadius.all(Radius.circular(xs));

  /// 小圆角
  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));

  /// 中等圆角
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));

  /// 大圆角
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(lg));

  /// 超大圆角
  static const BorderRadius borderXl = BorderRadius.all(Radius.circular(xl));

  /// 特大圆角
  static const BorderRadius borderXxl = BorderRadius.all(Radius.circular(xxl));

  /// 完全圆角
  static const BorderRadius borderFull =
      BorderRadius.all(Radius.circular(full));

  // ============================================================================
  // 快捷方法
  // ============================================================================

  /// 创建所有角相同的圆角
  static BorderRadius circular(double radius) =>
      BorderRadius.all(Radius.circular(radius));

  /// 仅顶部圆角
  static BorderRadius top(double radius) => BorderRadius.only(
        topLeft: Radius.circular(radius),
        topRight: Radius.circular(radius),
      );

  /// 仅底部圆角
  static BorderRadius bottom(double radius) => BorderRadius.only(
        bottomLeft: Radius.circular(radius),
        bottomRight: Radius.circular(radius),
      );

  /// 仅左侧圆角
  static BorderRadius left(double radius) => BorderRadius.only(
        topLeft: Radius.circular(radius),
        bottomLeft: Radius.circular(radius),
      );

  /// 仅右侧圆角
  static BorderRadius right(double radius) => BorderRadius.only(
        topRight: Radius.circular(radius),
        bottomRight: Radius.circular(radius),
      );

  // ============================================================================
  // 常用场景圆角
  // ============================================================================

  /// 卡片圆角
  static const BorderRadius card = borderLg;

  /// 按钮圆角
  static const BorderRadius button = borderMd;

  /// 输入框圆角
  static const BorderRadius input = borderMd;

  /// 对话框圆角
  static const BorderRadius dialog = borderXl;

  /// 底部弹窗圆角（仅顶部）
  static BorderRadius get bottomSheet => top(xl);

  /// 头像圆角（完全圆形）
  static const BorderRadius avatar = borderFull;

  /// 标签/徽章圆角
  static const BorderRadius badge = borderSm;

  /// 图片圆角
  static const BorderRadius image = borderMd;
}

/// 阴影系统 - 深色主题优化
///
/// 深色主题下阴影效果较弱，主要通过边框和背景色区分层级
class AppShadows {
  AppShadows._();

  /// 无阴影
  static const List<BoxShadow> none = [];

  /// 微弱阴影
  static List<BoxShadow> get subtle => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  /// 小阴影
  static List<BoxShadow> get sm => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  /// 中等阴影
  static List<BoxShadow> get md => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  /// 大阴影
  static List<BoxShadow> get lg => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];

  /// 超大阴影
  static List<BoxShadow> get xl => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ];
}
