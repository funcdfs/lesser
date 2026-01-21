import 'package:flutter/material.dart';

enum LinkNavigateResult {
  success,
  notInitialized,
  invalidLink,
  notFound,
  unsupported,
  failed,
}

enum LinkNavigateMode {
  push,
  replace,
}

typedef NavigateToChannelCallback =
    Future<bool> Function(BuildContext context, String channelId);

typedef NavigateToMessageCallback =
    Future<bool> Function(
      BuildContext context,
      String channelId,
      String messageId, {
      bool highlightMessage,
    });

typedef NavigateToCommentCallback =
    Future<bool> Function(
      BuildContext context,
      String channelId,
      String messageId,
      String rootCommentId,
      String targetCommentId, {
      LinkNavigateMode mode,
    });
