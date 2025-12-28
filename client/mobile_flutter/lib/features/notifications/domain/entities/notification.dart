import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user.dart';

/// Notification type enum
enum NotificationType {
  like,
  comment,
  reply,
  repost,
  follow,
  mention,
  bookmark,
}

/// Notification entity
class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.type,
    required this.actor,
    required this.createdAt,
    this.postId,
    this.commentId,
    this.message,
    this.isRead = false,
  });

  final String id;
  final NotificationType type;
  final User actor;
  final DateTime createdAt;
  final String? postId;
  final String? commentId;
  final String? message;
  final bool isRead;

  @override
  List<Object?> get props => [
        id,
        type,
        actor,
        createdAt,
        postId,
        commentId,
        message,
        isRead,
      ];
}
