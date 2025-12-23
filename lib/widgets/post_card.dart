import 'package:flutter/material.dart';
import '../config/shadcn_theme.dart';
import '../widgets/shadcn/shadcn_avatar.dart';
import '../models/post.dart';
import '../utils/number_formatter.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback onTap;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with TickerProviderStateMixin {
  late bool _isLiked;
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
          vertical: ShadcnSpacing.md
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Avatar
            ShadcnAvatar(
              avatarUrl: widget.post.authorAvatarUrl,
              fallbackInitials: widget.post.author,
              size: 40,
            ),
            const SizedBox(width: ShadcnSpacing.md),
            // Right: Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Name + Handle + Time
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
                      const SizedBox(width: ShadcnSpacing.xs),
                      Text(
                        '· ${timeAgo(widget.post.timestamp)}',
                        style: const TextStyle(
                          color: ShadcnColors.mutedForeground,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _showActionMenu(context),
                        child: const Icon(Icons.more_horiz, size: 20, color: ShadcnColors.mutedForeground),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Content
                  Text(
                    widget.post.content,
                    style: const TextStyle(
                      fontSize: 15,
                      color: ShadcnColors.foreground,
                      height: 1.4,
                    ),
                  ),
                  // Actions Row
                  Padding(
                    padding: const EdgeInsets.only(right: ShadcnSpacing.xs),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left Group: Comment, Repost, Like
                        Row(
                          children: [
                            _ActionButton(
                              icon: Icons.chat_bubble_outline,
                              count: widget.post.commentsCount,
                            ),
                            const SizedBox(width: ShadcnSpacing.sm),
                            _ActionButton(
                              icon: Icons.repeat,
                              count: widget.post.repostsCount,
                            ),
                            const SizedBox(width: ShadcnSpacing.sm),
                            _ActionButton(
                              icon: Icons.favorite_border,
                              count: widget.post.likesCount,
                              onTap: _toggleLike,
                              isLiked: _isLiked,
                              isLikeButton: true,
                            ),
                          ],
                        ),
                        // Right Group: Share, Bookmark (Book, Share)
                        // User requested: "Bookmark and Share are a group. Comment, Repost, Like are a group."
                        // Usually share is last.
                        Row(
                          children: [
                            const _ActionButton(
                              icon: Icons.bookmark_border,
                            ),
                            const SizedBox(width: ShadcnSpacing.xs), // Closer together
                            const _ActionButton(
                              icon: Icons.share_outlined,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ShadcnColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(ShadcnRadius.xl)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: ShadcnSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionItem(context, '对此帖子不感兴趣', Icons.visibility_off_outlined),
              _buildActionItem(context, '取消关注 ${widget.post.author}', Icons.person_remove_outlined),
              _buildActionItem(context, '单向隐藏 ${widget.post.author}', Icons.block_outlined),
              _buildActionItem(context, '双向屏蔽 ${widget.post.author}', Icons.do_not_disturb_on_outlined, isDestructive: true),
              const Divider(height: 1, color: ShadcnColors.border),
              _buildActionItem(context, '举报帖子', Icons.report_gmailerrorred_outlined, isDestructive: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, String title, IconData icon, {bool isDestructive = false}) {
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
              color: isDestructive ? ShadcnColors.destructive : ShadcnColors.foreground,
            ),
            const SizedBox(width: ShadcnSpacing.lg),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDestructive ? ShadcnColors.destructive : ShadcnColors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inHours < 24) {
      if (diff.inMinutes < 60) {
        return '${diff.inMinutes} 分钟前';
      }
      return '${diff.inHours} 小时前';
    }
    
    // Full Format: 2025 12 月 23 日 周二 16:35
    // Need to handle week day manually if locale not set, or use standard
    // Just using a manual builder for safety and exact requirement
    final weekDays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final weekDay = weekDays[date.weekday - 1];
    
    return '${date.year} ${date.month} 月 ${date.day} 日 $weekDay ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
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

class _ActionButtonState extends State<_ActionButton> with TickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _scaleController;
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
          padding: const EdgeInsets.symmetric(horizontal: ShadcnSpacing.sm, vertical: ShadcnSpacing.xs),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ShadcnRadius.full),
            color: _isHovered ? ShadcnColors.secondary.withValues(alpha: 0.5) : Colors.transparent,
          ),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.isLikeButton && widget.isLiked ? Icons.favorite : widget.icon,
                  size: 20,
                  color: widget.isLikeButton && widget.isLiked
                      ? const Color(0xFFEF4444)
                      : (_isHovered ? ShadcnColors.foreground : ShadcnColors.mutedForeground),
                ),
                if (widget.count != null && widget.count! > 0) ...[
                  const SizedBox(width: 6),
                  Text(
                    formatCount(widget.count!),
                    style: const TextStyle(fontSize: 13, color: ShadcnColors.mutedForeground),
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
