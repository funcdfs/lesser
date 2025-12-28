import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/notification.dart';

/// Notification repository interface
abstract class NotificationRepository {
  /// Get notifications
  Future<Either<Failure, List<AppNotification>>> getNotifications({
    int page = 1,
    int pageSize = 20,
  });

  /// Mark notification as read
  Future<Either<Failure, void>> markAsRead(String notificationId);

  /// Mark all notifications as read
  Future<Either<Failure, void>> markAllAsRead();

  /// Get unread count
  Future<Either<Failure, int>> getUnreadCount();
}
