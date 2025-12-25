import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/number_formatter.dart';

/// Feed 操作栏组件
///
/// 功能：包含点赞、评论、转发、收藏、分享等操作按钮。
/// 特性：
/// - 支持响应式布局：根据屏幕宽度自动切换宽屏（一行显示）或窄屏（两行显示）布局。
/// - 点赞特效：集成了波纹扩散和粒子爆发动画。
class FeedsActionsBar extends StatefulWidget {
  final int likesCount;
  final int commentsCount;
  final int repostsCount;
  final int? bookmarksCount;
  final int? sharesCount;
  final bool initiallyLiked;
  final VoidCallback? onLikeToggle;
  final VoidCallback? onComment;
  final VoidCallback? onRepost;
  final VoidCallback? onBookmark;
  final VoidCallback? onShare;
  final bool responsive;

  const FeedsActionsBar({
    super.key,
    required this.likesCount,
    required this.commentsCount,
    required this.repostsCount,
    this.bookmarksCount,
    this.sharesCount,
    this.initiallyLiked = false,
    this.onLikeToggle,
    this.onComment,
    this.onRepost,
    this.onBookmark,
    this.onShare,
    this.responsive = true,
  });

  @override
  State<FeedsActionsBar> createState() => _FeedsActionsBarState();
}

class _FeedsActionsBarState extends State<FeedsActionsBar> {
  late bool _userLiked;

  @override
  void initState() {
    super.initState();
    _userLiked = widget.initiallyLiked;
  }

  @override
  void didUpdateWidget(FeedsActionsBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initiallyLiked != widget.initiallyLiked) {
      _userLiked = widget.initiallyLiked;
    }
  }

  void _handleLikeTap() {
    setState(() {
      _userLiked = !_userLiked;
    });
    widget.onLikeToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    // 桌面布局或宽屏布局建议
    final isWide =
        widget.responsive && MediaQuery.of(context).size.width >= 640;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: isWide ? _buildWideLayout() : _buildCompactLayout(),
    );
  }

  Widget _buildCompactLayout() {
    return Row(
      children: [
        // Left group: Like, Comment, Repost
        FeedsActionButton(
          icon: Icons.favorite_border,
          count:
              widget.likesCount +
              (_userLiked && !widget.initiallyLiked
                  ? 1
                  : (!_userLiked && widget.initiallyLiked ? -1 : 0)),
          isLiked: _userLiked,
          isLikeButton: true,
          onTap: _handleLikeTap,
        ),
        FeedsActionButton(
          icon: Icons.chat_bubble_outline,
          count: widget.commentsCount,
          onTap: widget.onComment,
        ),
        FeedsActionButton(
          icon: Icons.repeat,
          count: widget.repostsCount,
          onTap: widget.onRepost,
        ),
        const Spacer(),
        // Right group: Bookmark, Share
        if (widget.bookmarksCount != null)
          FeedsActionButton(
            icon: Icons.bookmark_outline,
            count: widget.bookmarksCount,
            onTap: widget.onBookmark,
          ),
        FeedsActionButton(
          icon: Icons.share_outlined,
          count: widget.sharesCount,
          onTap: widget.onShare,
        ),
      ],
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        FeedsActionButton(
          icon: Icons.favorite_border,
          count:
              widget.likesCount +
              (_userLiked && !widget.initiallyLiked
                  ? 1
                  : (!_userLiked && widget.initiallyLiked ? -1 : 0)),
          isLiked: _userLiked,
          isLikeButton: true,
          onTap: _handleLikeTap,
        ),
        const SizedBox(width: AppSpacing.lg),
        FeedsActionButton(
          icon: Icons.chat_bubble_outline,
          count: widget.commentsCount,
          onTap: widget.onComment,
        ),
        const SizedBox(width: AppSpacing.lg),
        FeedsActionButton(
          icon: Icons.repeat,
          count: widget.repostsCount,
          onTap: widget.onRepost,
        ),
        const Spacer(),
        if (widget.bookmarksCount != null) ...[
          FeedsActionButton(
            icon: Icons.bookmark_outline,
            count: widget.bookmarksCount,
            onTap: widget.onBookmark,
          ),
          const SizedBox(width: AppSpacing.md),
        ],
        FeedsActionButton(
          icon: Icons.share_outlined,
          count: widget.sharesCount,
          onTap: widget.onShare,
        ),
      ],
    );
  }
}

class FeedsActionButton extends StatefulWidget {
  final IconData icon;
  final int? count;
  final VoidCallback? onTap;
  final bool isLiked;
  final bool isLikeButton;

  const FeedsActionButton({
    super.key,
    required this.icon,
    this.count,
    this.onTap,
    this.isLiked = false,
    this.isLikeButton = false,
  });

  @override
  State<FeedsActionButton> createState() => _FeedsActionButtonState();
}

class _FeedsActionButtonState extends State<FeedsActionButton>
    with TickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _rippleAnimController;
  late AnimationController _burstAnimController;
  late Animation<double> _rippleAnimation;
  late Animation<double> _burstAnimation;

  @override
  void initState() {
    super.initState();
    _rippleAnimController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rippleAnimController,
        curve: Curves.easeOutCubic,
      ),
    );

    _burstAnimController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _burstAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _burstAnimController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(FeedsActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLiked && !oldWidget.isLiked) {
      _rippleAnimController.forward(from: 0.0);
      _burstAnimController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _rippleAnimController.dispose();
    _burstAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap ?? () {},
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.full),
            color: _isHovered
                ? AppColors.secondary.withValues(alpha: 0.5)
                : Colors.transparent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIconWithEffects(),
              if (widget.count != null && widget.count! > 0) ...[
                const SizedBox(width: 6),
                Text(
                  formatCount(widget.count!),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconWithEffects() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          widget.isLikeButton && widget.isLiked ? Icons.favorite : widget.icon,
          size: 18,
          color: widget.isLikeButton && widget.isLiked
              ? AppColors.destructive
              : (_isHovered ? AppColors.foreground : AppColors.mutedForeground),
        ),
        if (widget.isLikeButton)
          Positioned.fill(
            child: Center(
              child: AnimatedBuilder(
                animation: _rippleAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _RippleEffectPainter(
                      progress: _rippleAnimation.value,
                      color: AppColors.destructive,
                    ),
                  );
                },
              ),
            ),
          ),
        if (widget.isLikeButton)
          Positioned.fill(
            child: Center(
              child: AnimatedBuilder(
                animation: _burstAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _BurstEffectPainter(
                      progress: _burstAnimation.value,
                      color: AppColors.destructive,
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _RippleEffectPainter extends CustomPainter {
  final double progress;
  final Color color;
  _RippleEffectPainter({required this.progress, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0.0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    final currentRadius = maxRadius * progress;
    final opacity = 1.0 - progress;
    final paint = Paint()
      ..color = color.withValues(alpha: opacity * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, currentRadius, paint);
  }

  @override
  bool shouldRepaint(_RippleEffectPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _BurstEffectPainter extends CustomPainter {
  final double progress;
  final Color color;
  _BurstEffectPainter({required this.progress, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0.0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final opacity = 1.0 - progress;
    const particleCount = 8;
    final angleStep = 360.0 / particleCount;
    final maxDistance = 15.0;
    final currentDistance = maxDistance * progress;
    final paint = Paint()
      ..color = color.withValues(alpha: opacity * 0.8)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < particleCount; i++) {
      final angle = angleStep * i;
      final radian = angle * 3.14159 / 180;
      final x = center.dx + currentDistance * cos(radian);
      final y = center.dy + currentDistance * sin(radian);
      final dotRadius = 2.0 * (1.0 - progress * 0.5);
      canvas.drawCircle(Offset(x, y), dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(_BurstEffectPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
