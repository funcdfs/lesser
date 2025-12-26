import 'package:lesser/core/data/base_repository.dart';
import 'package:lesser/core/network/api_client.dart';
import 'package:lesser/features/feeds/domain/models/comment.dart';

/// Repository for managing comment data operations
class CommentsRepository extends BaseRepository {
  final ApiClient _apiClient;

  CommentsRepository(this._apiClient);

  /// Fetches comments for a specific post
  /// 
  /// [postId] - The ID of the post to fetch comments for
  /// [page] - Page number for pagination (default: 1)
  /// [limit] - Number of comments per page (default: 20)
  Future<List<Comment>> getComments({
    required String postId,
    int page = 1,
    int limit = 20,
  }) async {
    return safeApiCall(
      () => _apiClient.apiService.getComments(postId, page, limit),
      mapper: (data) => _parseComments(data, postId),
    );
  }

  /// Creates a new comment on a post
  /// 
  /// [postId] - The ID of the post to comment on
  /// [content] - The comment content
  Future<Comment> createComment({
    required String postId,
    required String content,
  }) async {
    return safeApiCall(
      () => _apiClient.apiService.createComment(postId, {'content': content}),
      mapper: (data) => _parseComment(data, postId),
    );
  }

  /// Deletes a comment
  /// 
  /// [commentId] - The ID of the comment to delete
  Future<void> deleteComment(String commentId) async {
    return safeApiCall(
      () => _apiClient.apiService.deleteComment(commentId),
      mapper: (_) {},
    );
  }

  /// Parses a list of comments from API response
  List<Comment> _parseComments(dynamic data, String postId) {
    if (data is List) {
      return data.map((e) => _parseComment(e, postId)).toList();
    }
    // Handle paginated response format
    if (data is Map && data['results'] != null) {
      return (data['results'] as List).map((e) => _parseComment(e, postId)).toList();
    }
    return [];
  }

  /// Parses a single comment from API response
  Comment _parseComment(dynamic data, String postId) {
    final map = data as Map<String, dynamic>;
    return Comment(
      id: map['id']?.toString() ?? '',
      postId: map['post_id']?.toString() ?? postId,
      userId: map['user_id']?.toString() ?? map['author']?['id']?.toString() ?? '',
      username: map['username'] ?? map['author']?['username'] ?? '',
      avatarUrl: map['avatar_url'] ?? map['author']?['avatar_url'] ?? '',
      isVerified: map['is_verified'] ?? map['author']?['is_verified'] ?? false,
      content: map['content'] ?? '',
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      likesCount: map['like_count'] ?? map['likes_count'] ?? 0,
      isLiked: map['is_liked'] ?? map['is_liked_by_current_user'] ?? false,
      replyCount: map['reply_count'] ?? map['replies_count'] ?? 0,
      isFromAuthor: map['is_from_author'] ?? false,
    );
  }
}
