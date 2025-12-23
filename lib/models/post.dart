class Post {
  final String id;
  final String title;
  final String content;
  final String author;
  final String authorHandle;
  final String authorAvatarUrl;
  final DateTime timestamp;
  final int likesCount;
  final int commentsCount;
  final int repostsCount;
  final String? location;
  final List<String> imageUrls;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.authorHandle,
    required this.authorAvatarUrl,
    required this.timestamp,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.repostsCount = 0,
    this.location,
    this.imageUrls = const [],
  });
}
