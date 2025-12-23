import 'package:flutter/material.dart';
import '../../config/shadcn_theme.dart';

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
          const EdgeInsets.symmetric(
            horizontal: ShadcnSpacing.lg,
            vertical: ShadcnSpacing.md,
          ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: ShadcnSpacing.md),
          ],
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
                    color: ShadcnColors.foreground,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: ShadcnColors.mutedForeground,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: ShadcnSpacing.md),
            trailing!,
          ],
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(onTap: onTap, child: content);
    }

    return content;
  }
}
