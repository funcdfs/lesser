// =============================================================================
// 剧集列表项组件 - Premium Subject Item
// =============================================================================
//
// 以“消息/话题”风格显示剧集，包含头像、标题、内容预览、统计信息。
//
// ## 设计美学
// - 采用左侧头像引导，右侧内容展开的平衡布局
// - 高密度设计：缩减边距，合并统计信息到元数据行
// - 元数据（点赞、浏览、评论）使用彩色微图标
// - 话题标签（Tags）使用浅背景胶囊（Chip）样式
//
// =============================================================================

import 'package:flutter/material.dart';
import '../../../pkg/ui/effects/effects.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../../../pkg/utils/format_utils.dart';
import '../models/subject_models.dart';
import '../data_access/mock/subject_mock_data.dart';

/// 剧集列表项 - プレミアム话题展示
class SubjectItem extends StatelessWidget {
  const SubjectItem({
    super.key,
    required this.subject,
    this.uiState,
    this.onTap,
  });

  final SubjectModel subject;
  final SubjectUIState? uiState;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final unreadCount = uiState?.unreadCount ?? 0;

    return TapScale(
      onTap: onTap,
      scale: TapScales.card,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 列表项容器 (Card Container)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.divider.withValues(alpha: 0.08), width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: colors.textPrimary.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatar(colors),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(colors),
                        const SizedBox(height: 3),
                        _buildLastMessage(colors),
                        const SizedBox(height: 8),
                        _buildFooter(colors),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 3. 右上角未读数 (Unread Badge at Top-Right)
          if (unreadCount > 0)
            Positioned(
              top: 0,
              right: 8,
              child: _buildUnreadBadge(unreadCount, colors),
            ),
        ],
      ),
    );
  }

  Widget _buildUnreadBadge(int count, AppColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          height: 1,
        ),
      ),
    );
  }

  Widget _buildAvatar(AppColorScheme colors) {
    final hasCover = subject.coverUrl != null && subject.coverUrl!.isNotEmpty;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: colors.surfaceBase,
        borderRadius: BorderRadius.circular(12),
        image: hasCover
            ? DecorationImage(image: NetworkImage(subject.coverUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: !hasCover
          ? Icon(Icons.movie_filter_rounded, color: colors.textDisabled)
          : null,
    );
  }

  Widget _buildHeader(AppColorScheme colors) {
    final descriptionPrefix = subject.description?.split('\n').first ?? '';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          subject.title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
            letterSpacing: -0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (descriptionPrefix.isNotEmpty) ...[
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              descriptionPrefix,
              style: TextStyle(
                fontSize: 12,
                color: colors.textTertiary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLastMessage(AppColorScheme colors) {
    return Text(
      subject.lastPostPreview ?? '暂无动态',
      style: TextStyle(
        fontSize: 13.5,
        color: colors.textSecondary,
        height: 1.4,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter(AppColorScheme colors) {
    final tags = subject.tags.take(2).map((id) {
      return mockSubjectTags.firstWhere(
        (t) => t.id == id,
        orElse: () => SubjectTag(id: id, name: id),
      );
    }).toList();

    return Row(
      children: [
        if (tags.isNotEmpty)
          Expanded(
            child: Wrap(
              spacing: 6,
              children: tags.map((t) => _TagChip(tag: t, colors: colors)).toList(),
            ),
          ),
        const Spacer(),
        if (subject.lastPostTime != null)
          Text(
            formatTimeRelative(subject.lastPostTime!),
            style: TextStyle(
              fontSize: 11,
              color: colors.textTertiary,
            ),
          ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.tag, required this.colors});

  final SubjectTag tag;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.accentSoft.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '#${tag.name}',
        style: TextStyle(
          fontSize: 11,
          color: colors.accent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
