import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../common/widgets/shadcn/shadcn_avatar.dart';
import 'post_actions_bar.dart';
import '../../common/models/post.dart';
import '../../theme/theme.dart';
import '../../common/utils/time_formatter.dart';

/// 帖子卡片组件
///
/// 职责：负责展示单个帖子的核心信息流视图。
/// 布局结构：
/// - 左侧：作者头像。
/// - 右侧：
///   - 顶部：作者名、账号句柄、发布时间及更多菜单按钮。
///   - 中间：帖子正文内容。
///   - 底部：交互操作栏（PostActionsBar）。
class PostCard extends StatefulWidget {
  /// 帖子数据实体
  final Post post;

  /// 整个卡片的点击回调（通常用于跳转到详情页）
  final VoidCallback onTap;

  /// 点赞状态发生改变时的回调（用于父组件同步状态）
  final ValueChanged<bool>? onLikeChanged;

  /// 点击顶部"更多"按钮时的回调
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
  /// 当前点赞状态（来自 Post 模型）
  late bool _postIsLiked;

  /// 当前点赞数（支持乐观更新）
  late int _currentLikeCount;

  @override
  void initState() {
    super.initState();
    _postIsLiked = widget.post.isLiked;
    _currentLikeCount = widget.post.likesCount;
  }

  @override
  void didUpdateWidget(covariant PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.post.id != oldWidget.post.id) {
      _postIsLiked = widget.post.isLiked;
      _currentLikeCount = widget.post.likesCount;
    }
  }

  /// 处理点赞按钮点击
  void _handleLikeTap() {
    setState(() {
      _postIsLiked = !_postIsLiked;
      // 乐观更新点赞计数
      _currentLikeCount += _postIsLiked ? 1 : -1;
    });

    // 通知父组件点赞状态已改变
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
          horizontal: PostThemeConstants.postCardPaddingHorizontal,
          vertical: PostThemeConstants.postCardPaddingVertical,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 左侧：用户头像
            _buildUserAvatar(),
            const SizedBox(width: ShadcnSpacing.md),

            /// 右侧：主要内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 标题栏：用户名、句柄、时间、更多菜单
                  _buildHeaderRow(),
                  const SizedBox(height: 8),

                  /// 帖子文本内容
                  _buildContentText(),
                  const SizedBox(height: 12),

                  /// 操作栏（点赞、评论、转发等）
                  _buildActionsBar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建用户头像
  Widget _buildUserAvatar() {
    return ShadcnAvatar(
      avatarUrl: widget.post.authorAvatarUrl,
      fallbackInitials: widget.post.author,
      size: PostThemeConstants.postAvatarSize,
    );
  }

  /// 构建头部信息行（用户名、句柄、时间、菜单）
  Widget _buildHeaderRow() {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 用户名和句柄
            _buildAuthorInfo(),
            const SizedBox(height: 2),

            /// 时间信息
            _buildTimestampInfo(),
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
                color: ThemeConstants.iconColorMuted,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建作者信息（用户名和句柄）
  Widget _buildAuthorInfo() {
    return Row(
      children: [
        Text(widget.post.author, style: PostThemeConstants.postAuthorNameStyle),
        const SizedBox(width: ShadcnSpacing.xs),
        Flexible(
          child: Text(
            widget.post.authorHandle,
            style: PostThemeConstants.postAuthorHandleStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// 构建时间戳信息（相对时间和绝对时间）
  Widget _buildTimestampInfo() {
    final relativeTime = TimeFormatter.formatRelativeTime(
      widget.post.timestamp,
    );
    final absoluteTime = TimeFormatter.formatAbsoluteTime(
      widget.post.timestamp,
    );

    return Row(
      children: [
        Text(relativeTime, style: PostThemeConstants.postTimestampStyle),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: ShadcnSpacing.xs),
          child: Container(
            width: 12,
            height: 1,
            color: ThemeConstants.separatorColor,
          ),
        ),
        Expanded(
          child: Text(
            absoluteTime,
            style: PostThemeConstants.postTimestampStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// 构建帖子内容文本
  Widget _buildContentText() {
    return Text(
      widget.post.content,
      style: PostThemeConstants.postContentStyle,
    );
  }

  /// 构建操作栏
  Widget _buildActionsBar() {
    return PostActionsBar(
      likesCount: _currentLikeCount,
      commentsCount: widget.post.commentsCount,
      repostsCount: widget.post.repostsCount,
      bookmarksCount: widget.post.bookmarksCount,
      sharesCount: widget.post.sharesCount,
      initiallyLiked: _postIsLiked,
      onLikeToggle: _handleLikeTap,
      responsive: true,
    );
  }

  /// 显示更多操作菜单
  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: PostThemeConstants.postBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ShadcnRadius.xl),
        ),
      ),
      builder: (context) => _buildActionMenuSheet(context),
    );
  }

  /// 构建操作菜单 Sheet
  Widget _buildActionMenuSheet(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: ShadcnSpacing.lg),
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
            const Divider(height: 1, color: PostThemeConstants.postBorderColor),
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

  /// 构建单个菜单项
  Widget _buildActionMenuItem(
    BuildContext context,
    String label,
    IconData icon, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        // TODO: 实现具体的操作逻辑
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
              size: ThemeConstants.iconSizeLarge,
              color: isDestructive
                  ? ThemeConstants.errorColor
                  : ThemeConstants.enabledColor,
            ),
            const SizedBox(width: ShadcnSpacing.lg),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDestructive
                    ? ThemeConstants.errorColor
                    : ThemeConstants.enabledColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

