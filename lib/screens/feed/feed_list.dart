import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/post.dart';
import '../../config/shadcn_theme.dart';
import '../../widgets/shadcn/shadcn_avatar.dart';
import '../detail_screen.dart';
import '../../utils/number_formatter.dart';
import '../../widgets/post_card_skeleton.dart';
import '../../widgets/post_images_widget.dart';
import '../../widgets/expandable_text.dart';
import '../../widgets/animated_like_button.dart';

class FeedList extends StatefulWidget {
  final String feedType; // 'following' or 'trending'
  final Widget? header;

  const FeedList({super.key, required this.feedType, this.header});

  @override
  State<FeedList> createState() => _FeedListState();
}

class _FeedListState extends State<FeedList>
    with AutomaticKeepAliveClientMixin {
  ScrollController? _scrollController;
  bool _showBottomActions = false;
  bool _isLoading = true; // Initial loading state

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Simulate network delay
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
    // Do not dispose _scrollController as it is inherited
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController == null || !_scrollController!.hasClients) return;

    // Show bottom actions when scrolled to bottom area (e.g., last 300 pixels)
    final currentScroll = _scrollController!.position.pixels;

    // Simple check: if we are deeper than 1 screen height or near bottom
    final show = currentScroll > MediaQuery.of(context).size.height;
    if (show != _showBottomActions) {
      setState(() {
        _showBottomActions = show;
      });
    }
  }

  void _scrollToTop() {
    _scrollController?.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  Future<void> _refreshFeed() async {
    // Navigate to top and simulate refresh
    _scrollToTop();
    // In a real app, you might trigger a refresh indicator or reload data here
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Feed Refreshed')));
    }
  }

  void _navigateToDetail(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailScreen(post: post)),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Stack(
      children: [
        if (_isLoading)
          ListView.builder(
            padding: EdgeInsets.zero,
            physics:
                const NeverScrollableScrollPhysics(), // Disable scrolling while loading
            itemCount:
                5 +
                (widget.header != null ? 1 : 0), // Show 5 skeletons + header
            itemBuilder: (context, index) {
              if (widget.header != null && index == 0) {
                return widget.header!;
              }
              return const PostCardSkeleton();
            },
          )
        else
          ListView.builder(
            // controller: _scrollController, // Do NOT set controller for NestedScrollView child
            padding: EdgeInsets.zero,
            itemCount:
                mockPosts.length +
                10 +
                (widget.header != null
                    ? 1
                    : 0), // Mock infinite scroll + header
            itemBuilder: (context, index) {
              if (widget.header != null) {
                if (index == 0) return widget.header!;
                // Adjust index for posts
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
          color: ShadcnColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: ShadcnColors.primaryForeground, size: 24),
      ),
    );
  }

  Widget _buildPostItem(Post post) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ShadcnColors.border)),
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(post),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    // Header
                    Row(
                      children: [
                        Text(
                          post.author,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: ShadcnColors.foreground,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${post.authorHandle} · 2h',
                            style: const TextStyle(
                              color: ShadcnColors.mutedForeground,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.more_horiz,
                          size: 16,
                          color: ShadcnColors.mutedForeground,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Content
                    ExpandableText(
                      text: post.content,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: ShadcnColors.foreground,
                      ),
                    ),
                    if (post.imageUrls.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      PostImagesWidget(imageUrls: post.imageUrls),
                    ],
                    const SizedBox(height: 12),
                    // Actions
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
                          isLiked: false, // In a real app, bind to data
                          onData: () {
                            // Handle like API
                          },
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
      ),
    );
  }

  Widget _buildAction(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: ShadcnColors.mutedForeground),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: ShadcnColors.mutedForeground,
            ),
          ),
        ],
      ],
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

    // Stagger based on index (up to a limit to avoid long delays on scroll)
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
