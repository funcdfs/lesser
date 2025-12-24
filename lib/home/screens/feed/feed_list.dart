import 'package:flutter/material.dart';
import '../../../common/data/mock_data.dart';
import '../../../common/models/post.dart';
import '../../../theme/theme.dart';
import '../../../common/widgets/shadcn/shadcn_avatar.dart';
import '../../../post/screens/detail_screen.dart';
import '../../../common/utils/number_formatter.dart';
import '../../../post/widgets/post_card_skeleton.dart';
import '../../../post/widgets/post_images_widget.dart';
import '../../../common/widgets/expandable_text.dart';
import '../../../post/widgets/animated_like_button.dart';

/// 动态流列表组件 (Feed List)
///
/// 这是一个通用的帖子列表容器，支持：
/// 1. 骨架屏加载状态 (Skeleton Loading)。
/// 2. 模拟下拉刷新和向上平滑滚动。
/// 3. 基于 NestedScrollView 的滚动容器适配。
/// 4. 帖子列表渲染及加载更多模拟。
/// 5. 悬浮快捷按钮组（刷新、回到顶部）。
class FeedList extends StatefulWidget {
  /// 动态流类型：'following' (关注) 或 'trending' (推荐/热门)
  final String feedType;

  /// 可选的列表头部组件（例如故事栏）
  final Widget? header;

  const FeedList({super.key, required this.feedType, this.header});

  @override
  State<FeedList> createState() => _FeedListState();
}

class _FeedListState extends State<FeedList>
    with AutomaticKeepAliveClientMixin {
  ScrollController? _scrollController;

  /// 是否显示右下角的悬浮按钮组
  bool _showBottomActions = false;

  /// 初始加载状态
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // 模拟网络请求延迟，展示骨架屏效果
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 获取当前环境的滚动控制器（通常由父级的 NestedScrollView 提供）
    final newController = PrimaryScrollController.of(context);
    if (_scrollController != newController) {
      _scrollController?.removeListener(_onScroll);
      _scrollController = newController;
      _scrollController?.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  /// 滚动监听，决定何时显示返回顶部按钮
  void _onScroll() {
    if (_scrollController == null || !_scrollController!.hasClients) return;

    final currentScroll = _scrollController!.position.pixels;

    // 当滚动超过一屏高度时，显示悬浮按钮
    final show = currentScroll > MediaQuery.of(context).size.height;
    if (show != _showBottomActions) {
      setState(() {
        _showBottomActions = show;
      });
    }
  }

  /// 滚动回顶部
  void _scrollToTop() {
    _scrollController?.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  /// 刷新动态流
  Future<void> _refreshFeed() async {
    _scrollToTop();
    // 模拟刷新请求
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('动态已更新')));
    }
  }

  /// 跳转至详情页
  void _navigateToDetail(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailScreen(post: post)),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 保持页面状态

    return Stack(
      children: [
        if (_isLoading)
          // 加载中：展示骨架屏
          ListView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5 + (widget.header != null ? 1 : 0),
            itemBuilder: (context, index) {
              if (widget.header != null && index == 0) {
                return widget.header!;
              }
              return const PostCardSkeleton();
            },
          )
        else
          // 加载完成：展示实际帖子列表
          ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: mockPosts.length + 10 + (widget.header != null ? 1 : 0),
            itemBuilder: (context, index) {
              if (widget.header != null) {
                if (index == 0) return widget.header!;
                final postIndex = index - 1;
                final post = mockPosts[postIndex % mockPosts.length];
                return _AnimatedPostItem(
                  index: postIndex,
                  child: _buildPostItem(post),
                );
              }

              final post = mockPosts[index % mockPosts.length];
              return _AnimatedPostItem(
                index: index,
                child: _buildPostItem(post),
              );
            },
          ),

        // 悬浮按钮组
        if (_showBottomActions && !_isLoading)
          Positioned(
            bottom: 24,
            right: 16,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFloatingButton(
                    icon: Icons.refresh,
                    onTap: _refreshFeed,
                  ),
                  const SizedBox(height: 12),
                  _buildFloatingButton(
                    icon: Icons.arrow_upward,
                    onTap: _scrollToTop,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// 构建圆形悬浮按钮
  Widget _buildFloatingButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.primaryForeground, size: 24),
      ),
    );
  }

  /// 构建单个帖子条目
  Widget _buildPostItem(Post post) {
    return InkWell(
      onTap: () => _navigateToDetail(post),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 作者头像
            ShadcnAvatar(
              avatarUrl: post.authorAvatarUrl,
              fallbackInitials: post.author,
              size: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 帖子头部：作者名、账号、时间、更多按钮
                  Row(
                    children: [
                      Text(
                        post.author,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColors.foreground,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${post.authorHandle} · 2h',
                          style: const TextStyle(
                            color: AppColors.mutedForeground,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.more_horiz,
                        size: 16,
                        color: AppColors.mutedForeground,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // 正文内容：支持展开折叠
                  ExpandableText(
                    text: post.content,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: AppColors.foreground,
                    ),
                  ),
                  // 图片区域
                  if (post.imageUrls.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    PostImagesWidget(imageUrls: post.imageUrls),
                  ],
                  const SizedBox(height: 12),
                  // 操作按钮组：评论、转发、点赞、分享
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildAction(
                        Icons.chat_bubble_outline,
                        formatCount(post.commentsCount),
                      ),
                      _buildAction(
                        Icons.repeat,
                        formatCount(post.repostsCount),
                      ),
                      AnimatedLikeButton(
                        isLiked: false,
                        onData: () {},
                        size: 18,
                      ),
                      _buildAction(Icons.share_outlined, ''),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建底部操作小图标和计数
  Widget _buildAction(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.mutedForeground),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ],
    );
  }
}

/// 内部私有：为帖子条目添加进场动画（渐变+位移）
class _AnimatedPostItem extends StatefulWidget {
  final int index;
  final Widget child;

  const _AnimatedPostItem({required this.index, required this.child});

  @override
  State<_AnimatedPostItem> createState() => _AnimatedPostItemState();
}

class _AnimatedPostItemState extends State<_AnimatedPostItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // 根据索引执行交错动画效果
    final delay = (widget.index % 10) * 50;
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}
