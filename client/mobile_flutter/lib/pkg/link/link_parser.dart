// 深层链接 URL 解析器
//
// 解析 lesser.app 的深层链接 URL，提取内容类型和 ID

import 'models/link_model.dart';

/// 链接解析器
///
/// 解析 URL 格式: https://lesser.app/{type}/{id}[/subtype/subid]...
///
/// 支持的内容类型:
/// - channel: 频道
/// - message: 频道消息/帖子
/// - comment: 评论
/// - user: 用户
/// - post: 通用帖子
///
/// 示例 URL:
/// - https://lesser.app/channel/123
/// - https://lesser.app/channel/123/message/456
/// - https://lesser.app/channel/123/message/456/comment/789
/// - https://lesser.app/user/123
class LinkParser {
  LinkParser._();

  /// 基础 URL
  static const _baseUrl = 'https://lesser.app';

  /// 备用基础 URL（支持 http）
  static const _baseUrlHttp = 'http://lesser.app';

  /// 类型字符串到枚举的映射
  static const _typeMap = {
    'channel': LinkContentType.channel,
    'message': LinkContentType.message,
    'comment': LinkContentType.comment,
    'user': LinkContentType.user,
    'post': LinkContentType.post,
  };

  /// 枚举到类型字符串的映射
  static const _reverseTypeMap = {
    LinkContentType.channel: 'channel',
    LinkContentType.message: 'message',
    LinkContentType.comment: 'comment',
    LinkContentType.user: 'user',
    LinkContentType.post: 'post',
  };

  /// 解析 URL 为 LinkModel
  ///
  /// 如果 URL 格式无效或不是 lesser.app 链接，返回 null
  static LinkModel? parse(String url) {
    // 去除首尾空白
    final trimmedUrl = url.trim();
    if (trimmedUrl.isEmpty) return null;

    // 检查是否是 lesser.app 链接
    String path;
    if (trimmedUrl.startsWith(_baseUrl)) {
      path = trimmedUrl.substring(_baseUrl.length);
    } else if (trimmedUrl.startsWith(_baseUrlHttp)) {
      path = trimmedUrl.substring(_baseUrlHttp.length);
    } else {
      return null;
    }

    // 移除查询参数和锚点
    final queryIndex = path.indexOf('?');
    if (queryIndex != -1) {
      path = path.substring(0, queryIndex);
    }
    final hashIndex = path.indexOf('#');
    if (hashIndex != -1) {
      path = path.substring(0, hashIndex);
    }

    // 分割路径
    final parts = path.split('/').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return null;

    // 解析路径段（type/id 对）
    final segments = <LinkSegment>[];
    for (var i = 0; i < parts.length; i += 2) {
      // 需要成对出现
      if (i + 1 >= parts.length) break;

      final typeStr = parts[i].toLowerCase();
      final id = parts[i + 1];

      // 验证类型
      final type = _typeMap[typeStr];
      if (type == null) return null;

      // 验证 ID 非空
      if (id.isEmpty) return null;

      segments.add(LinkSegment(type: type, id: id));
    }

    // 至少需要一个有效的 segment
    if (segments.isEmpty) return null;

    return LinkModel(url: trimmedUrl, segments: segments);
  }

  /// 检查字符串是否是有效的 lesser.app 链接
  static bool isValidLink(String url) {
    return parse(url) != null;
  }

  /// 构建 URL
  ///
  /// 从 segments 列表构建完整的 URL
  static String buildUrl(List<LinkSegment> segments) {
    if (segments.isEmpty) return _baseUrl;

    final buffer = StringBuffer(_baseUrl);
    for (final segment in segments) {
      final typeStr = _reverseTypeMap[segment.type];
      if (typeStr != null) {
        buffer.write('/$typeStr/${segment.id}');
      }
    }
    return buffer.toString();
  }

  /// 构建频道链接
  static String buildChannelUrl(String channelId) {
    return '$_baseUrl/channel/$channelId';
  }

  /// 构建消息链接
  static String buildMessageUrl(String channelId, String messageId) {
    return '$_baseUrl/channel/$channelId/message/$messageId';
  }

  /// 构建评论链接
  static String buildCommentUrl(
    String channelId,
    String messageId,
    String commentId,
  ) {
    return '$_baseUrl/channel/$channelId/message/$messageId/comment/$commentId';
  }

  /// 构建用户链接
  static String buildUserUrl(String userId) {
    return '$_baseUrl/user/$userId';
  }

  /// 构建帖子链接
  static String buildPostUrl(String postId) {
    return '$_baseUrl/post/$postId';
  }
}
