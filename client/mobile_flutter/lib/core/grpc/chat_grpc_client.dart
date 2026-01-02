import 'package:grpc/grpc.dart';
import '../../generated/protos/chat/chat.pbgrpc.dart';
import '../../generated/protos/common/common.pb.dart' as common;
import '../constants/app_constants.dart';
import 'grpc_client.dart';

/// Chat gRPC 客户端
/// 封装聊天相关的 gRPC 调用
/// 注意：Chat 服务使用独立的 gRPC 端口
class ChatGrpcClient {
  ChatGrpcClient(this._manager) {
    // Chat 服务使用独立端口，创建专用 channel
    // 移动平台使用原生 gRPC
    _channel = ClientChannel(
      AppConstants.grpcHost,
      port: AppConstants.chatGrpcPort,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        connectionTimeout: AppConstants.connectionTimeout,
        idleTimeout: Duration(minutes: 5),
      ),
    );
    _stub = ChatServiceClient(_channel!);
  }

  final GrpcClientManager _manager;
  ClientChannel? _channel;
  late final ChatServiceClient _stub;

  /// 获取用户的所有会话
  Future<ConversationsResponse> getConversations({
    required String userId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = GetConversationsRequest()
        ..userId = userId
        ..pagination = (common.Pagination()
          ..page = page
          ..pageSize = pageSize);
      return await _stub.getConversations(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'GetConversations');
      rethrow;
    }
  }

  /// 获取单个会话
  Future<Conversation> getConversation(String conversationId) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = GetConversationRequest()..conversationId = conversationId;
      return await _stub.getConversation(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'GetConversation');
      rethrow;
    }
  }

  /// 创建新会话
  Future<Conversation> createConversation({
    required ConversationType type,
    required String creatorId,
    required List<String> memberIds,
    String? name,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = CreateConversationRequest()
        ..type = type
        ..creatorId = creatorId
        ..memberIds.addAll(memberIds);
      if (name != null) {
        request.name = name;
      }
      return await _stub.createConversation(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'CreateConversation');
      rethrow;
    }
  }

  /// 获取会话中的消息
  Future<MessagesResponse> getMessages({
    required String conversationId,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = GetMessagesRequest()
        ..conversationId = conversationId
        ..pagination = (common.Pagination()
          ..page = page
          ..pageSize = pageSize);
      return await _stub.getMessages(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'GetMessages');
      rethrow;
    }
  }

  /// 发送消息
  Future<Message> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    String messageType = 'text',
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = SendMessageRequest()
        ..conversationId = conversationId
        ..senderId = senderId
        ..content = content
        ..messageType = messageType;
      return await _stub.sendMessage(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'SendMessage');
      rethrow;
    }
  }

  /// 实时事件流（双向流）
  /// 使用 ClientEvent/ServerEvent 进行实时通信
  ResponseStream<ServerEvent> streamEvents(Stream<ClientEvent> requests) {
    return _stub.streamEvents(requests);
  }

  /// 标记消息已读
  Future<ReadReceipt> markAsRead({
    required String messageId,
    required String userId,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = MarkAsReadRequest()
        ..messageId = messageId
        ..userId = userId;
      return await _stub.markAsRead(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'MarkAsRead');
      rethrow;
    }
  }

  /// 标记会话所有消息已读
  Future<BatchReadReceipt> markConversationAsRead({
    required String conversationId,
    required String userId,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = MarkConversationAsReadRequest()
        ..conversationId = conversationId
        ..userId = userId;
      return await _stub.markConversationAsRead(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'MarkConversationAsRead');
      rethrow;
    }
  }

  /// 获取未读数
  Future<GetUnreadCountsResponse> getUnreadCounts({
    required String userId,
    List<String>? conversationIds,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = GetUnreadCountsRequest()..userId = userId;
      if (conversationIds != null) {
        request.conversationIds.addAll(conversationIds);
      }
      return await _stub.getUnreadCounts(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'GetUnreadCounts');
      rethrow;
    }
  }

  /// 关闭连接
  Future<void> shutdown() async {
    await _channel?.shutdown();
    _channel = null;
  }
}
