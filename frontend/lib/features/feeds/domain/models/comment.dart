// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment.freezed.dart';
part 'comment.g.dart';

/// Comment model for post comments
@freezed
sealed class Comment with _$Comment {
  const factory Comment({
    required String id,
    @JsonKey(name: 'post_id') required String postId,
    @JsonKey(name: 'user_id') required String userId,
    required String username,
    required String content,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @Default(0) @JsonKey(name: 'likes_count') int likesCount,
    @Default('') @JsonKey(name: 'avatar_url') String avatarUrl,
    @Default(false) @JsonKey(name: 'is_liked') bool isLiked,
    @Default(0) @JsonKey(name: 'reply_count') int replyCount,
    @Default(false) @JsonKey(name: 'is_from_author') bool isFromAuthor,
    @Default(false) @JsonKey(name: 'is_verified') bool isVerified,
  }) = _Comment;

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
}

/// Comment author information (for backward compatibility)
class CommentAuthor {
  /// User ID
  final String userId;

  /// Username
  final String username;

  /// User avatar URL
  final String avatarUrl;

  /// Whether the user is verified
  final bool isVerified;

  CommentAuthor({
    required this.userId,
    required this.username,
    required this.avatarUrl,
    required this.isVerified,
  });

  factory CommentAuthor.fromJson(Map<String, dynamic> json) {
    return CommentAuthor(
      userId: json['user_id']?.toString() ?? json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      isVerified: json['is_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'avatar_url': avatarUrl,
      'is_verified': isVerified,
    };
  }
}
