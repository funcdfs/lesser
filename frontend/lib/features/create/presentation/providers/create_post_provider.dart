import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lesser/core/network/api_provider.dart';
import 'package:lesser/features/create/data/create_post_repository.dart';

// Repository provider
final createPostRepositoryProvider = Provider<CreatePostRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CreatePostRepository(apiClient);
});

// Notifier provider for creating posts
final createPostProvider =
    StateNotifierProvider<CreatePostNotifier, AsyncValue<void>>((ref) {
      final repository = ref.watch(createPostRepositoryProvider);
      return CreatePostNotifier(repository);
    });

class CreatePostNotifier extends StateNotifier<AsyncValue<void>> {
  final CreatePostRepository _repository;

  CreatePostNotifier(this._repository) : super(const AsyncData<void>(null));

  Future<void> createPost({required String content, String? location}) async {
    state = const AsyncLoading<void>();
    try {
      await _repository.createPost(content: content, location: location);
      state = const AsyncData<void>(null);
    } catch (e) {
      state = AsyncError<void>(e, StackTrace.current);
    }
  }
}
