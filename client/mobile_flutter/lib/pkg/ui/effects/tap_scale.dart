// 点击缩放效果 - 统一的呼吸感交互

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../animation/animation.dart';

/// 点击时产生柔和缩放效果的包装组件
///
/// 用法：
/// ```dart
/// TapScale(
///   onTap: () => print('tapped'),
///   onLongPress: () => print('long pressed'),
///   child: Icon(Icons.favorite),
/// )
/// ```
class TapScale extends StatefulWidget {
  const TapScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scale = TapScales.small,
    this.duration = AnimDurations.fast,
    this.haptic = true,
  });

  final Widget child;
  final VoidCallback? onTap;

  /// 长按回调
  final VoidCallback? onLongPress;

  /// 按下时的缩放比例，默认 0.9
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
    _ctrl.forward().then((_) {
      // 检查组件是否仍然挂载，避免 dispose 后调用
      if (mounted) _ctrl.reverse();
    });
    if (widget.haptic) {
      HapticFeedback.lightImpact();
    }
    widget.onTap?.call();
  }

  void _onLongPress() {
    if (widget.haptic) {
      HapticFeedback.mediumImpact();
    }
    widget.onLongPress?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      onLongPress: widget.onLongPress != null ? _onLongPress : null,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          final t = AnimCurves.standard.transform(_ctrl.value);
          final scale = 1.0 - (1.0 - widget.scale) * t;
          return Transform.scale(scale: scale, child: child);
        },
        child: widget.child,
      ),
    );
  }
}
