import 'package:flutter/material.dart';
import '../../common/models/post.dart';
import '../../theme/theme.dart';
import '../../common/widgets/shadcn/shadcn_avatar.dart';
import '../widgets/post_actions_bar.dart';
import '../widgets/comment_section.dart';

/// 帖子详情屏幕 (Post Detail Screen)
///
/// 该页面用于展示单条帖子的完整内容，包括：
/// 1. 帖子正文、图片、位置和精确发布时间。
/// 2. 交互操作栏 (点赞、评论、转发等)。
/// 3. 评论列表占位符。
/// 4. 针对帖子的管理操作菜单（不感兴趣、屏蔽、举报等）。
class DetailScreen extends StatefulWidget {
  final Post post;

  const DetailScreen({super.key, required this.post});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  /// 模拟本地点赞状态
  late bool _isLiked;

  @override
  void initState() {
    super.initState();
    _isLiked = false;
  }

  /// 切换点赞状态
  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.foreground),
        title: const Text(
          '帖子详情',
          style: TextStyle(
            color: AppColors.foreground,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 帖子核心内容区块
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 作者信息头部
                  Row(
                    children: [
                      ShadcnAvatar(
                        avatarUrl: widget.post.authorAvatarUrl,
                        fallbackInitials: widget.post.author,
                        size: 48,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.post.author,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColors.foreground,
                              ),
                            ),
                            Text(
                              widget.post.authorHandle,
                              style: const TextStyle(
                                color: AppColors.mutedForeground,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.more_horiz,
                          color: AppColors.mutedForeground,
                        ),
                        onPressed: () => _showActionMenu(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 帖子正文文本
                  Text(
                    widget.post.content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 发布时间与位置信息
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '发布时间 ',
                            style: TextStyle(
                              color: AppColors.mutedForeground,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _formatFullDate(widget.post.timestamp),
                            style: const TextStyle(
                              color: AppColors.mutedForeground,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      if (widget.post.location != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          '地点 ${widget.post.location!}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: AppSpacing.md),

                  // 交互操作栏封装组件
                  PostActionsBar(
                    likesCount: widget.post.likesCount,
                    commentsCount: widget.post.commentsCount,
                    repostsCount: widget.post.repostsCount,
                    bookmarksCount: widget.post.bookmarksCount,
                    sharesCount: widget.post.sharesCount,
                    initiallyLiked: _isLiked,
                    onLikeToggle: _toggleLike,
                    responsive: false, // 详情页通常固定排版
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),

            // 评论区组件
            CommentSection(commentCount: widget.post.commentsCount),
          ],
        ),
      ),
    );
  }

  /// 弹出针对该帖子的更多操作菜单
  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
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
              const Divider(height: 1, color: AppColors.border),
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

  /// 构建菜单中的单一可点击项
  Widget _buildActionItem(
    BuildContext context,
    String title,
    IconData icon, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        // 此处应实现具体的业务逻辑
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md + 4,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isDestructive
                  ? AppColors.destructive
                  : AppColors.foreground,
            ),
            const SizedBox(width: AppSpacing.lg),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDestructive
                    ? AppColors.destructive
                    : AppColors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 格式化为长日期字符串，例如：2023 年 12 月 23 日 周六 14:30
  String _formatFullDate(DateTime date) {
    final weekDays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final weekDay = weekDays[date.weekday - 1];

    return '${date.year} 年 ${date.month} 月 ${date.day} 日 $weekDay ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
