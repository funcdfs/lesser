import 'package:equatable/equatable.dart';

import '../../../feeds/domain/entities/feed_item.dart';

/// Create post request entity
class CreatePostRequest extends Equatable {
  const CreatePostRequest({
    required this.content,
    required this.postType,
    this.title,
    this.mediaUrls = const [],
  });

  final String content;
  final PostType postType;
  final String? title;
  final List<String> mediaUrls;

  @override
  List<Object?> get props => [content, postType, title, mediaUrls];
}
