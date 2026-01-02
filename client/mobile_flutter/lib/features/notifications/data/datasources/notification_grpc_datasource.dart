import 'package:grpc/grpc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/grpc/notification_grpc_client.dart';
import '../models/notification_model.dart';
import 'notification_remote_datasource.dart';

/// Notification gRPC data source implementation
class NotificationGrpcDataSourceImpl implements NotificationRemoteDataSource {
  const NotificationGrpcDataSourceImpl(this._client, this._prefs);

  final NotificationGrpcClient _client;
  final SharedPreferences _prefs;

  String? get _currentUserId => _prefs.getString('user_id');

  @override
  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int pageSize = 20,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const UnauthorizedException();
    }
    try {
      final response = await _client.getNotifications(
        userId: userId,
        page: page,
        pageSize: pageSize,
      );
      return response.notifications.map((notification) {
        return NotificationModel.fromProto(notification);
      }).toList();
    } on GrpcError catch (e) {
      throw _handleGrpcError(e);
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const UnauthorizedException();
    }
    try {
      await _client.markAsRead(
        notificationId: notificationId,
        userId: userId,
      );
    } on GrpcError catch (e) {
      throw _handleGrpcError(e);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const UnauthorizedException();
    }
    try {
      await _client.markAllAsRead(userId: userId);
    } on GrpcError catch (e) {
      throw _handleGrpcError(e);
    }
  }

  @override
  Future<int> getUnreadCount() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const UnauthorizedException();
    }
    try {
      final response = await _client.getUnreadCount(userId: userId);
      return response.count;
    } on GrpcError catch (e) {
      throw _handleGrpcError(e);
    }
  }

  AppException _handleGrpcError(GrpcError e) {
    switch (e.code) {
      case StatusCode.unauthenticated:
        return const UnauthorizedException();
      case StatusCode.notFound:
        return const NotFoundException();
      case StatusCode.unavailable:
      case StatusCode.deadlineExceeded:
        return const TimeoutException();
      default:
        return ServerException(statusCode: e.code);
    }
  }
}
