// 频道反应系统统一数据模型
//
// Post 和 Comment 共用同一套反应设计
//
// ┌─────────────────────────────────────────────────────────────┐
// │                    反应系统数据层级设计                       │
// ├─────────────────────────────────────────────────────────────┤
// │                                                             │
// │  1. ReactionStats（聚合统计，Post/Comment 共用）             │
// │     ├── counts: Map<emoji, count>  ← 支持任意表情           │
// │     └── totalCount: 总反应数                                │
// │                                                             │
// │  2. myReaction（当前用户状态）                               │
// │     └── 存在 Post/Comment Model 中，用于高亮显示            │
// │                                                             │
// │  3. ReactionSummary（UI 展示用）                            │
// │     └── emoji, count, isSelected                           │
// │                                                             │
// │  4. ReactionRecord（存储层，owner 查看详情用）               │
// │     ├── id, targetId, userId, emoji, createdAt             │
// │     └── user: ReactionUser（关联用户信息）                  │
// │                                                             │
// │  5. ReactionDetail（详情聚合，owner 专用）                   │
// │     └── reactionsByEmoji: Map<emoji, List<ReactionRecord>> │
// │                                                             │
// └─────────────────────────────────────────────────────────────┘

import 'package:flutter/foundation.dart' show mapEquals;

// ============================================================================
// 核心统计类（Post/Comment 共用）
// ============================================================================

/// 反应统计（聚合数据）
/// Post 和 Comment 共用同一个类
class ReactionStats {
  const ReactionStats({this.counts = const {}, this.totalCount = 0});

  /// 按 emoji 统计的数量 {"👍": 12, "❤️": 5}
  final Map<String, int> counts;

  /// 总反应数
  final int totalCount;

  static const empty = ReactionStats();

  bool get hasReactions => totalCount > 0;

  /// 获取排序后的 emoji 列表（按数量降序）
  List<String> get sortedEmojis {
    final entries = counts.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.map((e) => e.key).toList();
  }

  /// 转换为 UI 展示列表
  List<ReactionSummary> toSummaryList(String? myReaction) {
    return sortedEmojis.map((emoji) {
      return ReactionSummary(
        emoji: emoji,
        count: counts[emoji] ?? 0,
        isSelected: myReaction == emoji,
      );
    }).toList();
  }

  /// 乐观更新：添加反应
  ReactionStats withAdded(String emoji) {
    final newCounts = Map<String, int>.from(counts);
    newCounts[emoji] = (newCounts[emoji] ?? 0) + 1;
    return ReactionStats(counts: newCounts, totalCount: totalCount + 1);
  }

  /// 乐观更新：移除反应
  ReactionStats withRemoved(String emoji) {
    if (!counts.containsKey(emoji)) return this;
    final newCounts = Map<String, int>.from(counts);
    final count = (newCounts[emoji] ?? 1) - 1;
    if (count <= 0) {
      newCounts.remove(emoji);
    } else {
      newCounts[emoji] = count;
    }
    return ReactionStats(
      counts: newCounts,
      totalCount: (totalCount - 1).clamp(0, totalCount),
    );
  }

  /// 乐观更新：切换反应（移除旧的，添加新的）
  ReactionStats withToggled(String? oldEmoji, String newEmoji) {
    ReactionStats result = this;
    if (oldEmoji != null && oldEmoji != newEmoji) {
      result = result.withRemoved(oldEmoji);
    }
    return result.withAdded(newEmoji);
  }

  ReactionStats copyWith({Map<String, int>? counts, int? totalCount}) {
    return ReactionStats(
      counts: counts ?? this.counts,
      totalCount: totalCount ?? this.totalCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReactionStats &&
          totalCount == other.totalCount &&
          mapEquals(counts, other.counts));

  @override
  int get hashCode => Object.hash(totalCount, counts);
}

// ============================================================================
// UI 展示类
// ============================================================================

/// 反应摘要（UI 展示用）
class ReactionSummary {
  const ReactionSummary({
    required this.emoji,
    required this.count,
    this.isSelected = false,
  });

  final String emoji;
  final int count;
  final bool isSelected;

  /// 格式化数量（超过 999 显示 999+）
  String get formattedCount => count > 999 ? '999+' : count.toString();

  ReactionSummary copyWith({String? emoji, int? count, bool? isSelected}) {
    return ReactionSummary(
      emoji: emoji ?? this.emoji,
      count: count ?? this.count,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

// ============================================================================
// 详情类（owner 专用）
// ============================================================================

/// 反应用户信息
class ReactionUser {
  const ReactionUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
  });

  final String id;
  final String username;
  final String displayName;
  final String avatarUrl;
}

/// 单条反应记录
class ReactionRecord {
  const ReactionRecord({
    required this.id,
    required this.targetId,
    required this.userId,
    required this.emoji,
    required this.createdAtMs,
    this.user,
  });

  final String id;
  final String targetId;
  final String userId;
  final String emoji;
  final int createdAtMs;
  final ReactionUser? user;

  DateTime get createdAt => DateTime.fromMillisecondsSinceEpoch(createdAtMs);
}

/// 反应详情（按 emoji 分组，owner 查看用）
class ReactionDetail {
  const ReactionDetail({
    required this.targetId,
    this.reactionsByEmoji = const {},
    this.totalCount = 0,
  });

  final String targetId;
  final Map<String, List<ReactionRecord>> reactionsByEmoji;
  final int totalCount;

  /// 获取所有 emoji 列表（按数量降序）
  List<String> get sortedEmojis {
    final entries = reactionsByEmoji.entries.toList();
    entries.sort((a, b) => b.value.length.compareTo(a.value.length));
    return entries.map((e) => e.key).toList();
  }

  /// 获取指定 emoji 的反应记录
  List<ReactionRecord> getRecordsForEmoji(String emoji) {
    return reactionsByEmoji[emoji] ?? [];
  }

  /// 获取指定 emoji 的用户列表
  List<ReactionUser> getUsersForEmoji(String emoji) {
    return getRecordsForEmoji(
      emoji,
    ).where((r) => r.user != null).map((r) => r.user!).toList();
  }
}
