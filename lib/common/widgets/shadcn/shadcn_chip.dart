import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// Shadcn 风格的标签/碎片组件
class ShadcnChip extends StatelessWidget {
  /// 标签文本内容
  final String label;

  /// 点击回调（可选）
  final VoidCallback? onTap;

  /// 背景颜色（可选，默认为 ShadcnColors.secondary）
  final Color? backgroundColor;

  /// 文本颜色（可选）
  final Color? textColor;

  /// 内边距（可选）
  final EdgeInsetsGeometry? padding;

  const ShadcnChip({
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
          const EdgeInsets.symmetric(
            horizontal: ShadcnSpacing.lg,
            vertical: ShadcnSpacing.sm,
          ),
      decoration: BoxDecoration(
        color: backgroundColor ?? ShadcnColors.secondary,
        borderRadius: BorderRadius.circular(ShadcnRadius.md),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor ?? ShadcnColors.foreground,
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ShadcnRadius.md),
        child: content,
      );
    }

    return content;
  }
}

/// Shadcn 风格的徽章组件（用于显示数字、通知或简短状态）
class ShadcnBadge extends StatelessWidget {
  /// 徽章显示的文本内容
  final String text;

  /// 背景颜色（可选，默认为 ShadcnColors.destructive）
  final Color? backgroundColor;

  /// 文本颜色（可选，默认为白色）
  final Color? textColor;

  const ShadcnBadge({
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
        color: backgroundColor ?? ShadcnColors.destructive,
        borderRadius: BorderRadius.circular(ShadcnRadius.full),
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
