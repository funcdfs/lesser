import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lesser/features/feeds/data/feeds_repository.dart';
import 'package:lesser/core/network/api_provider.dart';
import 'package:lesser/features/feeds/domain/models/post.dart';
import 'package:lesser/core/config/debug_config.dart';

part 'feeds_provider.g.dart';

@riverpod
FeedsRepository feedsRepository(FeedsRepositoryRef ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FeedsRepository(apiClient);
}

@riverpod
Future<List<Post>> feedsList(FeedsListRef ref) async {
  if (DebugConfig.debugLocal) {
    // 纯前端调试模式：返回fake数据
    await Future.delayed(const Duration(milliseconds: 800)); // 模拟网络延迟
    return [
      Post(
        id: '1',
        username: 'debug_user',
        content: '这是一条测试帖子，用于纯前端调试模式。',
        createdAt: '2024-01-15T10:30:00Z',
        likes: 123,
        location: '北京',
        imageUrls: [],
        commentsCount: 23,
        repostsCount: 15,
        bookmarksCount: 45,
        sharesCount: 8,
        isLiked: false,
      ),
      Post(
        id: '2',
        username: 'test_user',
        content: '这是另一条测试帖子，展示了图片功能。',
        createdAt: '2024-01-15T09:15:00Z',
        likes: 256,
        location: '上海',
        imageUrls: ['https://picsum.photos/seed/test1/600/400'],
        commentsCount: 42,
        repostsCount: 33,
        bookmarksCount: 78,
        sharesCount: 12,
        isLiked: true,
      ),
      Post(
        id: '3',
        username: 'developer',
        content: 'Flutter开发真的很有趣！',
        createdAt: '2024-01-14T16:45:00Z',
        likes: 89,
        location: '深圳',
        imageUrls: [],
        commentsCount: 11,
        repostsCount: 7,
        bookmarksCount: 24,
        sharesCount: 5,
        isLiked: false,
      ),
    ];
  } else {
    // 前后端联动调试模式：调用API获取真实数据
    final repository = ref.watch(feedsRepositoryProvider);
    return repository.getFeeds();
  }
}
