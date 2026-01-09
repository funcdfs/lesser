// 评论数据模型
//
// 独立的评论系统模型，可在任何场景复用

/// 评论交互状态（用于判断是否可以回复）
enum CommentIconState {
  /// 正常 - 可以评论
  normal,

  /// 被封禁 - 无法评论
  banned,
}

/// 评论作者
class CommentAuthor {
  const CommentAuthor({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.isVerified = false,
    this.roleLabel,
    this.isDeletedUser = false,
  });

  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final bool isVerified;
  final String? roleLabel;
  final bool isDeletedUser; // 显式标记是否为已注销用户

  /// 已注销用户的静态实例
  static const deleted = CommentAuthor(
    id: 'deleted',
    username: 'deleted',
    displayName: '已注销用户',
    isDeletedUser: true,
  );

  /// 判断是否为已注销用户
  bool get isDeleted => isDeletedUser;
}

/// 回复目标
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

/// 评论模型
class CommentModel {
  const CommentModel({
    required this.id,
    required this.targetId,
    required this.targetType,
    required this.author,
    required this.content,
    this.replyTo,
    this.replyCount = 0,
    this.likeCount = 0,
    this.isLiked = false,
    required this.createdAtMs,
    this.isDeleted = false,
    this.isPinned = false,
    this.isOwn = false,
    this.interactionState = CommentIconState.normal,
  });

  final String id;
  final String targetId; // 评论目标 ID（帖子、文章等）
  final String targetType; // 评论目标类型
  final CommentAuthor author;
  final String content;
  final ReplyTarget? replyTo;
  final int replyCount;
  final int likeCount;
  final bool isLiked;
  final int createdAtMs;
  final bool isDeleted;
  final bool isPinned;
  final bool isOwn;
  final CommentIconState interactionState;

  bool get hasReplies => replyCount > 0;
  bool get isReply => replyTo != null;
  DateTime get createdAt => DateTime.fromMillisecondsSinceEpoch(createdAtMs);

  CommentModel copyWith({
    String? id,
    String? targetId,
    String? targetType,
    CommentAuthor? author,
    String? content,
    ReplyTarget? replyTo,
    int? replyCount,
    int? likeCount,
    bool? isLiked,
    int? createdAtMs,
    bool? isDeleted,
    bool? isPinned,
    bool? isOwn,
    CommentIconState? interactionState,
  }) {
    return CommentModel(
      id: id ?? this.id,
      targetId: targetId ?? this.targetId,
      targetType: targetType ?? this.targetType,
      author: author ?? this.author,
      content: content ?? this.content,
      replyTo: replyTo ?? this.replyTo,
      replyCount: replyCount ?? this.replyCount,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      isDeleted: isDeleted ?? this.isDeleted,
      isPinned: isPinned ?? this.isPinned,
      isOwn: isOwn ?? this.isOwn,
      interactionState: interactionState ?? this.interactionState,
    );
  }

  /// 切换点赞
  CommentModel withLikeToggled() => copyWith(
    likeCount: isLiked ? likeCount - 1 : likeCount + 1,
    isLiked: !isLiked,
  );

  /// 增加回复数
  CommentModel withReplyAdded() => copyWith(replyCount: replyCount + 1);
}

/// 评论列表状态
class CommentListState {
  const CommentListState({
    this.comments = const [],
    this.pinnedComment,
    this.rootComment,
    this.totalCount = 0,
    this.hasMore = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.cursor,
    this.error,
  });

  final List<CommentModel> comments;
  final CommentModel? pinnedComment;
  final CommentModel? rootComment;
  final int totalCount;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? cursor; // 分页游标
  final String? error;

  bool get isEmpty =>
      comments.isEmpty &&
      pinnedComment == null &&
      rootComment == null &&
      !isLoading;
  bool get isThreadView => rootComment != null;

  /// 用于 copyWith 中显式设置 null 的哨兵值
  static const _sentinel = Object();

  CommentListState copyWith({
    List<CommentModel>? comments,
    Object? pinnedComment = _sentinel,
    Object? rootComment = _sentinel,
    int? totalCount,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    String? cursor,
    String? error,
  }) {
    return CommentListState(
      comments: comments ?? this.comments,
      pinnedComment: pinnedComment == _sentinel
          ? this.pinnedComment
          : pinnedComment as CommentModel?,
      rootComment: rootComment == _sentinel
          ? this.rootComment
          : rootComment as CommentModel?,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      cursor: cursor ?? this.cursor,
      error: error,
    );
  }
}

/// 评论输入状态
class CommentInputState {
  const CommentInputState({
    this.text = '',
    this.replyTo,
    this.isSubmitting = false,
    this.error,
  });

  final String text;
  final ReplyTarget? replyTo;
  final bool isSubmitting;
  final String? error;

  bool get canSubmit => text.trim().isNotEmpty && !isSubmitting;
  bool get isReplying => replyTo != null;

  CommentInputState copyWith({
    String? text,
    ReplyTarget? replyTo,
    bool? isSubmitting,
    String? error,
  }) {
    return CommentInputState(
      text: text ?? this.text,
      replyTo: replyTo ?? this.replyTo,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }

  /// 清除回复目标
  CommentInputState clearReplyTo() =>
      CommentInputState(text: text, isSubmitting: isSubmitting, error: error);

  CommentInputState clear() => const CommentInputState();
}
