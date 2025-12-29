import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/token_model.dart';
import '../models/user_model.dart';

/// Auth remote data source interface
abstract class AuthRemoteDataSource {
  Future<({UserModel user, TokenModel tokens})> register({
    required String username,
    required String email,
    required String password,
    String? displayName,
  });

  Future<({UserModel user, TokenModel tokens})> login({
    required String email,
    required String password,
  });

  Future<void> logout(String accessToken);

  Future<UserModel> getCurrentUser();

  Future<String> refreshToken(String refreshToken);
}

/// Auth remote data source implementation
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<({UserModel user, TokenModel tokens})> register({
    required String username,
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: {
          'username': username,
          'email': email,
          'password': password,
          'password_confirm': password,
          if (displayName != null) 'display_name': displayName,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return (
          user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
          tokens: TokenModel.fromJson(data),
        );
      }
      throw ServerException(
        message: 'Registration failed',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<({UserModel user, TokenModel tokens})> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return (
          user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
          tokens: TokenModel.fromJson(data),
        );
      }
      throw ServerException(
        message: 'Login failed',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> logout(String accessToken) async {
    try {
      await _apiClient.post(
        ApiEndpoints.logout,
        data: {'token': accessToken},
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.me);

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ServerException(
        message: 'Failed to get user',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.tokenRefresh,
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['access'] as String;
      }
      throw ServerException(
        message: 'Token refresh failed',
        statusCode: response.statusCode,
      );
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
        final message = _extractErrorMessage(e.response?.data);
        if (statusCode == 401) {
          return UnauthorizedException(message: message);
        } else if (statusCode == 403) {
          return ForbiddenException(message: message);
        } else if (statusCode == 404) {
          return NotFoundException(message: message);
        }
        return ServerException(message: message, statusCode: statusCode);
      default:
        return const ServerException();
    }
  }

  String _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data.containsKey('detail')) {
        return data['detail'] as String;
      }
      if (data.containsKey('message')) {
        return data['message'] as String;
      }
      if (data.containsKey('error')) {
        return data['error'] as String;
      }
    }
    return 'An error occurred';
  }
}
