// 链接卡片组件
//
// 用于渲染深层链接的预览卡片，显示内容类型图标、频道名称、内容预览等

import 'package:flutter/material.dart';

import '../../ui/effects/effects.dart';
import '../../ui/theme/theme.dart';
import '../models/link_model.dart';

/// 链接卡片组件
///
/// 显示链接的预览信息，包括内容类型图标、频道名称、内容预览等
/// 格式：频道: xxx · 评论: xxx
class LinkCard extends StatelessWidget {
  const LinkCard({
    super.key,
    required this.link,
    required this.metadata,
    this.onTap,
  });

  /// 链接模型
  final LinkModel link;

  /// 链接元数据
  final LinkMetadata metadata;

  /// 点击回调
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(colors),
            const SizedBox(width: 10),
            Flexible(child: _buildContent(colors)),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: colors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建内容类型图标
  Widget _buildIcon(AppColorScheme colors) {
    final iconData = _getIconForType(link.targetType);
    final iconColor = metadata.isDeleted ? colors.textDisabled : colors.accent;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, size: 18, color: iconColor),
    );
  }

  /// 构建内容区域
  Widget _buildContent(AppColorScheme colors) {
    final displayText = _buildDisplayText();
    final textColor = metadata.isDeleted
        ? colors.textDisabled
        : colors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 类型标签
        Text(
          _getTypeLabel(link.targetType),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: colors.textTertiary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        // 内容预览
        Text(
          displayText,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: textColor,
            height: 1.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// 构建显示文本
  ///
  /// 格式：频道: {channel_name} · {type_label}: {content_preview}
  String _buildDisplayText() {
    if (metadata.isDeleted) return '内容已删除';

    final parts = <String>[];

    // 添加频道名称
    if (metadata.channelName != null && metadata.channelName!.isNotEmpty) {
      parts.add('频道: ${metadata.channelName}');
    }

    // 添加内容预览
    if (metadata.contentPreview != null &&
        metadata.contentPreview!.isNotEmpty) {
      final typeLabel = _getContentTypeLabel(link.targetType);
      parts.add('$typeLabel: ${metadata.contentPreview}');
    }

    // 如果没有任何内容，显示作者名称
    if (parts.isEmpty && metadata.authorName != null) {
      parts.add(metadata.authorName!);
    }

    // 如果还是空的，显示默认文本
    if (parts.isEmpty) {
      return '查看详情';
    }

    return parts.join(' · ');
  }

  /// 获取内容类型对应的图标
  IconData _getIconForType(LinkContentType type) {
    return switch (type) {
      LinkContentType.channel => Icons.campaign_rounded,
      LinkContentType.message => Icons.article_rounded,
      LinkContentType.comment => Icons.chat_bubble_outline_rounded,
      LinkContentType.user => Icons.person_rounded,
      LinkContentType.post => Icons.description_rounded,
      LinkContentType.anchor => Icons.tag_rounded, // 锚点使用 tag 图标
    };
  }

  /// 获取内容类型标签
  String _getTypeLabel(LinkContentType type) {
    return switch (type) {
      LinkContentType.channel => '频道',
      LinkContentType.message => '消息',
      LinkContentType.comment => '评论',
      LinkContentType.user => '用户',
      LinkContentType.post => '帖子',
      LinkContentType.anchor => '锚点',
    };
  }

  /// 获取内容类型标签（用于显示文本）
  String _getContentTypeLabel(LinkContentType type) {
    return switch (type) {
      LinkContentType.comment => '评论',
      LinkContentType.message => '消息',
      LinkContentType.post => '帖子',
      _ => '内容',
    };
  }
}
