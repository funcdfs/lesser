import 'package:grpc/grpc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/grpc/post_grpc_client.dart';
import '../../../../core/grpc/grpc_client.dart';
import '../../../../generated/protos/post/post.pb.dart' as post_pb;
import '../../../feeds/data/models/feed_item_model.dart';
import '../../../feeds/domain/entities/feed_item.dart';
import 'post_remote_datasource.dart';

/// Post gRPC data source implementation
/// 使用 gRPC 替代 REST API 实现 Post 数据源
class PostGrpcDataSourceImpl implements PostRemoteDataSource {
  PostGrpcDataSourceImpl(
    this._grpcClient,
    this._sharedPreferences,
  );

  final PostGrpcClient _grpcClient;
  final SharedPreferences _sharedPreferences;

  String? get _currentUserId => _sharedPreferences.getString('user_id');

  @override
  Future<FeedItemModel> createPost({
    required String content,
    required PostType postType,
    String? title,
    List<String>? mediaUrls,
  }) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw const UnauthorizedException();
      }

      final post = await _grpcClient.createPost(
        authorId: userId,
        postType: _entityPostTypeToProto(postType),
        content: content,
        mediaUrls: mediaUrls,
      );

      return FeedItemModel.fromPostProto(post);
    } on GrpcError catch (e) {
      throw _handleGrpcError(e);
    }
  }

  @override
  Future<FeedItemModel> updatePost({
    required String postId,
    String? content,
    String? title,
  }) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw const UnauthorizedException();
      }

      final post = await _grpcClient.updatePost(
        postId: postId,
        authorId: userId,
        content: content,
      );

      return FeedItemModel.fromPostProto(post);
    } on GrpcError catch (e) {
      throw _handleGrpcError(e);
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw const UnauthorizedException();
      }

      await _grpcClient.deletePost(
        postId: postId,
        authorId: userId,
      );
    } on GrpcError catch (e) {
      throw _handleGrpcError(e);
    }
  }

  @override
  Future<List<FeedItemModel>> getUserPosts({
    required String userId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _grpcClient.getUserPosts(
        userId: userId,
        page: page,
        pageSize: pageSize,
      );

      return response.posts.map((p) => FeedItemModel.fromPostProto(p)).toList();
    } on GrpcError catch (e) {
      throw _handleGrpcError(e);
    }
  }

  post_pb.PostType _entityPostTypeToProto(PostType type) {
    switch (type) {
      case PostType.story:
        return post_pb.PostType.STORY;
      case PostType.short:
        return post_pb.PostType.SHORT;
      case PostType.column:
        return post_pb.PostType.COLUMN;
    }
  }

  AppException _handleGrpcError(GrpcError e) {
    GrpcErrorHandler.logError(e, context: 'PostGrpcDataSource');

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
        return ServerException(message: e.message);
      default:
        return ServerException(message: e.message);
    }
  }
}
