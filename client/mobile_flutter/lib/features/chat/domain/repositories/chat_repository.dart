import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';

/// 标记已读结果
class MarkAsReadResult {
  const MarkAsReadResult({required this.markedCount});
  final int markedCount;
}

/// 未读数结果
class UnreadCountResult {
  const UnreadCountResult({
    required this.conversationId,
    required this.count,
  });
  final String conversationId;
  final int count;
}

/// 聊天仓库接口
abstract class ChatRepository {
  /// 获取会话列表
  Future<Either<Failure, List<Conversation>>> getConversations({
    int page = 1,
    int pageSize = 20,
  });

  /// 根据ID获取会话
  Future<Either<Failure, Conversation>> getConversation(String conversationId);

  /// 创建会话
  Future<Either<Failure, Conversation>> createConversation({
    required ConversationType type,
    required List<String> memberIds,
    String? name,
  });

  /// 获取消息列表
  Future<Either<Failure, List<Message>>> getMessages({
    required String conversationId,
    int page = 1,
    int pageSize = 50,
  });

  /// 发送消息
  Future<Either<Failure, Message>> sendMessage({
    required String conversationId,
    required String content,
    MessageType messageType = MessageType.text,
  });

  /// 标记会话为已读
  Future<Either<Failure, MarkAsReadResult>> markAsRead(String conversationId);

  /// 批量获取多个会话的未读数
  Future<Either<Failure, List<UnreadCountResult>>> getUnreadCounts(List<String> conversationIds);

  /// 消息流（用于实时更新）
  Stream<Message> streamMessages(String conversationId);
}
