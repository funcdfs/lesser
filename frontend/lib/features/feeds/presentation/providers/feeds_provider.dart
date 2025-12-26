import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lesser/features/feeds/data/feeds_repository.dart';
import 'package:lesser/core/network/api_provider.dart';
import 'package:lesser/features/feeds/domain/models/post.dart';
import 'package:lesser/core/config/debug_config.dart';

part 'feeds_provider.g.dart';

@riverpod
FeedsRepository feedsRepository(Ref ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FeedsRepository(apiClient);
}

@riverpod
class PagedFeeds extends _$PagedFeeds {
  @override
  Future<List<Post>> build() async {
    // 初始加载第一页
    return fetchPage(1);
  }

  Future<List<Post>> fetchPage(int page) async {
    if (DebugConfig.debugLocal) {
      // 纯前端调试模式：返回fake数据
      await Future.delayed(const Duration(milliseconds: 800)); // 模拟网络延迟

      // 模拟分页数据
      final posts = List.generate(10, (index) {
        final postIndex = (page - 1) * 10 + index + 1;
        return Post(
          id: postIndex.toString(),
          username: 'debug_user',
          content: '这是第 $postIndex 条测试帖子，用于纯前端调试模式。',
          createdAt: '2024-01-15T10:30:00Z',
          likes: 123 + postIndex,
          location: '北京',
          imageUrls: postIndex % 3 == 0
              ? ['https://picsum.photos/seed/test$postIndex/600/400']
              : [],
          commentsCount: 23 + postIndex,
          repostsCount: 15 + postIndex,
          bookmarksCount: 45 + postIndex,
          sharesCount: 8 + postIndex,
          isLiked: postIndex % 2 == 0,
        );
      });

      // 模拟只有3页数据
      if (page > 3) {
        return [];
      }

      return posts;
    } else {
      // 前后端联动调试模式：调用API获取真实数据
      final repository = ref.watch(feedsRepositoryProvider);
      return repository.getFeeds(page: page, limit: 10);
    }
  }

  Future<void> loadNextPage() async {
    if (state is AsyncLoading) return;

    final currentState = state as AsyncData<List<Post>>;
    final currentPosts = currentState.value;
    final nextPage = (currentPosts.length ~/ 10) + 1;

    state = const AsyncLoading();
    try {
      final newPosts = await fetchPage(nextPage);
      if (newPosts.isEmpty) {
        // No more posts to load
        return;
      }
      state = AsyncData([...currentPosts, ...newPosts]);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => fetchPage(1));
  }
}
