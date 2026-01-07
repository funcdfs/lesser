// 频道帖子/消息数据模型
//
// ┌─────────────────────────────────────────────────────────────┐
// │                    反应系统数据层级设计                       │
// ├─────────────────────────────────────────────────────────────┤
// │                                                             │
// │  1. PostReactionStats（聚合统计）                            │
// │     ├── postId: 帖子 ID                                     │
// │     ├── counts: Map<emoji, count>  ← 支持任意表情           │
// │     └── totalCount: 总反应数                                │
// │                                                             │
// │  2. ChannelPostModel.myReaction（当前用户状态）              │
// │     └── 当前用户点的表情（用于高亮显示）                      │
// │                                                             │
// │  3. ReactionRecord（存储层，owner 查看详情用）               │
// │     ├── id, postId, userId, emoji, createdAt               │
// │     └── user: ReactionUser（关联用户信息）                  │
// │                                                             │
// │  4. PostReactionDetail（详情聚合，owner 专用）               │
// │     └── reactionsByEmoji: Map<emoji, List<ReactionRecord>> │
// │                                                             │
// └─────────────────────────────────────────────────────────────┘

/// 频道帖子/消息
class ChannelPostModel {
  const ChannelPostModel({
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
    this.reactionStats,
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

  /// 反应统计（聚合数据，用于 UI 展示）
  final PostReactionStats? reactionStats;

  /// 当前用户的反应（如果有）
  final String? myReaction;

  // UI 扩展字段
  final int commentCount;
  final String? linkUrl;
  final String? linkTitle;
  final List<String> commentAvatars;

  ChannelPostModel copyWith({
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
    PostReactionStats? reactionStats,
    String? myReaction,
    int? commentCount,
    String? linkUrl,
    String? linkTitle,
    List<String>? commentAvatars,
  }) {
    return ChannelPostModel(
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
      myReaction: myReaction ?? this.myReaction,
      commentCount: commentCount ?? this.commentCount,
      linkUrl: linkUrl ?? this.linkUrl,
      linkTitle: linkTitle ?? this.linkTitle,
      commentAvatars: commentAvatars ?? this.commentAvatars,
    );
  }

  String get formattedViewCount {
    if (viewCount >= 10000) {
      return '${(viewCount / 10000).toStringAsFixed(1)}万';
    }
    return viewCount.toString();
  }

  /// 获取用于 UI 展示的反应列表
  List<ReactionSummary> get reactions {
    return reactionStats?.toSummaryList(myReaction) ?? [];
  }
}

// ============================================================================
// 反应系统数据结构
// ============================================================================

/// 帖子反应统计（聚合数据）
/// 存储格式：Map<emoji, count>，支持任意表情
class PostReactionStats {
  const PostReactionStats({
    required this.postId,
    this.counts = const {},
    this.totalCount = 0,
  });

  final String postId;
  final Map<String, int> counts;
  final int totalCount;

  List<String> get sortedEmojis {
    final entries = counts.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.map((e) => e.key).toList();
  }

  List<ReactionSummary> toSummaryList(String? myReaction) {
    return sortedEmojis.map((emoji) {
      return ReactionSummary(
        emoji: emoji,
        count: counts[emoji] ?? 0,
        isSelected: myReaction == emoji,
      );
    }).toList();
  }

  PostReactionStats copyWith({
    String? postId,
    Map<String, int>? counts,
    int? totalCount,
  }) {
    return PostReactionStats(
      postId: postId ?? this.postId,
      counts: counts ?? this.counts,
      totalCount: totalCount ?? this.totalCount,
    );
  }

  PostReactionStats addReaction(String emoji) {
    final newCounts = Map<String, int>.from(counts);
    newCounts[emoji] = (newCounts[emoji] ?? 0) + 1;
    return PostReactionStats(
      postId: postId,
      counts: newCounts,
      totalCount: totalCount + 1,
    );
  }

  PostReactionStats removeReaction(String emoji) {
    final newCounts = Map<String, int>.from(counts);
    final current = newCounts[emoji] ?? 0;
    if (current <= 1) {
      newCounts.remove(emoji);
    } else {
      newCounts[emoji] = current - 1;
    }
    return PostReactionStats(
      postId: postId,
      counts: newCounts,
      totalCount: totalCount > 0 ? totalCount - 1 : 0,
    );
  }
}

/// 反应汇总（用于 UI 展示单个表情）
class ReactionSummary {
  const ReactionSummary({
    required this.emoji,
    required this.count,
    this.isSelected = false,
  });

  final String emoji;
  final int count;
  final bool isSelected;

  String get formattedCount => count > 999 ? '999+' : count.toString();

  ReactionSummary copyWith({String? emoji, int? count, bool? isSelected}) {
    return ReactionSummary(
      emoji: emoji ?? this.emoji,
      count: count ?? this.count,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

/// 单条反应记录（存储层，用于 owner 查看详情）
class ReactionRecord {
  const ReactionRecord({
    required this.id,
    required this.postId,
    required this.userId,
    required this.emoji,
    required this.createdAt,
    this.user,
  });

  final String id;
  final String postId;
  final String userId;
  final String emoji;
  final DateTime createdAt;
  final ReactionUser? user;

  ReactionRecord copyWith({
    String? id,
    String? postId,
    String? userId,
    String? emoji,
    DateTime? createdAt,
    ReactionUser? user,
  }) {
    return ReactionRecord(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt ?? this.createdAt,
      user: user ?? this.user,
    );
  }
}

/// 反应用户简要信息
class ReactionUser {
  const ReactionUser({
    required this.userId,
    required this.username,
    this.avatarUrl,
  });

  final String userId;
  final String username;
  final String? avatarUrl;
}

/// 帖子反应详情（owner 查看用）
class PostReactionDetail {
  const PostReactionDetail({
    required this.postId,
    required this.totalCount,
    this.reactionsByEmoji = const {},
  });

  final String postId;
  final int totalCount;
  final Map<String, List<ReactionRecord>> reactionsByEmoji;

  List<String> get sortedEmojis {
    final entries = reactionsByEmoji.entries.toList();
    entries.sort((a, b) => b.value.length.compareTo(a.value.length));
    return entries.map((e) => e.key).toList();
  }

  List<ReactionRecord> getRecordsForEmoji(String emoji) {
    return reactionsByEmoji[emoji] ?? [];
  }

  List<ReactionUser> getUsersForEmoji(String emoji) {
    return getRecordsForEmoji(
      emoji,
    ).where((r) => r.user != null).map((r) => r.user!).toList();
  }
}
