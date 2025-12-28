import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/comment.dart';
import '../entities/feed_item.dart';

/// Feed repository interface
abstract class FeedRepository {
  /// Get paginated feed items
  Future<Either<Failure, List<FeedItem>>> getFeeds({
    int page = 1,
    int pageSize = 20,
  });

  /// Get a single feed item by ID
  Future<Either<Failure, FeedItem>> getFeedById(String id);

  /// Like a post
  Future<Either<Failure, void>> likePost(String postId);

  /// Unlike a post
  Future<Either<Failure, void>> unlikePost(String postId);

  /// Repost a post
  Future<Either<Failure, void>> repost(String postId);

  /// Remove repost
  Future<Either<Failure, void>> removeRepost(String postId);

  /// Bookmark a post
  Future<Either<Failure, void>> bookmark(String postId);

  /// Remove bookmark
  Future<Either<Failure, void>> removeBookmark(String postId);

  /// Get comments for a post
  Future<Either<Failure, List<Comment>>> getComments({
    required String postId,
    int page = 1,
    int pageSize = 20,
  });

  /// Add a comment to a post
  Future<Either<Failure, Comment>> addComment({
    required String postId,
    required String content,
    String? parentId,
  });

  /// Delete a comment
  Future<Either<Failure, void>> deleteComment({
    required String postId,
    required String commentId,
  });
}
