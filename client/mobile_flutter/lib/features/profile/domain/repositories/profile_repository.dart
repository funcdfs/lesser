import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../entities/profile.dart';

/// Profile repository interface
abstract class ProfileRepository {
  /// Get profile by user ID
  Future<Either<Failure, Profile>> getProfile(String userId);

  /// Get current user's profile
  Future<Either<Failure, Profile>> getCurrentProfile();

  /// Update profile
  Future<Either<Failure, User>> updateProfile({
    String? displayName,
    String? bio,
    String? avatarUrl,
  });

  /// Follow user
  Future<Either<Failure, void>> followUser(String userId);

  /// Unfollow user
  Future<Either<Failure, void>> unfollowUser(String userId);

  /// Get followers
  Future<Either<Failure, List<User>>> getFollowers({
    required String userId,
    int page = 1,
    int pageSize = 20,
  });

  /// Get following
  Future<Either<Failure, List<User>>> getFollowing({
    required String userId,
    int page = 1,
    int pageSize = 20,
  });
}
