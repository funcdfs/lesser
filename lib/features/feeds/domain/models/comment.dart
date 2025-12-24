/// Comment 业务模型
///
/// 定义：评论的业务结构和字段
class Comment {
  /// 评论 ID
  final String id;

  /// 发布者信息
  final CommentAuthor author;

  /// 评论内容
  final String content;

  /// 发布时间
  final DateTime createdAt;

  /// 点赞数
  final int likeCount;

  /// 是否被当前用户点赞
  final bool isLikedByCurrentUser;

  /// 回复数量
  final int replyCount;

  /// 子回复列表（可选，用于嵌套显示）
  final List<Comment>? replies;

  /// 是否是作者本人评论
  final bool isFromAuthor;

  Comment({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
    this.likeCount = 0,
    this.isLikedByCurrentUser = false,
    this.replyCount = 0,
    this.replies,
    this.isFromAuthor = false,
  });

  /// 创建副本，用于状态更新
  Comment copyWith({
    String? id,
    CommentAuthor? author,
    String? content,
    DateTime? createdAt,
    int? likeCount,
    bool? isLikedByCurrentUser,
    int? replyCount,
    List<Comment>? replies,
    bool? isFromAuthor,
  }) {
    return Comment(
      id: id ?? this.id,
      author: author ?? this.author,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likeCount: likeCount ?? this.likeCount,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      replyCount: replyCount ?? this.replyCount,
      replies: replies ?? this.replies,
      isFromAuthor: isFromAuthor ?? this.isFromAuthor,
    );
  }
}

/// Comment 发布者信息
class CommentAuthor {
  /// 用户 ID
  final String userId;

  /// 用户名
  final String username;

  /// 用户头像 URL
  final String avatarUrl;

  /// 是否是认证用户
  final bool isVerified;

  CommentAuthor({
    required this.userId,
    required this.username,
    required this.avatarUrl,
    required this.isVerified,
  });
}
