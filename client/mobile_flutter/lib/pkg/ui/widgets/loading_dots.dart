// 加载点动画组件
//
// 轻量优雅的三点脉冲动画，用于内联加载状态

import 'package:flutter/material.dart';

/// 加载点动画
///
/// 简洁的三点脉冲动画，比 CircularProgressIndicator 更轻量优雅。
/// 适用于按钮内、内联文本等需要小型加载指示器的场景。
///
/// 用法：
/// ```dart
/// LoadingDots(color: colors.accent)
/// LoadingDots.mini(color: colors.accent)  // 更小尺寸
/// ```
class LoadingDots extends StatefulWidget {
  const LoadingDots({
    super.key,
    required this.color,
    this.size = LoadingDotsSize.normal,
  });

  /// 迷你尺寸构造器
  const LoadingDots.mini({super.key, required this.color})
    : size = LoadingDotsSize.mini;

  final Color color;
  final LoadingDotsSize size;

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

/// 加载点尺寸
enum LoadingDotsSize {
  /// 迷你尺寸：14x14，点直径 3px
  mini(14, 3, 2),

  /// 正常尺寸：16x16，点直径 4px
  normal(16, 4, 2);

  const LoadingDotsSize(this.containerSize, this.dotSize, this.spacing);

  final double containerSize;
  final double dotSize;
  final double spacing;
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    return SizedBox(
      width: size.containerSize,
      height: size.containerSize,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              // 每个点的动画相位错开
              final phase = (_ctrl.value + i * 0.33) % 1.0;
              final opacity = (1.0 - (phase * 2 - 1).abs()).clamp(0.3, 1.0);
              return Container(
                width: size.dotSize,
                height: size.dotSize,
                margin: EdgeInsets.only(left: i > 0 ? size.spacing : 0),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: opacity),
                  shape: BoxShape.circle,
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
