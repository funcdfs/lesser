import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

/// Auth local data source interface
abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearCachedUser();

  Future<void> cacheTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearTokens();

  Future<bool> isAuthenticated();
}

/// Auth local data source implementation
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl({
    required SharedPreferences sharedPreferences,
    required FlutterSecureStorage secureStorage,
  })  : _sharedPreferences = sharedPreferences,
        _secureStorage = secureStorage;

  final SharedPreferences _sharedPreferences;
  final FlutterSecureStorage _secureStorage;

  static const String _cachedUserKey = 'cached_user';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await _sharedPreferences.setString(
        _cachedUserKey,
        jsonEncode(user.toJson()),
      );
    } catch (e) {
      throw const CacheException(message: 'Failed to cache user');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final jsonString = _sharedPreferences.getString(_cachedUserKey);
      if (jsonString == null) return null;
      return UserModel.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearCachedUser() async {
    try {
      await _sharedPreferences.remove(_cachedUserKey);
    } catch (e) {
      throw const CacheException(message: 'Failed to clear cached user');
    }
  }

  @override
  Future<void> cacheTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await _secureStorage.write(key: _accessTokenKey, value: accessToken);
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    } catch (e) {
      throw const CacheException(message: 'Failed to cache tokens');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return await _secureStorage.read(key: _accessTokenKey);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: _refreshTokenKey);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearTokens() async {
    try {
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
    } catch (e) {
      throw const CacheException(message: 'Failed to clear tokens');
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null;
  }
}
