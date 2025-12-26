// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatUser _$ChatUserFromJson(Map<String, dynamic> json) => _ChatUser(
  id: json['id'] as String,
  username: json['username'] as String,
  avatarUrl: json['avatar_url'] as String?,
  isOnline: json['is_online'] as bool? ?? false,
  lastSeen: json['last_seen'] == null
      ? null
      : DateTime.parse(json['last_seen'] as String),
);

Map<String, dynamic> _$ChatUserToJson(_ChatUser instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'avatar_url': instance.avatarUrl,
  'is_online': instance.isOnline,
  'last_seen': instance.lastSeen?.toIso8601String(),
};
