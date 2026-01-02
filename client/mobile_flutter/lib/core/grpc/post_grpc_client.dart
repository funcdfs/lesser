import 'package:grpc/grpc.dart';
import '../../generated/protos/post/post.pbgrpc.dart';
import '../../generated/protos/common/common.pb.dart' as common;
import 'grpc_client.dart';

/// Post gRPC 客户端
/// 封装 Post 相关的 gRPC 调用（创建、获取、更新、删除帖子）
class PostGrpcClient {
  PostGrpcClient(this._manager) {
    _stub = PostServiceClient(_manager.channel);
  }

  final GrpcClientManager _manager;
  late final PostServiceClient _stub;

  /// 创建帖子
  Future<Post> createPost({
    required String authorId,
    required PostType postType,
    required String content,
    List<String>? mediaUrls,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = CreatePostRequest()
        ..authorId = authorId
        ..postType = postType
        ..content = content;
      if (mediaUrls != null && mediaUrls.isNotEmpty) {
        request.mediaUrls.addAll(mediaUrls);
      }
      return await _stub.create(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'CreatePost');
      rethrow;
    }
  }

  /// 获取帖子详情
  Future<Post> getPost(String postId) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = GetPostRequest()..postId = postId;
      return await _stub.get(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'GetPost');
      rethrow;
    }
  }

  /// 更新帖子
  Future<Post> updatePost({
    required String postId,
    required String authorId,
    String? content,
    List<String>? mediaUrls,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = UpdatePostRequest()
        ..postId = postId
        ..userId = authorId;
      if (content != null) {
        request.content = content;
      }
      if (mediaUrls != null) {
        request.mediaUrls.addAll(mediaUrls);
      }
      return await _stub.update(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'UpdatePost');
      rethrow;
    }
  }

  /// 删除帖子
  Future<void> deletePost({
    required String postId,
    required String authorId,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = DeletePostRequest()
        ..postId = postId
        ..userId = authorId;
      await _stub.delete(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'DeletePost');
      rethrow;
    }
  }

  /// 获取帖子列表
  Future<ListPostsResponse> getUserPosts({
    required String userId,
    PostType? postType,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = ListPostsRequest()
        ..authorId = userId
        ..pagination = (common.Pagination()
          ..page = page
          ..pageSize = pageSize);
      if (postType != null) {
        request.postType = postType;
      }
      return await _stub.list(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'GetUserPosts');
      rethrow;
    }
  }
}
