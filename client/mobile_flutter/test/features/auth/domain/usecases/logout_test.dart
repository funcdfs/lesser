import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/core/errors/failures.dart';
import 'package:mobile_flutter/features/auth/domain/entities/user.dart';
import 'package:mobile_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile_flutter/features/auth/domain/usecases/logout.dart';

/// Mock implementation of AuthRepository for testing
class MockAuthRepository implements AuthRepository {
  Either<Failure, void>? logoutResult;
  bool logoutCalled = false;

  @override
  Future<Either<Failure, void>> logout() async {
    logoutCalled = true;
    return logoutResult ?? const Right(null);
  }

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    return const Left(ServerFailure());
  }

  @override
  Future<Either<Failure, User>> register({
    required String username,
    required String email,
    required String password,
    String? displayName,
  }) async {
    return const Left(ServerFailure());
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
  late LogoutUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LogoutUseCase(mockRepository);
  });

  group('LogoutUseCase', () {
    test('should return Right(null) when logout is successful', () async {
      // Arrange
      mockRepository.logoutResult = const Right(null);

      // Act
      final result = await useCase();

      // Assert
      expect(result, const Right(null));
      expect(mockRepository.logoutCalled, true);
    });

    test('should return CacheFailure when clearing local data fails', () async {
      // Arrange
      mockRepository.logoutResult = const Left(CacheFailure(message: 'Failed to clear cache'));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should call repository logout method', () async {
      // Arrange
      mockRepository.logoutResult = const Right(null);

      // Act
      await useCase();

      // Assert
      expect(mockRepository.logoutCalled, true);
    });
  });
}
