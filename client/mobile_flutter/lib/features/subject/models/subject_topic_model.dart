// =============================================================================
// 剧集话题模型
// =============================================================================
//
// Discord 风格视图中的话题（Topic）数据模型
// 每个话题包含多个动态（Post）

/// 剧集话题模型
class SubjectTopicModel {
  const SubjectTopicModel({
    required this.id,
    required this.title,
    required this.description,
    required this.postCount,
    required this.lastPostTime,
    this.isPinned = false,
    this.isLocked = false,
  });

  /// 话题 ID
  final String id;

  /// 话题标题
  final String title;

  /// 话题描述
  final String description;

  /// 动态数量
  final int postCount;

  /// 最后动态时间
  final DateTime lastPostTime;

  /// 是否置顶
  final bool isPinned;

  /// 是否锁定（不允许新动态）
  final bool isLocked;

  /// 复制并修改
  SubjectTopicModel copyWith({
    String? id,
    String? title,
    String? description,
    int? postCount,
    DateTime? lastPostTime,
    bool? isPinned,
    bool? isLocked,
  }) {
    return SubjectTopicModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      postCount: postCount ?? this.postCount,
      lastPostTime: lastPostTime ?? this.lastPostTime,
      isPinned: isPinned ?? this.isPinned,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}
