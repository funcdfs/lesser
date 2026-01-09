// 评论高亮动画组件
//
// 用于深层链接导航时高亮目标评论

import 'package:flutter/material.dart';
import '../../ui/theme/theme.dart';

/// 高亮动画时长（较长，用于吸引注意力）
const _highlightDuration = Duration(milliseconds: 1500);

/// 评论高亮动画组件
///
/// 包裹评论项，在需要时显示高亮动画效果
class CommentHighlight extends StatefulWidget {
  const CommentHighlight({
    super.key,
    required this.child,
    this.isHighlighted = false,
    this.onHighlightComplete,
  });

  /// 子组件
  final Widget child;

  /// 是否高亮
  final bool isHighlighted;

  /// 高亮动画完成回调
  final VoidCallback? onHighlightComplete;

  @override
  State<CommentHighlight> createState() => _CommentHighlightState();
}

class _CommentHighlightState extends State<CommentHighlight>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shadowAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: _highlightDuration,
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
      TweenSequenceItem(tween: ConstantTween<double>(1), weight: 40),
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
      TweenSequenceItem(tween: ConstantTween<double>(0.15), weight: 40),
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
  void didUpdateWidget(CommentHighlight oldWidget) {
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

        return Container(
          decoration: BoxDecoration(
            color: colors.accent.withValues(alpha: opacityValue),
            borderRadius: BorderRadius.circular(12),
            boxShadow: shadowValue > 0
                ? [
                    BoxShadow(
                      color: colors.accent.withValues(alpha: 0.3 * shadowValue),
                      blurRadius: 12 * shadowValue,
                      spreadRadius: 2 * shadowValue,
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
