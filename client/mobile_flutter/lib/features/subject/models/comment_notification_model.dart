// =============================================================================
// 评论通知模型
// =============================================================================

/// 通知类型
enum CommentNotificationType {
  /// 点赞
  like,
  /// 回复
  reply,
}

/// 评论通知模型
class CommentNotificationModel {
  const CommentNotificationModel({
    required this.id,
    required this.type,
    required this.subjectId,
    required this.postId,
    required this.fromUserId,
    required this.fromUserName,
    this.fromUserAvatar,
    required this.contentPreview,
    required this.createdAt,
    this.isRead = false,
  });

  final String id;
  final CommentNotificationType type;
  final String subjectId;
  final String postId;
  final String fromUserId;
  final String fromUserName;
  final String? fromUserAvatar;
  final String contentPreview;
  final DateTime createdAt;
  final bool isRead;

  CommentNotificationModel copyWith({
    String? id,
    CommentNotificationType? type,
    String? subjectId,
    String? postId,
    String? fromUserId,
    String? fromUserName,
    String? fromUserAvatar,
    String? contentPreview,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return CommentNotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      subjectId: subjectId ?? this.subjectId,
      postId: postId ?? this.postId,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUserName: fromUserName ?? this.fromUserName,
      fromUserAvatar: fromUserAvatar ?? this.fromUserAvatar,
      contentPreview: contentPreview ?? this.contentPreview,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
