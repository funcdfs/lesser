// 转发按钮

import 'package:flutter/material.dart';
import '../effects/effects.dart';
import 'icon_painter.dart';
import 'animated_count.dart';

const _iconRepost =
    'M17 2L21 6L17 10 M21 6H8C5.24 6 3 8.24 3 11 M7 22L3 18L7 14 M3 18H16C18.76 18 21 15.76 21 13';

class RepostButton extends StatelessWidget {
  const RepostButton({
    super.key,
    this.isReposted = false,
    this.count,
    this.size = 24,
    this.onTap,
  });

  final bool isReposted;
  final int? count;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isReposted
        ? const Color(0xFF4CAF50)
        : const Color(0xFF888888);
    final strokeWidth = isReposted ? 2.0 : 1.5;

    return TapScale(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: IconPainter(_iconRepost, color, strokeWidth),
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 4),
            AnimatedCount(
              count: count!,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: isReposted ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
