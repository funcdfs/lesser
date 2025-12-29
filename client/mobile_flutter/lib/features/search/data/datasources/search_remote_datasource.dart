import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../feeds/data/models/feed_item_model.dart';

/// Search remote data source interface
abstract class SearchRemoteDataSource {
  Future<List<FeedItemModel>> searchPosts({
    required String query,
    String? postType,
    DateTime? fromDate,
    DateTime? toDate,
    int page = 1,
    int pageSize = 20,
  });

  Future<List<UserModel>> searchUsers({
    required String query,
    int page = 1,
    int pageSize = 20,
  });
}

/// Search remote data source implementation
class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  const SearchRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<FeedItemModel>> searchPosts({
    required String query,
    String? postType,
    DateTime? fromDate,
    DateTime? toDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.searchPosts,
        queryParameters: {
          'q': query,
          if (postType != null) 'post_type': postType,
          if (fromDate != null) 'from_date': fromDate.toIso8601String(),
          if (toDate != null) 'to_date': toDate.toIso8601String(),
          'page': page,
          'page_size': pageSize,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>;
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
  Future<List<UserModel>> searchUsers({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.searchUsers,
        queryParameters: {
          'q': query,
          'page': page,
          'page_size': pageSize,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>;
        return results
            .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ServerException(statusCode: response.statusCode);
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
      default:
        return ServerException(statusCode: e.response?.statusCode);
    }
  }
}
