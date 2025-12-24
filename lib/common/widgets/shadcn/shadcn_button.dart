import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// Shadcn 按钮变体类型
enum ShadcnButtonVariant {
  primary, // 主要按钮（深色背景）
  secondary, // 次要按钮（浅色背景）
  ghost, // 幽灵按钮（无背景）
  outline, // 边框按钮
}

/// Shadcn 风格的通用按钮组件
class ShadcnButton extends StatelessWidget {
  /// 按钮子组件（通常为 Text 或 Icon）
  final Widget child;

  /// 点击回调函数
  final VoidCallback onPressed;

  /// 按钮外观变体
  final ShadcnButtonVariant variant;

  /// 按钮图标（可选）
  final IconData? icon;

  /// 按钮尺寸尺寸
  final double? size;

  const ShadcnButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.variant = ShadcnButtonVariant.primary,
    this.icon,
    this.size,
  });

  /// 工厂方法：创建一个幽灵图标按钮
  factory ShadcnButton.ghost({
    required VoidCallback onPressed,
    required IconData icon,
    Color? color,
    double? size,
  }) {
    return ShadcnButton(
      onPressed: onPressed,
      variant: ShadcnButtonVariant.ghost,
      size: size,
      child: Icon(
        icon,
        size: size ?? 20,
        color: color ?? ShadcnColors.mutedForeground,
      ),
    );
  }

  /// 工厂方法：创建一个带有文本和图标的幽灵按钮
  factory ShadcnButton.ghostText({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    Color? color,
  }) {
    return ShadcnButton(
      onPressed: onPressed,
      variant: ShadcnButtonVariant.ghost,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color ?? ShadcnColors.mutedForeground),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color ?? ShadcnColors.mutedForeground,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color foregroundColor;
    Border? border;

    // 根据变体设置颜色和样式
    switch (variant) {
      case ShadcnButtonVariant.primary:
        backgroundColor = ShadcnColors.primary;
        foregroundColor = ShadcnColors.primaryForeground;
        break;
      case ShadcnButtonVariant.secondary:
        backgroundColor = ShadcnColors.secondary;
        foregroundColor = ShadcnColors.secondaryForeground;
        break;
      case ShadcnButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = ShadcnColors.foreground;
        break;
      case ShadcnButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = ShadcnColors.foreground;
        border = Border.all(color: ShadcnColors.border);
        break;
    }

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(ShadcnRadius.md),
      clipBehavior: Clip.antiAlias,
      shape: border != null
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ShadcnRadius.md),
              side: BorderSide(color: ShadcnColors.border),
            )
          : null,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: variant == ShadcnButtonVariant.ghost
              ? const EdgeInsets.all(8)
              : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: DefaultTextStyle(
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
