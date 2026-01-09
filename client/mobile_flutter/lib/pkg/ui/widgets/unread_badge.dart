// 未读数徽章组件

import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// 未读数徽章
class UnreadBadge extends StatelessWidget {
  const UnreadBadge({
    super.key,
    required this.count,
    this.isMuted = false,
    this.maxCount = 99,
  });

  final int count;
  final bool isMuted;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final text = count > maxCount ? '$maxCount+' : count.toString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      constraints: const BoxConstraints(minWidth: 18),
      decoration: BoxDecoration(
        // 静音时使用辅助色，否则使用强调色
        color: isMuted ? colors.textTertiary : colors.accent,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isMuted ? colors.surfaceBase : colors.surfaceElevated,
        ),
      ),
    );
  }
}
