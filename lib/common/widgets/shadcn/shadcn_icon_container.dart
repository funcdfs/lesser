import 'package:flutter/material.dart';
import '../../../theme/theme.dart';

/// 带有统一样式的图标容器组件
/// 提供一致的圆角背景和图标间距装饰。
class ShadcnIconContainer extends StatelessWidget {
  /// 显示的图标
  final IconData icon;

  /// 图标颜色（可选）
  final Color? iconColor;

  /// 背景颜色（可选，默认根据图标颜色生成透明背景）
  final Color? backgroundColor;

  /// 容器整体大小
  final double size;

  const ShadcnIconContainer({
    super.key,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AppColors.foreground;
    // 如果未提供背景色，则使用图标颜色的 10% 透明度作为背景
    final effectiveBackgroundColor =
        backgroundColor ?? effectiveIconColor.withValues(alpha: 0.1);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Icon(icon, color: effectiveIconColor, size: size * 0.55),
    );
  }
}
