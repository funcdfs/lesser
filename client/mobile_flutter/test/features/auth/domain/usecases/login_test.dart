import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/core/errors/failures.dart';
import 'package:mobile_flutter/features/auth/domain/entities/user.dart';
import 'package:mobile_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile_flutter/features/auth/domain/usecases/login.dart';

/// Mock implementation of AuthRepository for testing
class MockAuthRepository implements AuthRepository {
  Either<Failure, User>? loginResult;
  Either<Failure, User>? registerResult;
  Either<Failure, void>? logoutResult;
  Either<Failure, User>? getCurrentUserResult;
  Either<Failure, void>? refreshTokenResult;
  bool isAuthenticatedResult = false;

  String? lastLoginEmail;
  String? lastLoginPassword;

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    lastLoginEmail = email;
    lastLoginPassword = password;
    return loginResult ?? const Left(ServerFailure());
  }

  @override
  Future<Either<Failure, User>> register({
    required String username,
    required String email,
    required String password,
    String? displayName,
  }) async {
    return registerResult ?? const Left(ServerFailure());
  }

  @override
  Future<Either<Failure, void>> logout() async {
    return logoutResult ?? const Right(null);
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    return getCurrentUserResult ?? const Left(ServerFailure());
  }

  @override
  Future<bool> isAuthenticated() async {
    return isAuthenticatedResult;
  }

  @override
  Future<Either<Failure, void>> refreshToken() async {
    return refreshTokenResult ?? const Right(null);
  }
}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  const testUser = User(
    id: '1',
    username: 'testuser',
    email: 'test@example.com',
    displayName: 'Test User',
  );

  group('LoginUseCase', () {
    test('should return User when login is successful', () async {
      // Arrange
      mockRepository.loginResult = const Right(testUser);
      const params = LoginParams(
        email: 'test@example.com',
        password: 'password123',
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, const Right(testUser));
      expect(mockRepository.lastLoginEmail, 'test@example.com');
      expect(mockRepository.lastLoginPassword, 'password123');
    });

    test('should return AuthFailure when credentials are invalid', () async {
      // Arrange
      mockRepository.loginResult = const Left(AuthFailure(message: 'Invalid credentials'));
      const params = LoginParams(
        email: 'test@example.com',
        password: 'wrongpassword',
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should return NetworkFailure when there is no connection', () async {
      // Arrange
      mockRepository.loginResult = const Left(NetworkFailure());
      const params = LoginParams(
        email: 'test@example.com',
        password: 'password123',
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should pass correct parameters to repository', () async {
      // Arrange
      mockRepository.loginResult = const Right(testUser);
      const params = LoginParams(
        email: 'user@test.com',
        password: 'securepass',
      );

      // Act
      await useCase(params);

      // Assert
      expect(mockRepository.lastLoginEmail, 'user@test.com');
      expect(mockRepository.lastLoginPassword, 'securepass');
    });
  });
}
