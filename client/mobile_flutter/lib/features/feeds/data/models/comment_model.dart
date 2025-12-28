import '../../../auth/data/models/user_model.dart';
import '../../domain/entities/comment.dart';

/// Comment data model
class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.postId,
    required super.author,
    required super.content,
    required super.createdAt,
    super.parentId,
    super.likesCount,
    super.repliesCount,
    super.isLiked,
  });

  /// Create from JSON
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      author: UserModel.fromJson(json['author'] as Map<String, dynamic>),
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      parentId: json['parent_id'] as String?,
      likesCount: json['likes_count'] as int? ?? 0,
      repliesCount: json['replies_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'author': (author as UserModel).toJson(),
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'parent_id': parentId,
      'likes_count': likesCount,
      'replies_count': repliesCount,
      'is_liked': isLiked,
    };
  }
}
