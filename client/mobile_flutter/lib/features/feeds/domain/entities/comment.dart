import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user.dart';

/// Comment entity
class Comment extends Equatable {
  const Comment({
    required this.id,
    required this.postId,
    required this.author,
    required this.content,
    required this.createdAt,
    this.parentId,
    this.likesCount = 0,
    this.repliesCount = 0,
    this.isLiked = false,
  });

  final String id;
  final String postId;
  final User author;
  final String content;
  final DateTime createdAt;
  final String? parentId;
  final int likesCount;
  final int repliesCount;
  final bool isLiked;

  @override
  List<Object?> get props => [
        id,
        postId,
        author,
        content,
        createdAt,
        parentId,
        likesCount,
        repliesCount,
        isLiked,
      ];
}
