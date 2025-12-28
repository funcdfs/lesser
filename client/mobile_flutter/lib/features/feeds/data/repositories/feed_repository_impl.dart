import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/feed_item.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_remote_datasource.dart';

/// Feed repository implementation
class FeedRepositoryImpl implements FeedRepository {
  const FeedRepositoryImpl({
    required FeedRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final FeedRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<FeedItem>>> getFeeds({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final feeds = await _remoteDataSource.getFeeds(
        page: page,
        pageSize: pageSize,
      );
      return Right(feeds);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, FeedItem>> getFeedById(String id) async {
    try {
      final feed = await _remoteDataSource.getFeedById(id);
      return Right(feed);
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
  Future<Either<Failure, void>> likePost(String postId) async {
    try {
      await _remoteDataSource.likePost(postId);
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
  Future<Either<Failure, void>> unlikePost(String postId) async {
    try {
      await _remoteDataSource.unlikePost(postId);
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
  Future<Either<Failure, void>> repost(String postId) async {
    try {
      await _remoteDataSource.repost(postId);
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
  Future<Either<Failure, void>> removeRepost(String postId) async {
    try {
      await _remoteDataSource.removeRepost(postId);
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
  Future<Either<Failure, void>> bookmark(String postId) async {
    try {
      await _remoteDataSource.bookmark(postId);
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
  Future<Either<Failure, void>> removeBookmark(String postId) async {
    try {
      await _remoteDataSource.removeBookmark(postId);
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
  Future<Either<Failure, List<Comment>>> getComments({
    required String postId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final comments = await _remoteDataSource.getComments(
        postId: postId,
        page: page,
        pageSize: pageSize,
      );
      return Right(comments);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Comment>> addComment({
    required String postId,
    required String content,
    String? parentId,
  }) async {
    try {
      final comment = await _remoteDataSource.addComment(
        postId: postId,
        content: content,
        parentId: parentId,
      );
      return Right(comment);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      await _remoteDataSource.deleteComment(
        postId: postId,
        commentId: commentId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }
}
