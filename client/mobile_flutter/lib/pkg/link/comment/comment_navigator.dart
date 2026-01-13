// 评论导航器
//
// 处理评论相关的导航逻辑

import 'package:flutter/material.dart';

import '../link_resolver.dart';
import '../link_service.dart';
import '../models/link_model.dart';
import 'comment_link.dart';

/// 评论导航器
///
/// 处理评论链接的导航逻辑，包括：
/// - 普通评论跳转
/// - 锚点跳转（header/bottom）
class CommentNavigator {
  CommentNavigator({required this.resolver, required this.onNavigateToComment});

  /// 链接解析器
  final LinkResolver resolver;

  /// 导航到评论回调
  final NavigateToCommentCallback onNavigateToComment;

  /// 导航到评论
  ///
  /// [link] 评论链接模型
  /// [mode] 导航模式
  Future<LinkNavigateResult> navigate(
    BuildContext context,
    LinkModel link, {
    LinkNavigateMode mode = LinkNavigateMode.push,
  }) async {
    // 获取频道 ID 和消息 ID
    final channelSegment = link.getSegment(LinkContentType.channel);
    final messageSegment = link.getSegment(LinkContentType.message);

    if (channelSegment == null || messageSegment == null) {
      return LinkNavigateResult.invalidLink;
    }

    final channelId = channelSegment.id;
    final messageId = messageSegment.id;
    final commentId = link.targetId;

    // 解析根节点 ID
    final rootCommentId = await resolver.resolveCommentRoot(commentId);
    if (rootCommentId == null) {
      return LinkNavigateResult.notFound;
    }

    // 检查 context 是否仍然有效
    if (!context.mounted) {
      return LinkNavigateResult.failed;
    }

    final success = await onNavigateToComment(
      context,
      channelId,
      messageId,
      rootCommentId,
      commentId,
      mode: mode,
    );

    return success ? LinkNavigateResult.success : LinkNavigateResult.notFound;
  }

  /// 导航到锚点（header/bottom）
  ///
  /// [link] 锚点链接模型
  /// [mode] 导航模式
  Future<LinkNavigateResult> navigateToAnchor(
    BuildContext context,
    LinkModel link, {
    LinkNavigateMode mode = LinkNavigateMode.push,
  }) async {
    // 获取频道 ID 和消息 ID
    final channelSegment = link.getSegment(LinkContentType.channel);
    final messageSegment = link.getSegment(LinkContentType.message);

    if (channelSegment == null || messageSegment == null) {
      return LinkNavigateResult.invalidLink;
    }

    final channelId = channelSegment.id;
    final messageId = messageSegment.id;
    final anchorId = link.targetId;

    // 检查 context 是否仍然有效
    if (!context.mounted) {
      return LinkNavigateResult.failed;
    }

    // 锚点导航：使用特殊的 rootCommentId 和 targetCommentId
    final success = await onNavigateToComment(
      context,
      channelId,
      messageId,
      anchorId, // rootCommentId = anchorId
      anchorId, // targetCommentId = anchorId
      mode: mode,
    );

    return success ? LinkNavigateResult.success : LinkNavigateResult.notFound;
  }

  /// 检查是否是评论链接
  static bool isCommentLink(LinkModel link) {
    return link.targetType == LinkContentType.comment;
  }

  /// 检查是否是锚点链接
  static bool isAnchorLink(LinkModel link) {
    return link.targetType == LinkContentType.anchor;
  }

  /// 检查是否是特殊锚点（header/bottom）
  static bool isSpecialAnchor(LinkModel link) {
    if (!isAnchorLink(link)) return false;
    return CommentLink.isSpecialAnchor(link.targetId);
  }
}
