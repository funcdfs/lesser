// 频道评论数据模型
//
// 与 Post 共用 ReactionStats（来自 reaction_model.dart）

import 'reaction_model.dart';

// ============================================================================
// 媒体类型
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
// 作者信息
// ============================================================================

/// 评论作者（包含频道角色）
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
// 回复关系
// ============================================================================

/// 被回复评论的摘要（严格一层，不递归）
class ReplyTarget {
  const ReplyTarget({
    required this.commentId,
    required this.authorName,
    required this.contentPreview,
    this.isDeleted = false,
  });

  final String commentId;
  final String authorName;
  final String contentPreview;
  final bool isDeleted;
}

// ============================================================================
// 核心模型
// ============================================================================

/// 频道评论
class ChannelCommentModel {
  const ChannelCommentModel({
    required this.id,
    required this.postId,
    required this.channelId,
    required this.author,
    required this.content,
    this.media = const [],
    this.replyTo,
    this.replyCount = 0,
    this.reactionStats = ReactionStats.empty,
    this.myReaction,
    required this.createdAtMs,
    this.isDeleted = false,
    this.isPinned = false,
    this.isOwn = false,
    // UI 临时状态
    this.isHighlighted = false,
    this.isExpanded = false,
    this.isSubmitting = false,
  });

  final String id;
  final String postId;
  final String channelId;
  final CommentAuthor author;
  final String content;
  final List<CommentMedia> media;
  final ReplyTarget? replyTo;
  final int replyCount;
  final ReactionStats reactionStats;
  final String? myReaction;
  final int createdAtMs;
  final bool isDeleted;
  final bool isPinned;
  final bool isOwn;
  final bool isHighlighted;
  final bool isExpanded;
  final bool isSubmitting;

  // ---- 便捷 getter ----

  bool get hasReplies => replyCount > 0;
  bool get isReply => replyTo != null;
  bool get hasMedia => media.isNotEmpty;
  bool get hasReacted => myReaction != null;
  bool get hasReactions => reactionStats.hasReactions;
  DateTime get createdAt => DateTime.fromMillisecondsSinceEpoch(createdAtMs);

  /// 获取用于 UI 展示的反应列表
  List<ReactionSummary> get reactions =>
      reactionStats.toSummaryList(myReaction);

  ChannelCommentModel copyWith({
    String? id,
    String? postId,
    String? channelId,
    CommentAuthor? author,
    String? content,
    List<CommentMedia>? media,
    ReplyTarget? replyTo,
    int? replyCount,
    ReactionStats? reactionStats,
    String? myReaction,
    int? createdAtMs,
    bool? isDeleted,
    bool? isPinned,
    bool? isOwn,
    bool? isHighlighted,
    bool? isExpanded,
    bool? isSubmitting,
  }) {
    return ChannelCommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      channelId: channelId ?? this.channelId,
      author: author ?? this.author,
      content: content ?? this.content,
      media: media ?? this.media,
      replyTo: replyTo ?? this.replyTo,
      replyCount: replyCount ?? this.replyCount,
      reactionStats: reactionStats ?? this.reactionStats,
      myReaction: myReaction,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      isDeleted: isDeleted ?? this.isDeleted,
      isPinned: isPinned ?? this.isPinned,
      isOwn: isOwn ?? this.isOwn,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      isExpanded: isExpanded ?? this.isExpanded,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  // ---- 乐观更新快捷方法 ----

  ChannelCommentModel withReactionAdded(String emoji) => copyWith(
    reactionStats: reactionStats.withAdded(emoji),
    myReaction: emoji,
  );

  ChannelCommentModel withReactionRemoved() {
    if (myReaction == null) return this;
    return copyWith(
      reactionStats: reactionStats.withRemoved(myReaction!),
      myReaction: null,
    );
  }

  ChannelCommentModel withReactionToggled(String emoji) {
    if (myReaction == emoji) {
      return withReactionRemoved();
    }
    return copyWith(
      reactionStats: reactionStats.withToggled(myReaction, emoji),
      myReaction: emoji,
    );
  }

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
// 页面状态
// ============================================================================

/// 频道消息上下文（评论列表页头部）
class CommentPostContext {
  const CommentPostContext({
    required this.postId,
    required this.channelId,
    required this.channelName,
    required this.channelAvatarUrl,
    required this.contentPreview,
    required this.createdAtMs,
  });

  final String postId;
  final String channelId;
  final String channelName;
  final String channelAvatarUrl;
  final String contentPreview;
  final int createdAtMs;

  DateTime get createdAt => DateTime.fromMillisecondsSinceEpoch(createdAtMs);
}

/// 面包屑导航项
class CommentBreadcrumb {
  const CommentBreadcrumb({
    required this.commentId,
    required this.authorName,
    required this.contentPreview,
  });

  final String commentId;
  final String authorName;
  final String contentPreview;
}

/// 加载状态
enum CommentLoadState {
  idle,
  loading,
  loadingMore,
  error;

  bool get isLoading => this == loading;
  bool get isLoadingMore => this == loadingMore;
  bool get hasError => this == error;
}

/// 评论列表页状态
class CommentListState {
  const CommentListState({
    this.comments = const [],
    this.pinnedComment,
    this.rootComment,
    this.nextCursor,
    this.hasMore = false,
    this.totalCount = 0,
    this.loadState = CommentLoadState.idle,
    this.errorMessage,
    this.postContext,
    this.breadcrumbs = const [],
  });

  final List<ChannelCommentModel> comments;
  final ChannelCommentModel? pinnedComment;
  final ChannelCommentModel? rootComment;
  final String? nextCursor;
  final bool hasMore;
  final int totalCount;
  final CommentLoadState loadState;
  final String? errorMessage;
  final CommentPostContext? postContext;
  final List<CommentBreadcrumb> breadcrumbs;

  bool get isTopLevel => rootComment == null;
  bool get isEmpty => comments.isEmpty && !loadState.isLoading;

  CommentListState copyWith({
    List<ChannelCommentModel>? comments,
    ChannelCommentModel? pinnedComment,
    ChannelCommentModel? rootComment,
    String? nextCursor,
    bool? hasMore,
    int? totalCount,
    CommentLoadState? loadState,
    String? errorMessage,
    CommentPostContext? postContext,
    List<CommentBreadcrumb>? breadcrumbs,
  }) {
    return CommentListState(
      comments: comments ?? this.comments,
      pinnedComment: pinnedComment ?? this.pinnedComment,
      rootComment: rootComment ?? this.rootComment,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      totalCount: totalCount ?? this.totalCount,
      loadState: loadState ?? this.loadState,
      errorMessage: errorMessage,
      postContext: postContext ?? this.postContext,
      breadcrumbs: breadcrumbs ?? this.breadcrumbs,
    );
  }

  CommentListState updateComment(
    String id,
    ChannelCommentModel Function(ChannelCommentModel) updater,
  ) {
    final index = comments.indexWhere((c) => c.id == id);
    if (index == -1) return this;
    final newComments = List<ChannelCommentModel>.from(comments);
    newComments[index] = updater(newComments[index]);
    return copyWith(comments: newComments);
  }

  CommentListState prependComment(ChannelCommentModel comment) {
    return copyWith(
      comments: [comment, ...comments],
      totalCount: totalCount + 1,
    );
  }

  CommentListState softDeleteComment(String id) {
    return updateComment(
      id,
      (c) => c.copyWith(isDeleted: true, content: '该评论已删除'),
    );
  }
}

// ============================================================================
// 输入状态
// ============================================================================

/// 评论输入状态
class CommentInputState {
  const CommentInputState({
    this.text = '',
    this.attachments = const [],
    this.replyTo,
    this.isSubmitting = false,
    this.error,
  });

  final String text;
  final List<CommentMedia> attachments;
  final ReplyTarget? replyTo;
  final bool isSubmitting;
  final String? error;

  bool get canSubmit => text.trim().isNotEmpty && !isSubmitting;
  bool get hasAttachments => attachments.isNotEmpty;
  bool get isReplying => replyTo != null;

  CommentInputState copyWith({
    String? text,
    List<CommentMedia>? attachments,
    ReplyTarget? replyTo,
    bool? isSubmitting,
    String? error,
  }) {
    return CommentInputState(
      text: text ?? this.text,
      attachments: attachments ?? this.attachments,
      replyTo: replyTo ?? this.replyTo,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }

  CommentInputState clear() => const CommentInputState();
  CommentInputState withReplyTo(ReplyTarget? target) =>
      copyWith(replyTo: target);
}
