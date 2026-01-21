// 深层链接内容解析器
//
// 解析链接元数据，用于渲染链接预览卡片

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'models/link_model.dart';

/// 链接解析器接口
///
/// 用于获取链接指向内容的元数据
abstract class LinkResolver {
  /// 解析链接元数据
  ///
  /// 根据链接类型获取对应的内容信息，用于渲染预览卡片
  Future<LinkMetadata> resolve(LinkModel link);

  /// 解析评论的根节点 ID
  ///
  /// 对于嵌套评论，需要先找到评论树的根节点才能正确导航
  /// 返回根评论的 ID，如果评论本身就是根评论则返回自身 ID
  /// 如果评论不存在或已删除，返回 null
  Future<String?> resolveCommentRoot(String commentId);
}

/// 链接解析结果
class LinkResolveResult {
  const LinkResolveResult({
    required this.link,
    required this.metadata,
    this.error,
  });

  /// 原始链接
  final LinkModel link;

  /// 解析后的元数据
  final LinkMetadata metadata;

  /// 解析错误（如果有）
  final String? error;

  /// 是否解析成功
  bool get isSuccess => error == null;

  /// 是否内容已删除
  bool get isDeleted => metadata.isDeleted;
}

/// 链接解析器数据源接口
///
/// 提供获取各类内容信息的方法，由具体实现注入
abstract class LinkResolverDataSource {
  /// 获取频道信息
  Future<ChannelInfo?> getChannelInfo(String channelId);

  /// 获取消息信息
  Future<MessageInfo?> getMessageInfo(String channelId, String messageId);

  /// 获取评论信息
  Future<CommentInfo?> getCommentInfo(String commentId);

  /// 获取用户信息
  Future<UserInfo?> getUserInfo(String userId);

  /// 获取帖子信息
  Future<PostInfo?> getPostInfo(String postId);

  /// 获取评论的根节点 ID
  Future<String?> getCommentRootId(String commentId);
}

/// 频道信息
class ChannelInfo {
  const ChannelInfo({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.description,
    this.subscriberCount = 0,
    this.isSubscribed = false,
  });

  final String id;
  final String name;
  final String? avatarUrl;
  final String? description;
  final int subscriberCount;
  final bool isSubscribed;
}

/// 消息信息
class MessageInfo {
  const MessageInfo({
    required this.id,
    required this.channelId,
    required this.channelName,
    this.content,
    this.authorName,
    this.isDeleted = false,
  });

  final String id;
  final String channelId;
  final String channelName;
  final String? content;
  final String? authorName;
  final bool isDeleted;
}

/// 评论信息
class CommentInfo {
  const CommentInfo({
    required this.id,
    this.rootId,
    this.channelId,
    this.channelName,
    this.messageId,
    this.content,
    this.authorName,
    this.isDeleted = false,
  });

  final String id;
  final String? rootId; // 根评论 ID（如果是回复）
  final String? channelId;
  final String? channelName;
  final String? messageId;
  final String? content;
  final String? authorName;
  final bool isDeleted;

  /// 是否是根评论
  bool get isRoot => rootId == null || rootId == id;
}

/// 用户信息
class UserInfo {
  const UserInfo({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
  });

  final String id;
  final String username;
  final String? displayName;
  final String? avatarUrl;
}

/// 帖子信息
class PostInfo {
  const PostInfo({
    required this.id,
    this.content,
    this.authorName,
    this.isDeleted = false,
  });

  final String id;
  final String? content;
  final String? authorName;
  final bool isDeleted;
}

/// 默认链接解析器实现
///
/// 使用 LinkResolverDataSource 获取内容信息
class DefaultLinkResolver implements LinkResolver {
  DefaultLinkResolver({required this.dataSource});

  final LinkResolverDataSource dataSource;

  @override
  Future<LinkMetadata> resolve(LinkModel link) async {
    try {
      switch (link.targetType) {
        case LinkContentType.channel:
          return _resolveChannel(link.targetId);

        case LinkContentType.message:
          return _resolveMessage(link);

        case LinkContentType.comment:
          return _resolveComment(link);

        case LinkContentType.user:
          return _resolveUser(link.targetId);

        case LinkContentType.post:
          return _resolvePost(link.targetId);

        case LinkContentType.anchor:
          // 锚点类型不需要解析元数据，直接返回空
          return LinkMetadata.empty;
      }
    } catch (e) {
      // 解析失败返回空元数据
      return LinkMetadata.empty;
    }
  }

  @override
  Future<String?> resolveCommentRoot(String commentId) async {
    try {
      return await dataSource.getCommentRootId(commentId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Link] resolveCommentRoot failed commentId=$commentId error=$e');
      }
      return null;
    }
  }

  /// 解析频道链接
  Future<LinkMetadata> _resolveChannel(String channelId) async {
    final info = await dataSource.getChannelInfo(channelId);
    if (info == null) {
      return LinkMetadata.deleted;
    }

    return LinkMetadata(channelName: info.name, channelAvatar: info.avatarUrl);
  }

  /// 解析消息链接
  Future<LinkMetadata> _resolveMessage(LinkModel link) async {
    // 获取频道 ID
    final channelSegment = link.getSegment(LinkContentType.channel);
    if (channelSegment == null) {
      return LinkMetadata.empty;
    }

    final info = await dataSource.getMessageInfo(
      channelSegment.id,
      link.targetId,
    );
    if (info == null) {
      return LinkMetadata.deleted;
    }

    if (info.isDeleted) {
      return LinkMetadata.deleted;
    }

    return LinkMetadata(
      channelName: info.channelName,
      contentPreview: _truncateContent(info.content),
      authorName: info.authorName,
    );
  }

  /// 解析评论链接
  Future<LinkMetadata> _resolveComment(LinkModel link) async {
    final info = await dataSource.getCommentInfo(link.targetId);
    if (info == null) {
      return LinkMetadata.deleted;
    }

    if (info.isDeleted) {
      return LinkMetadata.deleted;
    }

    return LinkMetadata(
      channelName: info.channelName,
      contentPreview: _truncateContent(info.content),
      authorName: info.authorName,
    );
  }

  /// 解析用户链接
  Future<LinkMetadata> _resolveUser(String userId) async {
    final info = await dataSource.getUserInfo(userId);
    if (info == null) {
      return LinkMetadata.deleted;
    }

    return LinkMetadata(
      authorName: info.displayName ?? info.username,
      channelAvatar: info.avatarUrl,
    );
  }

  /// 解析帖子链接
  Future<LinkMetadata> _resolvePost(String postId) async {
    final info = await dataSource.getPostInfo(postId);
    if (info == null) {
      return LinkMetadata.deleted;
    }

    if (info.isDeleted) {
      return LinkMetadata.deleted;
    }

    return LinkMetadata(
      contentPreview: _truncateContent(info.content),
      authorName: info.authorName,
    );
  }

  /// 截断内容预览
  String? _truncateContent(String? content) {
    if (content == null || content.isEmpty) return null;
    if (content.length <= 50) return content;
    return '${content.substring(0, 50)}...';
  }
}
