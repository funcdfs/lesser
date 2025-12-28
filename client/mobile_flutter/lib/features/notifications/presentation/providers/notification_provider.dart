import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';

/// Notification state
enum NotificationStatus { initial, loading, loaded, error }

class NotificationState {
  const NotificationState({
    this.status = NotificationStatus.initial,
    this.notifications = const [],
    this.unreadCount = 0,
    this.errorMessage,
  });

  final NotificationStatus status;
  final List<AppNotification> notifications;
  final int unreadCount;
  final String? errorMessage;

  NotificationState copyWith({
    NotificationStatus? status,
    List<AppNotification>? notifications,
    int? unreadCount,
    String? errorMessage,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      errorMessage: errorMessage,
    );
  }
}

/// Notification notifier
class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier({
    required NotificationRepository repository,
  })  : _repository = repository,
        super(const NotificationState());

  final NotificationRepository _repository;

  /// Load notifications
  Future<void> loadNotifications() async {
    state = state.copyWith(status: NotificationStatus.loading);

    final result = await _repository.getNotifications();

    result.fold(
      (failure) => state = state.copyWith(
        status: NotificationStatus.error,
        errorMessage: failure.message,
      ),
      (notifications) => state = state.copyWith(
        status: NotificationStatus.loaded,
        notifications: notifications,
      ),
    );
  }

  /// Load unread count
  Future<void> loadUnreadCount() async {
    final result = await _repository.getUnreadCount();

    result.fold(
      (failure) {},
      (count) => state = state.copyWith(unreadCount: count),
    );
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final result = await _repository.markAsRead(notificationId);

    result.fold(
      (failure) {},
      (_) {
        final notifications = state.notifications.map((n) {
          if (n.id == notificationId) {
            return AppNotification(
              id: n.id,
              type: n.type,
              actor: n.actor,
              createdAt: n.createdAt,
              postId: n.postId,
              commentId: n.commentId,
              message: n.message,
              isRead: true,
            );
          }
          return n;
        }).toList();

        state = state.copyWith(
          notifications: notifications,
          unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
        );
      },
    );
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    final result = await _repository.markAllAsRead();

    result.fold(
      (failure) {},
      (_) {
        final notifications = state.notifications.map((n) {
          return AppNotification(
            id: n.id,
            type: n.type,
            actor: n.actor,
            createdAt: n.createdAt,
            postId: n.postId,
            commentId: n.commentId,
            message: n.message,
            isRead: true,
          );
        }).toList();

        state = state.copyWith(
          notifications: notifications,
          unreadCount: 0,
        );
      },
    );
  }
}

/// Notification provider
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final repository = getIt<NotificationRepository>();
  return NotificationNotifier(repository: repository);
});
