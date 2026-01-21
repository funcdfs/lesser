// 深层链接服务
//
// 全局单例服务，处理应用内的深层链接导航

import 'package:flutter/material.dart';

import 'link_parser.dart';
import 'link_resolver.dart';
import 'models/link_model.dart';
import 'card/channel_card.dart';

/// 链接服务
///
/// 提供全局的深层链接导航功能
/// 使用方式：
/// 1. 在应用启动时初始化 LinkService.instance.init(...)
/// 2. 调用 LinkService.instance.navigate(context, url) 导航到链接
class LinkService {
  LinkService._();

  static final LinkService instance = LinkService._();

  LinkResolverDataSource? _dataSource;
  DefaultLinkResolver? _resolver;

  /// 导航回调
  NavigateToChannelCallback? _onNavigateToChannel;
  NavigateToMessageCallback? _onNavigateToMessage;
  NavigateToCommentCallback? _onNavigateToComment;

  /// 初始化服务
  void init({
    required LinkResolverDataSource dataSource,
    required NavigateToChannelCallback onNavigateToChannel,
    required NavigateToMessageCallback onNavigateToMessage,
    required NavigateToCommentCallback onNavigateToComment,
  }) {
    _dataSource = dataSource;
    _resolver = DefaultLinkResolver(dataSource: dataSource);
    _onNavigateToChannel = onNavigateToChannel;
    _onNavigateToMessage = onNavigateToMessage;
    _onNavigateToComment = onNavigateToComment;
  }

  /// 是否已初始化
  bool get isInitialized => _resolver != null;

  /// 从 URL 导航
  ///
  /// [mode] 导航模式：
  /// - [LinkNavigateMode.push]：新增页面（默认）
  /// - [LinkNavigateMode.replace]：替换当前页面（页面内滚动）
  Future<LinkNavigateResult> navigate(
    BuildContext context,
    String url, {
    LinkNavigateMode mode = LinkNavigateMode.push,
  }) async {
    if (!isInitialized) {
      return LinkNavigateResult.notInitialized;
    }

    // 解析 URL
    final link = LinkParser.parse(url);
    if (link == null) {
      return LinkNavigateResult.invalidLink;
    }

    return navigateToLink(context, link, mode: mode);
  }

  /// 从 LinkModel 导航
  Future<LinkNavigateResult> navigateToLink(
    BuildContext context,
    LinkModel link, {
    LinkNavigateMode mode = LinkNavigateMode.push,
  }) async {
    if (!isInitialized) {
      return LinkNavigateResult.notInitialized;
    }

    try {
      switch (link.targetType) {
        case LinkContentType.channel:
          return _navigateToChannel(context, link);

        case LinkContentType.message:
          return _navigateToMessage(context, link);

        case LinkContentType.comment:
          return _navigateToComment(context, link, mode: mode);

        case LinkContentType.anchor:
          return _navigateToAnchor(context, link, mode: mode);

        case LinkContentType.user:
        case LinkContentType.post:
          // 暂不支持
          return LinkNavigateResult.unsupported;
      }
    } catch (e) {
      return LinkNavigateResult.failed;
    }
  }

  /// 导航到频道（显示名片）
  Future<LinkNavigateResult> _navigateToChannel(
    BuildContext context,
    LinkModel link,
  ) async {
    final channelId = link.targetId;

    // 获取频道信息
    final info = await _dataSource!.getChannelInfo(channelId);
    if (info == null) {
      return LinkNavigateResult.notFound;
    }

    // 检查 context 是否仍然有效
    if (!context.mounted) {
      return LinkNavigateResult.failed;
    }

    // 显示频道名片
    await ChannelCard.show(
      context,
      channelId: info.id,
      channelName: info.name,
      description: info.description,
      avatarUrl: info.avatarUrl,
      subscriberCount: info.subscriberCount,
      isSubscribed: info.isSubscribed,
      onOpen: () {
        _onNavigateToChannel?.call(context, info.id);
      },
    );

    return LinkNavigateResult.success;
  }

  /// 导航到消息
  Future<LinkNavigateResult> _navigateToMessage(
    BuildContext context,
    LinkModel link,
  ) async {
    // 获取频道 ID
    final channelSegment = link.getSegment(LinkContentType.channel);
    if (channelSegment == null) {
      return LinkNavigateResult.invalidLink;
    }

    final channelId = channelSegment.id;
    final messageId = link.targetId;

    // 检查 context 是否仍然有效
    if (!context.mounted) {
      return LinkNavigateResult.failed;
    }

    final success = await _onNavigateToMessage?.call(
      context,
      channelId,
      messageId,
      highlightMessage: true,
    );

    return (success ?? false)
        ? LinkNavigateResult.success
        : LinkNavigateResult.notFound;
  }

  /// 导航到评论
  Future<LinkNavigateResult> _navigateToComment(
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

    // 普通评论：解析根节点 ID
    final rootCommentId = await _resolver!.resolveCommentRoot(commentId);
    if (rootCommentId == null) {
      return LinkNavigateResult.notFound;
    }

    // 检查 context 是否仍然有效
    if (!context.mounted) {
      return LinkNavigateResult.failed;
    }

    final success = await _onNavigateToComment?.call(
      context,
      channelId,
      messageId,
      rootCommentId,
      commentId,
      mode: mode,
    );

    return (success ?? false)
        ? LinkNavigateResult.success
        : LinkNavigateResult.notFound;
  }

  /// 导航到锚点（header/bottom）
  Future<LinkNavigateResult> _navigateToAnchor(
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
    final success = await _onNavigateToComment?.call(
      context,
      channelId,
      messageId,
      anchorId, // rootCommentId = anchorId
      anchorId, // targetCommentId = anchorId
      mode: mode,
    );

    return (success ?? false)
        ? LinkNavigateResult.success
        : LinkNavigateResult.notFound;
  }

  /// 获取链接元数据（用于渲染预览卡片）
  Future<LinkMetadata?> getMetadata(String url) async {
    if (!isInitialized) return null;

    final link = LinkParser.parse(url);
    if (link == null) return null;

    return _resolver!.resolve(link);
  }
}

/// 导航结果
enum LinkNavigateResult {
  /// 成功
  success,

  /// 服务未初始化
  notInitialized,

  /// 链接无效
  invalidLink,

  /// 内容不存在
  notFound,

  /// 不支持的链接类型
  unsupported,

  /// 导航失败
  failed,
}

/// 导航模式
enum LinkNavigateMode {
  /// 新增页面（push 新页面）
  push,

  /// 替换当前页面（页面内滚动，不创建新页面）
  replace,
}

/// 导航到频道回调
typedef NavigateToChannelCallback =
    Future<bool> Function(BuildContext context, String channelId);

/// 导航到消息回调
typedef NavigateToMessageCallback =
    Future<bool> Function(
      BuildContext context,
      String channelId,
      String messageId, {
      bool highlightMessage,
    });

/// 导航到评论回调
typedef NavigateToCommentCallback =
    Future<bool> Function(
      BuildContext context,
      String channelId,
      String messageId,
      String rootCommentId,
      String targetCommentId, {
      LinkNavigateMode mode,
    });
