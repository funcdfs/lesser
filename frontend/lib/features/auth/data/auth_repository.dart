import 'dart:io';

import 'package:chopper/chopper.dart';
import 'package:logger/logger.dart';
import 'package:lesser/core/network/api_client.dart';
import 'package:lesser/core/network/token_manager.dart';
import 'package:lesser/features/auth/domain/models/user.dart';

/// Exception types for authentication errors
enum AuthErrorType {
  networkError,
  invalidCredentials,
  validationError,
  serverError,
  unknown,
}

/// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;
  final AuthErrorType type;

  const AuthException(this.message, this.type);

  @override
  String toString() => message;
}

/// Response model for authentication operations
class AuthResponse {
  final String token;
  final int userId;
  final String username;

  const AuthResponse({
    required this.token,
    required this.userId,
    required this.username,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      userId: (json['userId'] ?? json['user_id']) as int,
      username: json['username'] as String,
    );
  }
}

/// Repository for authentication operations
class AuthRepository {
  final ApiClient _apiClient;
  final Logger _logger = Logger();

  /// 本地测试账号列表（用户名, 密码）
  static const _localTestAccounts = {
    'admin': 'fw142857',
    'funcdfs': 'fw142857',
  };

  AuthRepository(this._apiClient);

  /// 检查是否为本地测试账号
  bool _isLocalTestAccount(String username, String password) {
    final expectedPassword = _localTestAccounts[username];
    return expectedPassword != null && expectedPassword == password;
  }

  /// 创建本地测试用户的认证响应
  AuthResponse _createLocalAuthResponse(String username) {
    return AuthResponse(
      token: 'local_test_token_${username}_${DateTime.now().millisecondsSinceEpoch}',
      userId: username == 'admin' ? 1 : 2,
      username: username,
    );
  }

  /// Register a new user
  Future<AuthResponse> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiClient.apiService.register({
        'username': username,
        'email': email,
        'password': password,
        'password1': password,
        'password2': confirmPassword,
      });

      return _handleAuthResponse(response);
    } on SocketException {
      throw const AuthException(
        'Network error. Please check your connection.',
        AuthErrorType.networkError,
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      _logger.e('Registration error', error: e);
      throw const AuthException(
        'An unexpected error occurred',
        AuthErrorType.unknown,
      );
    }
  }

  /// Login with credentials
  Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    // 检查是否为本地测试账号
    if (_isLocalTestAccount(username, password)) {
      _logger.i('Local test account login: $username');
      final response = _createLocalAuthResponse(username);
      // 保存 token
      await TokenManager.saveToken(response.token);
      return response;
    }

    try {
      final response = await _apiClient.apiService.login({
        'username': username,
        'password': password,
      });

      return _handleAuthResponse(response);
    } on SocketException {
      throw const AuthException(
        'Network error. Please check your connection.',
        AuthErrorType.networkError,
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      _logger.e('Login error', error: e);
      throw const AuthException(
        'An unexpected error occurred',
        AuthErrorType.unknown,
      );
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    try {
      await _apiClient.apiService.logout();
    } on SocketException {
      // Even on network error, we should clear local token
      _logger.w('Network error during logout, clearing local token anyway');
    } catch (e) {
      _logger.e('Logout error', error: e);
      // Still proceed to clear local token
    } finally {
      await TokenManager.deleteToken();
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await TokenManager.getToken();
    return token != null && token.isNotEmpty;
  }

  /// Get current user profile
  Future<User> getProfile() async {
    try {
      final response = await _apiClient.apiService.getProfile();

      if (response.isSuccessful && response.body != null) {
        return User.fromJson(response.body as Map<String, dynamic>);
      }

      if (response.statusCode == 401) {
        throw const AuthException(
          'Session expired. Please login again.',
          AuthErrorType.invalidCredentials,
        );
      }

      throw const AuthException(
        'Failed to get profile',
        AuthErrorType.serverError,
      );
    } on SocketException {
      throw const AuthException(
        'Network error. Please check your connection.',
        AuthErrorType.networkError,
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      _logger.e('Get profile error', error: e);
      throw const AuthException(
        'An unexpected error occurred',
        AuthErrorType.unknown,
      );
    }
  }

  /// Handle authentication response
  AuthResponse _handleAuthResponse(Response response) {
    if (response.isSuccessful && response.body != null) {
      final body = response.body as Map<String, dynamic>;
      return AuthResponse.fromJson(body);
    }

    // Handle specific error codes
    final statusCode = response.statusCode;
    final body = response.body as Map<String, dynamic>?;
    final errorMessage = body?['error'] as String?;

    if (statusCode == 400) {
      throw AuthException(
        errorMessage ?? 'Invalid request',
        AuthErrorType.validationError,
      );
    }

    if (statusCode == 401) {
      throw AuthException(
        errorMessage ?? 'Invalid credentials',
        AuthErrorType.invalidCredentials,
      );
    }

    throw AuthException(
      errorMessage ?? 'Server error',
      AuthErrorType.serverError,
    );
  }
}
