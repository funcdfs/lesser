// SVG Path 图标绘制器

import 'package:flutter/material.dart';

/// SVG Path 绘制器（24x24 viewBox）
class IconPainter extends CustomPainter {
  IconPainter(this.path, this.color, this.strokeWidth, {this.fill = false});
  final String path;
  final Color color;
  final double strokeWidth;
  final bool fill;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = fill ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(parse(path, size), paint);
  }

  static Path parse(String data, Size size) {
    final p = Path();
    final tokens = _tokenize(data);
    final sx = size.width / 24, sy = size.height / 24;
    double cx = 0, cy = 0;
    int i = 0;

    while (i < tokens.length) {
      switch (tokens[i]) {
        case 'M':
          cx = double.parse(tokens[++i]) * sx;
          cy = double.parse(tokens[++i]) * sy;
          p.moveTo(cx, cy);
        case 'L':
          cx = double.parse(tokens[++i]) * sx;
          cy = double.parse(tokens[++i]) * sy;
          p.lineTo(cx, cy);
        case 'H':
          cx = double.parse(tokens[++i]) * sx;
          p.lineTo(cx, cy);
        case 'V':
          cy = double.parse(tokens[++i]) * sy;
          p.lineTo(cx, cy);
        case 'C':
          final x1 = double.parse(tokens[++i]) * sx;
          final y1 = double.parse(tokens[++i]) * sy;
          final x2 = double.parse(tokens[++i]) * sx;
          final y2 = double.parse(tokens[++i]) * sy;
          cx = double.parse(tokens[++i]) * sx;
          cy = double.parse(tokens[++i]) * sy;
          p.cubicTo(x1, y1, x2, y2, cx, cy);
        case 'Q':
          final x1 = double.parse(tokens[++i]) * sx;
          final y1 = double.parse(tokens[++i]) * sy;
          cx = double.parse(tokens[++i]) * sx;
          cy = double.parse(tokens[++i]) * sy;
          p.quadraticBezierTo(x1, y1, cx, cy);
        case 'A':
          // 简化弧线处理
          i += 5;
          cx = double.parse(tokens[++i]) * sx;
          cy = double.parse(tokens[++i]) * sy;
          p.lineTo(cx, cy);
        case 'Z':
          p.close();
      }
      i++;
    }
    return p;
  }

  static List<String> _tokenize(String data) {
    final r = <String>[];
    for (final m in RegExp(r'([MLHVCQAZ])|(-?\d+\.?\d*)').allMatches(data)) {
      final v = m.group(0);
      if (v != null && v.isNotEmpty) r.add(v);
    }
    return r;
  }

  @override
  bool shouldRepaint(IconPainter old) =>
      old.path != path ||
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.fill != fill;
}
