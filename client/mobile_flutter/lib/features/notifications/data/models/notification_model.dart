import '../../../auth/data/models/user_model.dart';
import '../../domain/entities/notification.dart';
import '../../../../generated/protos/notification/notification.pb.dart' as notification_pb;

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

  /// Create from Proto message
  /// Note: Proto only provides actor_id, so we create a placeholder user.
  /// The full user details should be fetched separately if needed.
  factory NotificationModel.fromProto(notification_pb.Notification proto) {
    return NotificationModel(
      id: proto.id,
      type: _parseProtoNotificationType(proto.type),
      // Proto only has actor_id, create placeholder user
      actor: UserModel(
        id: proto.actorId,
        username: '',
        email: '',
      ),
      createdAt: proto.hasCreatedAt()
          ? DateTime.fromMillisecondsSinceEpoch(
              proto.createdAt.seconds.toInt() * 1000,
            )
          : DateTime.now(),
      postId: proto.targetType == 'post' ? proto.targetId : null,
      commentId: proto.targetType == 'comment' ? proto.targetId : null,
      message: proto.hasMessage() ? proto.message : null,
      isRead: proto.isRead,
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

  static NotificationType _parseProtoNotificationType(
      notification_pb.NotificationType type) {
    switch (type) {
      case notification_pb.NotificationType.LIKE:
        return NotificationType.like;
      case notification_pb.NotificationType.COMMENT:
        return NotificationType.comment;
      case notification_pb.NotificationType.REPLY:
        return NotificationType.reply;
      case notification_pb.NotificationType.REPOST:
        return NotificationType.repost;
      case notification_pb.NotificationType.FOLLOW:
        return NotificationType.follow;
      case notification_pb.NotificationType.MENTION:
        return NotificationType.mention;
      case notification_pb.NotificationType.BOOKMARK:
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
