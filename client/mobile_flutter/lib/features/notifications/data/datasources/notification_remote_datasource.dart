import '../models/notification_model.dart';

/// Notification remote data source interface
abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int pageSize = 20,
  });
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<int> getUnreadCount();
}
