import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart' show MarkAsReadResult, UnreadCountResult;
import '../models/conversation_model.dart';
import '../models/message_model.dart';

const _tag = 'ChatDataSource';

/// 聊天远程数据源接口
abstract class ChatRemoteDataSource {
  /// 获取会话列表
  Future<List<ConversationModel>> getConversations({
    int page = 1,
    int pageSize = 20,
  });
  
  /// 获取单个会话详情
  Future<ConversationModel> getConversation(String conversationId);
  
  /// 创建新会话
  Future<ConversationModel> createConversation({
    required ConversationType type,
    required List<String> memberIds,
    String? name,
  });
  
  /// 获取会话消息列表
  Future<List<MessageModel>> getMessages({
    required String conversationId,
    int page = 1,
    int pageSize = 50,
  });
  
  /// 发送消息
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
    MessageType messageType = MessageType.text,
  });

  /// 标记会话消息为已读
  Future<MarkAsReadResult> markAsRead(String conversationId);

  /// 批量获取多个会话的未读数
  Future<List<UnreadCountResult>> getUnreadCounts(List<String> conversationIds);
}

/// 聊天远程数据源实现
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  ChatRemoteDataSourceImpl(this._apiClient, this._sharedPreferences);

  final ApiClient _apiClient;
  final SharedPreferences _sharedPreferences;

  /// 获取当前用户ID
  String? _getCurrentUserId() {
    final userJson = _sharedPreferences.getString('cached_user');
    if (userJson == null) return null;
    final userData = jsonDecode(userJson) as Map<String, dynamic>;
    return userData['id'] as String?;
  }

  /// 构建带用户ID的请求选项
  Options _getOptionsWithUserId() {
    final userId = _getCurrentUserId();
    return Options(
      headers: userId != null ? {'X-User-ID': userId} : null,
    );
  }

  @override
  Future<List<ConversationModel>> getConversations({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final options = _getOptionsWithUserId();

      final response = await _apiClient.get(
        ApiEndpoints.conversations,
        queryParameters: {'page': page, 'page_size': pageSize},
        options: options,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final conversations = data['conversations'] as List<dynamic>?;
        if (conversations == null) return [];
        return conversations
            .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ServerException(statusCode: response.statusCode);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e, stackTrace) {
      log.e('获取会话列表失败: $e', tag: _tag, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<ConversationModel> getConversation(String conversationId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.conversationById(conversationId),
        options: _getOptionsWithUserId(),
      );

      if (response.statusCode == 200) {
        return ConversationModel.fromJson(
            response.data as Map<String, dynamic>);
      }
      throw ServerException(statusCode: response.statusCode);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ConversationModel> createConversation({
    required ConversationType type,
    required List<String> memberIds,
    String? name,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.conversations,
        data: {
          'type': _conversationTypeToString(type),
          'member_ids': memberIds,
          if (name != null) 'name': name,
        },
        options: _getOptionsWithUserId(),
      );

      if (response.statusCode == 201) {
        return ConversationModel.fromJson(
            response.data as Map<String, dynamic>);
      }
      throw ServerException(statusCode: response.statusCode);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<MessageModel>> getMessages({
    required String conversationId,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.messages(conversationId),
        queryParameters: {'page': page, 'page_size': pageSize},
        options: _getOptionsWithUserId(),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final messages = data['messages'] as List<dynamic>?;
        if (messages == null) return [];
        return messages
            .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ServerException(statusCode: response.statusCode);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
    MessageType messageType = MessageType.text,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.messages(conversationId),
        data: {
          'content': content,
          'message_type': _messageTypeToString(messageType),
        },
        options: _getOptionsWithUserId(),
      );

      if (response.statusCode == 201) {
        return MessageModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ServerException(statusCode: response.statusCode);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<MarkAsReadResult> markAsRead(String conversationId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.markAsRead(conversationId),
        options: _getOptionsWithUserId(),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>?;
        final markedCount = data?['marked_count'] as int? ?? 0;
        return MarkAsReadResult(markedCount: markedCount);
      }
      throw ServerException(statusCode: response.statusCode);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<UnreadCountResult>> getUnreadCounts(List<String> conversationIds) async {
    if (conversationIds.isEmpty) return [];
    
    try {
      final response = await _apiClient.get(
        ApiEndpoints.unreadCounts,
        queryParameters: {'conversation_ids': conversationIds.join(',')},
        options: _getOptionsWithUserId(),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final unreadCounts = data['unread_counts'] as List<dynamic>?;
        if (unreadCounts == null) return [];
        
        return unreadCounts.map((e) {
          final item = e as Map<String, dynamic>;
          return UnreadCountResult(
            conversationId: item['conversation_id'] as String,
            count: item['count'] as int? ?? 0,
          );
        }).toList();
      }
      throw ServerException(statusCode: response.statusCode);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 会话类型转字符串
  String _conversationTypeToString(ConversationType type) {
    switch (type) {
      case ConversationType.private:
        return 'private';
      case ConversationType.group:
        return 'group';
      case ConversationType.channel:
        return 'channel';
    }
  }

  /// 消息类型转字符串
  String _messageTypeToString(MessageType type) {
    switch (type) {
      case MessageType.text:
        return 'text';
      case MessageType.image:
        return 'image';
      case MessageType.file:
        return 'file';
      case MessageType.video:
        return 'video';
      case MessageType.link:
        return 'link';
      case MessageType.system:
        return 'system';
    }
  }

  /// 处理 Dio 异常
  AppException _handleDioError(DioException e) {
    log.w(
      'DioError: ${e.type}, status=${e.response?.statusCode}',
      tag: _tag,
    );
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data as Map<String, dynamic>?;
        final message = responseData?['error']?.toString() ?? 
                        responseData?['message']?.toString() ??
                        '服务器错误: $statusCode';
        if (statusCode == 401) {
          return UnauthorizedException(message: message);
        } else if (statusCode == 403) {
          return ForbiddenException(message: message);
        } else if (statusCode == 404) {
          return NotFoundException(message: message);
        }
        return ServerException(statusCode: statusCode, message: message);
      default:
        return ServerException(
          statusCode: e.response?.statusCode,
          message: e.message ?? '未知错误',
        );
    }
  }
}
