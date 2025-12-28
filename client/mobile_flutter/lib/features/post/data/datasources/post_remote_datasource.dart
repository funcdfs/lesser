import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
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

/// Post remote data source implementation
class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  const PostRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<FeedItemModel> createPost({
    required String content,
    required PostType postType,
    String? title,
    List<String>? mediaUrls,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.posts,
        data: {
          'content': content,
          'post_type': _postTypeToString(postType),
          if (title != null) 'title': title,
          if (mediaUrls != null && mediaUrls.isNotEmpty) 'media_urls': mediaUrls,
        },
      );

      if (response.statusCode == 201) {
        return FeedItemModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ServerException(statusCode: response.statusCode);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<FeedItemModel> updatePost({
    required String postId,
    String? content,
    String? title,
  }) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.postById(postId),
        data: {
          if (content != null) 'content': content,
          if (title != null) 'title': title,
        },
      );

      if (response.statusCode == 200) {
        return FeedItemModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ServerException(statusCode: response.statusCode);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      await _apiClient.delete(ApiEndpoints.postById(postId));
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<FeedItemModel>> getUserPosts({
    required String userId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.posts,
        queryParameters: {
          'user_id': userId,
          'page': page,
          'page_size': pageSize,
        },
      );

      if (response.statusCode == 200) {
        final results = response.data['results'] as List<dynamic>;
        return results
            .map((e) => FeedItemModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ServerException(statusCode: response.statusCode);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  String _postTypeToString(PostType type) {
    switch (type) {
      case PostType.story:
        return 'story';
      case PostType.short:
        return 'short';
      case PostType.column:
        return 'column';
    }
  }

  AppException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();
      case DioExceptionType.connectionError:
        return const NetworkException();
      default:
        return ServerException(statusCode: e.response?.statusCode);
    }
  }
}
