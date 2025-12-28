import 'package:equatable/equatable.dart';

/// Message type enum
enum MessageType { text, image, file, system }

/// Message entity
class Message extends Equatable {
  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.messageType,
    required this.createdAt,
    this.isRead = false,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final MessageType messageType;
  final DateTime createdAt;
  final bool isRead;

  @override
  List<Object?> get props => [
        id,
        conversationId,
        senderId,
        content,
        messageType,
        createdAt,
        isRead,
      ];
}
