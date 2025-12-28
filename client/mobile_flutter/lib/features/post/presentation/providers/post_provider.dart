import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../feeds/domain/entities/feed_item.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';

/// Create post state
enum CreatePostStatus { initial, loading, success, error }

class CreatePostState {
  const CreatePostState({
    this.status = CreatePostStatus.initial,
    this.selectedPostType = PostType.short,
    this.errorMessage,
    this.createdPost,
  });

  final CreatePostStatus status;
  final PostType selectedPostType;
  final String? errorMessage;
  final FeedItem? createdPost;

  CreatePostState copyWith({
    CreatePostStatus? status,
    PostType? selectedPostType,
    String? errorMessage,
    FeedItem? createdPost,
  }) {
    return CreatePostState(
      status: status ?? this.status,
      selectedPostType: selectedPostType ?? this.selectedPostType,
      errorMessage: errorMessage,
      createdPost: createdPost,
    );
  }
}

/// Create post notifier
class CreatePostNotifier extends StateNotifier<CreatePostState> {
  CreatePostNotifier({
    required PostRepository repository,
  })  : _repository = repository,
        super(const CreatePostState());

  final PostRepository _repository;

  /// Select post type
  void selectPostType(PostType type) {
    state = state.copyWith(selectedPostType: type);
  }

  /// Create post
  Future<void> createPost({
    required String content,
    String? title,
    List<String>? mediaUrls,
  }) async {
    state = state.copyWith(status: CreatePostStatus.loading, errorMessage: null);

    final request = CreatePostRequest(
      content: content,
      postType: state.selectedPostType,
      title: title,
      mediaUrls: mediaUrls ?? [],
    );

    final result = await _repository.createPost(request);

    result.fold(
      (failure) => state = state.copyWith(
        status: CreatePostStatus.error,
        errorMessage: failure.message,
      ),
      (post) => state = state.copyWith(
        status: CreatePostStatus.success,
        createdPost: post,
      ),
    );
  }

  /// Reset state
  void reset() {
    state = const CreatePostState();
  }
}

/// Create post provider
final createPostProvider =
    StateNotifierProvider<CreatePostNotifier, CreatePostState>((ref) {
  final repository = getIt<PostRepository>();
  return CreatePostNotifier(repository: repository);
});
