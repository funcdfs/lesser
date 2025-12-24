import 'package:flutter/material.dart';
import '../../../theme/theme.dart';

/// Shadcn 风格的列表项组件
/// 对标准的 ListTile 进行了风格统一。
class ShadcnListTile extends StatelessWidget {
  /// 左侧显示的 Widget（通常是 Icon 或 Avatar）
  final Widget? leading;

  /// 标题文本
  final String title;

  /// 副标题文本
  final String? subtitle;

  /// 右侧显示的 Widget（通常是 Arrow 或 Switch）
  final Widget? trailing;

  /// 点击回调
  final VoidCallback? onTap;

  /// 内边距（可选）
  final EdgeInsetsGeometry? padding;

  const ShadcnListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding:
          padding ??
          EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
      child: Row(
        children: [
          if (leading != null) ...[leading!, SizedBox(width: AppSpacing.md)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.foreground,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[SizedBox(width: AppSpacing.md), trailing!],
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(onTap: onTap, child: content);
    }

    return content;
  }
}
