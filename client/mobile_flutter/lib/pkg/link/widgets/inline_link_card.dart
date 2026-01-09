// 内联链接卡片组件
//
// 用于在文本中渲染深层链接的紧凑预览卡片
// 格式：【频道：test。评论：xxxx（内容）】

import 'package:flutter/material.dart';

import '../../ui/effects/effects.dart';
import '../../ui/theme/theme.dart';
import '../link_parser.dart';
import '../models/link_model.dart';

/// 内联链接卡片组件
///
/// 紧凑的链接预览卡片，适合嵌入到文本或消息中
/// 显示格式：【频道：{name}。{type}：{content}】
class InlineLinkCard extends StatelessWidget {
  const InlineLinkCard({
    super.key,
    required this.link,
    required this.metadata,
    this.onTap,
    this.maxWidth,
  });

  /// 链接模型
  final LinkModel link;

  /// 链接元数据
  final LinkMetadata metadata;

  /// 点击回调
  final VoidCallback? onTap;

  /// 最大宽度
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final displayText = _buildDisplayText();

    return TapScale(
      onTap: onTap,
      scale: TapScales.small,
      child: Container(
        constraints: maxWidth != null
            ? BoxConstraints(maxWidth: maxWidth!)
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: colors.accentSoft,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colors.accent.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 链接图标
            Icon(
              _getIconForType(link.targetType),
              size: 14,
              color: colors.accent,
            ),
            const SizedBox(width: 6),
            // 链接文本
            Flexible(
              child: Text(
                displayText,
                style: TextStyle(
                  fontSize: 13,
                  color: colors.accent,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建显示文本
  ///
  /// 格式：频道：{name}。{type}：{content}
  String _buildDisplayText() {
    if (metadata.isDeleted) return '内容已删除';

    final parts = <String>[];

    // 添加频道名称
    if (metadata.channelName != null && metadata.channelName!.isNotEmpty) {
      parts.add('频道：${metadata.channelName}');
    }

    // 添加内容预览
    if (metadata.contentPreview != null &&
        metadata.contentPreview!.isNotEmpty) {
      final typeLabel = _getContentTypeLabel(link.targetType);
      parts.add('$typeLabel：${metadata.contentPreview}');
    }

    // 如果没有任何内容，显示作者名称
    if (parts.isEmpty && metadata.authorName != null) {
      parts.add(metadata.authorName!);
    }

    // 如果还是空的，显示默认文本
    if (parts.isEmpty) {
      return '查看详情';
    }

    return parts.join('。');
  }

  /// 获取内容类型对应的图标
  IconData _getIconForType(LinkContentType type) {
    switch (type) {
      case LinkContentType.channel:
        return Icons.campaign_rounded;
      case LinkContentType.message:
        return Icons.article_rounded;
      case LinkContentType.comment:
        return Icons.chat_bubble_outline_rounded;
      case LinkContentType.user:
        return Icons.person_rounded;
      case LinkContentType.post:
        return Icons.description_rounded;
    }
  }

  /// 获取内容类型标签
  String _getContentTypeLabel(LinkContentType type) {
    switch (type) {
      case LinkContentType.comment:
        return '评论';
      case LinkContentType.message:
        return '消息';
      case LinkContentType.post:
        return '帖子';
      default:
        return '内容';
    }
  }
}

/// 从 URL 创建内联链接卡片
///
/// 异步加载链接元数据并渲染卡片
class InlineLinkCardFromUrl extends StatefulWidget {
  const InlineLinkCardFromUrl({
    super.key,
    required this.url,
    required this.resolveMetadata,
    this.onTap,
    this.maxWidth,
  });

  /// 链接 URL
  final String url;

  /// 解析元数据的回调
  final Future<LinkMetadata?> Function(LinkModel link) resolveMetadata;

  /// 点击回调
  final VoidCallback? onTap;

  /// 最大宽度
  final double? maxWidth;

  @override
  State<InlineLinkCardFromUrl> createState() => _InlineLinkCardFromUrlState();
}

class _InlineLinkCardFromUrlState extends State<InlineLinkCardFromUrl> {
  LinkModel? _link;
  LinkMetadata? _metadata;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMetadata();
  }

  @override
  void didUpdateWidget(InlineLinkCardFromUrl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _loadMetadata();
    }
  }

  Future<void> _loadMetadata() async {
    setState(() => _isLoading = true);

    // 使用 LinkParser 解析 URL
    final link = LinkParser.parse(widget.url);
    if (link == null) {
      setState(() {
        _link = null;
        _metadata = null;
        _isLoading = false;
      });
      return;
    }

    // 获取元数据
    final metadata = await widget.resolveMetadata(link);

    if (mounted) {
      setState(() {
        _link = link;
        _metadata = metadata ?? LinkMetadata.empty;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: colors.textDisabled,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '加载中...',
              style: TextStyle(fontSize: 13, color: colors.textDisabled),
            ),
          ],
        ),
      );
    }

    if (_link == null || _metadata == null) {
      // 无效链接，显示为普通文本
      return Text(
        widget.url,
        style: TextStyle(
          fontSize: 13,
          color: colors.accent,
          decoration: TextDecoration.underline,
        ),
      );
    }

    return InlineLinkCard(
      link: _link!,
      metadata: _metadata!,
      onTap: widget.onTap,
      maxWidth: widget.maxWidth,
    );
  }
}
