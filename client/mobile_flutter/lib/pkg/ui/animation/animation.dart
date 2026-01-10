// 动画常量
//
// 统一管理所有动画参数，确保一致的交互体验

import 'package:flutter/animation.dart';

/// 动画时长常量
abstract class AnimDurations {
  /// 快速动画 - 用于小元素的即时反馈（按钮点击、图标变化）
  static const fast = Duration(milliseconds: 80);

  /// 标准动画 - 用于一般过渡效果（弹出菜单、淡入淡出）
  static const normal = Duration(milliseconds: 100);

  /// 中等动画 - 用于较大元素的过渡（列表淡入、页面切换准备）
  static const medium = Duration(milliseconds: 150);

  /// 慢速动画 - 用于复杂过渡（抽屉展开、大面积变化）
  static const slow = Duration(milliseconds: 200);
}

/// 动画曲线常量
abstract class AnimCurves {
  /// 标准缓出曲线 - 用于大多数动画
  static const standard = Curves.easeOut;

  /// 弹性曲线 - 用于需要弹性效果的动画
  static const bounce = Curves.easeOutBack;
}

/// TapScale 缩放比例常量
abstract class TapScales {
  /// 小按钮缩放 - 用于图标按钮、emoji 按钮等小元素
  static const small = 0.9;

  /// 中等组件缩放 - 用于标签芯片、徽章等中等元素
  static const medium = 0.96;

  /// 卡片/列表项缩放 - 用于列表项、卡片等较大元素
  static const card = 0.98;

  /// 大组件缩放 - 用于消息气泡等大面积元素
  static const large = 0.99;
}

/// 弹出动画参数
abstract class PopupAnim {
  /// 起始缩放比例
  static const startScale = 0.95;

  /// 结束缩放比例
  static const endScale = 1.0;

  /// 动画时长
  static const duration = AnimDurations.normal;

  /// 动画曲线
  static const curve = AnimCurves.standard;
}

/// 淡入动画参数
abstract class FadeInAnim {
  /// 起始透明度
  static const startOpacity = 0.0;

  /// 结束透明度
  static const endOpacity = 1.0;

  /// 动画时长
  static const duration = AnimDurations.medium;

  /// 动画曲线
  static const curve = AnimCurves.standard;
}

/// 抽屉动画参数
abstract class DrawerAnim {
  /// 动画时长
  static const duration = AnimDurations.slow;

  /// 动画曲线
  static const curve = AnimCurves.standard;
}

/// Circular Reveal 主题切换动画参数
abstract class CircularRevealAnim {
  /// 动画时长 - 主题切换需要较长时间以保证视觉流畅
  static const duration = Duration(milliseconds: 400);

  /// 动画曲线 - 使用缓出曲线，开始快结束慢
  static const curve = Curves.easeOut;

  /// 模糊强度
  static const blurSigma = 8.0;

  /// 透明度衰减系数（>1 使后半段加速消失）
  static const opacityDecay = 1.2;

  /// 缩放增量（轻微放大效果）
  static const scaleIncrement = 0.05;

  /// 羽化边缘宽度比例
  static const featherRatio = 0.15;
}
