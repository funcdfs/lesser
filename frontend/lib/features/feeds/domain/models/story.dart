/// Story 业务模型
///
/// 定义：Story 的业务结构和字段（日常限时状态）
class Story {
  /// Story ID
  final String id;

  /// Story 图片内容 URL
  final String imageUrl;

  /// Story 视频内容 URL（预留）
  final String? videoUrl;

  /// Story 发布时间
  final DateTime timestamp;

  /// 是否已查看
  final bool isSeen;

  /// Story 文字描述（可选）
  final String? caption;

  /// Story 显示时长（秒）
  final int duration;

  /// Story 查看人数
  final int viewsCount;

  /// Story 外部链接（可选）
  final String? linkUrl;

  /// 媒体类型
  final StoryMediaType mediaType;

  Story({
    required this.id,
    required this.imageUrl,
    this.videoUrl,
    required this.timestamp,
    this.isSeen = false,
    this.caption,
    this.duration = 15,
    this.viewsCount = 0,
    this.linkUrl,
    this.mediaType = StoryMediaType.image,
  });

  /// 创建副本
  Story copyWith({
    String? id,
    String? imageUrl,
    String? videoUrl,
    DateTime? timestamp,
    bool? isSeen,
    String? caption,
    int? duration,
    int? viewsCount,
    String? linkUrl,
    StoryMediaType? mediaType,
  }) {
    return Story(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      timestamp: timestamp ?? this.timestamp,
      isSeen: isSeen ?? this.isSeen,
      caption: caption ?? this.caption,
      duration: duration ?? this.duration,
      viewsCount: viewsCount ?? this.viewsCount,
      linkUrl: linkUrl ?? this.linkUrl,
      mediaType: mediaType ?? this.mediaType,
    );
  }
}

/// Story 媒体类型
enum StoryMediaType {
  /// 图片
  image,

  /// 视频
  video,
}
