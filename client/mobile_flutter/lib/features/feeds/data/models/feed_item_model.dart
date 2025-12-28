import '../../../auth/data/models/user_model.dart';
import '../../domain/entities/feed_item.dart';

/// Feed item data model
class FeedItemModel extends FeedItem {
  const FeedItemModel({
    required super.id,
    required super.author,
    required super.content,
    required super.postType,
    required super.createdAt,
    super.title,
    super.mediaUrls,
    super.likesCount,
    super.commentsCount,
    super.repostsCount,
    super.isLiked,
    super.isReposted,
    super.isBookmarked,
    super.expiresAt,
  });

  /// Create from JSON
  factory FeedItemModel.fromJson(Map<String, dynamic> json) {
    return FeedItemModel(
      id: json['id'] as String,
      author: UserModel.fromJson(json['author'] as Map<String, dynamic>),
      content: json['content'] as String,
      postType: _parsePostType(json['post_type'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      title: json['title'] as String?,
      mediaUrls: (json['media_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      repostsCount: json['reposts_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      isReposted: json['is_reposted'] as bool? ?? false,
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': (author as UserModel).toJson(),
      'content': content,
      'post_type': _postTypeToString(postType),
      'created_at': createdAt.toIso8601String(),
      'title': title,
      'media_urls': mediaUrls,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'reposts_count': repostsCount,
      'is_liked': isLiked,
      'is_reposted': isReposted,
      'is_bookmarked': isBookmarked,
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  static PostType _parsePostType(String type) {
    switch (type) {
      case 'story':
        return PostType.story;
      case 'short':
        return PostType.short;
      case 'column':
        return PostType.column;
      default:
        return PostType.short;
    }
  }

  static String _postTypeToString(PostType type) {
    switch (type) {
      case PostType.story:
        return 'story';
      case PostType.short:
        return 'short';
      case PostType.column:
        return 'column';
    }
  }
}
