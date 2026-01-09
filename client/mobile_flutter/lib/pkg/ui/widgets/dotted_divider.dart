// 点状分割线组件
//
// 轻盈的点状分割线，用于内容区块之间的视觉分隔
// 比实线更具呼吸感，符合现代 UI 设计风格

import 'package:flutter/material.dart';

/// 点状分割线
class DottedDivider extends StatelessWidget {
  const DottedDivider({
    super.key,
    required this.color,
    this.dashWidth = 3.0,
    this.dashSpace = 4.0,
    this.strokeWidth = 1.0,
  });

  /// 线条颜色
  final Color color;

  /// 点的宽度
  final double dashWidth;

  /// 点之间的间距
  final double dashSpace;

  /// 线条粗细
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: strokeWidth,
      child: CustomPaint(
        size: Size(double.infinity, strokeWidth),
        painter: _DottedLinePainter(
          color: color,
          dashWidth: dashWidth,
          dashSpace: dashSpace,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  _DottedLinePainter({
    required this.color,
    required this.dashWidth,
    required this.dashSpace,
    required this.strokeWidth,
  });

  final Color color;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DottedLinePainter oldDelegate) {
    return color != oldDelegate.color ||
        dashWidth != oldDelegate.dashWidth ||
        dashSpace != oldDelegate.dashSpace ||
        strokeWidth != oldDelegate.strokeWidth;
  }
}
