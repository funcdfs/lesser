// 订阅量徽章组件

import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../../utils/format_utils.dart';

/// 订阅量徽章
///
/// 圆角矩形背景 + 双人线条图标 + 数字
class SubscriberBadge extends StatelessWidget {
  const SubscriberBadge({
    super.key,
    required this.count,
    this.size = SubscriberBadgeSize.small,
    this.showIcon = true,
  });

  final int count;
  final SubscriberBadgeSize size;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final config = _getConfig();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: config.paddingH,
        vertical: config.paddingV,
      ),
      decoration: BoxDecoration(
        color: colors.textPrimary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(config.radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            SizedBox(
              width: config.iconSize * 1.4, // 双人图标需要更宽
              height: config.iconSize,
              child: CustomPaint(
                painter: _SubscriberIconPainter(
                  color: colors.textTertiary,
                  strokeWidth: config.strokeWidth,
                ),
              ),
            ),
            SizedBox(width: config.spacing),
          ],
          Text(
            formatSubscriberCount(count),
            style: TextStyle(
              fontSize: config.fontSize,
              fontWeight: FontWeight.w500,
              color: colors.textTertiary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeConfig _getConfig() {
    switch (size) {
      case SubscriberBadgeSize.small:
        return const _BadgeConfig(
          paddingH: 6,
          paddingV: 3,
          radius: 10,
          iconSize: 10,
          fontSize: 11,
          spacing: 3,
          strokeWidth: 1.2,
        );
      case SubscriberBadgeSize.medium:
        return const _BadgeConfig(
          paddingH: 8,
          paddingV: 4,
          radius: 12,
          iconSize: 12,
          fontSize: 12,
          spacing: 4,
          strokeWidth: 1.4,
        );
      case SubscriberBadgeSize.large:
        return const _BadgeConfig(
          paddingH: 10,
          paddingV: 5,
          radius: 14,
          iconSize: 14,
          fontSize: 13,
          spacing: 5,
          strokeWidth: 1.6,
        );
    }
  }
}

/// 徽章尺寸
enum SubscriberBadgeSize { small, medium, large }

/// 徽章配置
class _BadgeConfig {
  const _BadgeConfig({
    required this.paddingH,
    required this.paddingV,
    required this.radius,
    required this.iconSize,
    required this.fontSize,
    required this.spacing,
    required this.strokeWidth,
  });

  final double paddingH;
  final double paddingV;
  final double radius;
  final double iconSize;
  final double fontSize;
  final double spacing;
  final double strokeWidth;
}

/// 订阅者图标绘制器（双人线条图标）
class _SubscriberIconPainter extends CustomPainter {
  const _SubscriberIconPainter({
    required this.color,
    required this.strokeWidth,
  });

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 后面的人（左侧，半透明）
    final backPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 后面的人 - 头
    canvas.drawCircle(Offset(w * 0.28, h * 0.28), h * 0.20, backPaint);
    // 后面的人 - 身体弧线
    final backBody = Path()
      ..moveTo(w * 0.06, h * 0.92)
      ..quadraticBezierTo(w * 0.06, h * 0.52, w * 0.28, h * 0.52)
      ..quadraticBezierTo(w * 0.50, h * 0.52, w * 0.50, h * 0.92);
    canvas.drawPath(backBody, backPaint);

    // 前面的人 - 头
    canvas.drawCircle(Offset(w * 0.72, h * 0.28), h * 0.20, paint);
    // 前面的人 - 身体弧线
    final frontBody = Path()
      ..moveTo(w * 0.50, h * 0.92)
      ..quadraticBezierTo(w * 0.50, h * 0.52, w * 0.72, h * 0.52)
      ..quadraticBezierTo(w * 0.94, h * 0.52, w * 0.94, h * 0.92);
    canvas.drawPath(frontBody, paint);
  }

  @override
  bool shouldRepaint(covariant _SubscriberIconPainter oldDelegate) {
    return color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
  }
}
