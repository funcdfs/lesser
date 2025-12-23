/// 帖子数据模型
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
  final int bookmarksCount;
  final int sharesCount;
  final String? location;
  final List<String> imageUrls;

  /// 当前用户是否点赞了该帖子
  final bool isLiked;

  /// 当前用户是否已阅读该帖子
  final bool isRead;

  /// 当前用户是否收藏了该帖子
  final bool isBookmarked;

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
    this.bookmarksCount = 0,
    this.sharesCount = 0,
    this.location,
    this.imageUrls = const [],
    this.isLiked = false,
    this.isRead = false,
    this.isBookmarked = false,
  });

  /// 创建帖子的副本，部分字段可以被替换
  Post copyWith({
    String? id,
    String? title,
    String? content,
    String? author,
    String? authorHandle,
    String? authorAvatarUrl,
    DateTime? timestamp,
    int? likesCount,
    int? commentsCount,
    int? repostsCount,
    int? bookmarksCount,
    int? sharesCount,
    String? location,
    List<String>? imageUrls,
    bool? isLiked,
    bool? isRead,
    bool? isBookmarked,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      author: author ?? this.author,
      authorHandle: authorHandle ?? this.authorHandle,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      timestamp: timestamp ?? this.timestamp,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      repostsCount: repostsCount ?? this.repostsCount,
      bookmarksCount: bookmarksCount ?? this.bookmarksCount,
      sharesCount: sharesCount ?? this.sharesCount,
      location: location ?? this.location,
      imageUrls: imageUrls ?? this.imageUrls,
      isLiked: isLiked ?? this.isLiked,
      isRead: isRead ?? this.isRead,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  @override
  String toString() =>
      '''Post(
    id: $id,
    author: $author,
    likesCount: $likesCount,
    isLiked: $isLiked,
  )''';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Post &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          isLiked == other.isLiked &&
          likesCount == other.likesCount;

  @override
  int get hashCode => id.hashCode ^ isLiked.hashCode ^ likesCount.hashCode;
}
