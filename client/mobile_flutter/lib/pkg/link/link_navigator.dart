// 深层链接导航器
//
// 处理 lesser.app 链接的导航逻辑，支持跳转到频道、消息、评论等

import 'package:flutter/material.dart';

import 'models/link_model.dart';
import 'link_parser.dart';
import 'link_resolver.dart';

/// 链接导航结果
enum LinkNavigationResult {
  /// 导航成功
  success,

  /// 链接无效
  invalidLink,

  /// 内容不存在
  notFound,

  /// 内容已删除
  deleted,

  /// 导航失败
  failed,
}

/// 链接导航器
///
/// 解析深层链接并导航到对应页面
/// 支持的链接格式：
/// - https://lesser.app/channel/{channelId}
/// - https://lesser.app/channel/{channelId}/message/{messageId}
/// - https://lesser.app/channel/{channelId}/message/{messageId}/comment/{commentId}
class LinkNavigator {
  LinkNavigator({
    required this.resolver,
    required this.onNavigateToChannel,
    required this.onNavigateToMessage,
    required this.onNavigateToComment,
    this.onShowChannelCard,
  });

  /// 链接解析器
  final LinkResolver resolver;

  /// 导航到频道
  final Future<bool> Function(BuildContext context, String channelId)
  onNavigateToChannel;

  /// 导航到消息
  final Future<bool> Function(
    BuildContext context,
    String channelId,
    String messageId, {
    bool highlightMessage,
  })
  onNavigateToMessage;

  /// 导航到评论
  ///
  /// [rootCommentId] 评论树的根节点 ID（用于打开正确的线程）
  /// [targetCommentId] 目标评论 ID（用于高亮和滚动）
  final Future<bool> Function(
    BuildContext context,
    String channelId,
    String messageId,
    String rootCommentId,
    String targetCommentId,
  )
  onNavigateToComment;

  /// 显示频道名片（可选）
  final Future<void> Function(BuildContext context, String channelId)?
  onShowChannelCard;

  /// 从 URL 字符串导航
  Future<LinkNavigationResult> navigateFromUrl(
    BuildContext context,
    String url,
  ) async {
    // 解析 URL
    final link = LinkParser.parse(url);
    if (link == null) {
      return LinkNavigationResult.invalidLink;
    }

    return navigateFromLink(context, link);
  }

  /// 从 LinkModel 导航
  Future<LinkNavigationResult> navigateFromLink(
    BuildContext context,
    LinkModel link,
  ) async {
    try {
      return switch (link.targetType) {
        LinkContentType.channel => _navigateToChannel(context, link),
        LinkContentType.message => _navigateToMessage(context, link),
        LinkContentType.comment => _navigateToComment(context, link),
        LinkContentType.user ||
        LinkContentType.post ||
        LinkContentType.anchor => Future.value(LinkNavigationResult.failed),
      };
    } catch (e) {
      return LinkNavigationResult.failed;
    }
  }

  /// 导航到频道
  Future<LinkNavigationResult> _navigateToChannel(
    BuildContext context,
    LinkModel link,
  ) async {
    final channelId = link.targetId;

    // 如果有显示名片的回调，显示名片而不是直接跳转
    if (onShowChannelCard != null) {
      if (!context.mounted) return LinkNavigationResult.failed;
      await onShowChannelCard!(context, channelId);
      return LinkNavigationResult.success;
    }

    // 直接导航到频道
    if (!context.mounted) return LinkNavigationResult.failed;
    final success = await onNavigateToChannel(context, channelId);
    return success
        ? LinkNavigationResult.success
        : LinkNavigationResult.notFound;
  }

  /// 导航到消息
  Future<LinkNavigationResult> _navigateToMessage(
    BuildContext context,
    LinkModel link,
  ) async {
    // 获取频道 ID
    final channelSegment = link.getSegment(LinkContentType.channel);
    if (channelSegment == null) {
      return LinkNavigationResult.invalidLink;
    }

    final channelId = channelSegment.id;
    final messageId = link.targetId;

    if (!context.mounted) return LinkNavigationResult.failed;
    final success = await onNavigateToMessage(
      context,
      channelId,
      messageId,
      highlightMessage: true,
    );

    return success
        ? LinkNavigationResult.success
        : LinkNavigationResult.notFound;
  }

  /// 导航到评论
  Future<LinkNavigationResult> _navigateToComment(
    BuildContext context,
    LinkModel link,
  ) async {
    // 获取频道 ID 和消息 ID
    final channelSegment = link.getSegment(LinkContentType.channel);
    final messageSegment = link.getSegment(LinkContentType.message);

    if (channelSegment == null || messageSegment == null) {
      return LinkNavigationResult.invalidLink;
    }

    final channelId = channelSegment.id;
    final messageId = messageSegment.id;
    final commentId = link.targetId;

    // 解析评论的根节点 ID
    final rootCommentId = await resolver.resolveCommentRoot(commentId);
    if (rootCommentId == null) {
      return LinkNavigationResult.notFound;
    }

    if (!context.mounted) return LinkNavigationResult.failed;
    final success = await onNavigateToComment(
      context,
      channelId,
      messageId,
      rootCommentId,
      commentId,
    );

    return success
        ? LinkNavigationResult.success
        : LinkNavigationResult.notFound;
  }
}
