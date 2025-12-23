import 'dart:math';
import 'package:flutter/material.dart';
import '../config/shadcn_theme.dart';
import '../utils/number_formatter.dart';
import '../utils/theme_constants.dart';
import '../utils/constants.dart';

/// 帖子操作栏组件
///
/// 包含点赞、评论、转发、收藏、分享等操作按钮
/// 支持响应式布局和完整的点赞动画特效
class PostActionsBar extends StatefulWidget {
  /// 点赞数
  final int likesCount;

  /// 评论数
  final int commentsCount;

  /// 转发数
  final int repostsCount;

  /// 收藏数（可选）
  final int? bookmarksCount;

  /// 分享数（可选）
  final int? sharesCount;

  /// 是否已点赞
  final bool initiallyLiked;

  /// 点赞状态变更回调
  final VoidCallback? onLikeToggle;

  /// 评论回调
  final VoidCallback? onComment;

  /// 转发回调
  final VoidCallback? onRepost;

  /// 收藏回调
  final VoidCallback? onBookmark;

  /// 分享回调
  final VoidCallback? onShare;

  /// 是否使用响应式布局
  final bool responsive;

  const PostActionsBar({
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
  State<PostActionsBar> createState() => _PostActionsBarState();
}

class _PostActionsBarState extends State<PostActionsBar> {
  /// 当前的点赞状态
  late bool _userLiked;

  @override
  void initState() {
    super.initState();
    _userLiked = widget.initiallyLiked;
  }

  @override
  void didUpdateWidget(PostActionsBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initiallyLiked != widget.initiallyLiked) {
      _userLiked = widget.initiallyLiked;
    }
  }

  /// 处理点赞按钮点击
  void _handleLikeTap() {
    setState(() {
      _userLiked = !_userLiked;
    });
    widget.onLikeToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.responsive) {
      // 非响应式布局（详情页）
      return _buildFixedLayout();
    }

    // 响应式布局（卡片）
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrowLayout =
            constraints.maxWidth < AppConstants.narrowLayoutWidth;

        if (isNarrowLayout) {
          return _buildNarrowLayout();
        } else {
          return _buildWideLayout();
        }
      },
    );
  }

  /// 构建非响应式布局
  Widget _buildFixedLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 左侧操作组
        Row(
          children: [
            PostActionButton(
              icon: Icons.favorite_border,
              count: widget.likesCount,
              onTap: _handleLikeTap,
              isLiked: _userLiked,
              isLikeButton: true,
            ),
            const SizedBox(width: ShadcnSpacing.lg),
            PostActionButton(
              icon: Icons.chat_bubble_outline,
              count: widget.commentsCount,
              onTap: widget.onComment,
            ),
            const SizedBox(width: ShadcnSpacing.lg),
            PostActionButton(
              icon: Icons.repeat,
              count: widget.repostsCount,
              onTap: widget.onRepost,
            ),
          ],
        ),
        // 右侧操作组
        Row(
          children: [
            if (widget.bookmarksCount != null)
              PostActionButton(
                icon: Icons.bookmark_border,
                count: widget.bookmarksCount,
                onTap: widget.onBookmark,
              ),
            if (widget.bookmarksCount != null && widget.sharesCount != null)
              const SizedBox(width: ShadcnSpacing.lg),
            if (widget.sharesCount != null)
              PostActionButton(
                icon: Icons.share_outlined,
                count: widget.sharesCount,
                onTap: widget.onShare,
              ),
          ],
        ),
      ],
    );
  }

  /// 构建窄屏布局（分两行）
  Widget _buildNarrowLayout() {
    return Column(
      children: [
        // 上行：点赞、评论、转发
        Align(
          alignment: Alignment.centerLeft,
          child: Transform.translate(
            offset: const Offset(-8, 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PostActionButton(
                  icon: Icons.favorite_border,
                  count: widget.likesCount,
                  onTap: _handleLikeTap,
                  isLiked: _userLiked,
                  isLikeButton: true,
                ),
                const SizedBox(width: ShadcnSpacing.sm),
                PostActionButton(
                  icon: Icons.chat_bubble_outline,
                  count: widget.commentsCount,
                  onTap: widget.onComment,
                ),
                const SizedBox(width: ShadcnSpacing.sm),
                PostActionButton(
                  icon: Icons.repeat,
                  count: widget.repostsCount,
                  onTap: widget.onRepost,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // 下行：收藏、分享
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PostActionButton(
                  icon: Icons.bookmark_border,
                  onTap: widget.onBookmark,
                ),
                const SizedBox(width: ShadcnSpacing.xs),
                PostActionButton(
                  icon: Icons.share_outlined,
                  onTap: widget.onShare,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建宽屏布局（一行）
  Widget _buildWideLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 左侧操作组
        Transform.translate(
          offset: const Offset(-8, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PostActionButton(
                icon: Icons.favorite_border,
                count: widget.likesCount,
                onTap: _handleLikeTap,
                isLiked: _userLiked,
                isLikeButton: true,
              ),
              const SizedBox(width: ShadcnSpacing.sm),
              PostActionButton(
                icon: Icons.chat_bubble_outline,
                count: widget.commentsCount,
                onTap: widget.onComment,
              ),
              const SizedBox(width: ShadcnSpacing.sm),
              PostActionButton(
                icon: Icons.repeat,
                count: widget.repostsCount,
                onTap: widget.onRepost,
              ),
            ],
          ),
        ),
        // 右侧操作组
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PostActionButton(
                icon: Icons.bookmark_border,
                onTap: widget.onBookmark,
              ),
              const SizedBox(width: ShadcnSpacing.xs),
              PostActionButton(
                icon: Icons.share_outlined,
                onTap: widget.onShare,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 单个操作按钮组件
///
/// 用于帖子操作栏中的各种按钮，如点赞、评论、转发等
/// 支持计数显示和动画效果
class PostActionButton extends StatefulWidget {
  /// 按钮图标
  final IconData icon;

  /// 计数值（可选）
  final int? count;

  /// 点击回调
  final VoidCallback? onTap;

  /// 是否已点赞（仅点赞按钮使用）
  final bool isLiked;

  /// 是否是点赞按钮（决定是否显示特殊动画效果）
  final bool isLikeButton;

  const PostActionButton({
    super.key,
    required this.icon,
    this.count,
    this.onTap,
    this.isLiked = false,
    this.isLikeButton = false,
  });

  @override
  State<PostActionButton> createState() => _PostActionButtonState();
}

class _PostActionButtonState extends State<PostActionButton>
    with TickerProviderStateMixin {
  /// 鼠标悬停状态
  bool _isHovered = false;

  /// 波纹扩散动画控制器
  late AnimationController _rippleAnimController;

  /// 粒子爆发动画控制器
  late AnimationController _burstAnimController;

  /// 波纹扩散动画
  late Animation<double> _rippleAnimation;

  /// 粒子爆发动画
  late Animation<double> _burstAnimation;

  @override
  void initState() {
    super.initState();

    // 波纹扩散动画 - 从中心向外扩散的圆形
    _rippleAnimController = AnimationController(
      duration: AppConstants.animationDurationLong,
      vsync: this,
    );
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rippleAnimController,
        curve: Curves.easeOutCubic,
      ),
    );

    // 粒子爆发动画 - 小圆点从中心向外爆发
    _burstAnimController = AnimationController(
      duration: AppConstants.animationDurationMedium,
      vsync: this,
    );
    _burstAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _burstAnimController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(PostActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当点赞状态从 false 变为 true 时，触发动画
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
        borderRadius: BorderRadius.circular(ShadcnRadius.full),
        child: AnimatedContainer(
          duration: ThemeConstants.standardAnimationDuration,
          padding: const EdgeInsets.symmetric(
            horizontal: ShadcnSpacing.sm,
            vertical: ShadcnSpacing.xs,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ShadcnRadius.full),
            color: _isHovered
                ? ShadcnColors.secondary.withValues(alpha: 0.5)
                : Colors.transparent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 图标容器（包含动画效果）
              _buildIconWithEffects(),

              // 计数文本
              if (widget.count != null && widget.count! > 0) ...[
                const SizedBox(width: 6),
                Text(
                  formatCount(widget.count!),
                  style: const TextStyle(
                    fontSize: 13,
                    color: ShadcnColors.mutedForeground,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 构建带动画效果的图标
  Widget _buildIconWithEffects() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 主图标
        Icon(
          widget.isLikeButton && widget.isLiked ? Icons.favorite : widget.icon,
          size: ActionButtonThemeConstants.buttonIconSize,
          color: widget.isLikeButton && widget.isLiked
              ? ActionButtonThemeConstants.likeButtonColor
              : (_isHovered
                    ? ThemeConstants.iconColorActive
                    : ThemeConstants.iconColorDefault),
        ),

        // 波纹扩散效果（仅在点赞按钮上）
        if (widget.isLikeButton)
          Positioned.fill(
            child: Center(
              child: AnimatedBuilder(
                animation: _rippleAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _RippleEffectPainter(
                      progress: _rippleAnimation.value,
                      color: ActionButtonThemeConstants.likeButtonColor,
                    ),
                  );
                },
              ),
            ),
          ),

        // 粒子爆发效果（仅在点赞按钮上）
        if (widget.isLikeButton)
          Positioned.fill(
            child: Center(
              child: AnimatedBuilder(
                animation: _burstAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _BurstEffectPainter(
                      progress: _burstAnimation.value,
                      color: ActionButtonThemeConstants.likeButtonColor,
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

/// 波纹扩散效果绘制器
class _RippleEffectPainter extends CustomPainter {
  /// 动画进度 [0.0, 1.0]
  final double progress;

  /// 波纹颜色
  final Color color;

  _RippleEffectPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0.0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    final currentRadius = maxRadius * progress;

    // 透明度随着扩散逐渐减弱
    final opacity = 1.0 - progress;

    final paint = Paint()
      ..color = color.withValues(alpha: opacity * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, currentRadius, paint);
  }

  @override
  bool shouldRepaint(_RippleEffectPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// 粒子爆发效果绘制器
class _BurstEffectPainter extends CustomPainter {
  /// 动画进度 [0.0, 1.0]
  final double progress;

  /// 粒子颜色
  final Color color;

  _BurstEffectPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0.0) return;

    final center = Offset(size.width / 2, size.height / 2);

    // 透明度随着移动逐渐减弱
    final opacity = 1.0 - progress;

    // 从中心向8个方向爆发小圆点
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

      // 圆点大小随着扩散逐渐减小
      final dotRadius = 2.0 * (1.0 - progress * 0.5);
      canvas.drawCircle(Offset(x, y), dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(_BurstEffectPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
