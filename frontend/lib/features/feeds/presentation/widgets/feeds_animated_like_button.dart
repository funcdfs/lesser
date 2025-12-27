import 'package:flutter/material.dart';
import 'package:lesser/shared/theme/colors.dart';

/// Feed 动画点赞按钮
///
/// 特性：
/// - 支持带动画效果的点赞
/// - 使用 ScaleTransition 实现弹性缩放动画
class FeedsAnimatedLikeButton extends StatefulWidget {
  final bool isLiked;
  final VoidCallback onPressed;

  const FeedsAnimatedLikeButton({
    super.key,
    required this.isLiked,
    required this.onPressed,
  });

  @override
  State<FeedsAnimatedLikeButton> createState() =>
      _FeedsAnimatedLikeButtonState();
}

class _FeedsAnimatedLikeButtonState extends State<FeedsAnimatedLikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 1.3).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.elasticIn,
          ),
        ),
        child: Icon(
          widget.isLiked ? Icons.favorite : Icons.favorite_outline,
          color: widget.isLiked ? AppColors.error : null,
        ),
      ),
      onPressed: () {
        if (widget.isLiked) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
        widget.onPressed();
      },
    );
  }
}
