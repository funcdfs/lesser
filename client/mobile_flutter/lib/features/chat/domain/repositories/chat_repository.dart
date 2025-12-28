import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';

/// Chat repository interface
abstract class ChatRepository {
  /// Get conversations
  Future<Either<Failure, List<Conversation>>> getConversations({
    int page = 1,
    int pageSize = 20,
  });

  /// Get conversation by ID
  Future<Either<Failure, Conversation>> getConversation(String conversationId);

  /// Create conversation
  Future<Either<Failure, Conversation>> createConversation({
    required ConversationType type,
    required List<String> memberIds,
    String? name,
  });

  /// Get messages
  Future<Either<Failure, List<Message>>> getMessages({
    required String conversationId,
    int page = 1,
    int pageSize = 50,
  });

  /// Send message
  Future<Either<Failure, Message>> sendMessage({
    required String conversationId,
    required String content,
    MessageType messageType = MessageType.text,
  });

  /// Stream messages (for real-time updates)
  Stream<Message> streamMessages(String conversationId);
}
