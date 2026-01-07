// 更多操作按钮

import 'package:flutter/material.dart';
import '../effects/effects.dart';
import 'icon_painter.dart';

// 横向三点图标 (more_horiz)
const _iconMore =
    'M6 10C4.9 10 4 10.9 4 12C4 13.1 4.9 14 6 14C7.1 14 8 13.1 8 12C8 10.9 7.1 10 6 10Z M12 10C10.9 10 10 10.9 10 12C10 13.1 10.9 14 12 14C13.1 14 14 13.1 14 12C14 10.9 13.1 10 12 10Z M18 10C16.9 10 16 10.9 16 12C16 13.1 16.9 14 18 14C19.1 14 20 13.1 20 12C20 10.9 19.1 10 18 10Z';

class MoreButton extends StatelessWidget {
  const MoreButton({super.key, this.size = 24, this.onTap});

  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: IconPainter(
            _iconMore,
            const Color(0xFF888888),
            1.5,
            fill: true,
          ),
        ),
      ),
    );
  }
}
