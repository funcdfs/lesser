// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post.freezed.dart';
part 'post.g.dart';

@freezed
sealed class Post with _$Post {
  const factory Post({
    required String id,
    required String username,
    required String content,
    @JsonKey(name: 'created_at') required String createdAt,
    @Default(0) int likes,
    String? location,
    @Default([]) @JsonKey(name: 'image_urls') List<String> imageUrls,
    @Default(0) @JsonKey(name: 'comments_count') int commentsCount,
    @Default(0) @JsonKey(name: 'reposts_count') int repostsCount,
    @Default(0) @JsonKey(name: 'bookmarks_count') int bookmarksCount,
    @Default(0) @JsonKey(name: 'shares_count') int sharesCount,
    @Default(false) @JsonKey(name: 'is_liked') bool isLiked,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}
