import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/profile_model.dart';

/// Profile remote data source interface
abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile(String userId);
  Future<ProfileModel> getCurrentProfile();
  Future<UserModel> updateProfile({
    String? displayName,
    String? bio,
    String? avatarUrl,
  });
  Future<void> followUser(String userId);
  Future<void> unfollowUser(String userId);
  Future<List<UserModel>> getFollowers({
    required String userId,
    int page = 1,
    int pageSize = 20,
  });
  Future<List<UserModel>> getFollowing({
    required String userId,
    int page = 1,
    int pageSize = 20,
  });
}

/// Profile remote data source implementation
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  const ProfileRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ProfileModel> getProfile(String userId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.userById(userId));

      if (response.statusCode == 200) {
        return ProfileModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ServerException(statusCode: response.statusCode);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ProfileModel> getCurrentProfile() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.me);

      if (response.statusCode == 200) {
        return ProfileModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ServerException(statusCode: response.statusCode);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserModel> updateProfile({
    String? displayName,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.me,
        data: {
          if (displayName != null) 'display_name': displayName,
          if (bio != null) 'bio': bio,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
        },
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ServerException(statusCode: response.statusCode);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> followUser(String userId) async {
    try {
      await _apiClient.post(ApiEndpoints.follow(userId));
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> unfollowUser(String userId) async {
    try {
      await _apiClient.delete(ApiEndpoints.unfollow(userId));
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<UserModel>> getFollowers({
    required String userId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.userById(userId)}followers/',
        queryParameters: {'page': page, 'page_size': pageSize},
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

  @override
  Future<List<UserModel>> getFollowing({
    required String userId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.userById(userId)}following/',
        queryParameters: {'page': page, 'page_size': pageSize},
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
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 404) {
          return const NotFoundException();
        }
        return ServerException(statusCode: e.response?.statusCode);
      default:
        return const ServerException();
    }
  }
}
