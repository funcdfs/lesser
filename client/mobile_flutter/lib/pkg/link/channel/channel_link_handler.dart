import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../card/channel_card.dart';
import '../link_handler.dart';
import '../link_resolver.dart';
import '../link_types.dart';

class ChannelLinkHandler implements LinkHandler {
  ChannelLinkHandler({
    required LinkResolverDataSource dataSource,
    required LinkResolver resolver,
    required NavigateToChannelCallback onNavigateToChannel,
    required NavigateToMessageCallback onNavigateToMessage,
    required NavigateToCommentCallback onNavigateToComment,
  }) : _dataSource = dataSource,
       _resolver = resolver,
       _onNavigateToChannel = onNavigateToChannel,
       _onNavigateToMessage = onNavigateToMessage,
       _onNavigateToComment = onNavigateToComment;

  final LinkResolverDataSource _dataSource;
  final LinkResolver _resolver;
  final NavigateToChannelCallback _onNavigateToChannel;
  final NavigateToMessageCallback _onNavigateToMessage;
  final NavigateToCommentCallback _onNavigateToComment;

  static const _host = 'lesser.app';

  @override
  bool canHandle(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return false;
    if (uri.host != _host) return false;

    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return false;

    // /c/{channelKey}
    if (segments.length == 2 && segments[0] == 'c') return true;

    // /channel/{channelId}[/message/{messageId}[/comment/{commentId}|/anchor/{anchorId}]]
    if (segments[0] != 'channel') return false;
    if (segments.length < 2) return false;

    // At least /channel/{id}
    return true;
  }

  @override
  Future<LinkNavigateResult> navigate(
    BuildContext context,
    String url, {
    LinkNavigateMode mode = LinkNavigateMode.push,
  }) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || uri.host != _host) return LinkNavigateResult.invalidLink;

    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return LinkNavigateResult.invalidLink;

    try {
      if (kDebugMode) {
        debugPrint('[Link][Channel] handle url=$url segments=$segments mode=$mode');
      }

      if (segments.length == 2 && segments[0] == 'c') {
        final channelKey = segments[1];
        if (!_isValidId(channelKey)) return LinkNavigateResult.invalidLink;
        return _navigateToChannel(context, channelKey);
      }

      if (segments[0] != 'channel') return LinkNavigateResult.invalidLink;
      if (segments.length < 2) return LinkNavigateResult.invalidLink;

      final channelId = segments[1];
      if (!_isValidId(channelId)) return LinkNavigateResult.invalidLink;

      // /channel/{channelId}
      if (segments.length == 2) {
        return _navigateToChannel(context, channelId);
      }

      // /channel/{channelId}/message/{messageId}
      if (segments.length >= 4 && segments[2] == 'message') {
        final messageId = segments[3];
        if (!_isValidId(messageId)) return LinkNavigateResult.invalidLink;

        if (segments.length == 4) {
          return _navigateToMessage(context, channelId, messageId);
        }

        // /channel/{channelId}/message/{messageId}/comment/{commentId}
        if (segments.length == 6 && segments[4] == 'comment') {
          final commentId = segments[5];
          if (!_isValidId(commentId)) return LinkNavigateResult.invalidLink;
          return _navigateToComment(
            context,
            channelId,
            messageId,
            commentId,
            mode: mode,
          );
        }

        // /channel/{channelId}/message/{messageId}/anchor/{anchorId}
        if (segments.length == 6 && segments[4] == 'anchor') {
          final anchorId = segments[5];
          if (!_isValidAnchorId(anchorId)) return LinkNavigateResult.invalidLink;
          return _navigateToAnchor(
            context,
            channelId,
            messageId,
            anchorId,
            mode: mode,
          );
        }
      }

      return LinkNavigateResult.invalidLink;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Link][Channel] navigate failed: $e url=$url');
      }
      return LinkNavigateResult.failed;
    }
  }

  Future<LinkNavigateResult> _navigateToChannel(
    BuildContext context,
    String channelKey,
  ) async {
    final info = await _dataSource.getChannelInfo(channelKey);
    if (info == null) return LinkNavigateResult.notFound;

    if (!context.mounted) return LinkNavigateResult.failed;

    await ChannelCard.show(
      context,
      channelId: info.id,
      channelName: info.name,
      description: info.description,
      avatarUrl: info.avatarUrl,
      subscriberCount: info.subscriberCount,
      isSubscribed: info.isSubscribed,
      onOpen: () {
        _onNavigateToChannel(context, info.id);
      },
    );

    return LinkNavigateResult.success;
  }

  Future<LinkNavigateResult> _navigateToMessage(
    BuildContext context,
    String channelId,
    String messageId,
  ) async {
    if (!context.mounted) return LinkNavigateResult.failed;

    final success = await _onNavigateToMessage(
      context,
      channelId,
      messageId,
      highlightMessage: true,
    );

    return success ? LinkNavigateResult.success : LinkNavigateResult.notFound;
  }

  Future<LinkNavigateResult> _navigateToComment(
    BuildContext context,
    String channelId,
    String messageId,
    String commentId, {
    required LinkNavigateMode mode,
  }) async {
    final rootCommentId = await _resolver.resolveCommentRoot(commentId);
    if (rootCommentId == null) return LinkNavigateResult.notFound;

    if (!context.mounted) return LinkNavigateResult.failed;

    final success = await _onNavigateToComment(
      context,
      channelId,
      messageId,
      rootCommentId,
      commentId,
      mode: mode,
    );

    return success ? LinkNavigateResult.success : LinkNavigateResult.notFound;
  }

  Future<LinkNavigateResult> _navigateToAnchor(
    BuildContext context,
    String channelId,
    String messageId,
    String anchorId, {
    required LinkNavigateMode mode,
  }) async {
    if (!context.mounted) return LinkNavigateResult.failed;

    final success = await _onNavigateToComment(
      context,
      channelId,
      messageId,
      anchorId,
      anchorId,
      mode: mode,
    );

    return success ? LinkNavigateResult.success : LinkNavigateResult.notFound;
  }

  static bool _isValidId(String id) {
    if (id.isEmpty || id.length > 128) return false;
    final ok = RegExp(r'^[A-Za-z0-9_\-]+$').hasMatch(id);
    return ok;
  }

  static bool _isValidAnchorId(String id) {
    return id == 'header' || id == 'bottom';
  }
}
