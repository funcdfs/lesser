import 'package:flutter/material.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/avatar.dart';
import '../../../../shared/utils/time_formatter.dart';
import '../../../../shared/models/post.dart';
import 'feeds_actions_bar.dart';
import 'feed_images_widget.dart';
import '../../../../shared/widgets/expandable_text.dart';

/// 帖子卡片组件
///
/// 职责：负责展示单个帖子的核心信息流视图。
/// 布局结构：
/// - 左侧：作者头像。
/// - 右侧：
///   - 顶部：作者名、账号句柄、发布时间及更多菜单按钮。
///   - 中间：帖子正文内容。
///   - 底部：交互操作栏 (FeedsActionsBar)。
class PostCard extends StatefulWidget {
  /// 帖子数据实体
  final Post post;

  /// 整个卡片的点击回调（通常用于跳转到详情页）
  final VoidCallback onTap;

  /// 点赞状态发生改变时的回调（用于父组件同步状态）
  final ValueChanged<bool>? onLikeChanged;

  /// 点击顶部“更多”按钮时的回调
  final VoidCallback? onMoreTapped;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    this.onLikeChanged,
    this.onMoreTapped,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  /// 当前点赞状态
  late bool _postIsLiked;

  /// 当前点赞数（支持乐观更新）
  late int _currentLikeCount;

  @override
  void initState() {
    super.initState();
    _postIsLiked = widget.post.isLiked;
    _currentLikeCount = widget.post.likesCount;
  }

  /// 处理点赞按钮点击
  void _handleLikeTap() {
    setState(() {
      _postIsLiked = !_postIsLiked;
      _currentLikeCount += _postIsLiked ? 1 : -1;
    });
    widget.onLikeChanged?.call(_postIsLiked);
  }

  /// 处理更多操作菜单
  void _handleMoreTapped() {
    widget.onMoreTapped?.call();
    _showActionMenu(context);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 左侧：用户头像
            Avatar(
              avatarUrl: widget.post.authorAvatarUrl,
              fallbackInitials: widget.post.author.isNotEmpty
                  ? widget.post.author[0]
                  : 'U',
              size: 40,
            ),
            const SizedBox(width: AppSpacing.md),

            /// 右侧：主要内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 标题栏：用户名、句柄、时间、更多菜单
                  _buildHeaderRow(),
                  const SizedBox(height: 8),

                  /// 帖子文本内容
                  ExpandableText(
                    text: widget.post.content,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: AppColors.foreground,
                    ),
                  ),

                  /// 图片区域
                  if (widget.post.imageUrls.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    FeedImagesWidget(imageUrls: widget.post.imageUrls),
                  ],

                  const SizedBox(height: 12),

                  /// 操作栏（点赞、评论、转发等）
                  FeedsActionsBar(
                    likesCount: _currentLikeCount,
                    commentsCount: widget.post.commentsCount,
                    repostsCount: widget.post.repostsCount,
                    bookmarksCount: widget.post.bookmarksCount,
                    sharesCount: widget.post.sharesCount,
                    initiallyLiked: _postIsLiked,
                    onLikeToggle: _handleLikeTap,
                    responsive: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 用户名和句柄
            Row(
              children: [
                Text(
                  widget.post.author,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    widget.post.authorHandle,
                    style: const TextStyle(
                      color: AppColors.mutedForeground,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),

            /// 时间信息
            Row(
              children: [
                Text(
                  TimeFormatter.formatRelativeTime(widget.post.timestamp),
                  style: const TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  child: Container(
                    width: 12,
                    height: 1,
                    color: AppColors.border,
                  ),
                ),
                Expanded(
                  child: Text(
                    TimeFormatter.formatAbsoluteTime(widget.post.timestamp),
                    style: const TextStyle(
                      color: AppColors.mutedForeground,
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

        /// 更多操作菜单按钮
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: _handleMoreTapped,
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                Icons.more_horiz,
                size: 20,
                color: AppColors.mutedForeground,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => _buildActionMenuSheet(context),
    );
  }

  Widget _buildActionMenuSheet(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionMenuItem(
              context,
              '对此帖子不感兴趣',
              Icons.visibility_off_outlined,
            ),
            _buildActionMenuItem(
              context,
              '取消关注 ${widget.post.author}',
              Icons.person_remove_outlined,
            ),
            _buildActionMenuItem(
              context,
              '单向隐藏 ${widget.post.author}',
              Icons.block_outlined,
            ),
            _buildActionMenuItem(
              context,
              '双向屏蔽 ${widget.post.author}',
              Icons.do_not_disturb_on_outlined,
              isDestructive: true,
            ),
            const Divider(height: 1, color: AppColors.border),
            _buildActionMenuItem(
              context,
              '举报帖子',
              Icons.report_gmailerrorred_outlined,
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionMenuItem(
    BuildContext context,
    String label,
    IconData icon, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
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
              label,
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
}
