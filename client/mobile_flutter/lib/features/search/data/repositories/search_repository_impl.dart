import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../feeds/domain/entities/feed_item.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_datasource.dart';

/// Search repository implementation
class SearchRepositoryImpl implements SearchRepository {
  const SearchRepositoryImpl({
    required SearchRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final SearchRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<FeedItem>>> searchPosts({
    required String query,
    String? postType,
    DateTime? fromDate,
    DateTime? toDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final posts = await _remoteDataSource.searchPosts(
        query: query,
        postType: postType,
        fromDate: fromDate,
        toDate: toDate,
        page: page,
        pageSize: pageSize,
      );
      return Right(posts);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<User>>> searchUsers({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final users = await _remoteDataSource.searchUsers(
        query: query,
        page: page,
        pageSize: pageSize,
      );
      return Right(users);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }
}
