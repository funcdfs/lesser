// 深层链接数据模型
//
// 统一的内容链接系统模型，支持多层级嵌套链接

/// 内容类型枚举
enum LinkContentType {
  /// 频道
  channel,

  /// 频道消息/帖子
  message,

  /// 评论
  comment,

  /// 用户
  user,

  /// 通用帖子
  post,

  /// 锚点（header/bottom 等特殊位置）
  anchor,
}

/// 链接路径段
///
/// 表示 URL 路径中的一个 type/id 对
class LinkSegment {
  const LinkSegment({required this.type, required this.id});

  /// 内容类型
  final LinkContentType type;

  /// 内容 ID
  final String id;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LinkSegment && other.type == type && other.id == id;
  }

  @override
  int get hashCode => Object.hash(type, id);

  @override
  String toString() => 'LinkSegment(type: $type, id: $id)';
}

/// 深层链接模型
///
/// 表示一个完整的深层链接，包含 URL 和解析后的路径段
class LinkModel {
  const LinkModel({required this.url, required this.segments, this.metadata});

  /// 原始 URL
  final String url;

  /// 解析后的路径段列表
  final List<LinkSegment> segments;

  /// 链接元数据（用于渲染预览卡片）
  final LinkMetadata? metadata;

  /// 获取最终目标类型
  LinkContentType get targetType => segments.last.type;

  /// 获取最终目标 ID
  String get targetId => segments.last.id;

  /// 获取父级链（用于导航）
  ///
  /// 返回除最后一个 segment 外的所有 segment
  List<LinkSegment> get parentChain =>
      segments.length > 1 ? segments.sublist(0, segments.length - 1) : [];

  /// 是否有父级
  bool get hasParent => segments.length > 1;

  /// 获取指定类型的 segment
  LinkSegment? getSegment(LinkContentType type) {
    for (final segment in segments) {
      if (segment.type == type) return segment;
    }
    return null;
  }

  /// 创建带有元数据的副本
  LinkModel withMetadata(LinkMetadata metadata) {
    return LinkModel(url: url, segments: segments, metadata: metadata);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LinkModel) return false;
    if (other.url != url) return false;
    if (other.segments.length != segments.length) return false;
    for (var i = 0; i < segments.length; i++) {
      if (other.segments[i] != segments[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(url, Object.hashAll(segments));

  @override
  String toString() =>
      'LinkModel(url: $url, segments: $segments, metadata: $metadata)';
}

/// 链接元数据
///
/// 用于渲染链接预览卡片的附加信息
class LinkMetadata {
  const LinkMetadata({
    this.channelName,
    this.channelAvatar,
    this.contentPreview,
    this.authorName,
    this.isDeleted = false,
  });

  /// 频道名称
  final String? channelName;

  /// 频道头像 URL
  final String? channelAvatar;

  /// 内容预览文本
  final String? contentPreview;

  /// 作者名称
  final String? authorName;

  /// 内容是否已删除
  final bool isDeleted;

  /// 空元数据
  static const empty = LinkMetadata();

  /// 已删除内容的元数据
  static const deleted = LinkMetadata(isDeleted: true);

  /// 创建副本
  LinkMetadata copyWith({
    String? channelName,
    String? channelAvatar,
    String? contentPreview,
    String? authorName,
    bool? isDeleted,
  }) {
    return LinkMetadata(
      channelName: channelName ?? this.channelName,
      channelAvatar: channelAvatar ?? this.channelAvatar,
      contentPreview: contentPreview ?? this.contentPreview,
      authorName: authorName ?? this.authorName,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LinkMetadata &&
        other.channelName == channelName &&
        other.channelAvatar == channelAvatar &&
        other.contentPreview == contentPreview &&
        other.authorName == authorName &&
        other.isDeleted == isDeleted;
  }

  @override
  int get hashCode => Object.hash(
    channelName,
    channelAvatar,
    contentPreview,
    authorName,
    isDeleted,
  );

  @override
  String toString() =>
      'LinkMetadata('
      'channelName: $channelName, '
      'channelAvatar: $channelAvatar, '
      'contentPreview: $contentPreview, '
      'authorName: $authorName, '
      'isDeleted: $isDeleted)';
}
