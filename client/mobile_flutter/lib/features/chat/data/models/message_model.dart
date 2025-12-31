import '../../domain/entities/message.dart';

/// Message data model
class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.content,
    required super.messageType,
    required super.createdAt,
    super.readAt,
  });

  /// Create from JSON (匹配 Gin chat 服务的响应格式)
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: _parseId(json['id']),
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      messageType: _parseMessageTypeFromDynamic(json['message_type']),
      createdAt: _parseDateTime(json['created_at']),
      readAt: json['read_at'] != null ? _parseDateTime(json['read_at']) : null,
    );
  }

  /// 解析 ID（支持 int64 和 String 类型）
  /// Go 服务返回 int64，但 JSON 序列化后可能是 String 或 int
  static String _parseId(dynamic value) {
    if (value is String) {
      return value;
    } else if (value is int) {
      return value.toString();
    }
    throw FormatException('无法解析 ID: $value');
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content': content,
      'message_type': _messageTypeToString(messageType),
      'created_at': createdAt.toIso8601String(),
      if (readAt != null) 'read_at': readAt!.toIso8601String(),
    };
  }

  /// 解析日期时间（支持 ISO8601 字符串格式）
  static DateTime _parseDateTime(dynamic value) {
    if (value is String) {
      return DateTime.parse(value);
    }
    throw FormatException('无法解析日期时间: $value');
  }

  /// 从动态类型解析消息类型（支持 String 和 int）
  static MessageType _parseMessageTypeFromDynamic(dynamic value) {
    if (value == null) {
      return MessageType.text;
    } else if (value is String) {
      return _parseMessageType(value);
    } else if (value is int) {
      return _parseMessageTypeFromInt(value);
    }
    return MessageType.text;
  }

  /// 从 int 解析消息类型（匹配 Go 服务的枚举值）
  /// Go 定义: text=0, image=1, video=2, link=3, file=4, system=9
  static MessageType _parseMessageTypeFromInt(int type) {
    switch (type) {
      case 0:
        return MessageType.text;
      case 1:
        return MessageType.image;
      case 2:
        return MessageType.video;
      case 3:
        return MessageType.link;
      case 4:
        return MessageType.file;
      case 9:
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }

  static MessageType _parseMessageType(String type) {
    switch (type) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      case 'link':
        return MessageType.link;
      case 'file':
        return MessageType.file;
      case 'system':
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }

  static String _messageTypeToString(MessageType type) {
    switch (type) {
      case MessageType.text:
        return 'text';
      case MessageType.image:
        return 'image';
      case MessageType.video:
        return 'video';
      case MessageType.link:
        return 'link';
      case MessageType.file:
        return 'file';
      case MessageType.system:
        return 'system';
    }
  }
}
