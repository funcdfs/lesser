import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lesser/features/feeds/domain/models/post.dart';
import 'package:lesser/features/feeds/presentation/providers/feeds_provider.dart';
import '../../../../shared/theme/theme.dart';
import '../screens/post_detail_screen.dart';
import 'feeds_card_skeleton.dart';
import 'post_card.dart';

/// 动态流列表组件 (Feed List)
class FeedList extends ConsumerStatefulWidget {
  final String feedType;
  final Widget? header;
  final ScrollController? controller;

  const FeedList({
    super.key,
    required this.feedType,
    this.header,
    this.controller,
  });

  @override
  ConsumerState<FeedList> createState() => _FeedListState();
}

class _FeedListState extends ConsumerState<FeedList> with AutomaticKeepAliveClientMixin {
  final ValueNotifier<bool> _showBottomActions = ValueNotifier<bool>(false);

  ScrollController? get _effectiveController =>
      widget.controller ?? (PrimaryScrollController.maybeOf(context));

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _showBottomActions.dispose();
    super.dispose();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final show = notification.metrics.pixels > MediaQuery.of(context).size.height;
      if (show != _showBottomActions.value) {
        _showBottomActions.value = show;
      }
    }
    return false;
  }

  void _scrollToTop() {
    final controller = _effectiveController;
    if (controller != null && controller.hasClients) {
      controller.animateTo(
        0.0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _navigateToDetail(Post post) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      useRootNavigator: false,
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
    super.build(context);
    final feedsAsync = ref.watch(feedsListProvider);

    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: _handleScrollNotification,
          child: CustomScrollView(
            key: PageStorageKey<String>(widget.feedType),
            controller: widget.controller,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverOverlapInjector(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              if (widget.header != null)
                SliverToBoxAdapter(child: widget.header!),
              
              feedsAsync.when(
                data: (posts) => SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = posts[index];
                      return _AnimatedPostItem(
                        index: index,
                        child: PostCard(
                          post: post,
                          onTap: () => _navigateToDetail(post),
                        ),
                      );
                    },
                    childCount: posts.length,
                  ),
                ),
                loading: () => SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const FeedsCardSkeleton(),
                    childCount: 5,
                  ),
                ),
                error: (err, stack) => SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Text('加载失败: $err'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _showBottomActions,
          builder: (context, show, child) {
            if (!show) return const SizedBox.shrink();
            return _FloatingButtons(
              onRefresh: () => ref.refresh(feedsListProvider),
              onScrollToTop: _scrollToTop,
            );
          },
        ),
      ],
    );
  }
}

class _FloatingButtons extends StatelessWidget {
  final VoidCallback onRefresh;
  final VoidCallback onScrollToTop;

  const _FloatingButtons({required this.onRefresh, required this.onScrollToTop});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 32,
      right: 24,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildButton(icon: Icons.refresh_rounded, onTap: onRefresh),
            const SizedBox(height: 16),
            _buildButton(icon: Icons.arrow_upward_rounded, onTap: onScrollToTop),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({required IconData icon, required VoidCallback onTap}) {
    return _AnimatedScaleButton(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.8),
          shape: BoxShape.circle,
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

class _AnimatedPostItem extends StatefulWidget {
  final int index;
  final Widget child;
  const _AnimatedPostItem({required this.index, required this.child});
  @override
  State<_AnimatedPostItem> createState() => _AnimatedPostItemState();
}

class _AnimatedPostItemState extends State<_AnimatedPostItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: (widget.index % 10) * 50), () {
      if (mounted) _controller.forward();
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
