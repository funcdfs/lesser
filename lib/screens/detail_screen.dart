import 'package:flutter/material.dart';
import '../models/post.dart';
import '../config/shadcn_theme.dart';
import '../widgets/shadcn/shadcn_avatar.dart';
import '../widgets/post_actions_bar.dart';

class DetailScreen extends StatefulWidget {
  final Post post;

  const DetailScreen({super.key, required this.post});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late bool _isLiked;

  @override
  void initState() {
    super.initState();
    _isLiked = false;
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShadcnColors.background,
      appBar: AppBar(
        backgroundColor: ShadcnColors.background,
        iconTheme: const IconThemeData(color: ShadcnColors.foreground),
        title: const Text(
          '帖子详情',
          style: TextStyle(
            color: ShadcnColors.foreground,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: ShadcnColors.border, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Post Content
            Padding(
              padding: const EdgeInsets.all(ShadcnSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author Header
                  Row(
                    children: [
                      ShadcnAvatar(
                        avatarUrl: widget.post.authorAvatarUrl,
                        fallbackInitials: widget.post.author,
                        size: 48,
                      ),
                      const SizedBox(width: ShadcnSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.post.author,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: ShadcnColors.foreground,
                              ),
                            ),
                            Text(
                              widget.post.authorHandle,
                              style: const TextStyle(
                                color: ShadcnColors.mutedForeground,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.more_horiz,
                          color: ShadcnColors.mutedForeground,
                        ),
                        onPressed: () => _showActionMenu(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: ShadcnSpacing.lg),
                  // Text Content
                  Text(
                    widget.post.content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: ShadcnColors.foreground,
                    ),
                  ),
                  const SizedBox(height: ShadcnSpacing.lg),
                  // Timestamp and Location
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '发布时间 ',
                            style: TextStyle(
                              color: ShadcnColors.mutedForeground,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _formatFullDate(widget.post.timestamp),
                            style: const TextStyle(
                              color: ShadcnColors.mutedForeground,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      if (widget.post.location != null) ...[
                        const SizedBox(height: ShadcnSpacing.sm),
                        Text(
                          '地点 ${widget.post.location!}',
                          style: const TextStyle(
                            color: ShadcnColors.primary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: ShadcnSpacing.lg),
                  const Divider(color: ShadcnColors.border),
                  const SizedBox(height: ShadcnSpacing.md),
                  // 操作栏
                  PostActionsBar(
                    likesCount: widget.post.likesCount,
                    commentsCount: widget.post.commentsCount,
                    repostsCount: widget.post.repostsCount,
                    bookmarksCount: widget.post.bookmarksCount,
                    sharesCount: widget.post.sharesCount,
                    initiallyLiked: _isLiked,
                    onLikeToggle: _toggleLike,
                    responsive: false,
                  ),
                  const SizedBox(height: ShadcnSpacing.md),
                ],
              ),
            ),

            const Divider(color: ShadcnColors.border, thickness: 8, height: 8),

            // Comments Section Placeholder
            Container(
              padding: const EdgeInsets.all(ShadcnSpacing.lg),
              alignment: Alignment.centerLeft,
              child: const Text(
                '评论',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ShadcnColors.foreground,
                ),
              ),
            ),
            // Placeholder List
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 3,
              separatorBuilder: (context, index) =>
                  const Divider(color: ShadcnColors.border, height: 1),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ShadcnSpacing.lg,
                    vertical: ShadcnSpacing.lg,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: ShadcnColors.secondary,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'U${index + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: ShadcnColors.foreground,
                          ),
                        ),
                      ),
                      const SizedBox(width: ShadcnSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'User ${index + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: ShadcnColors.foreground,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '2h',
                                  style: TextStyle(
                                    color: ShadcnColors.mutedForeground,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '这是一个评论占位符。真正的评论功能将在稍后实现。',
                              style: TextStyle(color: ShadcnColors.foreground),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            // Bottom spacing
            const SizedBox(height: 40),
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

  String _formatFullDate(DateTime date) {
    final weekDays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final weekDay = weekDays[date.weekday - 1];

    return '${date.year} 年 ${date.month} 月 ${date.day} 日 $weekDay ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
