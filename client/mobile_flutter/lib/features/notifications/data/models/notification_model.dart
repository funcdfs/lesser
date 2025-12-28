import '../../../auth/data/models/user_model.dart';
import '../../domain/entities/notification.dart';

/// Notification data model
class NotificationModel extends AppNotification {
  const NotificationModel({
    required super.id,
    required super.type,
    required super.actor,
    required super.createdAt,
    super.postId,
    super.commentId,
    super.message,
    super.isRead,
  });

  /// Create from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      type: _parseNotificationType(json['type'] as String),
      actor: UserModel.fromJson(json['actor'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      postId: json['post_id'] as String?,
      commentId: json['comment_id'] as String?,
      message: json['message'] as String?,
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': _notificationTypeToString(type),
      'actor': (actor as UserModel).toJson(),
      'created_at': createdAt.toIso8601String(),
      'post_id': postId,
      'comment_id': commentId,
      'message': message,
      'is_read': isRead,
    };
  }

  static NotificationType _parseNotificationType(String type) {
    switch (type) {
      case 'like':
        return NotificationType.like;
      case 'comment':
        return NotificationType.comment;
      case 'reply':
        return NotificationType.reply;
      case 'repost':
        return NotificationType.repost;
      case 'follow':
        return NotificationType.follow;
      case 'mention':
        return NotificationType.mention;
      case 'bookmark':
        return NotificationType.bookmark;
      default:
        return NotificationType.like;
    }
  }

  static String _notificationTypeToString(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return 'like';
      case NotificationType.comment:
        return 'comment';
      case NotificationType.reply:
        return 'reply';
      case NotificationType.repost:
        return 'repost';
      case NotificationType.follow:
        return 'follow';
      case NotificationType.mention:
        return 'mention';
      case NotificationType.bookmark:
        return 'bookmark';
    }
  }
}
