import 'package:flutter/material.dart';
import '../config/shadcn_theme.dart';
import '../widgets/shadcn/shadcn_avatar.dart';
import '../models/post.dart';
import '../utils/number_formatter.dart';

/// 帖子卡片组件
class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback onTap;

  const PostCard({super.key, required this.post, required this.onTap});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with TickerProviderStateMixin {
  /// 是否点赞
  late bool _isLiked;

  /// 点赞动画控制器
  late AnimationController _likeAnimationController;

  @override
  void initState() {
    super.initState();
    _isLiked = false;
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  /// 切换点赞状态
  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
    if (_isLiked) {
      _likeAnimationController.forward();
    } else {
      _likeAnimationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ShadcnSpacing.lg,
          vertical: ShadcnSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 左侧：头像
            ShadcnAvatar(
              avatarUrl: widget.post.authorAvatarUrl,
              fallbackInitials: widget.post.author,
              size: 40,
            ),
            const SizedBox(width: ShadcnSpacing.md),

            /// 右侧：内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 标题栏：用户名 + 用户句柄 + 时间
                  Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.post.author,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: ShadcnColors.foreground,
                                ),
                              ),
                              const SizedBox(width: ShadcnSpacing.xs),
                              Flexible(
                                child: Text(
                                  widget.post.authorHandle,
                                  style: const TextStyle(
                                    color: ShadcnColors.mutedForeground,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                _getRelativeTime(widget.post.timestamp),
                                style: const TextStyle(
                                  color: Color(0xAA999999),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                child: SizedBox(
                                  width: 12,
                                  height: 1,
                                  child: CustomPaint(
                                    painter: _DotSeparatorPainter(),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  _getAbsoluteTime(widget.post.timestamp),
                                  style: const TextStyle(
                                    color: Color(0xAA999999),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Positioned(
                        right: 16,
                        top: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: () => _showActionMenu(context),
                          child: const Icon(
                            Icons.more_horiz,
                            size: 20,
                            color: ShadcnColors.mutedForeground,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),

                  /// 帖子内容
                  Text(
                    widget.post.content,
                    style: const TextStyle(
                      fontSize: 15,
                      color: ShadcnColors.foreground,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  /// 操作栏
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 280;

                      if (isNarrow) {
                        // 窄屏：分两行显示
                        return Column(
                          children: [
                            /// 左侧操作组：点赞、评论、转发
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Transform.translate(
                                offset: const Offset(-8, 0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _ActionButton(
                                      icon: Icons.favorite_border,
                                      count: widget.post.likesCount,
                                      onTap: _toggleLike,
                                      isLiked: _isLiked,
                                      isLikeButton: true,
                                    ),
                                    const SizedBox(width: ShadcnSpacing.sm),
                                    _ActionButton(
                                      icon: Icons.chat_bubble_outline,
                                      count: widget.post.commentsCount,
                                    ),
                                    const SizedBox(width: ShadcnSpacing.sm),
                                    _ActionButton(
                                      icon: Icons.repeat,
                                      count: widget.post.repostsCount,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            /// 右侧操作组：收藏、分享
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const _ActionButton(
                                      icon: Icons.bookmark_border,
                                    ),
                                    const SizedBox(width: ShadcnSpacing.xs),
                                    const _ActionButton(
                                      icon: Icons.share_outlined,
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
                            /// 左侧操作组：点赞、评论、转发
                            Transform.translate(
                              offset: const Offset(-8, 0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _ActionButton(
                                    icon: Icons.favorite_border,
                                    count: widget.post.likesCount,
                                    onTap: _toggleLike,
                                    isLiked: _isLiked,
                                    isLikeButton: true,
                                  ),
                                  const SizedBox(width: ShadcnSpacing.sm),
                                  _ActionButton(
                                    icon: Icons.chat_bubble_outline,
                                    count: widget.post.commentsCount,
                                  ),
                                  const SizedBox(width: ShadcnSpacing.sm),
                                  _ActionButton(
                                    icon: Icons.repeat,
                                    count: widget.post.repostsCount,
                                  ),
                                ],
                              ),
                            ),

                            /// 右侧操作组：收藏、分享
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const _ActionButton(
                                    icon: Icons.bookmark_border,
                                  ),
                                  const SizedBox(width: ShadcnSpacing.xs),
                                  const _ActionButton(
                                    icon: Icons.share_outlined,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示更多操作菜单
  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ShadcnColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ShadcnRadius.xl),
        ),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: ShadcnSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionItem(
                context,
                '对此帖子不感兴趣',
                Icons.visibility_off_outlined,
              ),
              _buildActionItem(
                context,
                '取消关注 ${widget.post.author}',
                Icons.person_remove_outlined,
              ),
              _buildActionItem(
                context,
                '单向隐藏 ${widget.post.author}',
                Icons.block_outlined,
              ),
              _buildActionItem(
                context,
                '双向屏蔽 ${widget.post.author}',
                Icons.do_not_disturb_on_outlined,
                isDestructive: true,
              ),
              const Divider(height: 1, color: ShadcnColors.border),
              _buildActionItem(
                context,
                '举报帖子',
                Icons.report_gmailerrorred_outlined,
                isDestructive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建操作菜单项
  Widget _buildActionItem(
    BuildContext context,
    String title,
    IconData icon, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        // Implement action logic here
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ShadcnSpacing.lg,
          vertical: ShadcnSpacing.md + 4,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isDestructive
                  ? ShadcnColors.destructive
                  : ShadcnColors.foreground,
            ),
            const SizedBox(width: ShadcnSpacing.lg),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDestructive
                    ? ShadcnColors.destructive
                    : ShadcnColors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 计算时间差显示（如"5分钟前"或具体时间）
  String _getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inHours < 24) {
      return '${diff.inHours} 小时前';
    }

    if (diff.inDays < 7) {
      return '${diff.inDays} 天前';
    }

    if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return '$weeks 周前';
    }

    if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return '$months 个月前';
    }

    final years = (diff.inDays / 365).floor();
    return '$years 年前';
  }

  String _getAbsoluteTime(DateTime date) {
    final weekDays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final weekDay = weekDays[date.weekday - 1];
    return '${date.month}月${date.day}日 $weekDay ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    final weekDays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final weekDay = weekDays[date.weekday - 1];
    final timeStr =
        '${date.month}月${date.day}日 $weekDay ${date.hour}:${date.minute.toString().padLeft(2, '0')}';

    if (diff.inHours < 24) {
      // 一天内的帖子
      return '${diff.inHours} 小时前 · $timeStr';
    }

    if (diff.inDays < 7) {
      // 一周内的帖子
      return '${diff.inDays} 天前 · $timeStr';
    }

    if (diff.inDays < 30) {
      // 一月内的帖子
      final weeks = (diff.inDays / 7).floor();
      return '$weeks 周前 · $timeStr';
    }

    if (diff.inDays < 365) {
      // 一年内的帖子
      final months = (diff.inDays / 30).floor();
      return '$months 个月前 · $timeStr';
    }

    // 一年外的帖子
    final years = (diff.inDays / 365).floor();
    return '$years 年前 · $timeStr';
  }
}

/// 精致的点分隔符绘制器
class _DotSeparatorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xAA999999)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(_DotSeparatorPainter oldDelegate) => false;
}

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

  /// 缩放动画控制器
  late AnimationController _scaleController;

  /// 缩放动画
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(_ActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLiked && !oldWidget.isLiked) {
      _scaleController.forward().then((_) {
        _scaleController.reverse();
      });
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
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
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
      ),
    );
  }
}
