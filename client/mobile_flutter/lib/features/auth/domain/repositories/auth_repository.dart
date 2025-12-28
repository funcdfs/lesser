import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

/// Auth repository interface
abstract class AuthRepository {
  /// Register a new user
  Future<Either<Failure, User>> register({
    required String username,
    required String email,
    required String password,
    String? displayName,
  });

  /// Login with email and password
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Logout current user
  Future<Either<Failure, void>> logout();

  /// Get current authenticated user
  Future<Either<Failure, User>> getCurrentUser();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Refresh access token
  Future<Either<Failure, void>> refreshToken();
}
