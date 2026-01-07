// 点赞按钮 - 仿真烟花特效

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  List<_Particle>? _particles;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      duration: const Duration(milliseconds: 80), // 呼吸感，与其他按钮统一
      vsync: this,
    );
    _fireworkCtrl = AnimationController(
      duration: const Duration(milliseconds: 500), // 烟花动画
      vsync: this,
    );
    _wasLiked = widget.isLiked;
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
      _particles = _generateParticles();
      _fireworkCtrl.forward(from: 0);
    }
    _wasLiked = widget.isLiked;
  }

  List<_Particle> _generateParticles() {
    final random = math.Random();
    final particles = <_Particle>[];
    // 粒子数量适中，精致而不杂乱
    const particleCount = 18;

    for (int i = 0; i < particleCount; i++) {
      // 角度均匀分布 + 轻微随机抖动
      final baseAngle = (2 * math.pi * i) / particleCount;
      final angle = baseAngle + (random.nextDouble() - 0.5) * 0.25;

      // 速度收窄，让粒子飞行距离更可控
      final speed = 0.6 + random.nextDouble() * 0.6;

      final color = _Particle.colors[random.nextInt(_Particle.colors.length)];

      particles.add(
        _Particle(
          angle: angle,
          speed: speed,
          color: color,
          size: 1.0 + random.nextDouble() * 0.8, // 粒子更小更精致
          gravity: 0.005 + random.nextDouble() * 0.01, // 极低重力
          sparkle: random.nextDouble() > 0.6, // 40% 概率闪烁
        ),
      );
    }
    return particles;
  }

  void _onTap() {
    // 呼吸感：按下缩小，松开弹回
    _scaleCtrl.forward().then((_) => _scaleCtrl.reverse());
    HapticFeedback.lightImpact();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isLiked
        ? const Color(0xFFFF1744) // 与图标渐变起始色一致
        : const Color(0xFF888888);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([_scaleCtrl, _fireworkCtrl]),
            builder: (context, _) {
              // 呼吸感：按下缩小 12%，与其他按钮统一
              final tapScale =
                  1.0 - 0.12 * Curves.easeOut.transform(_scaleCtrl.value);

              return Transform.scale(
                scale: tapScale,
                child: SizedBox(
                  // 绘制区域紧凑，刚好容纳烟花
                  width: widget.size + 20,
                  height: widget.size + 20,
                  child: CustomPaint(
                    painter: _FireworkPainter(
                      progress: _fireworkCtrl.value,
                      particles: _particles,
                      iconSize: widget.size,
                      isActive: widget.isLiked,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: widget.size,
                        height: widget.size,
                        child: widget.isLiked
                            ? ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFFF3B30), // 正红色
                                        Color(0xFFE53935), // 深红色
                                      ],
                                    ).createShader(bounds),
                                child: Icon(
                                  Icons.favorite_rounded,
                                  size: widget.size,
                                  color: const Color(0xFFFF3B30), // 正红色
                                ),
                              )
                            : Icon(
                                Icons.favorite_border_rounded,
                                size: widget.size,
                                color: const Color(0xFF888888),
                              ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (widget.count != null) ...[
            // 烟花容器右侧有 10px 空白，用负 margin 补偿
            Transform.translate(
              offset: const Offset(-6, 0),
              child: AnimatedCount(
                count: widget.count!,
                style: TextStyle(
                  fontSize: 14,
                  color: color,
                  fontWeight: widget.isLiked
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 烟花粒子
class _Particle {
  _Particle({
    required this.angle,
    required this.speed,
    required this.color,
    required this.size,
    required this.gravity,
    required this.sparkle,
  });

  final double angle;
  final double speed;
  final Color color;
  final double size;
  final double gravity;
  final bool sparkle;

  // 精选暖色调色板，与正红心呼应
  static const colors = [
    Color(0xFFFF3B30), // 正红色
    Color(0xFFFF6B6B), // 浅红
    Color(0xFFFF8A80), // 珊瑚红
    Color(0xFFFF6E40), // 深橙
    Color(0xFFFFAB40), // 橙色
    Color(0xFFFFD740), // 琥珀
  ];
}

/// 仿真烟花绘制器
class _FireworkPainter extends CustomPainter {
  _FireworkPainter({
    required this.progress,
    required this.particles,
    required this.iconSize,
    required this.isActive,
  });

  final double progress;
  final List<_Particle>? particles;
  final double iconSize;
  final bool isActive;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1 || !isActive || particles == null) {
      return;
    }

    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.5);

    // 1. 绘制扩散波纹 - 更小更快消失
    if (progress < 0.25) {
      final ringProgress = progress / 0.25;
      // 波纹半径从图标边缘开始，扩散范围小
      final ringRadius = iconSize * 0.5 + (iconSize * 0.4 * ringProgress);
      final ringOpacity = (1 - ringProgress) * 0.4;
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * (1 - ringProgress)
        ..color = const Color(0xFFFF3B30).withValues(alpha: ringOpacity);

      canvas.drawCircle(center, ringRadius, ringPaint);
    }

    // 2. 绘制粒子
    for (final p in particles!) {
      // 使用 easeOut 曲线，前快后慢
      final t = Curves.easeOut.transform(progress);

      // 飞行距离大幅缩小
      final moveDist = p.speed * t * iconSize * 0.8;

      // 极低重力，几乎水平扩散
      final gravityDy = p.gravity * (t * t) * iconSize * 2;

      final x = center.dx + math.cos(p.angle) * moveDist;
      final y = center.dy + math.sin(p.angle) * moveDist + gravityDy;

      // 透明度曲线：快速淡入，平稳保持，快速淡出
      double opacity = 1.0;
      if (progress < 0.05) {
        opacity = progress * 20;
      } else if (progress > 0.5) {
        opacity = 1 - ((progress - 0.5) / 0.5);
      }

      // 闪烁效果
      if (p.sparkle) {
        final sparkleCycle = math.sin(progress * 40);
        opacity *= (0.8 + 0.2 * sparkleCycle);
      }

      // 粒子随时间缩小
      final pSize = p.size * (1 - progress * 0.4);

      if (opacity <= 0 || pSize <= 0) continue;

      paint.color = p.color.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), pSize, paint);

      // 高光核心
      final coreColor = Colors.white.withValues(alpha: opacity * 0.7);
      canvas.drawCircle(Offset(x, y), pSize * 0.35, Paint()..color = coreColor);
    }
  }

  @override
  bool shouldRepaint(_FireworkPainter old) =>
      old.progress != progress || old.isActive != isActive;
}
