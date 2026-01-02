import '../../../feeds/data/models/feed_item_model.dart';
import '../../../feeds/domain/entities/feed_item.dart';

/// Post remote data source interface
abstract class PostRemoteDataSource {
  Future<FeedItemModel> createPost({
    required String content,
    required PostType postType,
    String? title,
    List<String>? mediaUrls,
  });

  Future<FeedItemModel> updatePost({
    required String postId,
    String? content,
    String? title,
  });

  Future<void> deletePost(String postId);

  Future<List<FeedItemModel>> getUserPosts({
    required String userId,
    int page = 1,
    int pageSize = 20,
  });
}
