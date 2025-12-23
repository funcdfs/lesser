import 'dart:math';
import 'package:flutter/material.dart';
import '../config/shadcn_theme.dart';
import '../utils/number_formatter.dart';

/// 帖子操作栏组件
///
/// 包含点赞、评论、转发、收藏、分享等操作按钮
/// 支持响应式布局和完整的点赞动画特效
class PostActionsBar extends StatefulWidget {
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
  late bool _isLiked;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.initiallyLiked;
  }

  @override
  void didUpdateWidget(PostActionsBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initiallyLiked != widget.initiallyLiked) {
      _isLiked = widget.initiallyLiked;
    }
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
    widget.onLikeToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.responsive) {
      // 固定布局（用于详情页）
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左侧操作组
          Row(
            children: [
              _ActionButton(
                icon: Icons.favorite_border,
                count: widget.likesCount,
                onTap: _toggleLike,
                isLiked: _isLiked,
                isLikeButton: true,
              ),
              const SizedBox(width: ShadcnSpacing.lg),
              _ActionButton(
                icon: Icons.chat_bubble_outline,
                count: widget.commentsCount,
                onTap: widget.onComment,
              ),
              const SizedBox(width: ShadcnSpacing.lg),
              _ActionButton(
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
                _ActionButton(
                  icon: Icons.bookmark_border,
                  count: widget.bookmarksCount,
                  onTap: widget.onBookmark,
                ),
              if (widget.bookmarksCount != null && widget.sharesCount != null)
                const SizedBox(width: ShadcnSpacing.lg),
              if (widget.sharesCount != null)
                _ActionButton(
                  icon: Icons.share_outlined,
                  count: widget.sharesCount,
                  onTap: widget.onShare,
                ),
            ],
          ),
        ],
      );
    }

    // 响应式布局（用于卡片）
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 280;

        if (isNarrow) {
          // 窄屏：分两行显示
          return Column(
            children: [
              // 左侧操作组：点赞、评论、转发
              Align(
                alignment: Alignment.centerLeft,
                child: Transform.translate(
                  offset: const Offset(-8, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ActionButton(
                        icon: Icons.favorite_border,
                        count: widget.likesCount,
                        onTap: _toggleLike,
                        isLiked: _isLiked,
                        isLikeButton: true,
                      ),
                      const SizedBox(width: ShadcnSpacing.sm),
                      _ActionButton(
                        icon: Icons.chat_bubble_outline,
                        count: widget.commentsCount,
                        onTap: widget.onComment,
                      ),
                      const SizedBox(width: ShadcnSpacing.sm),
                      _ActionButton(
                        icon: Icons.repeat,
                        count: widget.repostsCount,
                        onTap: widget.onRepost,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // 右侧操作组：收藏、分享
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ActionButton(
                        icon: Icons.bookmark_border,
                        onTap: widget.onBookmark,
                      ),
                      const SizedBox(width: ShadcnSpacing.xs),
                      _ActionButton(
                        icon: Icons.share_outlined,
                        onTap: widget.onShare,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        } else {
          // 宽屏：一行显示，两组分开
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 左侧操作组：点赞、评论、转发
              Transform.translate(
                offset: const Offset(-8, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ActionButton(
                      icon: Icons.favorite_border,
                      count: widget.likesCount,
                      onTap: _toggleLike,
                      isLiked: _isLiked,
                      isLikeButton: true,
                    ),
                    const SizedBox(width: ShadcnSpacing.sm),
                    _ActionButton(
                      icon: Icons.chat_bubble_outline,
                      count: widget.commentsCount,
                      onTap: widget.onComment,
                    ),
                    const SizedBox(width: ShadcnSpacing.sm),
                    _ActionButton(
                      icon: Icons.repeat,
                      count: widget.repostsCount,
                      onTap: widget.onRepost,
                    ),
                  ],
                ),
              ),
              // 右侧操作组：收藏、分享
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ActionButton(
                      icon: Icons.bookmark_border,
                      onTap: widget.onBookmark,
                    ),
                    const SizedBox(width: ShadcnSpacing.xs),
                    _ActionButton(
                      icon: Icons.share_outlined,
                      onTap: widget.onShare,
                    ),
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

/// 操作按钮组件
class _ActionButton extends StatefulWidget {
  final IconData icon;
  final int? count;
  final VoidCallback? onTap;
  final bool isLiked;
  final bool isLikeButton;

  const _ActionButton({
    required this.icon,
    this.count,
    this.onTap,
    this.isLiked = false,
    this.isLikeButton = false,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with TickerProviderStateMixin {
  /// 是否悬停状态
  bool _isHovered = false;

  /// 波纹动画控制器
  late AnimationController _rippleController;

  /// 粒子动画控制器
  late AnimationController _burstController;

  /// 波纹扩散动画
  late Animation<double> _rippleAnimation;

  /// 粒子爆发动画
  late Animation<double> _burstAnimation;

  @override
  void initState() {
    super.initState();

    // 波纹扩散动画 - 从中心向外扩散的圆形
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOutCubic),
    );

    // 粒子爆发动画 - 小圆点从中心向外爆发
    _burstController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _burstAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _burstController, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(_ActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLiked && !oldWidget.isLiked) {
      // 点赞时触发动画
      _rippleController.forward(from: 0.0);
      _burstController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _burstController.dispose();
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
          duration: const Duration(milliseconds: 200),
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
              // 图标 + 特效层
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // 图标（作为 Stack 的主要子组件，决定 Stack 大小）
                  Icon(
                    widget.isLikeButton && widget.isLiked
                        ? Icons.favorite
                        : widget.icon,
                    size: 20,
                    color: widget.isLikeButton && widget.isLiked
                        ? const Color(0xFFEF4444)
                        : (_isHovered
                              ? ShadcnColors.foreground
                              : ShadcnColors.mutedForeground),
                  ),

                  // 波纹扩散效果（仅在点赞按钮上显示，不占据布局空间）
                  if (widget.isLikeButton)
                    Positioned.fill(
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _rippleAnimation,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: _RipplePainter(
                                progress: _rippleAnimation.value,
                                color: const Color(0xFFEF4444),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  // 粒子爆发效果（仅在点赞按钮上显示，不占据布局空间）
                  if (widget.isLikeButton)
                    Positioned.fill(
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _burstAnimation,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: _BurstPainter(
                                progress: _burstAnimation.value,
                                color: const Color(0xFFEF4444),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),

              // 数字（如果有）
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
}

/// 波纹扩散效果绘制器
class _RipplePainter extends CustomPainter {
  final double progress;
  final Color color;

  _RipplePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0.0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    final currentRadius = maxRadius * progress;

    // 计算透明度 - 随着扩散逐渐消失
    final opacity = 1.0 - progress;

    final paint = Paint()
      ..color = color.withValues(alpha: opacity * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, currentRadius, paint);
  }

  @override
  bool shouldRepaint(_RipplePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// 粒子爆发效果绘制器
class _BurstPainter extends CustomPainter {
  final double progress;
  final Color color;

  _BurstPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0.0) return;

    final center = Offset(size.width / 2, size.height / 2);

    // 计算透明度 - 随着移动逐渐消失
    final opacity = 1.0 - progress;

    // 绘制8个小圆点，从中心向8个方向爆发
    final angles = [0, 45, 90, 135, 180, 225, 270, 315];
    final maxDistance = 15.0;
    final currentDistance = maxDistance * progress;

    final paint = Paint()
      ..color = color.withValues(alpha: opacity * 0.8)
      ..style = PaintingStyle.fill;

    for (final angle in angles) {
      final radian = angle * 3.14159 / 180;
      final x = center.dx + currentDistance * cos(radian);
      final y = center.dy + currentDistance * sin(radian);

      // 圆点大小随着距离变小
      final dotRadius = 2.0 * (1.0 - progress * 0.5);
      canvas.drawCircle(Offset(x, y), dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(_BurstPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
