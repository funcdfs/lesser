import 'package:flutter/material.dart';
import '../config/shadcn_theme.dart';

class AnimatedLikeButton extends StatefulWidget {
  final bool isLiked;
  final VoidCallback onData;
  final double size;
  final Color? activeColor;
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
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

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

  void _handleTap() {
    if (!_isLiked) {
      // Animate if becoming liked
      _controller.forward(from: 0.0);
    }

    // Optimistic update locally
    setState(() {
      _isLiked = !_isLiked;
    });

    // Notify parent
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
