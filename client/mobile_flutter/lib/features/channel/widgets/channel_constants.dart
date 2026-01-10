// =============================================================================
// 频道模块布局常量
// =============================================================================
//
// 集中定义频道模块的布局常量，确保 UI 一致性并便于统一调整。
//
// ## 设计原则
//
// 1. **使用 abstract final class**：Dart 3 推荐的常量类定义方式，
//    既不能被实例化也不能被继承
//
// 2. **按功能分组**：每个常量类对应一个 UI 组件或功能区域
//
// 3. **语义化命名**：常量名应清晰表达其用途
//
// ## 常量类列表
//
// - `ChannelLayoutConstants` - 通用布局常量
// - `ChannelItemLayout` - 频道列表项布局
// - `DateSeparatorLayout` - 日期分隔符布局
// - `YearCalendarAnim` - 年历页面动画

import 'package:flutter/material.dart';

// =============================================================================
// 通用布局常量
// =============================================================================

/// 频道模块通用布局常量
///
/// 定义消息列表、滚动行为等通用参数。
abstract final class ChannelLayoutConstants {
  /// 消息气泡最大宽度比例（相对于屏幕宽度）
  ///
  /// 设为 0.87 使气泡不会占满屏幕，保持视觉呼吸感
  static const double messageMaxWidthRatio = 0.87;

  /// 消息外边距
  static const EdgeInsets messagePadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  );

  /// 置顶消息横幅高度
  static const double pinnedBannerHeight = 60.0;

  /// 默认顶部间距（无置顶消息时）
  static const double defaultTopPadding = 8.0;

  /// 滚动定位对齐比例
  ///
  /// 0.3 表示目标项会定位在视口 30% 的位置，
  /// 使用户能看到目标项上方的部分内容作为上下文
  static const double scrollAlignment = 0.3;

  /// 滚动动画时长
  ///
  /// 略长于标准动画，使列表滚动更平滑
  static const Duration scrollDuration = Duration(milliseconds: 250);

  /// 估算的列表项平均高度
  ///
  /// 用于降级滚动定位（当无法获取精确位置时）
  static const double estimatedItemHeight = 120.0;
}

// =============================================================================
// 频道列表项布局
// =============================================================================

/// 频道列表项布局常量
///
/// 定义频道列表项的内边距、头像大小、间距等参数。
abstract final class ChannelItemLayout {
  /// 列表项内边距
  static const EdgeInsets padding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );

  /// 头像大小
  static const double avatarSize = 40.0;

  /// 头像与内容的间距
  static const double avatarSpacing = 12.0;

  /// 内容与右侧区域的间距
  static const double trailingSpacing = 8.0;

  /// 标题与副标题的间距
  static const double titleSpacing = 5.0;

  /// 未读徽章高度（用于占位）
  static const double unreadBadgeHeight = 20.0;
}

// =============================================================================
// 日期分隔符布局
// =============================================================================

/// 日期分隔符布局常量
///
/// 定义消息列表中日期分隔符的样式参数。
abstract final class DateSeparatorLayout {
  /// 分隔符外边距
  static const EdgeInsets padding = EdgeInsets.symmetric(vertical: 16);

  /// 日期芯片内边距
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 6,
  );

  /// 日期芯片圆角
  static const double borderRadius = 14.0;
}

// =============================================================================
// 年历页面动画
// =============================================================================

/// 年历页面动画常量
///
/// 定义从日期分隔符打开年历选择器的过渡动画参数。
abstract final class YearCalendarAnim {
  /// 页面进入动画起始偏移（从底部滑入）
  static const Offset slideBegin = Offset(0, 1);

  /// 页面进入动画结束偏移
  static const Offset slideEnd = Offset.zero;

  /// 页面过渡动画时长
  static const Duration transitionDuration = Duration(milliseconds: 350);
}

// =============================================================================
// 标签抽屉布局
// =============================================================================

/// 标签抽屉布局常量
///
/// 定义底部标签选择器抽屉的布局参数。
abstract final class TagDrawerLayout {
  /// 展开时占屏幕高度比例
  static const double expandedRatio = 0.5;

  /// 头部固定高度（包含拖拽指示条）
  static const double headerHeight = 56.0;

  /// 拖拽指示条宽度
  static const double handleWidth = 36.0;

  /// 拖拽指示条高度
  static const double handleHeight = 4.0;

  /// 拖拽指示条圆角
  static const double handleBorderRadius = 2.0;

  /// 头部垂直内边距
  static const double headerVerticalPadding = 12.0;

  /// 内容区水平内边距
  static const double contentHorizontalPadding = 12.0;

  /// 内容区底部额外间距
  static const double contentBottomPadding = 8.0;

  /// 抽屉顶部圆角
  static const double drawerBorderRadius = 16.0;

  /// 阴影模糊半径
  static const double shadowBlurRadius = 8.0;

  /// 阴影透明度
  static const double shadowOpacity = 0.08;

  /// 拖拽速度阈值（用于判断快速滑动）
  static const double velocityThreshold = 500.0;
}

// =============================================================================
// 标签芯片布局
// =============================================================================

/// 标签芯片布局常量
///
/// 定义标签选择器中单个标签芯片的样式参数。
abstract final class TagChipLayout {
  /// 芯片水平内边距
  static const double horizontalPadding = 14.0;

  /// 芯片垂直内边距
  static const double verticalPadding = 8.0;

  /// 芯片圆角
  static const double borderRadius = 18.0;

  /// 图标与文字间距
  static const double iconSpacing = 6.0;

  /// 文字与数量间距
  static const double countSpacing = 4.0;

  /// 芯片间水平间距
  static const double chipSpacing = 8.0;

  /// 芯片间垂直间距
  static const double chipRunSpacing = 8.0;

  /// 选中状态边框宽度
  static const double selectedBorderWidth = 1.5;

  /// 未选中状态边框宽度
  static const double normalBorderWidth = 1.0;

  /// 图标字体大小
  static const double iconFontSize = 14.0;

  /// 名称字体大小
  static const double nameFontSize = 14.0;

  /// 数量字体大小
  static const double countFontSize = 12.0;
}
