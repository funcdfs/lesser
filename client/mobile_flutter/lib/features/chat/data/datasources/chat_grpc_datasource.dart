import 'package:grpc/grpc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/grpc/chat_grpc_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../generated/protos/chat/chat.pbgrpc.dart' as pb;
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart' show MarkAsReadResult, UnreadCountResult;
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import 'chat_remote_datasource.dart';

const _tag = 'ChatGrpcDataSource';

/// 聊天 gRPC 数据源实现
/// 使用 Chat gRPC 客户端替代 Dio HTTP 客户端
class ChatGrpcDataSourceImpl implements ChatRemoteDataSource {
  ChatGrpcDataSourceImpl(this._chatClient, this._sharedPreferences);

  final ChatGrpcClient _chatClient;
  final SharedPreferences _sharedPreferences;

  /// 获取当前用户ID
  String? _getCurrentUserId() {
    final userJson = _sharedPreferences.getString('cached_user');
    if (userJson == null) return null;
    final userData = jsonDecode(userJson) as Map<String, dynamic>;
    return userData['id'] as String?;
  }

  @override
  Future<List<ConversationModel>> getConversations({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) {
        throw const UnauthorizedException(message: '用户未登录');
      }

      final response = await _chatClient.getConversations(
        userId: userId,
        page: page,
        pageSize: pageSize,
      );

      return response.conversations
          .map((conv) => _protoToConversationModel(conv))
          .toList();
    } on GrpcError catch (e) {
      log.e('获取会话列表失败: ${e.message}', tag: _tag);
      throw _handleGrpcError(e);
    }
  }

  @override
  Future<ConversationModel> getConversation(String conversationId) async {
    try {
      final response = await _chatClient.getConversation(conversationId);
      return _protoToConversationModel(response);
    } on GrpcError catch (e) {
      log.e('获取会话详情失败: ${e.message}', tag: _tag);
      throw _handleGrpcError(e);
    }
  }

  @override
  Future<ConversationModel> createConversation({
    required ConversationType type,
    required List<String> memberIds,
    String? name,
  }) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) {
        throw const UnauthorizedException(message: '用户未登录');
      }

      final response = await _chatClient.createConversation(
        type: _conversationTypeToProto(type),
        creatorId: userId,
        memberIds: memberIds,
        name: name,
      );

      return _protoToConversationModel(response);
    } on GrpcError catch (e) {
      log.e('创建会话失败: ${e.message}', tag: _tag);
      throw _handleGrpcError(e);
    }
  }

  @override
  Future<List<MessageModel>> getMessages({
    required String conversationId,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await _chatClient.getMessages(
        conversationId: conversationId,
        page: page,
        pageSize: pageSize,
      );

      return response.messages
          .map((msg) => _protoToMessageModel(msg))
          .toList();
    } on GrpcError catch (e) {
      log.e('获取消息列表失败: ${e.message}', tag: _tag);
      throw _handleGrpcError(e);
    }
  }

  @override
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
    MessageType messageType = MessageType.text,
  }) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) {
        throw const UnauthorizedException(message: '用户未登录');
      }

      final response = await _chatClient.sendMessage(
        conversationId: conversationId,
        senderId: userId,
        content: content,
        messageType: _messageTypeToString(messageType),
      );

      return _protoToMessageModel(response);
    } on GrpcError catch (e) {
      log.e('发送消息失败: ${e.message}', tag: _tag);
      throw _handleGrpcError(e);
    }
  }

  @override
  Future<MarkAsReadResult> markAsRead(String conversationId) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) {
        throw const UnauthorizedException(message: '用户未登录');
      }

      final response = await _chatClient.markConversationAsRead(
        conversationId: conversationId,
        userId: userId,
      );

      return MarkAsReadResult(markedCount: response.messageIds.length);
    } on GrpcError catch (e) {
      log.e('标记已读失败: ${e.message}', tag: _tag);
      throw _handleGrpcError(e);
    }
  }

  @override
  Future<List<UnreadCountResult>> getUnreadCounts(List<String> conversationIds) async {
    if (conversationIds.isEmpty) return [];

    try {
      final userId = _getCurrentUserId();
      if (userId == null) {
        throw const UnauthorizedException(message: '用户未登录');
      }

      final response = await _chatClient.getUnreadCounts(
        userId: userId,
        conversationIds: conversationIds,
      );

      return response.unreadCounts
          .map((uc) => UnreadCountResult(
                conversationId: uc.conversationId,
                count: uc.count.toInt(),
              ))
          .toList();
    } on GrpcError catch (e) {
      log.e('获取未读数失败: ${e.message}', tag: _tag);
      throw _handleGrpcError(e);
    }
  }

  // ============ 类型转换辅助方法 ============

  /// Proto 会话转模型
  ConversationModel _protoToConversationModel(pb.Conversation conv) {
    return ConversationModel(
      id: conv.id,
      type: _protoToConversationType(conv.type),
      name: conv.name,
      memberIds: conv.memberIds.toList(),
      creatorId: conv.creatorId,
      createdAt: conv.hasCreatedAt()
          ? DateTime.fromMillisecondsSinceEpoch(
              conv.createdAt.seconds.toInt() * 1000)
          : DateTime.now(),
      lastMessage: conv.hasLastMessage()
          ? _protoToMessageModel(conv.lastMessage)
          : null,
    );
  }

  /// Proto 消息转模型
  MessageModel _protoToMessageModel(pb.Message msg) {
    return MessageModel(
      id: msg.id,
      conversationId: msg.conversationId,
      senderId: msg.senderId,
      content: msg.content,
      messageType: _stringToMessageType(msg.messageType),
      createdAt: msg.hasCreatedAt()
          ? DateTime.fromMillisecondsSinceEpoch(
              msg.createdAt.seconds.toInt() * 1000)
          : DateTime.now(),
      readAt: msg.hasReadAt()
          ? DateTime.fromMillisecondsSinceEpoch(
              msg.readAt.seconds.toInt() * 1000)
          : null,
    );
  }

  /// 会话类型转 Proto
  pb.ConversationType _conversationTypeToProto(ConversationType type) {
    switch (type) {
      case ConversationType.private:
        return pb.ConversationType.PRIVATE;
      case ConversationType.group:
        return pb.ConversationType.GROUP;
      case ConversationType.channel:
        return pb.ConversationType.CHANNEL;
    }
  }

  /// Proto 转会话类型
  ConversationType _protoToConversationType(pb.ConversationType type) {
    switch (type) {
      case pb.ConversationType.PRIVATE:
        return ConversationType.private;
      case pb.ConversationType.GROUP:
        return ConversationType.group;
      case pb.ConversationType.CHANNEL:
        return ConversationType.channel;
      default:
        return ConversationType.private;
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

  /// 字符串转消息类型
  MessageType _stringToMessageType(String type) {
    switch (type) {
      case 'image':
        return MessageType.image;
      case 'file':
        return MessageType.file;
      case 'video':
        return MessageType.video;
      case 'link':
        return MessageType.link;
      case 'system':
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }

  /// 处理 gRPC 错误
  AppException _handleGrpcError(GrpcError e) {
    switch (e.code) {
      case StatusCode.unauthenticated:
        return UnauthorizedException(message: e.message ?? '认证失败');
      case StatusCode.permissionDenied:
        return ForbiddenException(message: e.message ?? '权限不足');
      case StatusCode.notFound:
        return NotFoundException(message: e.message ?? '资源不存在');
      case StatusCode.invalidArgument:
        return ServerException(message: e.message ?? '参数无效');
      case StatusCode.unavailable:
        return const NetworkException();
      case StatusCode.deadlineExceeded:
        return const TimeoutException();
      default:
        return ServerException(message: e.message ?? '服务器错误');
    }
  }
}
