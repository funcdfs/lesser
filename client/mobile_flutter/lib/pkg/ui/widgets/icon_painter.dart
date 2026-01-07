// SVG Path 图标绘制器

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Path 缓存，避免重复解析
final _pathCache = <String, Path>{};

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

    // 使用缓存的 Path，避免每帧重复解析
    final cacheKey = '$path|${size.width}|${size.height}';
    final cachedPath = _pathCache[cacheKey] ?? _parse(path, size);
    if (!_pathCache.containsKey(cacheKey)) {
      _pathCache[cacheKey] = cachedPath;
    }
    canvas.drawPath(cachedPath, paint);
  }

  /// 解析 SVG path 数据，支持大写（绝对）和小写（相对）命令
  static Path _parse(String data, Size size) {
    final p = Path();
    final tokens = _tokenize(data);
    final sx = size.width / 24, sy = size.height / 24;
    double cx = 0, cy = 0; // 当前点
    double startX = 0, startY = 0; // 子路径起点
    int i = 0;

    while (i < tokens.length) {
      final cmd = tokens[i];
      switch (cmd) {
        // 绝对坐标命令
        case 'M':
          cx = double.parse(tokens[++i]) * sx;
          cy = double.parse(tokens[++i]) * sy;
          startX = cx;
          startY = cy;
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
          // 完整弧线解析
          final rx = double.parse(tokens[++i]) * sx;
          final ry = double.parse(tokens[++i]) * sy;
          final rotation = double.parse(tokens[++i]) * math.pi / 180;
          final largeArc = tokens[++i] == '1';
          final sweep = tokens[++i] == '1';
          final endX = double.parse(tokens[++i]) * sx;
          final endY = double.parse(tokens[++i]) * sy;
          _arcTo(p, cx, cy, rx, ry, rotation, largeArc, sweep, endX, endY);
          cx = endX;
          cy = endY;
        case 'Z':
        case 'z':
          p.close();
          cx = startX;
          cy = startY;

        // 相对坐标命令
        case 'm':
          cx += double.parse(tokens[++i]) * sx;
          cy += double.parse(tokens[++i]) * sy;
          startX = cx;
          startY = cy;
          p.moveTo(cx, cy);
        case 'l':
          cx += double.parse(tokens[++i]) * sx;
          cy += double.parse(tokens[++i]) * sy;
          p.lineTo(cx, cy);
        case 'h':
          cx += double.parse(tokens[++i]) * sx;
          p.lineTo(cx, cy);
        case 'v':
          cy += double.parse(tokens[++i]) * sy;
          p.lineTo(cx, cy);
        case 'c':
          final x1 = cx + double.parse(tokens[++i]) * sx;
          final y1 = cy + double.parse(tokens[++i]) * sy;
          final x2 = cx + double.parse(tokens[++i]) * sx;
          final y2 = cy + double.parse(tokens[++i]) * sy;
          cx += double.parse(tokens[++i]) * sx;
          cy += double.parse(tokens[++i]) * sy;
          p.cubicTo(x1, y1, x2, y2, cx, cy);
        case 'q':
          final x1 = cx + double.parse(tokens[++i]) * sx;
          final y1 = cy + double.parse(tokens[++i]) * sy;
          cx += double.parse(tokens[++i]) * sx;
          cy += double.parse(tokens[++i]) * sy;
          p.quadraticBezierTo(x1, y1, cx, cy);
        case 'a':
          final rx = double.parse(tokens[++i]) * sx;
          final ry = double.parse(tokens[++i]) * sy;
          final rotation = double.parse(tokens[++i]) * math.pi / 180;
          final largeArc = tokens[++i] == '1';
          final sweep = tokens[++i] == '1';
          final endX = cx + double.parse(tokens[++i]) * sx;
          final endY = cy + double.parse(tokens[++i]) * sy;
          _arcTo(p, cx, cy, rx, ry, rotation, largeArc, sweep, endX, endY);
          cx = endX;
          cy = endY;
      }
      i++;
    }
    return p;
  }

  /// 绘制椭圆弧（SVG arc 命令实现）
  static void _arcTo(
    Path p,
    double x1,
    double y1,
    double rx,
    double ry,
    double phi,
    bool largeArc,
    bool sweep,
    double x2,
    double y2,
  ) {
    if (rx == 0 || ry == 0) {
      p.lineTo(x2, y2);
      return;
    }

    // 计算中心参数化
    final cosPhi = math.cos(phi);
    final sinPhi = math.sin(phi);

    final dx = (x1 - x2) / 2;
    final dy = (y1 - y2) / 2;

    final x1p = cosPhi * dx + sinPhi * dy;
    final y1p = -sinPhi * dx + cosPhi * dy;

    // 修正半径
    var rxSq = rx * rx;
    var rySq = ry * ry;
    final x1pSq = x1p * x1p;
    final y1pSq = y1p * y1p;

    final lambda = x1pSq / rxSq + y1pSq / rySq;
    if (lambda > 1) {
      final sqrtLambda = math.sqrt(lambda);
      rx *= sqrtLambda;
      ry *= sqrtLambda;
      rxSq = rx * rx;
      rySq = ry * ry;
    }

    // 计算中心点
    var sq =
        (rxSq * rySq - rxSq * y1pSq - rySq * x1pSq) /
        (rxSq * y1pSq + rySq * x1pSq);
    if (sq < 0) sq = 0;
    final coef = (largeArc == sweep ? -1 : 1) * math.sqrt(sq);

    final cxp = coef * rx * y1p / ry;
    final cyp = -coef * ry * x1p / rx;

    final cxCenter = cosPhi * cxp - sinPhi * cyp + (x1 + x2) / 2;
    final cyCenter = sinPhi * cxp + cosPhi * cyp + (y1 + y2) / 2;
    // cxCenter, cyCenter 为弧线中心点，保留用于调试
    assert(cxCenter.isFinite && cyCenter.isFinite);

    // 计算角度（用于调试，实际绘制使用 arcToPoint）
    // final theta1 = _angle(1, 0, (x1p - cxp) / rx, (y1p - cyp) / ry);
    // var dTheta = _angle(...);

    // 使用 arcToPoint 绘制
    p.arcToPoint(
      Offset(x2, y2),
      radius: Radius.elliptical(rx, ry),
      rotation: phi * 180 / math.pi,
      largeArc: largeArc,
      clockwise: sweep,
    );
  }

  /// 分词，支持大小写命令
  static List<String> _tokenize(String data) {
    final r = <String>[];
    for (final m in RegExp(
      r'([MLHVCQAZmlhvcqaz])|(-?\d+\.?\d*)',
    ).allMatches(data)) {
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
