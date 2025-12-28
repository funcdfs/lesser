import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/core/errors/failures.dart';
import 'package:mobile_flutter/features/auth/domain/entities/user.dart';
import 'package:mobile_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile_flutter/features/auth/domain/usecases/register.dart';

/// Mock implementation of AuthRepository for testing
class MockAuthRepository implements AuthRepository {
  Either<Failure, User>? registerResult;
  
  String? lastUsername;
  String? lastEmail;
  String? lastPassword;
  String? lastDisplayName;

  @override
  Future<Either<Failure, User>> register({
    required String username,
    required String email,
    required String password,
    String? displayName,
  }) async {
    lastUsername = username;
    lastEmail = email;
    lastPassword = password;
    lastDisplayName = displayName;
    return registerResult ?? const Left(ServerFailure());
  }

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    return const Left(ServerFailure());
  }

  @override
  Future<Either<Failure, void>> logout() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    return const Left(ServerFailure());
  }

  @override
  Future<bool> isAuthenticated() async {
    return false;
  }

  @override
  Future<Either<Failure, void>> refreshToken() async {
    return const Right(null);
  }
}

void main() {
  late RegisterUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = RegisterUseCase(mockRepository);
  });

  const testUser = User(
    id: '1',
    username: 'newuser',
    email: 'new@example.com',
    displayName: 'New User',
  );

  group('RegisterUseCase', () {
    test('should return User when registration is successful', () async {
      // Arrange
      mockRepository.registerResult = const Right(testUser);
      const params = RegisterParams(
        username: 'newuser',
        email: 'new@example.com',
        password: 'password123',
        displayName: 'New User',
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, const Right(testUser));
      expect(mockRepository.lastUsername, 'newuser');
      expect(mockRepository.lastEmail, 'new@example.com');
      expect(mockRepository.lastPassword, 'password123');
      expect(mockRepository.lastDisplayName, 'New User');
    });

    test('should return ServerFailure when registration fails', () async {
      // Arrange
      mockRepository.registerResult = const Left(ServerFailure(message: 'Email already exists'));
      const params = RegisterParams(
        username: 'existinguser',
        email: 'existing@example.com',
        password: 'password123',
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should work without displayName', () async {
      // Arrange
      mockRepository.registerResult = const Right(testUser);
      const params = RegisterParams(
        username: 'newuser',
        email: 'new@example.com',
        password: 'password123',
      );

      // Act
      await useCase(params);

      // Assert
      expect(mockRepository.lastDisplayName, isNull);
    });

    test('should return NetworkFailure when there is no connection', () async {
      // Arrange
      mockRepository.registerResult = const Left(NetworkFailure());
      const params = RegisterParams(
        username: 'newuser',
        email: 'new@example.com',
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
  });
}
