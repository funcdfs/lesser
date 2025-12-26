// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Post _$PostFromJson(Map<String, dynamic> json) => _Post(
  id: json['id'] as String,
  username: json['username'] as String,
  content: json['content'] as String,
  createdAt: json['created_at'] as String,
  likes: (json['likes'] as num?)?.toInt() ?? 0,
  location: json['location'] as String?,
  imageUrls:
      (json['image_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
  repostsCount: (json['reposts_count'] as num?)?.toInt() ?? 0,
  bookmarksCount: (json['bookmarks_count'] as num?)?.toInt() ?? 0,
  sharesCount: (json['shares_count'] as num?)?.toInt() ?? 0,
  isLiked: json['is_liked'] as bool? ?? false,
);

Map<String, dynamic> _$PostToJson(_Post instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'content': instance.content,
  'created_at': instance.createdAt,
  'likes': instance.likes,
  'location': instance.location,
  'image_urls': instance.imageUrls,
  'comments_count': instance.commentsCount,
  'reposts_count': instance.repostsCount,
  'bookmarks_count': instance.bookmarksCount,
  'shares_count': instance.sharesCount,
  'is_liked': instance.isLiked,
};
