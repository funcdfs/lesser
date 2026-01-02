import 'package:grpc/grpc.dart';
import '../../generated/protos/feed/feed.pbgrpc.dart';
import '../../generated/protos/common/common.pb.dart' as common;
import 'grpc_client.dart';

/// Feed gRPC 客户端
/// 封装 Feed 相关的 gRPC 调用（点赞、评论、转发、收藏等）
/// 注意：Feed 服务不提供获取动态流的功能，动态流需要通过 Post 服务获取
class FeedGrpcClient {
  FeedGrpcClient(this._manager) {
    _stub = FeedServiceClient(_manager.channel);
  }

  final GrpcClientManager _manager;
  late final FeedServiceClient _stub;

  /// 点赞帖子
  Future<void> likePost({
    required String userId,
    required String postId,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = LikeRequest()
        ..userId = userId
        ..postId = postId;
      await _stub.like(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'LikePost');
      rethrow;
    }
  }

  /// 取消点赞
  Future<void> unlikePost({
    required String userId,
    required String postId,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = UnlikeRequest()
        ..userId = userId
        ..postId = postId;
      await _stub.unlike(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'UnlikePost');
      rethrow;
    }
  }

  /// 添加评论
  Future<Comment> addComment({
    required String userId,
    required String postId,
    required String content,
    String? parentId,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = CreateCommentRequest()
        ..authorId = userId
        ..postId = postId
        ..content = content;
      if (parentId != null) {
        request.parentId = parentId;
      }
      return await _stub.createComment(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'AddComment');
      rethrow;
    }
  }

  /// 删除评论
  Future<void> deleteComment({
    required String commentId,
    required String userId,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = DeleteCommentRequest()
        ..commentId = commentId
        ..userId = userId;
      await _stub.deleteComment(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'DeleteComment');
      rethrow;
    }
  }

  /// 获取评论列表
  Future<ListCommentsResponse> getComments({
    required String postId,
    String? parentId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = ListCommentsRequest()
        ..postId = postId
        ..pagination = (common.Pagination()
          ..page = page
          ..pageSize = pageSize);
      if (parentId != null) {
        request.parentId = parentId;
      }
      return await _stub.listComments(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'GetComments');
      rethrow;
    }
  }

  /// 转发帖子
  Future<Repost> repost({
    required String userId,
    required String postId,
    String? quote,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = RepostRequest()
        ..userId = userId
        ..postId = postId;
      if (quote != null) {
        request.quote = quote;
      }
      return await _stub.createRepost(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'Repost');
      rethrow;
    }
  }

  /// 收藏帖子
  Future<void> bookmarkPost({
    required String userId,
    required String postId,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = BookmarkRequest()
        ..userId = userId
        ..postId = postId;
      await _stub.bookmark(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'BookmarkPost');
      rethrow;
    }
  }

  /// 取消收藏
  Future<void> removeBookmark({
    required String userId,
    required String postId,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = UnbookmarkRequest()
        ..userId = userId
        ..postId = postId;
      await _stub.unbookmark(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'RemoveBookmark');
      rethrow;
    }
  }

  /// 获取收藏列表
  Future<ListBookmarksResponse> getBookmarks({
    required String userId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = ListBookmarksRequest()
        ..userId = userId
        ..pagination = (common.Pagination()
          ..page = page
          ..pageSize = pageSize);
      return await _stub.listBookmarks(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'GetBookmarks');
      rethrow;
    }
  }
}
