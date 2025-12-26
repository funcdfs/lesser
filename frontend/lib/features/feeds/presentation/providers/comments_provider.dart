import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lesser/core/network/api_provider.dart';
import 'package:lesser/features/feeds/data/comments_repository.dart';
import 'package:lesser/features/feeds/domain/models/comment.dart';

part 'comments_provider.g.dart';

/// Provider for CommentsRepository
@riverpod
CommentsRepository commentsRepository(Ref ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CommentsRepository(apiClient);
}

/// State class for comments with pagination info
class CommentsState {
  final List<Comment> comments;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? error;

  const CommentsState({
    this.comments = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 0,
    this.error,
  });

  CommentsState copyWith({
    List<Comment>? comments,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? error,
  }) {
    return CommentsState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error,
    );
  }
}

/// Provider for managing comments for a specific post
@riverpod
class PostComments extends _$PostComments {
  static const int _pageSize = 20;

  @override
  CommentsState build(String postId) {
    // Initial state - will load comments when first accessed
    _loadInitialComments(postId);
    return const CommentsState(isLoading: true);
  }

  Future<void> _loadInitialComments(String postId) async {
    try {
      final repository = ref.read(commentsRepositoryProvider);
      final comments = await repository.getComments(
        postId: postId,
        page: 1,
        limit: _pageSize,
      );
      
      state = CommentsState(
        comments: comments,
        isLoading: false,
        hasMore: comments.length >= _pageSize,
        currentPage: 1,
      );
    } catch (e) {
      state = CommentsState(
        isLoading: false,
        hasMore: false,
        error: e.toString(),
      );
    }
  }

  /// Load more comments (pagination)
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      final repository = ref.read(commentsRepositoryProvider);
      final nextPage = state.currentPage + 1;
      final newComments = await repository.getComments(
        postId: postId,
        page: nextPage,
        limit: _pageSize,
      );

      state = state.copyWith(
        comments: [...state.comments, ...newComments],
        isLoading: false,
        hasMore: newComments.length >= _pageSize,
        currentPage: nextPage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh comments (reload from first page)
  Future<void> refresh() async {
    state = const CommentsState(isLoading: true);
    await _loadInitialComments(postId);
  }

  /// Add a new comment to the post
  Future<bool> addComment(String content) async {
    if (content.trim().isEmpty) return false;

    try {
      final repository = ref.read(commentsRepositoryProvider);
      final newComment = await repository.createComment(
        postId: postId,
        content: content.trim(),
      );

      // Add the new comment to the beginning of the list
      state = state.copyWith(
        comments: [newComment, ...state.comments],
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Delete a comment
  Future<bool> deleteComment(String commentId) async {
    try {
      final repository = ref.read(commentsRepositoryProvider);
      await repository.deleteComment(commentId);

      // Remove the comment from the list
      state = state.copyWith(
        comments: state.comments.where((c) => c.id != commentId).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Clear any error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for the total comment count of a post
/// This can be used to display comment count without loading all comments
@riverpod
class CommentCount extends _$CommentCount {
  @override
  int build(String postId) {
    // Watch the comments state to keep count in sync
    final commentsState = ref.watch(postCommentsProvider(postId));
    return commentsState.comments.length;
  }

  /// Update the count (useful when count comes from post data)
  void setCount(int count) {
    state = count;
  }
}
