import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lesser/core/network/api_provider.dart';
import 'package:lesser/features/feeds/data/post_repository.dart';

part 'post_interactions_provider.g.dart';

/// Provider for PostRepository
@riverpod
PostRepository postRepository(Ref ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PostRepository(apiClient);
}

/// State for a post's interaction status
class PostInteractionState {
  final bool isLiked;
  final bool isBookmarked;
  final int likesCount;
  final int bookmarksCount;
  final bool isLoading;
  final String? error;

  const PostInteractionState({
    this.isLiked = false,
    this.isBookmarked = false,
    this.likesCount = 0,
    this.bookmarksCount = 0,
    this.isLoading = false,
    this.error,
  });

  PostInteractionState copyWith({
    bool? isLiked,
    bool? isBookmarked,
    int? likesCount,
    int? bookmarksCount,
    bool? isLoading,
    String? error,
  }) {
    return PostInteractionState(
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      likesCount: likesCount ?? this.likesCount,
      bookmarksCount: bookmarksCount ?? this.bookmarksCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Provider for managing post interactions (like/bookmark)
@riverpod
class PostInteractions extends _$PostInteractions {
  @override
  PostInteractionState build(String postId) {
    // Initial state - can be initialized from post data
    return const PostInteractionState();
  }

  /// Initialize state from post data
  void initFromPost({
    required bool isLiked,
    required bool isBookmarked,
    required int likesCount,
    required int bookmarksCount,
  }) {
    state = PostInteractionState(
      isLiked: isLiked,
      isBookmarked: isBookmarked,
      likesCount: likesCount,
      bookmarksCount: bookmarksCount,
    );
  }

  /// Toggle like status for the post
  Future<void> toggleLike() async {
    if (state.isLoading) return;

    // Optimistic update
    final wasLiked = state.isLiked;
    final previousCount = state.likesCount;
    
    state = state.copyWith(
      isLiked: !wasLiked,
      likesCount: wasLiked ? previousCount - 1 : previousCount + 1,
      isLoading: true,
    );

    try {
      final repository = ref.read(postRepositoryProvider);
      final newCount = wasLiked
          ? await repository.unlikePost(postId)
          : await repository.likePost(postId);

      state = state.copyWith(
        likesCount: newCount > 0 ? newCount : state.likesCount,
        isLoading: false,
      );
    } catch (e) {
      // Revert on error
      state = state.copyWith(
        isLiked: wasLiked,
        likesCount: previousCount,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Toggle bookmark status for the post
  Future<void> toggleBookmark() async {
    if (state.isLoading) return;

    // Optimistic update
    final wasBookmarked = state.isBookmarked;
    final previousCount = state.bookmarksCount;
    
    state = state.copyWith(
      isBookmarked: !wasBookmarked,
      bookmarksCount: wasBookmarked ? previousCount - 1 : previousCount + 1,
      isLoading: true,
    );

    try {
      final repository = ref.read(postRepositoryProvider);
      final newCount = wasBookmarked
          ? await repository.unbookmarkPost(postId)
          : await repository.bookmarkPost(postId);

      state = state.copyWith(
        bookmarksCount: newCount > 0 ? newCount : state.bookmarksCount,
        isLoading: false,
      );
    } catch (e) {
      // Revert on error
      state = state.copyWith(
        isBookmarked: wasBookmarked,
        bookmarksCount: previousCount,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Clear any error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}
