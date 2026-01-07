// 订阅量徽章组件 - 使用 SVG 风格显示

import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// 订阅量徽章
///
/// 使用 SVG 风格的圆角矩形背景 + 图标 + 数字
/// 比单纯的文字更有视觉层次感
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
              width: config.iconSize,
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
            _formatCount(count),
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

  String _formatCount(int count) {
    if (count >= 100000000) {
      // 1 亿以上
      return '${(count / 100000000).toStringAsFixed(1)} 亿';
    } else if (count >= 10000) {
      // 1 万以上
      final wan = count / 10000;
      if (wan >= 100) {
        return '${wan.toStringAsFixed(0)} 万';
      }
      return '${wan.toStringAsFixed(1)} 万';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
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

/// 订阅者图标绘制器（人形图标）
class _SubscriberIconPainter extends CustomPainter {
  const _SubscriberIconPainter({
    required this.color,
    required this.strokeWidth,
  });

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // 头部（圆形）
    final headRadius = w * 0.22;
    final headCenter = Offset(w * 0.5, h * 0.28);
    canvas.drawCircle(headCenter, headRadius, paint);

    // 身体（弧形）
    final bodyPath = Path();
    bodyPath.moveTo(w * 0.15, h * 0.95);
    bodyPath.quadraticBezierTo(w * 0.15, h * 0.55, w * 0.5, h * 0.55);
    bodyPath.quadraticBezierTo(w * 0.85, h * 0.55, w * 0.85, h * 0.95);
    canvas.drawPath(bodyPath, paint);
  }

  @override
  bool shouldRepaint(covariant _SubscriberIconPainter oldDelegate) {
    return color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
  }
}
