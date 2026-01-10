// 未读数徽章组件

import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// 未读数徽章
///
/// 显示未读消息数量，支持静音状态的视觉区分。
/// 单位数时为圆形，多位数时为圆角矩形。
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
    final isSingleDigit = count < 10;

    // 静音时使用低饱和度灰色，否则使用柔和的强调色
    final bgColor = isMuted
        ? colors.textDisabled.withValues(alpha: 0.6)
        : colors.accent.withValues(alpha: 0.85);

    // 单位数：固定尺寸圆形；多位数：自适应宽度胶囊形
    if (isSingleDigit) {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.surfaceBase,
            height: 1,
          ),
        ),
      );
    }

    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colors.surfaceBase,
          height: 1,
        ),
      ),
    );
  }
}
