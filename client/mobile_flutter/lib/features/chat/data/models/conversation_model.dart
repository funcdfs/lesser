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

  /// Create from JSON
  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      type: _parseConversationType(json['type'] as String),
      members: (json['members'] as List<dynamic>)
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
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

  static ConversationType _parseConversationType(String type) {
    switch (type) {
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
