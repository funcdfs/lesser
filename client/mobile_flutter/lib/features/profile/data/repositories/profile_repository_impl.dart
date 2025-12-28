import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

/// Profile repository implementation
class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({
    required ProfileRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, Profile>> getProfile(String userId) async {
    try {
      final profile = await _remoteDataSource.getProfile(userId);
      return Right(profile);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NotFoundException {
      return const Left(NotFoundFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Profile>> getCurrentProfile() async {
    try {
      final profile = await _remoteDataSource.getCurrentProfile();
      return Right(profile);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    String? displayName,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      final user = await _remoteDataSource.updateProfile(
        displayName: displayName,
        bio: bio,
        avatarUrl: avatarUrl,
      );
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> followUser(String userId) async {
    try {
      await _remoteDataSource.followUser(userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> unfollowUser(String userId) async {
    try {
      await _remoteDataSource.unfollowUser(userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<User>>> getFollowers({
    required String userId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final followers = await _remoteDataSource.getFollowers(
        userId: userId,
        page: page,
        pageSize: pageSize,
      );
      return Right(followers);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<User>>> getFollowing({
    required String userId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final following = await _remoteDataSource.getFollowing(
        userId: userId,
        page: page,
        pageSize: pageSize,
      );
      return Right(following);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }
}
