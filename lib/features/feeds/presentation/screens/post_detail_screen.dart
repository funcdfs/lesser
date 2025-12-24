import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

class _PostDetailScreenState extends State<PostDetailScreen>
    with SingleTickerProviderStateMixin {
  late bool _isLiked;
  late int _likesCount;

  /// 当前垂直拖动的偏移量 (初始预留 1.5 行高度，约 36px)
  double _dragOffset = 36.0;

  /// 用于“回弹”动画的控制器
  late AnimationController _snapController;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _likesCount = widget.post.likesCount;

    _snapController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 300),
        )..addListener(() {
          setState(() {
            _dragOffset = _snapController.value;
          });
        });
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  void _handleLikeToggle() {
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        // 系统返回手势或按钮触发时，我们已经 pop 了，不需要额外操作
        // 这里主要确保 Navigator.pop(context) 是唯一的退出入口
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Transform.translate(
          offset: Offset(0, _dragOffset),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.xl2),
              ),
              child: Scaffold(
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
                                  fallbackInitials:
                                      widget.post.author.isNotEmpty
                                      ? widget.post.author[0]
                                      : 'U',
                                  size: 44,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.full,
                                      ),
                                    ),
                                    side: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                  ),
                                  child: const Text(
                                    '关注',
                                    style: TextStyle(
                                      color: AppColors.foreground,
                                    ),
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
                              child: FeedImagesWidget(
                                imageUrls: widget.post.imageUrls,
                              ),
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
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),

                          /// 评论列表 placeholder
                          const FeedsCommentSection(),

                          const SizedBox(height: 100), // 为底部输入留白
                        ],
                      ),
                    ),

                    /// 顶部交互手柄 - 固定在顶端且支持点击/交互式下滑关闭
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        behavior: HitTestBehavior.opaque,
                        onVerticalDragUpdate: (details) {
                          setState(() {
                            // 仅允许向下拖动，最小值为 36.0 (初始位置)
                            _dragOffset = (_dragOffset + details.primaryDelta!)
                                .clamp(36.0, double.infinity);
                          });
                        },
                        onVerticalDragEnd: (details) {
                          // 如果拖动距离超过 200px (从 36px 开始) 或 向下速度够快 (v > 500)，则关闭
                          if (_dragOffset > 200 ||
                              details.primaryVelocity! > 500) {
                            Navigator.pop(context);
                          } else {
                            // 否则，平滑回弹到初始位置 (36.0)
                            _snapController.value = _dragOffset;
                            _snapController.animateTo(
                              36.0,
                              curve: Curves.easeOutQuint,
                            );
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 80, // 保持 80px 的大热区
                          color: Colors.transparent,
                          alignment: Alignment.topCenter,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              /// “弧形/阔角”手柄：代替生硬的横条，更具拉伸感
                              SizedBox(
                                width: double.infinity,
                                height: 28, // 稍微增加高度以容纳阴影/线条
                                child: SvgPicture.string(
                                  '''
                        <svg viewBox="0 0 400 24" preserveAspectRatio="none" xmlns="http://www.w3.org/2000/svg">
                          <!-- 阔角形状主体，略微加深透明度 -->
                          <path d="M0 0 L200 14 L400 0 V24 H0 Z" fill="currentColor" fill-opacity="0.25"/>
                          <!-- 定义边缘线，增强视觉引导性 -->
                          <path d="M0 0 L200 14 L400 0" fill="none" stroke="currentColor" stroke-width="2.5" stroke-opacity="0.4" stroke-linecap="round" stroke-linejoin="round"/>
                        </svg>
                        ''',
                                  colorFilter: ColorFilter.mode(
                                    PostThemeConstants.postHandleColor,
                                    BlendMode.srcIn,
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
