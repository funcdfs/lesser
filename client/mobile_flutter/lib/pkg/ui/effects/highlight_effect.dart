// 通用高亮动画效果组件
//
// 用于深层链接导航时高亮目标内容（消息、评论等）

import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// 高亮动画时长（较长，用于吸引用户注意力）
const _kHighlightDuration = Duration(milliseconds: 1500);

/// 通用高亮效果组件
///
/// 包裹任意内容，在需要时显示高亮动画效果
/// 支持阴影闪动和背景色渐变
class HighlightEffect extends StatefulWidget {
  const HighlightEffect({
    super.key,
    required this.child,
    this.isHighlighted = false,
    this.onHighlightComplete,
    this.borderRadius = 12.0,
  });

  /// 子组件
  final Widget child;

  /// 是否高亮
  final bool isHighlighted;

  /// 高亮动画完成回调
  final VoidCallback? onHighlightComplete;

  /// 圆角半径
  final double borderRadius;

  @override
  State<HighlightEffect> createState() => _HighlightEffectState();
}

class _HighlightEffectState extends State<HighlightEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shadowAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: _kHighlightDuration,
      vsync: this,
    );

    // 阴影动画：先增强后消失
    _shadowAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 1), weight: 40),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: 0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
    ]).animate(_controller);

    // 透明度动画：淡入淡出
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: 0.15,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.15, end: 0.15),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.15,
          end: 0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
    ]).animate(_controller);

    _controller.addStatusListener(_onAnimationStatus);

    if (widget.isHighlighted) {
      _startHighlight();
    }
  }

  @override
  void didUpdateWidget(HighlightEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHighlighted && !oldWidget.isHighlighted) {
      _startHighlight();
    }
  }

  void _startHighlight() {
    _controller.forward(from: 0);
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onHighlightComplete?.call();
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onAnimationStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final shadowValue = _shadowAnimation.value;
        final opacityValue = _opacityAnimation.value;

        // 无动画时直接返回子组件，避免不必要的 Container 包装
        if (shadowValue == 0 && opacityValue == 0) {
          return child!;
        }

        return Container(
          decoration: BoxDecoration(
            color: colors.accentSoft.withValues(alpha: opacityValue),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: shadowValue > 0
                ? [
                    BoxShadow(
                      color: colors.accent.withValues(
                        alpha: 0.25 * shadowValue,
                      ),
                      blurRadius: 10 * shadowValue,
                      spreadRadius: 1 * shadowValue,
                    ),
                  ]
                : null,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
