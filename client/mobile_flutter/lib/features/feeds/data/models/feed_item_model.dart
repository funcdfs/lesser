import '../../../auth/data/models/user_model.dart';
import '../../../../generated/protos/post/post.pb.dart' as post_pb;
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
      mediaUrls:
          (json['media_urls'] as List<dynamic>?)
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

  /// Create from Proto Post message
  /// Note: Proto only provides author_id, so we create a placeholder user.
  /// The full user details should be fetched separately if needed.
  factory FeedItemModel.fromPostProto(post_pb.Post proto) {
    return FeedItemModel(
      id: proto.id,
      // Proto only has author_id, create placeholder user
      author: UserModel(id: proto.authorId, username: '', email: ''),
      content: proto.content,
      postType: _protoPostTypeToEntityFromPost(proto.postType),
      createdAt: proto.hasCreatedAt()
          ? DateTime.fromMillisecondsSinceEpoch(
              proto.createdAt.seconds.toInt() * 1000,
            )
          : DateTime.now(),
      title: proto.hasTitle() && proto.title.isNotEmpty ? proto.title : null,
      mediaUrls: proto.mediaUrls.toList(),
      likesCount: proto.likeCount,
      commentsCount: proto.commentCount,
      repostsCount: proto.repostCount,
      isLiked: false, // Post proto doesn't have interaction flags
      isReposted: false,
      isBookmarked: false,
      expiresAt: proto.hasExpiresAt()
          ? DateTime.fromMillisecondsSinceEpoch(
              proto.expiresAt.seconds.toInt() * 1000,
            )
          : null,
    );
  }

  /// Convert to Entity
  FeedItem toEntity() {
    return FeedItem(
      id: id,
      author: author,
      content: content,
      postType: postType,
      createdAt: createdAt,
      title: title,
      mediaUrls: mediaUrls,
      likesCount: likesCount,
      commentsCount: commentsCount,
      repostsCount: repostsCount,
      isLiked: isLiked,
      isReposted: isReposted,
      isBookmarked: isBookmarked,
      expiresAt: expiresAt,
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

  static PostType _protoPostTypeToEntity(post_pb.PostType protoType) {
    switch (protoType) {
      case post_pb.PostType.STORY:
        return PostType.story;
      case post_pb.PostType.SHORT:
        return PostType.short;
      case post_pb.PostType.COLUMN:
        return PostType.column;
      default:
        return PostType.short;
    }
  }

  static PostType _protoPostTypeToEntityFromPost(post_pb.PostType protoType) {
    return _protoPostTypeToEntity(protoType);
  }

  static post_pb.PostType entityPostTypeToProto(PostType type) {
    switch (type) {
      case PostType.story:
        return post_pb.PostType.STORY;
      case PostType.short:
        return post_pb.PostType.SHORT;
      case PostType.column:
        return post_pb.PostType.COLUMN;
    }
  }
}
