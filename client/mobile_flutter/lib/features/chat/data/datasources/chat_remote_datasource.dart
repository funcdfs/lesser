import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// Chat remote data source interface
abstract class ChatRemoteDataSource {
  Future<List<ConversationModel>> getConversations({
    int page = 1,
    int pageSize = 20,
  });
  Future<ConversationModel> getConversation(String conversationId);
  Future<ConversationModel> createConversation({
    required ConversationType type,
    required List<String> memberIds,
    String? name,
  });
  Future<List<MessageModel>> getMessages({
    required String conversationId,
    int page = 1,
    int pageSize = 50,
  });
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
    MessageType messageType = MessageType.text,
  });
}

/// Chat remote data source implementation
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  const ChatRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<ConversationModel>> getConversations({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.conversations,
        queryParameters: {'page': page, 'page_size': pageSize},
      );

      if (response.statusCode == 200) {
        final results = response.data['results'] as List<dynamic>;
        return results
            .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ServerException(statusCode: response.statusCode);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ConversationModel> getConversation(String conversationId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.conversationById(conversationId),
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
      );

      if (response.statusCode == 200) {
        final results = response.data['results'] as List<dynamic>;
        return results
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
      );

      if (response.statusCode == 201) {
        return MessageModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ServerException(statusCode: response.statusCode);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

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

  String _messageTypeToString(MessageType type) {
    switch (type) {
      case MessageType.text:
        return 'text';
      case MessageType.image:
        return 'image';
      case MessageType.file:
        return 'file';
      case MessageType.system:
        return 'system';
    }
  }

  AppException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();
      case DioExceptionType.connectionError:
        return const NetworkException();
      default:
        return ServerException(statusCode: e.response?.statusCode);
    }
  }
}
