import 'package:flutter/material.dart';
import '../../../theme/theme.dart';

/// Shadcn 风格的卡片组件
/// 提供统一的背景、圆角、边框和阴影样式。
class ShadcnCard extends StatelessWidget {
  /// 卡片内容
  final Widget child;

  /// 内边距（可选，默认为 AppSpacing.lg）
  final EdgeInsetsGeometry? padding;

  /// 点击回调（可选）
  final VoidCallback? onTap;

  const ShadcnCard({super.key, required this.child, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.subtle,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: padding ?? EdgeInsets.all(AppSpacing.lg),
          child: child,
        ),
      ),
    );

    // 如果提供了点击回调，则包装在 InkWell 中以支持交互
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: card,
      );
    }
    return card;
  }
}
