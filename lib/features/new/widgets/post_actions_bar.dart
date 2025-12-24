import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../common/utils/number_formatter.dart';
import '../../common/data/constants.dart';

/// 帖子底部操作栏组件
///
/// 功能：包含点赞、评论、转发、收藏、分享等操作按钮。
/// 特性：
/// - 支持响应式布局：根据屏幕宽度自动切换宽屏（一行显示）或窄屏（两行显示）布局。
/// - 点赞特效：集成了波纹扩散和粒子爆发动画。
/// - 逻辑解耦：通过回调函数通知父组件执行具体的业务逻辑。
class PostActionsBar extends StatefulWidget {
  /// 当前点赞总数
  final int likesCount;

  /// 当前评论总数
  final int commentsCount;

  /// 当前转发总数
  final int repostsCount;

  /// 收藏数（可选，不传则可能不显示图标）
  final int? bookmarksCount;

  /// 分享数（可选）
  final int? sharesCount;

  /// 初始点赞状态（通常来自数据模型）
  final bool initiallyLiked;

  /// 点击点赞按钮时的回调
  final VoidCallback? onLikeToggle;

  /// 点击评论按钮时的回调
  final VoidCallback? onComment;

  /// 点击转发按钮时的回调
  final VoidCallback? onRepost;

  /// 点击收藏按钮时的回调
  final VoidCallback? onBookmark;

  /// 点击分享按钮时的回调
  final VoidCallback? onShare;

  /// 是否开启响应式布局逻辑
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
            const SizedBox(width: AppSpacing.lg),
            PostActionButton(
              icon: Icons.chat_bubble_outline,
              count: widget.commentsCount,
              onTap: widget.onComment,
            ),
            const SizedBox(width: AppSpacing.lg),
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
              const SizedBox(width: AppSpacing.lg),
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
                const SizedBox(width: AppSpacing.sm),
                PostActionButton(
                  icon: Icons.chat_bubble_outline,
                  count: widget.commentsCount,
                  onTap: widget.onComment,
                ),
                const SizedBox(width: AppSpacing.sm),
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
                const SizedBox(width: AppSpacing.xs),
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
              const SizedBox(width: AppSpacing.sm),
              PostActionButton(
                icon: Icons.chat_bubble_outline,
                count: widget.commentsCount,
                onTap: widget.onComment,
              ),
              const SizedBox(width: AppSpacing.sm),
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
              const SizedBox(width: AppSpacing.xs),
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

  /// 按钮按下状态
  bool _isPressed = false;

  /// 波纹扩散动画控制器
  late AnimationController _rippleAnimController;

  /// 粒子爆发动画控制器
  late AnimationController _burstAnimController;

  /// 缩放动画控制器（用于 hover 和点击效果）
  late AnimationController _scaleAnimController;

  /// 波纹扩散动画
  late Animation<double> _rippleAnimation;

  /// 粒子爆发动画
  late Animation<double> _burstAnimation;

  /// 缩放动画
  late Animation<double> _scaleAnimation;

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

    // 缩放动画 - 用于 hover 和点击效果
    _scaleAnimController = AnimationController(
      duration: ThemeConstants.standardAnimationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _scaleAnimController, curve: Curves.easeInOut),
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
    _scaleAnimController.dispose();
    super.dispose();
  }

  /// 处理鼠标进入
  void _handleMouseEnter() {
    setState(() => _isHovered = true);
    _scaleAnimController.forward();
  }

  /// 处理鼠标离开
  void _handleMouseExit() {
    setState(() => _isHovered = false);
    _scaleAnimController.reverse();
  }

  /// 处理按下
  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    // 按下时缩小，使用动画控制器直接设置值并停止当前动画
    _scaleAnimController.stop();
    _scaleAnimController.value = 0.92; // 按下时缩小到 92%
  }

  /// 处理释放
  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    // 释放时根据 hover 状态恢复
    if (_isHovered) {
      _scaleAnimController.forward(); // 恢复到 hover 状态 (1.08)
    } else {
      _scaleAnimController.reverse(); // 恢复到正常状态 (1.0)
    }
  }

  /// 处理取消
  void _handleTapCancel() {
    setState(() => _isPressed = false);
    // 取消时根据 hover 状态恢复
    if (_isHovered) {
      _scaleAnimController.forward(); // 恢复到 hover 状态
    } else {
      _scaleAnimController.reverse(); // 恢复到正常状态
    }
  }

  @override
  Widget build(BuildContext context) {
    // 根据按钮类型确定 hover 时的背景色
    final hoverBackgroundColor = widget.isLikeButton && widget.isLiked
        ? ActionButtonThemeConstants.likeButtonColor.withValues(alpha: 0.1)
        : AppColors.secondary.withValues(alpha: 0.6);

    // 根据按钮类型确定 hover 时的图标颜色
    final hoverIconColor = widget.isLikeButton && widget.isLiked
        ? ActionButtonThemeConstants.likeButtonColor
        : (_isHovered
              ? ActionButtonThemeConstants.normalButtonHoverColor
              : ThemeConstants.iconColorDefault);

    return MouseRegion(
      onEnter: (_) => _handleMouseEnter(),
      onExit: (_) => _handleMouseExit(),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap ?? () {},
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: ThemeConstants.standardAnimationDuration,
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  color: _isHovered || _isPressed
                      ? hoverBackgroundColor
                      : Colors.transparent,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 图标容器（包含动画效果）
                    _buildIconWithEffects(hoverIconColor),

                    // 计数文本
                    if (widget.count != null && widget.count! > 0) ...[
                      const SizedBox(width: 6),
                      AnimatedDefaultTextStyle(
                        duration: ThemeConstants.standardAnimationDuration,
                        style: TextStyle(
                          fontSize: 13,
                          color: _isHovered || _isPressed
                              ? (widget.isLikeButton && widget.isLiked
                                    ? ActionButtonThemeConstants.likeButtonColor
                                    : ActionButtonThemeConstants
                                          .normalButtonHoverColor)
                              : AppColors.mutedForeground,
                          fontWeight: _isHovered || _isPressed
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        child: Text(formatCount(widget.count!)),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 构建带动画效果的图标
  Widget _buildIconWithEffects(Color hoverIconColor) {
    // 确定目标图标颜色
    final targetIconColor = widget.isLikeButton && widget.isLiked
        ? ActionButtonThemeConstants.likeButtonColor
        : hoverIconColor;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 主图标 - 使用 AnimatedSwitcher 处理图标切换，使用 TweenAnimationBuilder 处理颜色变化
        AnimatedSwitcher(
          duration: ThemeConstants.standardAnimationDuration,
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: TweenAnimationBuilder<Color?>(
            duration: ThemeConstants.standardAnimationDuration,
            curve: Curves.easeInOut,
            tween: ColorTween(end: targetIconColor),
            builder: (context, color, child) {
              return Icon(
                widget.isLikeButton && widget.isLiked
                    ? Icons.favorite
                    : widget.icon,
                key: ValueKey(
                  '${widget.isLikeButton}_${widget.isLiked}_${widget.icon}',
                ),
                size: ActionButtonThemeConstants.buttonIconSize,
                color: color ?? targetIconColor,
              );
            },
          ),
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
