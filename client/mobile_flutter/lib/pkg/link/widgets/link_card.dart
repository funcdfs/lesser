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
  String _getTypeLabel(LinkContentType type) {
    switch (type) {
      case LinkContentType.channel:
        return '频道';
      case LinkContentType.message:
        return '消息';
      case LinkContentType.comment:
        return '评论';
      case LinkContentType.user:
        return '用户';
      case LinkContentType.post:
        return '帖子';
    }
  }

  /// 获取内容类型标签（用于显示文本）
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
