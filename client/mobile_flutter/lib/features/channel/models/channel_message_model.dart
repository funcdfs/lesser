// 频道消息数据模型

import 'reaction_model.dart';

/// 频道消息
class ChannelMessageModel {
  const ChannelMessageModel({
    required this.id,
    required this.channelId,
    required this.authorId,
    required this.content,
    this.mediaUrls = const [],
    this.viewCount = 0,
    required this.createdAt,
    this.updatedAt,
    this.isPinned = false,
    this.isEdited = false,
    this.authorName,
    this.reactionStats = ReactionStats.empty,
    this.myReaction,
    this.commentCount = 0,
    this.linkUrl,
    this.linkTitle,
    this.commentAvatars = const [],
  });

  final String id;
  final String channelId;
  final String authorId;
  final String content;
  final List<String> mediaUrls;
  final int viewCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPinned;
  final bool isEdited;
  final String? authorName;

  /// 反应统计（使用统一的 ReactionStats）
  final ReactionStats reactionStats;

  /// 当前用户的反应（如果有）
  final String? myReaction;

  // UI 扩展字段
  final int commentCount;
  final String? linkUrl;
  final String? linkTitle;
  final List<String> commentAvatars;

  /// 是否有反应
  bool get hasReactions => reactionStats.hasReactions;

  /// 是否已反应
  bool get hasReacted => myReaction != null;

  /// 获取用于 UI 展示的反应列表
  List<ReactionSummary> get reactions =>
      reactionStats.toSummaryList(myReaction);

  String get formattedViewCount {
    if (viewCount >= 10000) {
      return '${(viewCount / 10000).toStringAsFixed(1)}万';
    }
    return viewCount.toString();
  }

  ChannelMessageModel copyWith({
    String? id,
    String? channelId,
    String? authorId,
    String? content,
    List<String>? mediaUrls,
    int? viewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    bool? isEdited,
    String? authorName,
    ReactionStats? reactionStats,
    String? myReaction,
    int? commentCount,
    String? linkUrl,
    String? linkTitle,
    List<String>? commentAvatars,
  }) {
    return ChannelMessageModel(
      id: id ?? this.id,
      channelId: channelId ?? this.channelId,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      isEdited: isEdited ?? this.isEdited,
      authorName: authorName ?? this.authorName,
      reactionStats: reactionStats ?? this.reactionStats,
      myReaction: myReaction,
      commentCount: commentCount ?? this.commentCount,
      linkUrl: linkUrl ?? this.linkUrl,
      linkTitle: linkTitle ?? this.linkTitle,
      commentAvatars: commentAvatars ?? this.commentAvatars,
    );
  }

  // ---- 乐观更新快捷方法 ----

  /// 添加反应
  ChannelMessageModel withReactionAdded(String emoji) => copyWith(
    reactionStats: reactionStats.withAdded(emoji),
    myReaction: emoji,
  );

  /// 移除反应
  ChannelMessageModel withReactionRemoved() {
    if (myReaction == null) return this;
    return copyWith(
      reactionStats: reactionStats.withRemoved(myReaction!),
      myReaction: null,
    );
  }

  /// 切换反应
  ChannelMessageModel withReactionToggled(String emoji) {
    if (myReaction == emoji) {
      return withReactionRemoved();
    }
    return copyWith(
      reactionStats: reactionStats.withToggled(myReaction, emoji),
      myReaction: emoji,
    );
  }

  /// 评论数 +1
  ChannelMessageModel withCommentAdded() =>
      copyWith(commentCount: commentCount + 1);
}
