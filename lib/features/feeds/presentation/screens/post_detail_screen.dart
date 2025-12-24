import 'package:flutter/material.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/avatar.dart';
import '../../../../shared/utils/time_formatter.dart';
import '../../../../shared/models/post.dart';
import '../widgets/feeds_actions_bar.dart';
import '../widgets/feed_images_widget.dart';
import '../widgets/feeds_comment_section.dart';

/// 帖子详情屏幕
///
/// 职责：展示帖子的完整内容，包括详细的时间、全文、所有图片、交互统计以及评论区。
class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late bool _isLiked;
  late int _likesCount;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _likesCount = widget.post.likesCount;
  }

  void _handleLikeToggle() {
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // 移除 AppBar 以消除不可点击的“死区”，将整个顶部区域统一为退出触发器
      appBar: null,
      body: Stack(
        children: [
          /// 主要内容区域
          SingleChildScrollView(
            // 增加顶部内边距，确保内容不被固定的交互手柄遮挡，但不再留出过大空白
            padding: const EdgeInsets.only(top: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 头部：用户信息
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Avatar(
                        avatarUrl: widget.post.authorAvatarUrl,
                        fallbackInitials: widget.post.author.isNotEmpty
                            ? widget.post.author[0]
                            : 'U',
                        size: 44,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.post.author,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
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
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        child: const Text(
                          '关注',
                          style: TextStyle(color: AppColors.foreground),
                        ),
                      ),
                    ],
                  ),
                ),

                /// 内容：正文
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Text(
                    widget.post.content,
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.5,
                      color: AppColors.foreground,
                    ),
                  ),
                ),

                /// 内容：图片
                if (widget.post.imageUrls.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: FeedImagesWidget(imageUrls: widget.post.imageUrls),
                  ),
                ],

                /// 时间
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    '${TimeFormatter.formatAbsoluteTime(widget.post.timestamp)} · ${TimeFormatter.formatRelativeTime(widget.post.timestamp)}',
                    style: const TextStyle(
                      color: AppColors.mutedForeground,
                      fontSize: 13,
                    ),
                  ),
                ),

                const Divider(height: 1, color: AppColors.border),

                /// 交互栏
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xs,
                  ),
                  child: FeedsActionsBar(
                    likesCount: _likesCount,
                    commentsCount: widget.post.commentsCount,
                    repostsCount: widget.post.repostsCount,
                    bookmarksCount: widget.post.bookmarksCount,
                    sharesCount: widget.post.sharesCount,
                    initiallyLiked: _isLiked,
                    onLikeToggle: _handleLikeToggle,
                    responsive: false, // 详情页通常固定布局
                  ),
                ),

                const Divider(height: 1, color: AppColors.border),

                /// 评论区标题
                const Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    0,
                  ),
                  child: Text(
                    '评论',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),

                /// 评论列表 placeholder
                const FeedsCommentSection(),

                const SizedBox(height: 100), // 为底部输入留白
              ],
            ),
          ),

          /// 顶部交互手柄 - 固定在顶端且支持点击/下滑关闭
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              behavior: HitTestBehavior.opaque, // 确保透明区域也能拦截手势
              onVerticalDragUpdate: (details) {
                // 如果向下拖动超过一定阈值，则关闭
                if (details.primaryDelta != null && details.primaryDelta! > 8) {
                  Navigator.pop(context);
                }
              },
              child: Container(
                width: double.infinity,
                height: 80, // 保持 80px 的大热区，确保任何触碰都能响应
                color: Colors.transparent,
                alignment: Alignment.topCenter, // 使手柄靠近顶端，模拟纸张边缘
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12), // 顶端留出极小空隙
                    /// “纸张边缘”手柄：极细、极宽、半透明，完全融入背景
                    FractionallySizedBox(
                      widthFactor: 0.8, // 宽度扩大到 80%
                      child: Container(
                        height: 3, // 更加纤细 (从 4px 减到 3px)
                        decoration: BoxDecoration(
                          color: AppColors.border.withValues(
                            alpha: 0.2,
                          ), // 极低透明度
                          borderRadius: BorderRadius.circular(1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
