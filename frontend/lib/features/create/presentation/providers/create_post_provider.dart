import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lesser/core/network/api_provider.dart';
import 'package:lesser/features/create/data/create_post_repository.dart';

part 'create_post_provider.g.dart';

/// Repository provider for creating posts
@riverpod
CreatePostRepository createPostRepository(Ref ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CreatePostRepository(apiClient);
}

/// Notifier provider for creating posts
@riverpod
class CreatePost extends _$CreatePost {
  @override
  AsyncValue<void> build() {
    return const AsyncData<void>(null);
  }

  Future<void> createPost({required String content, String? location}) async {
    state = const AsyncLoading<void>();
    try {
      final repository = ref.read(createPostRepositoryProvider);
      await repository.createPost(content: content, location: location);
      state = const AsyncData<void>(null);
    } catch (e, st) {
      state = AsyncError<void>(e, st);
    }
  }
}
