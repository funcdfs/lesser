/// Post 业务模型
///
/// 定义：Post 的业务结构和字段
/// ❌ 不包含 UI / JSON / API 字段（那些应该在 data 层处理）
class Post {
  /// Post ID
  final String id;

  /// 发布者信息
  final PostAuthor author;

  /// Post 内容
  final String content;

  /// Post 图片列表
  final List<String> images;

  /// 发布时间
  final DateTime createdAt;

  /// 点赞数
  final int likeCount;

  /// 评论数
  final int commentCount;

  /// 分享数
  final int shareCount;

  /// 是否被当前用户点赞
  final bool isLikedByCurrentUser;

  /// 是否被当前用户收藏
  final bool isSavedByCurrentUser;

  /// 转发数
  final int repostCount;

  /// 阅读数/展现数
  final int viewsCount;

  /// 标签/主题
  final List<String> tags;

  /// 位置信息（可选）
  final String? location;

  /// 是否是转发动态
  final bool isRepost;

  /// 原始动态 ID（如果是转发的话）
  final String? originPostId;

  /// 是否已编辑
  final bool isEdited;

  /// 是否包含敏感内容
  final bool isSensitive;

  /// 是否置顶
  final bool isPinned;

  Post({
    required this.id,
    required this.author,
    required this.content,
    required this.images,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.isLikedByCurrentUser,
    required this.isSavedByCurrentUser,
    this.repostCount = 0,
    this.viewsCount = 0,
    this.tags = const [],
    this.location,
    this.isRepost = false,
    this.originPostId,
    this.isEdited = false,
    this.isSensitive = false,
    this.isPinned = false,
  });

  /// 创建副本，用于状态更新
  Post copyWith({
    String? id,
    PostAuthor? author,
    String? content,
    List<String>? images,
    DateTime? createdAt,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    bool? isLikedByCurrentUser,
    bool? isSavedByCurrentUser,
    int? repostCount,
    int? viewsCount,
    List<String>? tags,
    String? location,
    bool? isRepost,
    String? originPostId,
    bool? isEdited,
    bool? isSensitive,
    bool? isPinned,
  }) {
    return Post(
      id: id ?? this.id,
      author: author ?? this.author,
      content: content ?? this.content,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      isSavedByCurrentUser: isSavedByCurrentUser ?? this.isSavedByCurrentUser,
      repostCount: repostCount ?? this.repostCount,
      viewsCount: viewsCount ?? this.viewsCount,
      tags: tags ?? this.tags,
      location: location ?? this.location,
      isRepost: isRepost ?? this.isRepost,
      originPostId: originPostId ?? this.originPostId,
      isEdited: isEdited ?? this.isEdited,
      isSensitive: isSensitive ?? this.isSensitive,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}

/// Post 发布者信息
class PostAuthor {
  /// 用户 ID
  final String userId;

  /// 用户名
  final String username;

  /// 用户头像 URL
  final String avatarUrl;

  /// 是否是认证用户
  final bool isVerified;

  PostAuthor({
    required this.userId,
    required this.username,
    required this.avatarUrl,
    required this.isVerified,
  });
}
