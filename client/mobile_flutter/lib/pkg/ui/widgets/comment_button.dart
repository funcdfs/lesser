// 评论按钮

import 'package:flutter/material.dart';
import '../effects/effects.dart';
import 'icon_painter.dart';
import 'animated_count.dart';

const _iconComment =
    'M21 11.5C21 16.19 16.97 20 12 20C10.81 20 9.66 19.8 8.62 19.45L3 21L4.5 16.5C3.55 15.1 3 13.37 3 11.5C3 6.81 7.03 3 12 3C16.97 3 21 6.81 21 11.5Z';

class CommentButton extends StatelessWidget {
  const CommentButton({
    super.key,
    this.isActive = false,
    this.count,
    this.size = 24,
    this.onTap,
  });

  final bool isActive;
  final int? count;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF2196F3) : const Color(0xFF888888);
    final strokeWidth = isActive ? 2.0 : 1.5;

    return TapScale(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: IconPainter(_iconComment, color, strokeWidth),
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 4),
            AnimatedCount(
              count: count!,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
