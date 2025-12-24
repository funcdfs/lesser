// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PostImpl _$$PostImplFromJson(Map<String, dynamic> json) => _$PostImpl(
  id: json['id'] as String,
  username: json['username'] as String,
  content: json['content'] as String,
  createdAt: json['created_at'] as String,
  likes: (json['likes'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$PostImplToJson(_$PostImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'content': instance.content,
      'created_at': instance.createdAt,
      'likes': instance.likes,
    };
