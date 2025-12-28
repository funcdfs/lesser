import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/core/errors/exceptions.dart';
import 'package:mobile_flutter/core/errors/failures.dart';
import 'package:mobile_flutter/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:mobile_flutter/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mobile_flutter/features/auth/data/models/token_model.dart';
import 'package:mobile_flutter/features/auth/data/models/user_model.dart';
import 'package:mobile_flutter/features/auth/data/repositories/auth_repository_impl.dart';

/// Mock implementation of AuthRemoteDataSource
class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  ({UserModel user, TokenModel tokens})? loginResult;
  ({UserModel user, TokenModel tokens})? registerResult;
  UserModel? getCurrentUserResult;
  String? refreshTokenResult;

  Exception? loginException;
  Exception? registerException;
  Exception? logoutException;
  Exception? getCurrentUserException;
  Exception? refreshTokenException;

  bool logoutCalled = false;
  String? lastLogoutToken;

  @override
  Future<({UserModel user, TokenModel tokens})> login({
    required String email,
    required String password,
  }) async {
    if (loginException != null) throw loginException!;
    return loginResult!;
  }

  @override
  Future<({UserModel user, TokenModel tokens})> register({
    required String username,
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (registerException != null) throw registerException!;
    return registerResult!;
  }

  @override
  Future<void> logout(String accessToken) async {
    lastLogoutToken = accessToken;
    logoutCalled = true;
    if (logoutException != null) throw logoutException!;
  }

  @override
  Future<UserModel> getCurrentUser() async {
    if (getCurrentUserException != null) throw getCurrentUserException!;
    return getCurrentUserResult!;
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    if (refreshTokenException != null) throw refreshTokenException!;
    return refreshTokenResult!;
  }
}

/// Mock implementation of AuthLocalDataSource
class MockAuthLocalDataSource implements AuthLocalDataSource {
  UserModel? cachedUser;
  String? accessToken;
  String? refreshToken;

  Exception? cacheUserException;
  Exception? cacheTokensException;
  Exception? clearTokensException;
  Exception? clearCachedUserException;

  bool cacheUserCalled = false;
  bool cacheTokensCalled = false;
  bool clearTokensCalled = false;
  bool clearCachedUserCalled = false;

  @override
  Future<void> cacheUser(UserModel user) async {
    cacheUserCalled = true;
    if (cacheUserException != null) throw cacheUserException!;
    cachedUser = user;
  }

  @override
  Future<UserModel?> getCachedUser() async {
    return cachedUser;
  }

  @override
  Future<void> clearCachedUser() async {
    clearCachedUserCalled = true;
    if (clearCachedUserException != null) throw clearCachedUserException!;
    cachedUser = null;
  }

  @override
  Future<void> cacheTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    cacheTokensCalled = true;
    if (cacheTokensException != null) throw cacheTokensException!;
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  @override
  Future<String?> getAccessToken() async {
    return accessToken;
  }

  @override
  Future<String?> getRefreshToken() async {
    return refreshToken;
  }

  @override
  Future<void> clearTokens() async {
    clearTokensCalled = true;
    if (clearTokensException != null) throw clearTokensException!;
    accessToken = null;
    refreshToken = null;
  }

  @override
  Future<bool> isAuthenticated() async {
    return accessToken != null;
  }
}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  const testUserModel = UserModel(
    id: '1',
    username: 'testuser',
    email: 'test@example.com',
    displayName: 'Test User',
  );

  const testTokenModel = TokenModel(
    accessToken: 'access_token_123',
    refreshToken: 'refresh_token_456',
  );

  group('login', () {
    test(
      'should return User and cache data when login is successful',
      () async {
        // Arrange
        mockRemoteDataSource.loginResult = (
          user: testUserModel,
          tokens: testTokenModel,
        );

        // Act
        final result = await repository.login(
          email: 'test@example.com',
          password: 'password123',
        );

        // Assert
        expect(result.isRight(), true);
        result.fold((_) => fail('Should return user'), (user) {
          expect(user.id, '1');
          expect(user.email, 'test@example.com');
        });
        expect(mockLocalDataSource.cacheUserCalled, true);
        expect(mockLocalDataSource.cacheTokensCalled, true);
      },
    );

    test('should return ServerFailure when server throws exception', () async {
      // Arrange
      mockRemoteDataSource.loginException = const ServerException(
        message: 'Server error',
      );

      // Act
      final result = await repository.login(
        email: 'test@example.com',
        password: 'password123',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should return AuthFailure when credentials are invalid', () async {
      // Arrange
      mockRemoteDataSource.loginException = const UnauthorizedException(
        message: 'Invalid credentials',
      );

      // Act
      final result = await repository.login(
        email: 'test@example.com',
        password: 'wrongpassword',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should return NetworkFailure when there is no connection', () async {
      // Arrange
      mockRemoteDataSource.loginException = const NetworkException();

      // Act
      final result = await repository.login(
        email: 'test@example.com',
        password: 'password123',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });

  group('register', () {
    test(
      'should return User and cache data when registration is successful',
      () async {
        // Arrange
        mockRemoteDataSource.registerResult = (
          user: testUserModel,
          tokens: testTokenModel,
        );

        // Act
        final result = await repository.register(
          username: 'testuser',
          email: 'test@example.com',
          password: 'password123',
          displayName: 'Test User',
        );

        // Assert
        expect(result.isRight(), true);
        result.fold((_) => fail('Should return user'), (user) {
          expect(user.id, '1');
          expect(user.username, 'testuser');
        });
        expect(mockLocalDataSource.cacheUserCalled, true);
        expect(mockLocalDataSource.cacheTokensCalled, true);
      },
    );

    test('should return ServerFailure when registration fails', () async {
      // Arrange
      mockRemoteDataSource.registerException = const ServerException(
        message: 'Email already exists',
      );

      // Act
      final result = await repository.register(
        username: 'testuser',
        email: 'existing@example.com',
        password: 'password123',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });

  group('logout', () {
    test('should clear local data and call remote logout', () async {
      // Arrange
      mockLocalDataSource.accessToken = 'access_token_123';

      // Act
      final result = await repository.logout();

      // Assert
      expect(result.isRight(), true);
      expect(mockRemoteDataSource.logoutCalled, true);
      expect(mockLocalDataSource.clearTokensCalled, true);
      expect(mockLocalDataSource.clearCachedUserCalled, true);
    });

    test('should still clear local data even if remote logout fails', () async {
      // Arrange
      mockLocalDataSource.accessToken = 'access_token_123';
      mockRemoteDataSource.logoutException = const ServerException();

      // Act
      final result = await repository.logout();

      // Assert
      expect(result.isRight(), true);
      expect(mockLocalDataSource.clearTokensCalled, true);
      expect(mockLocalDataSource.clearCachedUserCalled, true);
    });
  });

  group('getCurrentUser', () {
    test('should return cached user if available', () async {
      // Arrange
      mockLocalDataSource.cachedUser = testUserModel;

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return user'),
        (user) => expect(user.id, '1'),
      );
    });

    test('should fetch from remote if not cached', () async {
      // Arrange
      mockRemoteDataSource.getCurrentUserResult = testUserModel;

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result.isRight(), true);
      expect(mockLocalDataSource.cacheUserCalled, true);
    });
  });

  group('isAuthenticated', () {
    test('should return true when access token exists', () async {
      // Arrange
      mockLocalDataSource.accessToken = 'access_token_123';

      // Act
      final result = await repository.isAuthenticated();

      // Assert
      expect(result, true);
    });

    test('should return false when no access token', () async {
      // Act
      final result = await repository.isAuthenticated();

      // Assert
      expect(result, false);
    });
  });
}
