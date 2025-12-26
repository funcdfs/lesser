// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Comment _$CommentFromJson(Map<String, dynamic> json) => _Comment(
  id: json['id'] as String,
  postId: json['post_id'] as String,
  userId: json['user_id'] as String,
  username: json['username'] as String,
  content: json['content'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
  avatarUrl: json['avatar_url'] as String? ?? '',
  isLiked: json['is_liked'] as bool? ?? false,
  replyCount: (json['reply_count'] as num?)?.toInt() ?? 0,
  isFromAuthor: json['is_from_author'] as bool? ?? false,
  isVerified: json['is_verified'] as bool? ?? false,
);

Map<String, dynamic> _$CommentToJson(_Comment instance) => <String, dynamic>{
  'id': instance.id,
  'post_id': instance.postId,
  'user_id': instance.userId,
  'username': instance.username,
  'content': instance.content,
  'created_at': instance.createdAt.toIso8601String(),
  'likes_count': instance.likesCount,
  'avatar_url': instance.avatarUrl,
  'is_liked': instance.isLiked,
  'reply_count': instance.replyCount,
  'is_from_author': instance.isFromAuthor,
  'is_verified': instance.isVerified,
};
