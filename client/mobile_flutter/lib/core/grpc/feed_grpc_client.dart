import 'package:grpc/grpc.dart';
import '../../generated/protos/feed/feed.pbgrpc.dart';
import '../../generated/protos/common/common.pb.dart' as common;
import 'grpc_client.dart';

/// Feed gRPC 客户端
/// 封装 Feed 相关的 gRPC 调用（点赞、评论、转发、收藏等）
class FeedGrpcClient {
  FeedGrpcClient(this._manager) {
    _stub = FeedServiceClient(_manager.channel);
  }

  final GrpcClientManager _manager;
  late final FeedServiceClient _stub;

  /// 获取动态流
  Future<FeedResponse> getFeeds({
    required String userId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = GetFeedRequest()
        ..userId = userId
        ..pagination = (common.Pagination()
          ..page = page
          ..pageSize = pageSize);
      return await _stub.getFeed(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'GetFeeds');
      rethrow;
    }
  }

  /// 获取关注用户的动态流
  Future<FeedResponse> getFollowingFeed({
    required String userId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = GetFeedRequest()
        ..userId = userId
        ..pagination = (common.Pagination()
          ..page = page
          ..pageSize = pageSize);
      return await _stub.getFollowingFeed(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'GetFollowingFeed');
      rethrow;
    }
  }

  /// 点赞帖子
  Future<LikeResponse> likePost({
    required String userId,
    required String postId,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = LikeRequest()
        ..userId = userId
        ..postId = postId;
      return await _stub.likePost(request, options: options);
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
      final request = LikeRequest()
        ..userId = userId
        ..postId = postId;
      await _stub.unlikePost(request, options: options);
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
      final request = AddCommentRequest()
        ..userId = userId
        ..postId = postId
        ..content = content;
      if (parentId != null) {
        request.parentId = parentId;
      }
      return await _stub.addComment(request, options: options);
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
  Future<CommentsResponse> getComments({
    required String postId,
    String? parentId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = GetCommentsRequest()
        ..postId = postId
        ..pagination = (common.Pagination()
          ..page = page
          ..pageSize = pageSize);
      if (parentId != null) {
        request.parentId = parentId;
      }
      return await _stub.getComments(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'GetComments');
      rethrow;
    }
  }

  /// 转发帖子
  Future<RepostResponse> repost({
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
      return await _stub.repost(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'Repost');
      rethrow;
    }
  }

  /// 取消转发
  Future<void> removeRepost({
    required String userId,
    required String postId,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = RepostRequest()
        ..userId = userId
        ..postId = postId;
      await _stub.removeRepost(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'RemoveRepost');
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
      await _stub.bookmarkPost(request, options: options);
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
      final request = BookmarkRequest()
        ..userId = userId
        ..postId = postId;
      await _stub.removeBookmark(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'RemoveBookmark');
      rethrow;
    }
  }

  /// 获取收藏列表
  Future<FeedResponse> getBookmarks({
    required String userId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = GetBookmarksRequest()
        ..userId = userId
        ..pagination = (common.Pagination()
          ..page = page
          ..pageSize = pageSize);
      return await _stub.getBookmarks(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'GetBookmarks');
      rethrow;
    }
  }
}
