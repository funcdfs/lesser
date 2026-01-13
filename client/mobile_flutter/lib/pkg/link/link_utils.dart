// 链接工具类
//
// 提供链接相关的实用工具方法：复制、分享、外部链接处理等

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ui/theme/theme.dart';
import 'link_parser.dart';
import 'models/link_model.dart';

/// 链接工具类
///
/// 提供链接相关的实用方法
class LinkUtils {
  LinkUtils._();

  /// 复制链接到剪贴板
  ///
  /// 返回是否复制成功
  static Future<bool> copyToClipboard(String url) async {
    try {
      await Clipboard.setData(ClipboardData(text: url));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 复制链接并显示提示
  static Future<void> copyWithFeedback(
    BuildContext context,
    String url, {
    String successMessage = '链接已复制',
    String failureMessage = '复制失败',
  }) async {
    HapticFeedback.lightImpact();
    final success = await copyToClipboard(url);

    if (!context.mounted) return;

    // 使用项目语义化颜色
    final colors = AppColors.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? successMessage : failureMessage,
          style: TextStyle(color: colors.textPrimary),
        ),
        backgroundColor: colors.surfaceElevated,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  /// 检查是否是 lesser.app 内部链接
  static bool isInternalLink(String url) {
    return LinkParser.isValidLink(url);
  }

  /// 检查是否是外部链接
  static bool isExternalLink(String url) {
    if (url.isEmpty) return false;
    // 检查是否是有效的 URL
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return false;
    // 排除内部链接
    return !isInternalLink(url);
  }

  /// 获取链接的显示文本
  ///
  /// 对于内部链接，返回友好的类型描述
  /// 对于外部链接，返回域名
  static String getDisplayText(String url) {
    // 尝试解析为内部链接
    final link = LinkParser.parse(url);
    if (link != null) {
      return _getInternalLinkDisplayText(link);
    }

    // 外部链接，提取域名
    final uri = Uri.tryParse(url);
    if (uri != null && uri.host.isNotEmpty) {
      return uri.host;
    }

    // 无法解析，返回原始 URL（截断）
    if (url.length > 30) {
      return '${url.substring(0, 30)}...';
    }
    return url;
  }

  /// 获取内部链接的显示文本
  static String _getInternalLinkDisplayText(LinkModel link) {
    return switch (link.targetType) {
      LinkContentType.channel => '频道链接',
      LinkContentType.message => '消息链接',
      LinkContentType.comment => '评论链接',
      LinkContentType.user => '用户链接',
      LinkContentType.post => '帖子链接',
      LinkContentType.anchor => '锚点链接',
    };
  }

  /// 获取链接类型图标
  static IconData getIconForUrl(String url) {
    final link = LinkParser.parse(url);
    if (link != null) {
      return getIconForType(link.targetType);
    }
    // 外部链接
    return Icons.open_in_new_rounded;
  }

  /// 获取内容类型对应的图标
  static IconData getIconForType(LinkContentType type) {
    return switch (type) {
      LinkContentType.channel => Icons.campaign_rounded,
      LinkContentType.message => Icons.article_rounded,
      LinkContentType.comment => Icons.chat_bubble_outline_rounded,
      LinkContentType.user => Icons.person_rounded,
      LinkContentType.post => Icons.description_rounded,
      LinkContentType.anchor => Icons.tag_rounded,
    };
  }

  /// 获取内容类型标签
  static String getLabelForType(LinkContentType type) {
    return switch (type) {
      LinkContentType.channel => '频道',
      LinkContentType.message => '消息',
      LinkContentType.comment => '评论',
      LinkContentType.user => '用户',
      LinkContentType.post => '帖子',
      LinkContentType.anchor => '锚点',
    };
  }

  /// 构建分享文本
  ///
  /// 格式：{title}\n{url}
  static String buildShareText(String url, {String? title}) {
    if (title != null && title.isNotEmpty) {
      return '$title\n$url';
    }
    return url;
  }

  /// 从剪贴板获取链接
  ///
  /// 如果剪贴板内容是有效的 URL，返回该 URL
  /// 否则返回 null
  static Future<String?> getFromClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim();
      if (text == null || text.isEmpty) return null;

      // 检查是否是有效的 URL
      final uri = Uri.tryParse(text);
      if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
        return text;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 验证 URL 格式
  static bool isValidUrl(String url) {
    if (url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  /// 规范化 URL
  ///
  /// 移除尾部斜杠，统一小写 scheme
  static String normalizeUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return url;

    var normalized = uri.toString();
    // 移除尾部斜杠（除非是根路径）
    if (normalized.endsWith('/') && uri.path != '/') {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }
}

/// 链接类型扩展
extension LinkContentTypeExtension on LinkContentType {
  /// 获取图标
  IconData get icon => LinkUtils.getIconForType(this);

  /// 获取标签
  String get label => LinkUtils.getLabelForType(this);
}
