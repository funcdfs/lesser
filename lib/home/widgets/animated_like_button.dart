import 'package:flutter/material.dart';
import '../../common/config/shadcn_theme.dart';

/// 带有动画效果的点赞按钮组件
class AnimatedLikeButton extends StatefulWidget {
  /// 当前是否已点赞
  final bool isLiked;

  /// 点击回调
  final VoidCallback onData;

  /// 图标大小
  final double size;

  /// 激活状态颜色（已点赞）
  final Color? activeColor;

  /// 未激活状态颜色（未点赞）
  final Color? inactiveColor;

  const AnimatedLikeButton({
    super.key,
    required this.isLiked,
    required this.onData,
    this.size = 24.0,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<AnimatedLikeButton> createState() => _AnimatedLikeButtonState();
}

class _AnimatedLikeButtonState extends State<AnimatedLikeButton>
    with SingleTickerProviderStateMixin {
  /// 缩放动画控制器
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  /// 内部点赞状态，用于快速响应交互 (乐观更新)
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // 缩放序列动画：点击后稍微变大再恢复，产生回弹感
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(covariant AnimatedLikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLiked != oldWidget.isLiked) {
      _isLiked = widget.isLiked;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 处理点击交互
  void _handleTap() {
    if (!_isLiked) {
      // 只有在从未点赞变为点赞时触发动画
      _controller.forward(from: 0.0);
    }

    // 内部状态乐观更新
    setState(() {
      _isLiked = !_isLiked;
    });

    // 通知父组件执行业务逻辑
    widget.onData();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: _isLiked
                  ? (widget.activeColor ?? ShadcnColors.foreground)
                  : (widget.inactiveColor ?? ShadcnColors.mutedForeground),
              size: widget.size,
            ),
          );
        },
      ),
    );
  }
}
