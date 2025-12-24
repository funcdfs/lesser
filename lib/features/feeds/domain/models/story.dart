/// Story 业务模型
///
/// 定义：Story 的业务结构和字段（日常限时状态）
/// ❌ 不包含 UI / JSON / API 字段
class Story {
  /// Story ID
  final String id;

  /// Story 发布者信息
  final StoryAuthor author;

  /// Story 内容（文字或图片 URL）
  final String content;

  /// Story 发布时间
  final DateTime createdAt;

  /// Story 过期时间（通常 24 小时后过期）
  final DateTime expiresAt;

  /// 浏览数
  final int viewCount;

  /// 是否被当前用户浏览过
  final bool isViewedByCurrentUser;

  /// Story 类型
  final StoryType type;

  Story({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
    required this.expiresAt,
    required this.viewCount,
    required this.isViewedByCurrentUser,
    required this.type,
  });

  /// 判断 Story 是否已过期
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// 创建副本
  Story copyWith({
    String? id,
    StoryAuthor? author,
    String? content,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? viewCount,
    bool? isViewedByCurrentUser,
    StoryType? type,
  }) {
    return Story(
      id: id ?? this.id,
      author: author ?? this.author,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      viewCount: viewCount ?? this.viewCount,
      isViewedByCurrentUser:
          isViewedByCurrentUser ?? this.isViewedByCurrentUser,
      type: type ?? this.type,
    );
  }
}

/// Story 类型
enum StoryType {
  /// 图片
  image,

  /// 视频
  video,

  /// 文字
  text,
}

/// Story 发布者信息
class StoryAuthor {
  /// 用户 ID
  final String userId;

  /// 用户名
  final String username;

  /// 用户头像 URL
  final String avatarUrl;

  /// 是否是好友
  final bool isFriend;

  StoryAuthor({
    required this.userId,
    required this.username,
    required this.avatarUrl,
    required this.isFriend,
  });
}
