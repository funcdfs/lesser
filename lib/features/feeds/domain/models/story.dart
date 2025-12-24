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

  /// 是否过已查看
  final bool isSeen;

  Story({
    required this.id,
    required this.imageUrl,
    this.videoUrl,
    required this.timestamp,
    this.isSeen = false,
  });

  /// 创建副本
  Story copyWith({
    String? id,
    String? imageUrl,
    String? videoUrl,
    DateTime? timestamp,
    bool? isSeen,
  }) {
    return Story(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      timestamp: timestamp ?? this.timestamp,
      isSeen: isSeen ?? this.isSeen,
    );
  }
}
