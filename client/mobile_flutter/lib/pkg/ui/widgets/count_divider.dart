// 计数分隔符组件
//
// 带渐变线和计数标签的分隔符，用于评论/回复等场景

import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// 通用计数分隔符组件
///
/// 带渐变线和计数标签的分隔符，用于评论/回复等场景
class CountDivider extends StatelessWidget {
  const CountDivider({super.key, required this.count, required this.label});

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // 左侧渐变线
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.divider.withValues(alpha: 0), colors.divider],
                ),
              ),
            ),
          ),
          // 中间图标 + 文字
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: colors.textDisabled,
                ),
                const SizedBox(width: 4),
                Text(
                  '$count $label',
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.textDisabled,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // 右侧渐变线
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.divider, colors.divider.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
