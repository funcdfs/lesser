// 频道评论模型

import '../../../pkg/comment/comment.dart' as pkg_comment;

// 重新导出公共类型
export '../../../pkg/comment/comment.dart' show CommentIconState, ReplyTarget;

// ============================================================================
// 媒体
// ============================================================================

/// 评论媒体类型
enum CommentMediaType {
  image,
  video,
  gif;

  bool get isAnimated => this == video || this == gif;
}

/// 评论媒体附件
class CommentMedia {
  const CommentMedia({
    required this.url,
    required this.type,
    this.width,
    this.height,
    this.thumbnailUrl,
    this.durationMs,
    this.blurhash,
  });

  final String url;
  final CommentMediaType type;
  final int? width;
  final int? height;
  final String? thumbnailUrl;
  final int? durationMs;
  final String? blurhash;

  double? get aspectRatio => (width != null && height != null && height! > 0)
      ? width! / height!
      : null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is CommentMedia && url == other.url);

  @override
  int get hashCode => url.hashCode;
}

// ============================================================================
// 作者
// ============================================================================

/// 评论作者
class CommentAuthor {
  const CommentAuthor({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    this.isVerified = false,
    this.isChannelOwner = false,
    this.isChannelAdmin = false,
  });

  final String id;
  final String username;
  final String displayName;
  final String avatarUrl;
  final bool isVerified;
  final bool isChannelOwner;
  final bool isChannelAdmin;

  static const deleted = CommentAuthor(
    id: '',
    username: 'deleted',
    displayName: '已注销用户',
    avatarUrl: '',
  );

  bool get isDeleted => id.isEmpty;
  bool get hasPrivilege => isChannelOwner || isChannelAdmin;

  String? get roleLabel {
    if (isChannelOwner) return '频道主';
    if (isChannelAdmin) return '管理员';
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is CommentAuthor && id == other.id);

  @override
  int get hashCode => id.hashCode;
}

// ============================================================================
// 评论
// ============================================================================

/// 频道评论
class ChannelCommentModel {
  const ChannelCommentModel({
    required this.id,
    required this.messageId,
    required this.channelId,
    required this.author,
    required this.content,
    this.media = const [],
    this.replyTo,
    this.replyCount = 0,
    this.likeCount = 0,
    this.isLiked = false,
    required this.createdAtMs,
    this.isDeleted = false,
    this.isPinned = false,
    this.isOwn = false,
    // 评论交互状态
    this.interactionState = pkg_comment.CommentIconState.normal,
    this.isViewed = false,
    this.hasMyReply = false,
    // UI 临时状态
    this.isHighlighted = false,
    this.isExpanded = false,
    this.isSubmitting = false,
  });

  final String id;
  final String messageId; // 所属消息 ID
  final String channelId;
  final CommentAuthor author;
  final String content;
  final List<CommentMedia> media;
  final pkg_comment.ReplyTarget? replyTo;
  final int replyCount;
  final int likeCount;
  final bool isLiked;
  final int createdAtMs;
  final bool isDeleted;
  final bool isPinned;
  final bool isOwn;
  // 评论交互状态
  final pkg_comment.CommentIconState interactionState;
  final bool isViewed;
  final bool hasMyReply;
  // UI 临时状态
  final bool isHighlighted;
  final bool isExpanded;
  final bool isSubmitting;

  // ---- 便捷 getter ----

  bool get hasReplies => replyCount > 0;
  bool get isReply => replyTo != null;
  bool get hasMedia => media.isNotEmpty;
  DateTime get createdAt => DateTime.fromMillisecondsSinceEpoch(createdAtMs);

  ChannelCommentModel copyWith({
    String? id,
    String? messageId,
    String? channelId,
    CommentAuthor? author,
    String? content,
    List<CommentMedia>? media,
    pkg_comment.ReplyTarget? replyTo,
    int? replyCount,
    int? likeCount,
    bool? isLiked,
    int? createdAtMs,
    bool? isDeleted,
    bool? isPinned,
    bool? isOwn,
    pkg_comment.CommentIconState? interactionState,
    bool? isViewed,
    bool? hasMyReply,
    bool? isHighlighted,
    bool? isExpanded,
    bool? isSubmitting,
  }) {
    return ChannelCommentModel(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      channelId: channelId ?? this.channelId,
      author: author ?? this.author,
      content: content ?? this.content,
      media: media ?? this.media,
      replyTo: replyTo ?? this.replyTo,
      replyCount: replyCount ?? this.replyCount,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      isDeleted: isDeleted ?? this.isDeleted,
      isPinned: isPinned ?? this.isPinned,
      isOwn: isOwn ?? this.isOwn,
      interactionState: interactionState ?? this.interactionState,
      isViewed: isViewed ?? this.isViewed,
      hasMyReply: hasMyReply ?? this.hasMyReply,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      isExpanded: isExpanded ?? this.isExpanded,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  // ---- 乐观更新快捷方法 ----

  /// 切换点赞状态
  ChannelCommentModel withLikeToggled() => copyWith(
    likeCount: isLiked ? likeCount - 1 : likeCount + 1,
    isLiked: !isLiked,
  );

  ChannelCommentModel withReplyAdded() => copyWith(replyCount: replyCount + 1);
  ChannelCommentModel withHighlight(bool value) =>
      copyWith(isHighlighted: value);
  ChannelCommentModel withSubmitting(bool value) =>
      copyWith(isSubmitting: value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChannelCommentModel && id == other.id);

  @override
  int get hashCode => id.hashCode;
}

// ============================================================================
// 上下文
// ============================================================================

/// 频道消息上下文（评论页头部展示用）
class ChannelMessageContext {
  const ChannelMessageContext({
    required this.messageId,
    required this.channelId,
    required this.channelName,
    required this.channelAvatarUrl,
    required this.contentPreview,
    required this.createdAtMs,
  });

  final String messageId;
  final String channelId;
  final String channelName;
  final String channelAvatarUrl;
  final String contentPreview;
  final int createdAtMs;

  DateTime get createdAt => DateTime.fromMillisecondsSinceEpoch(createdAtMs);
}

// ============================================================================
// 输入
// ============================================================================

/// 评论输入状态
class ChannelCommentInputState {
  const ChannelCommentInputState({
    this.text = '',
    this.attachments = const [],
    this.replyTo,
    this.isSubmitting = false,
    this.error,
  });

  final String text;
  final List<CommentMedia> attachments;
  final pkg_comment.ReplyTarget? replyTo;
  final bool isSubmitting;
  final String? error;

  bool get canSubmit => text.trim().isNotEmpty && !isSubmitting;
  bool get hasAttachments => attachments.isNotEmpty;
  bool get isReplying => replyTo != null;

  ChannelCommentInputState copyWith({
    String? text,
    List<CommentMedia>? attachments,
    pkg_comment.ReplyTarget? replyTo,
    bool? isSubmitting,
    String? error,
  }) {
    return ChannelCommentInputState(
      text: text ?? this.text,
      attachments: attachments ?? this.attachments,
      replyTo: replyTo ?? this.replyTo,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }

  ChannelCommentInputState clear() => const ChannelCommentInputState();
  ChannelCommentInputState withReplyTo(pkg_comment.ReplyTarget? target) =>
      copyWith(replyTo: target);
}

// ============================================================================
// 模型转换扩展
// ============================================================================

/// 频道评论模型转换扩展
///
/// 提供统一的转换方法，避免在多处重复实现
extension ChannelCommentModelExt on ChannelCommentModel {
  /// 转换为公共评论模型
  pkg_comment.CommentModel toCommentModel() {
    return pkg_comment.CommentModel(
      id: id,
      targetId: messageId,
      targetType: 'channel_message',
      author: pkg_comment.CommentAuthor(
        id: author.id,
        username: author.username,
        displayName: author.displayName,
        avatarUrl: author.avatarUrl,
        isVerified: author.isVerified,
        roleLabel: author.roleLabel,
      ),
      content: content,
      replyTo: replyTo != null
          ? pkg_comment.ReplyTarget(
              commentId: replyTo!.commentId,
              authorName: replyTo!.authorName,
              contentPreview: replyTo!.contentPreview,
              isDeleted: replyTo!.isDeleted,
            )
          : null,
      replyCount: replyCount,
      likeCount: likeCount,
      isLiked: isLiked,
      createdAtMs: createdAtMs,
      isDeleted: isDeleted,
      isPinned: isPinned,
      isOwn: isOwn,
      interactionState: interactionState,
    );
  }
}
