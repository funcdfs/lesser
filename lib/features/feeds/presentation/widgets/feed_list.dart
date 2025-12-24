import 'package:flutter/material.dart';
import '../../../../shared/data/mock_data.dart';
import '../../../../shared/models/post.dart';
import '../../../../shared/theme/theme.dart';
import '../screens/post_detail_screen.dart';
import 'feeds_card_skeleton.dart';
import 'post_card.dart';

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
  void dispose() {
    super.dispose();
  }

  /// 处理滚动通知，决定何时显示返回顶部按钮
  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final currentScroll = notification.metrics.pixels;
      // 当滚动超过一屏高度时，显示悬浮按钮
      final show = currentScroll > MediaQuery.of(context).size.height;
      if (show != _showBottomActions) {
        setState(() {
          _showBottomActions = show;
        });
      }
    }
    return false; // 允许通知继续向上冒泡
  }

  /// 滚动回顶部
  void _scrollToTop() {
    final controller = PrimaryScrollController.of(context);
    if (controller.hasClients) {
      controller.animateTo(
        0.0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  /// 刷新动态流
  Future<void> _refreshFeed() async {
    _scrollToTop();
    // 模拟刷新请求
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('动态已更新'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  /// 跳转至详情页
  void _navigateToDetail(Post post) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      useRootNavigator: false, // 关键：使其在内容区域内显示，不覆盖侧边栏/底栏
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650, maxHeight: 850),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: PostDetailScreen(post: post),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutQuint)),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 保持页面状态

    return Stack(
      children: [
        if (_isLoading)
          // 加载中：展示骨架屏
          NotificationListener<ScrollNotification>(
            onNotification: _handleScrollNotification,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(
                parent: NeverScrollableScrollPhysics(),
              ),
              itemCount: 5 + (widget.header != null ? 1 : 0),
              itemBuilder: (context, index) {
                if (widget.header != null && index == 0) {
                  return widget.header!;
                }
                return const FeedsCardSkeleton();
              },
            ),
          )
        else
          // 加载完成：展示实际帖子列表
          NotificationListener<ScrollNotification>(
            onNotification: _handleScrollNotification,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              itemCount:
                  mockPosts.length + 10 + (widget.header != null ? 1 : 0),
              itemBuilder: (context, index) {
                if (widget.header != null) {
                  if (index == 0) return widget.header!;
                  final postIndex = index - 1;
                  final post = mockPosts[postIndex % mockPosts.length];
                  return _AnimatedPostItem(
                    index: postIndex,
                    child: PostCard(
                      post: post,
                      onTap: () => _navigateToDetail(post),
                    ),
                  );
                }

                final post = mockPosts[index % mockPosts.length];
                return _AnimatedPostItem(
                  index: index,
                  child: PostCard(
                    post: post,
                    onTap: () => _navigateToDetail(post),
                  ),
                );
              },
            ),
          ),

        // 悬浮按钮组
        if (_showBottomActions && !_isLoading)
          Positioned(
            bottom: 32,
            right: 24,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
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
                    icon: Icons.refresh_rounded,
                    onTap: _refreshFeed,
                  ),
                  const SizedBox(height: 16),
                  _buildFloatingButton(
                    icon: Icons.arrow_upward_rounded,
                    onTap: _scrollToTop,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// 构建圆形悬浮按钮 - 使用半透明高级感
  Widget _buildFloatingButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return _AnimatedScaleButton(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.8),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.primaryForeground, size: 20),
      ),
    );
  }
}

/// 内部私有：为悬浮按钮添加点击缩放反馈
class _AnimatedScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedScaleButton({required this.child, required this.onTap});

  @override
  State<_AnimatedScaleButton> createState() => _AnimatedScaleButtonState();
}

class _AnimatedScaleButtonState extends State<_AnimatedScaleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
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
    return RepaintBoundary(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(position: _slideAnimation, child: widget.child),
      ),
    );
  }
}
