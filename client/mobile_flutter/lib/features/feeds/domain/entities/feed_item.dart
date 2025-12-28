import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user.dart';

/// Post type enum
enum PostType { story, short, column }

/// Feed item entity
class FeedItem extends Equatable {
  const FeedItem({
    required this.id,
    required this.author,
    required this.content,
    required this.postType,
    required this.createdAt,
    this.title,
    this.mediaUrls = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    this.repostsCount = 0,
    this.isLiked = false,
    this.isReposted = false,
    this.isBookmarked = false,
    this.expiresAt,
  });

  final String id;
  final User author;
  final String content;
  final PostType postType;
  final DateTime createdAt;
  final String? title;
  final List<String> mediaUrls;
  final int likesCount;
  final int commentsCount;
  final int repostsCount;
  final bool isLiked;
  final bool isReposted;
  final bool isBookmarked;
  final DateTime? expiresAt;

  @override
  List<Object?> get props => [
        id,
        author,
        content,
        postType,
        createdAt,
        title,
        mediaUrls,
        likesCount,
        commentsCount,
        repostsCount,
        isLiked,
        isReposted,
        isBookmarked,
        expiresAt,
      ];
}
