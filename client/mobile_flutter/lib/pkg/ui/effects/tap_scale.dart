// 点击缩放效果 - 统一的呼吸感交互

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 点击时产生柔和缩放效果的包装组件
///
/// 用法：
/// ```dart
/// TapScale(
///   onTap: () => print('tapped'),
///   child: Icon(Icons.favorite),
/// )
/// ```
class TapScale extends StatefulWidget {
  const TapScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.88,
    this.duration = const Duration(milliseconds: 80),
    this.haptic = true,
  });

  final Widget child;
  final VoidCallback? onTap;

  /// 按下时的缩放比例，默认 0.88（缩小 12%）
  final double scale;

  /// 动画时长，默认 80ms
  final Duration duration;

  /// 是否触发触感反馈
  final bool haptic;

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: widget.duration, vsync: this);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTap() {
    _ctrl.forward().then((_) => _ctrl.reverse());
    if (widget.haptic) {
      HapticFeedback.lightImpact();
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          final t = Curves.easeOut.transform(_ctrl.value);
          final scale = 1.0 - (1.0 - widget.scale) * t;
          return Transform.scale(scale: scale, child: child);
        },
        child: widget.child,
      ),
    );
  }
}
