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
  late final PagingController<int, Post> _pagingController;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController(firstPageKey: 0);
    _pagingController.addPageRequestListener(_fetchPage);
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final posts = await ref
          .read(pagedFeedsProvider.notifier)
          .fetchPage(pageKey + 1);
      final isLastPage = posts.isEmpty;
      if (isLastPage) {
        _pagingController.appendLastPage(posts);
      } else {
        _pagingController.appendPage(posts, pageKey + 1);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  void _navigateToDetail(Post post) {
    NavigationService.navigateToPostDetail(post);
  }

  @override
  Widget build(BuildContext context) {
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
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<Post>(
            itemBuilder: (context, post, index) =>
                PostCard(post: post, onTap: () => _navigateToDetail(post)),
            firstPageProgressIndicatorBuilder: (_) =>
                const Center(child: CircularProgressIndicator()),
            newPageProgressIndicatorBuilder: (_) =>
                const Center(child: CircularProgressIndicator()),
            noItemsFoundIndicatorBuilder: (_) =>
                const Center(child: Text('No posts found')),
          ),
        ),
      ],
    );
  }
}
