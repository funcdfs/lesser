import '../../../auth/data/models/user_model.dart';
import '../../domain/entities/conversation.dart';
import 'message_model.dart';

/// Conversation data model
class ConversationModel extends Conversation {
  const ConversationModel({
    required super.id,
    required super.type,
    required super.members,
    required super.createdAt,
    super.name,
    super.creatorId,
    super.lastMessage,
    super.unreadCount,
  });

  /// Create from JSON (匹配 Gin chat 服务的响应格式)
  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    // 解析 members，处理可能为空或 null 的情况
    final membersJson = json['members'] as List<dynamic>?;
    final members = membersJson != null
        ? membersJson
            .where((e) => e != null && e is Map<String, dynamic>)
            .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : <UserModel>[];

    return ConversationModel(
      id: json['id'] as String,
      type: _parseConversationType(json['type'] as String),
      members: members,
      createdAt: _parseDateTime(json['created_at']),
      name: json['name'] as String?,
      creatorId: json['creator_id'] as String?,
      lastMessage: json['last_message'] != null
          ? MessageModel.fromJson(json['last_message'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': _conversationTypeToString(type),
      'members': members.map((m) => (m as UserModel).toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'name': name,
      'creator_id': creatorId,
      'last_message':
          lastMessage != null ? (lastMessage as MessageModel).toJson() : null,
      'unread_count': unreadCount,
    };
  }

  /// 解析日期时间（支持 ISO8601 字符串格式）
  static DateTime _parseDateTime(dynamic value) {
    if (value is String) {
      return DateTime.parse(value);
    }
    throw FormatException('无法解析日期时间: $value');
  }

  static ConversationType _parseConversationType(String type) {
    switch (type.toLowerCase()) {
      case 'private':
        return ConversationType.private;
      case 'group':
        return ConversationType.group;
      case 'channel':
        return ConversationType.channel;
      default:
        return ConversationType.private;
    }
  }

  static String _conversationTypeToString(ConversationType type) {
    switch (type) {
      case ConversationType.private:
        return 'private';
      case ConversationType.group:
        return 'group';
      case ConversationType.channel:
        return 'channel';
    }
  }
}
