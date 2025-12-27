import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lesser/features/feeds/presentation/widgets/post_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lesser/features/feeds/domain/models/post.dart';
import 'package:lesser/features/feeds/presentation/providers/feeds_provider.dart';
import 'package:lesser/core/navigation/navigation_service.dart';

class FeedList extends ConsumerStatefulWidget {
  final String feedType;
  final Widget? header;
  final ScrollController? controller;

  const FeedList({
    required this.feedType,
    this.header,
    this.controller,
    super.key,
  });

  @override
  ConsumerState<FeedList> createState() => _FeedListState();
}

class _FeedListState extends ConsumerState<FeedList> {
  int _currentPage = 0;
  final List<Post> _posts = [];
  bool _isLoading = false;
  bool _hasNextPage = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _fetchPage();
  }

  Future<void> _fetchPage() async {
    if (_isLoading || !_hasNextPage) return;

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final newPosts = await ref
          .read(pagedFeedsProvider.notifier)
          .fetchPage(_currentPage + 1);

      if (!mounted) return;
      setState(() {
        _posts.addAll(newPosts);
        _isLoading = false;
        _hasNextPage = newPosts.isNotEmpty;
        if (_hasNextPage) {
          _currentPage++;
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = error;
      });
    }
  }

  void _navigateToDetail(Post post) {
    NavigationService.navigateToPostDetail(post);
  }

  @override
  Widget build(BuildContext context) {
    final pagingState = PagingState(
      pages: [_posts],
      keys: [0],
      hasNextPage: _hasNextPage,
      isLoading: _isLoading,
      error: _error,
    );

    return CustomScrollView(
      key: PageStorageKey<String>(widget.feedType),
      controller: widget.controller,
      primary: false,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        if (widget.header != null) SliverToBoxAdapter(child: widget.header!),
        PagedSliverList<int, Post>(
          state: pagingState,
          fetchNextPage: _fetchPage,
          builderDelegate: PagedChildBuilderDelegate<Post>(
            itemBuilder: (context, post, index) =>
                PostCard(post: post, onTap: () => _navigateToDetail(post)),
            firstPageProgressIndicatorBuilder: (_) =>
                const Center(child: CircularProgressIndicator()),
            newPageProgressIndicatorBuilder: (_) =>
                const Center(child: CircularProgressIndicator()),
            noItemsFoundIndicatorBuilder: (_) =>
                const Center(child: Text('No posts found')),
            firstPageErrorIndicatorBuilder: (_) =>
                const Center(child: Text('Error loading posts')),
          ),
        ),
      ],
    );
  }
}
