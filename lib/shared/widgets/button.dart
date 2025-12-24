import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// 按钮变体类型
enum ButtonVariant {
  primary, // 主要按钮（深色背景）
  secondary, // 次要按钮（浅色背景）
  ghost, // 幽灵按钮（无背景）
  outline, // 边框按钮
}

/// 通用按钮组件
class AppButton extends StatelessWidget {
  /// 按钮子组件（通常为 Text 或 Icon）
  final Widget child;

  /// 点击回调函数
  final VoidCallback onPressed;

  /// 按钮外观变体
  final ButtonVariant variant;

  /// 按钮图标（可选）
  final IconData? icon;

  /// 按钮尺寸尺寸
  final double? size;

  const AppButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.size,
  });

  /// 工厂方法：创建一个幽灵图标按钮
  factory AppButton.ghost({
    required VoidCallback onPressed,
    required IconData icon,
    Color? color,
    double? size,
  }) {
    return AppButton(
      onPressed: onPressed,
      variant: ButtonVariant.ghost,
      size: size,
      child: Icon(
        icon,
        size: size ?? 20,
        color: color ?? AppColors.mutedForeground,
      ),
    );
  }

  /// 工厂方法：创建一个带有文本和图标的幽灵按钮
  factory AppButton.ghostText({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    Color? color,
  }) {
    return AppButton(
      onPressed: onPressed,
      variant: ButtonVariant.ghost,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color ?? AppColors.mutedForeground),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color ?? AppColors.mutedForeground,
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
      case ButtonVariant.primary:
        backgroundColor = AppColors.primary;
        foregroundColor = AppColors.primaryForeground;
        break;
      case ButtonVariant.secondary:
        backgroundColor = AppColors.secondary;
        foregroundColor = AppColors.secondaryForeground;
        break;
      case ButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = AppColors.foreground;
        break;
      case ButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = AppColors.foreground;
        border = Border.all(color: AppColors.border);
        break;
    }

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(AppRadius.md),
      clipBehavior: Clip.antiAlias,
      shape: border != null
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              side: BorderSide(color: AppColors.border),
            )
          : null,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: variant == ButtonVariant.ghost
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
