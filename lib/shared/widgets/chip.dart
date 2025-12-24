import 'package:flutter/material.dart';
import 'package:lesser/shared/theme/theme.dart';

/// 标签/碎片组件
class AppChip extends StatelessWidget {
  /// 标签文本内容
  final String label;

  /// 点击回调（可选）
  final VoidCallback? onTap;

  /// 背景颜色（可选，默认为 AppColors.secondary）
  final Color? backgroundColor;

  /// 文本颜色（可选）
  final Color? textColor;

  /// 内边距（可选）
  final EdgeInsetsGeometry? padding;

  const AppChip({
    super.key,
    required this.label,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding:
          padding ??
          EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.secondary,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor ?? AppColors.foreground,
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: content,
      );
    }

    return content;
  }
}

/// 徽章组件（用于显示数字、通知或简短状态）
class Badge extends StatelessWidget {
  /// 徽章显示的文本内容
  final String text;

  /// 背景颜色（可选，默认为 AppColors.destructive）
  final Color? backgroundColor;

  /// 文本颜色（可选，默认为白色）
  final Color? textColor;

  const Badge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.destructive,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
