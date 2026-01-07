// 点赞按钮 - 喜庆烟花特效

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';
import 'animated_count.dart';

class LikeButton extends StatefulWidget {
  const LikeButton({
    super.key,
    this.isLiked = false,
    this.count,
    this.size = 24,
    this.onTap,
  });

  final bool isLiked;
  final int? count;
  final double size;
  final VoidCallback? onTap;

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> with TickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final AnimationController _fireworkCtrl;
  bool _wasLiked = false;

  // 烟花火花
  late List<_Spark> _sparks;
  // 二次爆炸的小火花
  late List<_TinySpark> _tinySparks;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      duration: const Duration(milliseconds: 80),
      vsync: this,
    );
    _fireworkCtrl = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _wasLiked = widget.isLiked;
    _sparks = _generateSparks();
    _tinySparks = _generateTinySparks();
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _fireworkCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(LikeButton old) {
    super.didUpdateWidget(old);
    if (widget.isLiked && !_wasLiked) {
      _regenerateSparks();
      _fireworkCtrl.forward(from: 0);
    }
    _wasLiked = widget.isLiked;
  }

  void _regenerateSparks() {
    _sparks = _generateSparks();
    _tinySparks = _generateTinySparks();
  }

  /// 生成主火花 - 模拟烟花绽放的主要轨迹
  List<_Spark> _generateSparks() {
    final random = math.Random();
    final sparks = <_Spark>[];
    const sparkCount = 12;

    for (int i = 0; i < sparkCount; i++) {
      // 均匀分布的角度，带少量随机偏移
      final baseAngle = (2 * math.pi * i) / sparkCount;
      final angle = baseAngle + (random.nextDouble() - 0.5) * 0.3;

      sparks.add(
        _Spark(
          angle: angle,
          speed: 0.7 + random.nextDouble() * 0.5,
          color: _Spark.colors[random.nextInt(_Spark.colors.length)],
          // 轨迹长度
          trailLength: 2 + random.nextInt(2),
          // 弯曲程度
          curvature: (random.nextDouble() - 0.5) * 0.3,
          // 延迟启动
          delay: random.nextDouble() * 0.1,
        ),
      );
    }
    return sparks;
  }

  /// 生成二次爆炸的小火花
  List<_TinySpark> _generateTinySparks() {
    final random = math.Random();
    final sparks = <_TinySpark>[];
    const count = 24;

    for (int i = 0; i < count; i++) {
      sparks.add(
        _TinySpark(
          // 随机角度
          angle: random.nextDouble() * 2 * math.pi,
          // 随机速度
          speed: 0.3 + random.nextDouble() * 0.7,
          // 随机颜色
          color: _Spark.colors[random.nextInt(_Spark.colors.length)],
          // 随机大小
          size: 0.5 + random.nextDouble() * 1.0,
          // 重力影响
          gravity: 0.02 + random.nextDouble() * 0.03,
          // 启动延迟（在主火花之后）
          delay: 0.15 + random.nextDouble() * 0.15,
          // 生命周期
          life: 0.4 + random.nextDouble() * 0.3,
        ),
      );
    }
    return sparks;
  }

  void _onTap() {
    _scaleCtrl.forward().then((_) => _scaleCtrl.reverse());
    HapticFeedback.lightImpact();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final likeColor = colors.like;
    final inactiveColor = colors.textTertiary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([_scaleCtrl, _fireworkCtrl]),
            builder: (context, _) {
              final tapScale =
                  1.0 - 0.12 * Curves.easeOut.transform(_scaleCtrl.value);

              return Transform.scale(
                scale: tapScale,
                child: SizedBox(
                  width: widget.size + 24,
                  height: widget.size + 24,
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _FireworkPainter(
                        progress: _fireworkCtrl.value,
                        sparks: _sparks,
                        tinySparks: _tinySparks,
                        iconSize: widget.size,
                        isActive: widget.isLiked,
                      ),
                      child: Center(
                        child: SizedBox(
                          width: widget.size,
                          height: widget.size,
                          child: widget.isLiked
                              ? ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      likeColor,
                                      likeColor.withValues(alpha: 0.8),
                                    ],
                                  ).createShader(bounds),
                                  child: Icon(
                                    Icons.favorite_rounded,
                                    size: widget.size,
                                    color: likeColor,
                                  ),
                                )
                              : Icon(
                                  Icons.favorite_border_rounded,
                                  size: widget.size,
                                  color: inactiveColor,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (widget.count != null) ...[
            // 与其他按钮组件保持一致的间距和字体
            const SizedBox(width: 4),
            AnimatedCount(
              count: widget.count!,
              style: TextStyle(
                fontSize: 13,
                color: widget.isLiked ? likeColor : inactiveColor,
                fontWeight: widget.isLiked ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 主火花 - 带轨迹的烟花
class _Spark {
  _Spark({
    required this.angle,
    required this.speed,
    required this.color,
    required this.trailLength,
    required this.curvature,
    required this.delay,
  });

  final double angle;
  final double speed;
  final Color color;
  final int trailLength;
  final double curvature;
  final double delay;

  // 喜庆烟花调色板 - 红金为主
  static const colors = [
    Color(0xFFFF3B30), // 大红
    Color(0xFFFF2D55), // 玫红
    Color(0xFFFF6B6B), // 浅红
    Color(0xFFFFD700), // 金色
    Color(0xFFFFA500), // 橙金
    Color(0xFFFFE066), // 浅金
    Color(0xFFFF9500), // 橙
    Color(0xFFFF7043), // 珊瑚红
  ];
}

/// 二次爆炸的小火花
class _TinySpark {
  _TinySpark({
    required this.angle,
    required this.speed,
    required this.color,
    required this.size,
    required this.gravity,
    required this.delay,
    required this.life,
  });

  final double angle;
  final double speed;
  final Color color;
  final double size;
  final double gravity;
  final double delay;
  final double life;
}

/// 喜庆烟花绘制器
class _FireworkPainter extends CustomPainter {
  _FireworkPainter({
    required this.progress,
    required this.sparks,
    required this.tinySparks,
    required this.iconSize,
    required this.isActive,
  });

  final double progress;
  final List<_Spark> sparks;
  final List<_TinySpark> tinySparks;
  final double iconSize;
  final bool isActive;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1 || !isActive) return;

    final center = Offset(size.width / 2, size.height / 2);

    // 绘制初始爆炸光晕
    _drawExplosionGlow(canvas, center);

    // 绘制主火花轨迹
    _drawSparks(canvas, center);

    // 绘制二次爆炸的小火花
    _drawTinySparks(canvas, center);
  }

  /// 绘制爆炸光晕
  void _drawExplosionGlow(Canvas canvas, Offset center) {
    if (progress > 0.3) return;

    final glowProgress = progress / 0.3;
    final radius = iconSize * 0.4 * Curves.easeOut.transform(glowProgress);
    final opacity = (1 - glowProgress) * 0.6;

    final gradient = RadialGradient(
      colors: [
        const Color(0xFFFFD700).withValues(alpha: opacity),
        const Color(0xFFFF3B30).withValues(alpha: opacity * 0.5),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawCircle(center, radius, paint);
  }

  /// 绘制主火花轨迹
  void _drawSparks(Canvas canvas, Offset center) {
    for (final spark in sparks) {
      // 计算延迟后的进度
      final adjustedProgress = (progress - spark.delay).clamp(0.0, 1.0);
      if (adjustedProgress <= 0) continue;

      // 使用缓动曲线
      final t = Curves.easeOutCubic.transform(adjustedProgress);

      // 计算当前位置
      final distance = spark.speed * t * iconSize * 0.9;

      // 添加弯曲效果，模拟烟花下坠
      final curveOffset = spark.curvature * t * t * iconSize;

      final x = center.dx + math.cos(spark.angle) * distance;
      final y =
          center.dy +
          math.sin(spark.angle) * distance +
          curveOffset +
          (t * t * iconSize * 0.15); // 重力下坠

      // 绘制轨迹（拖尾）
      _drawSparkTrail(canvas, center, spark, t, Offset(x, y));

      // 绘制火花头部
      _drawSparkHead(canvas, spark, t, Offset(x, y));
    }
  }

  /// 绘制火花轨迹
  void _drawSparkTrail(
    Canvas canvas,
    Offset center,
    _Spark spark,
    double t,
    Offset headPos,
  ) {
    if (t < 0.1) return;

    final path = Path();
    path.moveTo(headPos.dx, headPos.dy);

    // 绘制渐变轨迹
    for (int i = 1; i <= spark.trailLength; i++) {
      final trailT = (t - i * 0.05).clamp(0.0, 1.0);
      if (trailT <= 0) break;

      final trailDist = spark.speed * trailT * iconSize * 0.9;
      final trailCurve = spark.curvature * trailT * trailT * iconSize;

      final tx = center.dx + math.cos(spark.angle) * trailDist;
      final ty =
          center.dy +
          math.sin(spark.angle) * trailDist +
          trailCurve +
          (trailT * trailT * iconSize * 0.15);

      path.lineTo(tx, ty);
    }

    // 轨迹透明度
    double opacity = 1.0;
    if (t > 0.6) {
      opacity = 1 - ((t - 0.6) / 0.4);
    }

    final paint = Paint()
      ..color = spark.color.withValues(alpha: opacity * 0.7)
      ..strokeWidth = 1.5 * (1 - t * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);
  }

  /// 绘制火花头部（星形）
  void _drawSparkHead(Canvas canvas, _Spark spark, double t, Offset pos) {
    double opacity = 1.0;
    if (t < 0.1) {
      opacity = t * 10;
    } else if (t > 0.5) {
      opacity = 1 - ((t - 0.5) / 0.5);
    }

    if (opacity <= 0) return;

    final sparkSize = 2.5 * (1 - t * 0.3);

    // 绘制星形火花
    _drawStar(canvas, pos, sparkSize, spark.color, opacity);

    // 绘制高光核心
    final corePaint = Paint()
      ..color = Colors.white.withValues(alpha: opacity * 0.9);
    canvas.drawCircle(pos, sparkSize * 0.3, corePaint);
  }

  /// 绘制星形
  void _drawStar(
    Canvas canvas,
    Offset center,
    double size,
    Color color,
    double opacity,
  ) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    final path = Path();
    const points = 4;
    const innerRatio = 0.4;

    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi / points) - math.pi / 2;
      final radius = i.isEven ? size : size * innerRatio;
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);

    // 添加发光效果
    final glowPaint = Paint()
      ..color = color.withValues(alpha: opacity * 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(center, size * 0.8, glowPaint);
  }

  /// 绘制二次爆炸的小火花
  void _drawTinySparks(Canvas canvas, Offset center) {
    for (final spark in tinySparks) {
      // 计算延迟后的进度
      final adjustedProgress = (progress - spark.delay) / spark.life;
      if (adjustedProgress <= 0 || adjustedProgress >= 1) continue;

      final t = Curves.easeOut.transform(adjustedProgress.clamp(0.0, 1.0));

      // 计算位置
      final distance = spark.speed * t * iconSize * 0.6;
      final gravityDy = spark.gravity * t * t * iconSize * 3;

      final x = center.dx + math.cos(spark.angle) * distance;
      final y = center.dy + math.sin(spark.angle) * distance + gravityDy;

      // 透明度
      double opacity = 1.0;
      if (adjustedProgress < 0.2) {
        opacity = adjustedProgress * 5;
      } else if (adjustedProgress > 0.6) {
        opacity = 1 - ((adjustedProgress - 0.6) / 0.4);
      }

      if (opacity <= 0) continue;

      // 绘制小火花点
      final sparkSize = spark.size * (1 - t * 0.5);
      final paint = Paint()
        ..color = spark.color.withValues(alpha: opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.5);

      canvas.drawCircle(Offset(x, y), sparkSize, paint);

      // 高光
      final corePaint = Paint()
        ..color = Colors.white.withValues(alpha: opacity * 0.6);
      canvas.drawCircle(Offset(x, y), sparkSize * 0.3, corePaint);
    }
  }

  @override
  bool shouldRepaint(_FireworkPainter old) =>
      old.progress != progress || old.isActive != isActive;
}
