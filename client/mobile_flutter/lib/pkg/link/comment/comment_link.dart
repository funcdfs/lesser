// 评论链接工具
//
// 评论相关的链接构建和锚点处理

/// 评论链接工具类
///
/// 提供评论相关的链接构建和锚点判断方法
class CommentLink {
  CommentLink._();

  /// 基础 URL
  static const _baseUrl = 'https://lesser.app';

  /// 特殊锚点：header（帖子/消息头部）
  static const headerAnchor = 'header';

  /// 特殊锚点：bottom（最后一条评论）
  static const bottomAnchor = 'bottom';

  /// 构建评论链接
  static String buildUrl(String channelId, String messageId, String commentId) {
    return '$_baseUrl/channel/$channelId/message/$messageId/comment/$commentId';
  }

  /// 构建 header 锚点链接（用于置顶）
  static String buildHeaderUrl(String channelId, String messageId) {
    return '$_baseUrl/channel/$channelId/message/$messageId/anchor/$headerAnchor';
  }

  /// 构建 bottom 锚点链接（用于置底）
  static String buildBottomUrl(String channelId, String messageId) {
    return '$_baseUrl/channel/$channelId/message/$messageId/anchor/$bottomAnchor';
  }

  /// 构建锚点链接（通用）
  static String buildAnchorUrl(
    String channelId,
    String messageId,
    String anchorId,
  ) {
    return '$_baseUrl/channel/$channelId/message/$messageId/anchor/$anchorId';
  }

  /// 检查是否是 header 锚点
  static bool isHeaderAnchor(String anchorId) => anchorId == headerAnchor;

  /// 检查是否是 bottom 锚点
  static bool isBottomAnchor(String anchorId) => anchorId == bottomAnchor;

  /// 检查是否是特殊锚点（header 或 bottom）
  static bool isSpecialAnchor(String anchorId) =>
      isHeaderAnchor(anchorId) || isBottomAnchor(anchorId);
}
