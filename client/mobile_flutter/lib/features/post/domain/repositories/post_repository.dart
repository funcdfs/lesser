import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../feeds/domain/entities/feed_item.dart';
import '../entities/post.dart';

/// Post repository interface
abstract class PostRepository {
  /// Create a new post
  Future<Either<Failure, FeedItem>> createPost(CreatePostRequest request);

  /// Update a post
  Future<Either<Failure, FeedItem>> updatePost({
    required String postId,
    String? content,
    String? title,
  });

  /// Delete a post
  Future<Either<Failure, void>> deletePost(String postId);

  /// Get user's posts
  Future<Either<Failure, List<FeedItem>>> getUserPosts({
    required String userId,
    int page = 1,
    int pageSize = 20,
  });
}
