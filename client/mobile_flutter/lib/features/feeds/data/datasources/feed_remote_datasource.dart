import '../models/comment_model.dart';
import '../models/feed_item_model.dart';

/// Feed remote data source interface
abstract class FeedRemoteDataSource {
  Future<List<FeedItemModel>> getFeeds({int page = 1, int pageSize = 20});
  Future<FeedItemModel> getFeedById(String id);
  Future<void> likePost(String postId);
  Future<void> unlikePost(String postId);
  Future<void> repost(String postId);
  Future<void> removeRepost(String postId);
  Future<void> bookmark(String postId);
  Future<void> removeBookmark(String postId);
  Future<List<CommentModel>> getComments({
    required String postId,
    int page = 1,
    int pageSize = 20,
  });
  Future<CommentModel> addComment({
    required String postId,
    required String content,
    String? parentId,
  });
  Future<void> deleteComment({
    required String postId,
    required String commentId,
  });
}
