// 分享按钮

import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../effects/effects.dart';
import 'icon_painter.dart';

// 圆润风格分享图标：向上箭头 + 圆角托盘
const _iconShare =
    'M12 3L12 15 M8 7L12 3L16 7 M5 11C5 11 5 19 5 19C5 20.1 5.9 21 7 21L17 21C18.1 21 19 20.1 19 19L19 11';

class ShareButton extends StatelessWidget {
  const ShareButton({super.key, this.size = 24, this.onTap});

  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return TapScale(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: IconPainter(_iconShare, colors.textTertiary, 1.5),
        ),
      ),
    );
  }
}
