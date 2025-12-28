import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user.dart';
import '../../../feeds/domain/entities/feed_item.dart';

/// Search result type
enum SearchResultType { post, user }

/// Search result entity
class SearchResult extends Equatable {
  const SearchResult({
    required this.posts,
    required this.users,
  });

  final List<FeedItem> posts;
  final List<User> users;

  @override
  List<Object?> get props => [posts, users];
}
