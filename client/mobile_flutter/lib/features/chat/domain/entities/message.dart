import 'package:equatable/equatable.dart';

/// Message type enum
enum MessageType { text, image, video, link, file, system }

/// Message entity
class Message extends Equatable {
  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.messageType,
    required this.createdAt,
    this.readAt,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final MessageType messageType;
  final DateTime createdAt;
  final DateTime? readAt; // null 表示未读

  /// 是否已读
  bool get isRead => readAt != null;

  /// 创建一个标记为已读的副本
  Message copyWithRead([DateTime? readTime]) {
    return Message(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      content: content,
      messageType: messageType,
      createdAt: createdAt,
      readAt: readTime ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        conversationId,
        senderId,
        content,
        messageType,
        createdAt,
        readAt,
      ];
}
