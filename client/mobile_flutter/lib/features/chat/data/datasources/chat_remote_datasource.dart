import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart' show MarkAsReadResult, UnreadCountResult;
import '../models/conversation_model.dart';
import '../models/message_model.dart';

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
