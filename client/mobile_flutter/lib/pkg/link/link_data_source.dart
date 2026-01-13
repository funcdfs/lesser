// 链接数据源
//
// 真实数据源实现，通过 gRPC 获取链接元数据

import 'link_resolver.dart';

/// gRPC 链接数据源
///
/// 通过 gRPC 调用后端服务获取链接元数据
/// 需要注入各服务的 DataAccess 实例
class GrpcLinkDataSource implements LinkResolverDataSource {
  GrpcLinkDataSource({
    required this.channelDataAccess,
    required this.contentDataAccess,
    required this.commentDataAccess,
    required this.userDataAccess,
  });

  /// 频道数据访问
  final ChannelDataAccessInterface channelDataAccess;

  /// 内容数据访问
  final ContentDataAccessInterface contentDataAccess;

  /// 评论数据访问
  final CommentDataAccessInterface commentDataAccess;

  /// 用户数据访问
  final UserDataAccessInterface userDataAccess;

  @override
  Future<ChannelInfo?> getChannelInfo(String channelId) async {
    try {
      return await channelDataAccess.getChannelInfo(channelId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<MessageInfo?> getMessageInfo(
    String channelId,
    String messageId,
  ) async {
    try {
      return await contentDataAccess.getMessageInfo(channelId, messageId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<CommentInfo?> getCommentInfo(String commentId) async {
    try {
      return await commentDataAccess.getCommentInfo(commentId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserInfo?> getUserInfo(String userId) async {
    try {
      return await userDataAccess.getUserInfo(userId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<PostInfo?> getPostInfo(String postId) async {
    try {
      return await contentDataAccess.getPostInfo(postId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getCommentRootId(String commentId) async {
    try {
      return await commentDataAccess.getCommentRootId(commentId);
    } catch (e) {
      return null;
    }
  }
}

// =============================================================================
// 数据访问接口定义
// =============================================================================

/// 频道数据访问接口
abstract class ChannelDataAccessInterface {
  Future<ChannelInfo?> getChannelInfo(String channelId);
}

/// 内容数据访问接口
abstract class ContentDataAccessInterface {
  Future<MessageInfo?> getMessageInfo(String channelId, String messageId);
  Future<PostInfo?> getPostInfo(String postId);
}

/// 评论数据访问接口
abstract class CommentDataAccessInterface {
  Future<CommentInfo?> getCommentInfo(String commentId);
  Future<String?> getCommentRootId(String commentId);
}

/// 用户数据访问接口
abstract class UserDataAccessInterface {
  Future<UserInfo?> getUserInfo(String userId);
}
