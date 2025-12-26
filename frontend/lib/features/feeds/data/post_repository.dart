import 'package:lesser/core/data/base_repository.dart';
import 'package:lesser/core/network/api_client.dart';
import 'package:lesser/features/feeds/domain/models/post.dart';

/// Repository for managing individual post operations
class PostRepository extends BaseRepository {
  final ApiClient _apiClient;

  PostRepository(this._apiClient);

  /// Get a single post by ID
  Future<Post> getPostById(String postId) async {
    return safeApiCall(
      () => _apiClient.apiService.getFeeds(1, 1), // TODO: Add dedicated endpoint
      mapper: (data) {
        // This is a placeholder - ideally there should be a dedicated endpoint
        final posts = (data as List).map((e) => Post.fromJson(e)).toList();
        return posts.firstWhere(
          (p) => p.id == postId,
          orElse: () => throw Exception('Post not found'),
        );
      },
    );
  }

  /// Like a post
  /// Returns the updated like count
  Future<int> likePost(String postId) async {
    return safeApiCall(
      () => _apiClient.apiService.likePost(postId),
      mapper: (data) {
        if (data is Map<String, dynamic>) {
          return data['likes_count'] ?? data['like_count'] ?? 0;
        }
        return 0;
      },
    );
  }

  /// Unlike a post
  /// Returns the updated like count
  Future<int> unlikePost(String postId) async {
    return safeApiCall(
      () => _apiClient.apiService.unlikePost(postId),
      mapper: (data) {
        if (data is Map<String, dynamic>) {
          return data['likes_count'] ?? data['like_count'] ?? 0;
        }
        return 0;
      },
    );
  }

  /// Bookmark a post
  /// Returns the updated bookmark count
  Future<int> bookmarkPost(String postId) async {
    return safeApiCall(
      () => _apiClient.apiService.bookmarkPost(postId),
      mapper: (data) {
        if (data is Map<String, dynamic>) {
          return data['bookmarks_count'] ?? data['bookmark_count'] ?? 0;
        }
        return 0;
      },
    );
  }

  /// Remove bookmark from a post
  /// Returns the updated bookmark count
  Future<int> unbookmarkPost(String postId) async {
    return safeApiCall(
      () => _apiClient.apiService.unbookmarkPost(postId),
      mapper: (data) {
        if (data is Map<String, dynamic>) {
          return data['bookmarks_count'] ?? data['bookmark_count'] ?? 0;
        }
        return 0;
      },
    );
  }
}
