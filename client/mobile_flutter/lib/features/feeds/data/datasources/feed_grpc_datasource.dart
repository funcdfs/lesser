import 'package:grpc/grpc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/grpc/feed_grpc_client.dart';
import '../../../../core/grpc/grpc_client.dart';
import '../models/comment_model.dart';
import '../models/feed_item_model.dart';
import 'feed_remote_datasource.dart';

/// Feed gRPC data source implementation
/// 使用 gRPC 替代 REST API 实现 Feed 数据源
class FeedGrpcDataSourceImpl implements FeedRemoteDataSource {
  FeedGrpcDataSourceImpl(
    this._grpcClient,
    this._sharedPreferences,
  );

  final FeedGrpcClient _grpcClient;
  final SharedPreferences _sharedPreferences;

  String? get _currentUserId => _sharedPreferences.getString('user_id');

  @override
  Future<List<FeedItemModel>> getFeeds({
    int page = 1,
    int pageSize = 20,
  }) async {
    // Note: Feed service doesn't provide getFeed method
    // This would need to be implemented via Post service
    // For now, return empty list
    throw UnimplementedError('getFeeds not implemented - use PostService instead');
  }

  @override
  Future<FeedItemModel> getFeedById(String id) async {
    // Note: The current proto doesn't have a GetFeedById method
    // This would need to be added to the proto or use GetPost from PostService
    throw UnimplementedError('getFeedById not implemented in gRPC');
  }

  @override
  Future<void> likePost(String postId) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw const UnauthorizedException();
      }

      await _grpcClient.likePost(
        userId: userId,
        postId: postId,
      );
    } on GrpcError catch (e) {
      throw _handleGrpcError(e);
    }
  }

  @override
  Future<void> unlikePost(String postId) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw const UnauthorizedException();
      }

      await _grpcClient.unlikePost(
        userId: userId,
        postId: postId,
      );
    } on GrpcError catch (e) {
      throw _handleGrpcError(e);
    }
  }

  @override
  Future<void> repost(String postId) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw const UnauthorizedException();
      }

      await _grpcClient.repost(
        userId: userId,
        postId: postId,
      );
    } on GrpcError catch (e) {
      throw _handleGrpcError(e);
    }
  }

  @override
  Future<void> removeRepost(String postId) async {
    // Note: Feed service doesn't have removeRepost method
    // This would need to be added to the proto
    throw UnimplementedError('removeRepost not implemented in proto');
  }

  @override
  Future<void> bookmark(String postId) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw const UnauthorizedException();
      }

      await _grpcClient.bookmarkPost(
        userId: userId,
        postId: postId,
      );
    } on GrpcError catch (e) {
      throw _handleGrpcError(e);
    }
  }

  @override
  Future<void> removeBookmark(String postId) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw const UnauthorizedException();
      }

      await _grpcClient.removeBookmark(
        userId: userId,
        postId: postId,
      );
    } on GrpcError catch (e) {
      throw _handleGrpcError(e);
    }
  }

  @override
  Future<List<CommentModel>> getComments({
    required String postId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _grpcClient.getComments(
        postId: postId,
        page: page,
        pageSize: pageSize,
      );

      return response.comments.map((c) => CommentModel.fromProto(c)).toList();
    } on GrpcError catch (e) {
      throw _handleGrpcError(e);
    }
  }

  @override
  Future<CommentModel> addComment({
    required String postId,
    required String content,
    String? parentId,
  }) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw const UnauthorizedException();
      }

      final comment = await _grpcClient.addComment(
        userId: userId,
        postId: postId,
        content: content,
        parentId: parentId,
      );

      return CommentModel.fromProto(comment);
    } on GrpcError catch (e) {
      throw _handleGrpcError(e);
    }
  }

  @override
  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw const UnauthorizedException();
      }

      await _grpcClient.deleteComment(
        commentId: commentId,
        userId: userId,
      );
    } on GrpcError catch (e) {
      throw _handleGrpcError(e);
    }
  }

  AppException _handleGrpcError(GrpcError e) {
    GrpcErrorHandler.logError(e, context: 'FeedGrpcDataSource');

    switch (e.code) {
      case StatusCode.unauthenticated:
        return const UnauthorizedException();
      case StatusCode.notFound:
        return const NotFoundException();
      case StatusCode.deadlineExceeded:
        return const TimeoutException();
      case StatusCode.unavailable:
        return const NetworkException();
      case StatusCode.invalidArgument:
        return ServerException(message: e.message ?? 'Invalid argument');
      default:
        return ServerException(message: e.message ?? 'Server error');
    }
  }
}
