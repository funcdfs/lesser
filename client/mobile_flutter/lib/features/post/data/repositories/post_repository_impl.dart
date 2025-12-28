import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../feeds/domain/entities/feed_item.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_remote_datasource.dart';

/// Post repository implementation
class PostRepositoryImpl implements PostRepository {
  const PostRepositoryImpl({
    required PostRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final PostRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, FeedItem>> createPost(CreatePostRequest request) async {
    try {
      final post = await _remoteDataSource.createPost(
        content: request.content,
        postType: request.postType,
        title: request.title,
        mediaUrls: request.mediaUrls,
      );
      return Right(post);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, FeedItem>> updatePost({
    required String postId,
    String? content,
    String? title,
  }) async {
    try {
      final post = await _remoteDataSource.updatePost(
        postId: postId,
        content: content,
        title: title,
      );
      return Right(post);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deletePost(String postId) async {
    try {
      await _remoteDataSource.deletePost(postId);
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
  Future<Either<Failure, List<FeedItem>>> getUserPosts({
    required String userId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final posts = await _remoteDataSource.getUserPosts(
        userId: userId,
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
}
