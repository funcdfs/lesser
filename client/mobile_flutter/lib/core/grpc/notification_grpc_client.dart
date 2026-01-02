import 'package:grpc/grpc.dart';
import '../../generated/protos/notification/notification.pbgrpc.dart';
import '../../generated/protos/common/common.pb.dart' as common;
import 'grpc_client.dart';

/// Notification gRPC 客户端
/// 封装通知相关的 gRPC 调用
class NotificationGrpcClient {
  NotificationGrpcClient(this._manager) {
    _stub = NotificationServiceClient(_manager.channel);
  }

  final GrpcClientManager _manager;
  late final NotificationServiceClient _stub;

  /// 获取通知列表
  Future<NotificationsResponse> getNotifications({
    required String userId,
    NotificationType? type,
    bool? unreadOnly,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = GetNotificationsRequest()
        ..userId = userId
        ..pagination = (common.Pagination()
          ..page = page
          ..pageSize = pageSize);
      if (type != null) request.type = type;
      if (unreadOnly != null) request.unreadOnly = unreadOnly;
      return await _stub.getNotifications(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'GetNotifications');
      rethrow;
    }
  }

  /// 获取未读通知数量
  Future<UnreadCountResponse> getUnreadCount({
    required String userId,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = GetUnreadCountRequest()..userId = userId;
      return await _stub.getUnreadCount(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'GetUnreadCount');
      rethrow;
    }
  }

  /// 标记通知为已读
  Future<void> markAsRead({
    required String notificationId,
    required String userId,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = MarkAsReadRequest()
        ..notificationId = notificationId
        ..userId = userId;
      await _stub.markAsRead(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'MarkAsRead');
      rethrow;
    }
  }

  /// 标记所有通知为已读
  Future<void> markAllAsRead({
    required String userId,
    NotificationType? type,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = MarkAllAsReadRequest()..userId = userId;
      if (type != null) request.type = type;
      await _stub.markAllAsRead(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'MarkAllAsRead');
      rethrow;
    }
  }

  /// 实时通知流
  Stream<Notification> streamNotifications({
    required String userId,
  }) async* {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = StreamNotificationsRequest()..userId = userId;
      yield* _stub.streamNotifications(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'StreamNotifications');
      rethrow;
    }
  }
}
