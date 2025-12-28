import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
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

/// Feed remote data source implementation
class FeedRemoteDataSourceImpl implements FeedRemoteDataSource {
  const FeedRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<FeedItemModel>> getFeeds({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.feeds,
        queryParameters: {'page': page, 'page_size': pageSize},
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

  @override
  Future<FeedItemModel> getFeedById(String id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.feedById(id));

      if (response.statusCode == 200) {
        return FeedItemModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ServerException(statusCode: response.statusCode);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> likePost(String postId) async {
    try {
      await _apiClient.post(ApiEndpoints.likePost(postId));
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> unlikePost(String postId) async {
    try {
      await _apiClient.delete(ApiEndpoints.likePost(postId));
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> repost(String postId) async {
    try {
      await _apiClient.post(ApiEndpoints.repost(postId));
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> removeRepost(String postId) async {
    try {
      await _apiClient.delete(ApiEndpoints.repost(postId));
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> bookmark(String postId) async {
    try {
      await _apiClient.post(ApiEndpoints.bookmark(postId));
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> removeBookmark(String postId) async {
    try {
      await _apiClient.delete(ApiEndpoints.bookmark(postId));
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<CommentModel>> getComments({
    required String postId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.comments(postId),
        queryParameters: {'page': page, 'page_size': pageSize},
      );

      if (response.statusCode == 200) {
        final results = response.data['results'] as List<dynamic>;
        return results
            .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ServerException(statusCode: response.statusCode);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<CommentModel> addComment({
    required String postId,
    required String content,
    String? parentId,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.comments(postId),
        data: {
          'content': content,
          if (parentId != null) 'parent_id': parentId,
        },
      );

      if (response.statusCode == 201) {
        return CommentModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ServerException(statusCode: response.statusCode);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      await _apiClient.delete(ApiEndpoints.commentById(postId, commentId));
    } on DioException catch (e) {
      throw _handleDioError(e);
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
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return const UnauthorizedException();
        } else if (statusCode == 404) {
          return const NotFoundException();
        }
        return ServerException(statusCode: statusCode);
      default:
        return const ServerException();
    }
  }
}
