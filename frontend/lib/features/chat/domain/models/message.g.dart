// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MessageSender _$MessageSenderFromJson(Map<String, dynamic> json) =>
    _MessageSender(
      userId: json['user_id'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String,
    );

Map<String, dynamic> _$MessageSenderToJson(_MessageSender instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'username': instance.username,
      'avatar_url': instance.avatarUrl,
    };

_Message _$MessageFromJson(Map<String, dynamic> json) => _Message(
  id: json['id'] as String,
  conversationId: json['conversation_id'] as String,
  sender: _senderFromJson(json['sender'] as Map<String, dynamic>),
  content: json['content'] as String,
  type:
      $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
      MessageType.text,
  status:
      $enumDecodeNullable(_$MessageStatusEnumMap, json['status']) ??
      MessageStatus.sent,
  sentAt: DateTime.parse(json['sent_at'] as String),
  isRead: json['is_read'] as bool? ?? false,
  isFromCurrentUser: json['is_from_current_user'] as bool? ?? false,
);

Map<String, dynamic> _$MessageToJson(_Message instance) => <String, dynamic>{
  'id': instance.id,
  'conversation_id': instance.conversationId,
  'sender': _senderToJson(instance.sender),
  'content': instance.content,
  'type': _$MessageTypeEnumMap[instance.type]!,
  'status': _$MessageStatusEnumMap[instance.status]!,
  'sent_at': instance.sentAt.toIso8601String(),
  'is_read': instance.isRead,
  'is_from_current_user': instance.isFromCurrentUser,
};

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.image: 'image',
  MessageType.video: 'video',
  MessageType.audio: 'audio',
  MessageType.system: 'system',
};

const _$MessageStatusEnumMap = {
  MessageStatus.sending: 'sending',
  MessageStatus.sent: 'sent',
  MessageStatus.delivered: 'delivered',
  MessageStatus.read: 'read',
  MessageStatus.failed: 'failed',
};
