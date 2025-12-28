import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/feed_item.dart';
import '../../domain/repositories/feed_repository.dart';

/// Feed state
enum FeedStatus { initial, loading, loaded, error, loadingMore }

class FeedState {
  const FeedState({
    this.status = FeedStatus.initial,
    this.feeds = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasMore = true,
  });

  final FeedStatus status;
  final List<FeedItem> feeds;
  final String? errorMessage;
  final int currentPage;
  final bool hasMore;

  FeedState copyWith({
    FeedStatus? status,
    List<FeedItem>? feeds,
    String? errorMessage,
    int? currentPage,
    bool? hasMore,
  }) {
    return FeedState(
      status: status ?? this.status,
      feeds: feeds ?? this.feeds,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Feed notifier
class FeedNotifier extends StateNotifier<FeedState> {
  FeedNotifier({
    required FeedRepository repository,
  })  : _repository = repository,
        super(const FeedState());

  final FeedRepository _repository;

  /// Load initial feeds
  Future<void> loadFeeds() async {
    state = state.copyWith(status: FeedStatus.loading);

    final result = await _repository.getFeeds(page: 1);

    result.fold(
      (failure) => state = state.copyWith(
        status: FeedStatus.error,
        errorMessage: failure.message,
      ),
      (feeds) => state = state.copyWith(
        status: FeedStatus.loaded,
        feeds: feeds,
        currentPage: 1,
        hasMore: feeds.length >= 20,
      ),
    );
  }

  /// Load more feeds
  Future<void> loadMore() async {
    if (!state.hasMore || state.status == FeedStatus.loadingMore) return;

    state = state.copyWith(status: FeedStatus.loadingMore);

    final nextPage = state.currentPage + 1;
    final result = await _repository.getFeeds(page: nextPage);

    result.fold(
      (failure) => state = state.copyWith(
        status: FeedStatus.loaded,
        errorMessage: failure.message,
      ),
      (feeds) => state = state.copyWith(
        status: FeedStatus.loaded,
        feeds: [...state.feeds, ...feeds],
        currentPage: nextPage,
        hasMore: feeds.length >= 20,
      ),
    );
  }

  /// Refresh feeds
  Future<void> refresh() async {
    final result = await _repository.getFeeds(page: 1);

    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (feeds) => state = state.copyWith(
        feeds: feeds,
        currentPage: 1,
        hasMore: feeds.length >= 20,
      ),
    );
  }

  /// Like a post
  Future<void> likePost(String postId) async {
    final index = state.feeds.indexWhere((f) => f.id == postId);
    if (index == -1) return;

    final feed = state.feeds[index];
    final isLiked = feed.isLiked;

    // Optimistic update
    _updateFeedItem(
      postId,
      isLiked: !isLiked,
      likesCount: feed.likesCount + (isLiked ? -1 : 1),
    );

    final result = isLiked
        ? await _repository.unlikePost(postId)
        : await _repository.likePost(postId);

    // Revert on failure
    result.fold(
      (failure) => _updateFeedItem(
        postId,
        isLiked: isLiked,
        likesCount: feed.likesCount,
      ),
      (_) {},
    );
  }

  /// Repost a post
  Future<void> repost(String postId) async {
    final index = state.feeds.indexWhere((f) => f.id == postId);
    if (index == -1) return;

    final feed = state.feeds[index];
    final isReposted = feed.isReposted;

    // Optimistic update
    _updateFeedItem(
      postId,
      isReposted: !isReposted,
      repostsCount: feed.repostsCount + (isReposted ? -1 : 1),
    );

    final result = isReposted
        ? await _repository.removeRepost(postId)
        : await _repository.repost(postId);

    // Revert on failure
    result.fold(
      (failure) => _updateFeedItem(
        postId,
        isReposted: isReposted,
        repostsCount: feed.repostsCount,
      ),
      (_) {},
    );
  }

  /// Bookmark a post
  Future<void> bookmark(String postId) async {
    final index = state.feeds.indexWhere((f) => f.id == postId);
    if (index == -1) return;

    final feed = state.feeds[index];
    final isBookmarked = feed.isBookmarked;

    // Optimistic update
    _updateFeedItem(postId, isBookmarked: !isBookmarked);

    final result = isBookmarked
        ? await _repository.removeBookmark(postId)
        : await _repository.bookmark(postId);

    // Revert on failure
    result.fold(
      (failure) => _updateFeedItem(postId, isBookmarked: isBookmarked),
      (_) {},
    );
  }

  void _updateFeedItem(
    String postId, {
    bool? isLiked,
    bool? isReposted,
    bool? isBookmarked,
    int? likesCount,
    int? repostsCount,
  }) {
    final feeds = state.feeds.map((feed) {
      if (feed.id == postId) {
        return FeedItem(
          id: feed.id,
          author: feed.author,
          content: feed.content,
          postType: feed.postType,
          createdAt: feed.createdAt,
          title: feed.title,
          mediaUrls: feed.mediaUrls,
          likesCount: likesCount ?? feed.likesCount,
          commentsCount: feed.commentsCount,
          repostsCount: repostsCount ?? feed.repostsCount,
          isLiked: isLiked ?? feed.isLiked,
          isReposted: isReposted ?? feed.isReposted,
          isBookmarked: isBookmarked ?? feed.isBookmarked,
          expiresAt: feed.expiresAt,
        );
      }
      return feed;
    }).toList();

    state = state.copyWith(feeds: feeds);
  }
}

/// Feed provider
final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  final repository = getIt<FeedRepository>();
  return FeedNotifier(repository: repository);
});
