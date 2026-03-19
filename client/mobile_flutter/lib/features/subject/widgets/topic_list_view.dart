// =============================================================================
// 话题列表视图 - Discord 风格
// =============================================================================
//
// Discord 风格的话题列表，显示所有话题及其基本信息

import 'package:flutter/material.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../../../pkg/ui/effects/effects.dart';
import '../../../pkg/utils/format_utils.dart';
import '../models/subject_topic_model.dart';

/// 话题列表视图
class TopicListView extends StatelessWidget {
  const TopicListView({
    super.key,
    required this.topics,
    required this.onTopicTap,
  });

  final List<SubjectTopicModel> topics;
  final ValueChanged<SubjectTopicModel> onTopicTap;

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) {
      return const _EmptyTopicView();
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: FadeInAnim.startOpacity, end: FadeInAnim.endOpacity),
      duration: FadeInAnim.duration,
      curve: FadeInAnim.curve,
      builder: (context, opacity, child) {
        return Opacity(opacity: opacity, child: child);
      },
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: topics.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          return TopicItem(
            topic: topics[index],
            onTap: () => onTopicTap(topics[index]),
          );
        },
      ),
    );
  }
}

/// 话题列表项
class TopicItem extends StatelessWidget {
  const TopicItem({super.key, required this.topic, required this.onTap});

  final SubjectTopicModel topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TapScale(
      onTap: onTap,
      scale: TapScales.card,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.divider.withValues(alpha: isDark ? 0.12 : 0.06),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.textPrimary.withValues(alpha: isDark ? 0.08 : 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 话题图标
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.interactive.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.tag_rounded,
                    size: 20,
                    color: colors.interactive,
                  ),
                ),
                const SizedBox(width: 12),
                // 话题标题和状态
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (topic.isPinned) ...[
                            Icon(
                              Icons.push_pin_rounded,
                              size: 14,
                              color: colors.accent,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              topic.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (topic.isLocked)
                            Icon(
                              Icons.lock_rounded,
                              size: 14,
                              color: colors.textDisabled,
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        topic.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 底部信息
            Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 14,
                  color: colors.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${topic.postCount} 条消息',
                  style: TextStyle(fontSize: 12, color: colors.textTertiary),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: colors.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  formatTimeRelative(topic.lastPostTime),
                  style: TextStyle(fontSize: 12, color: colors.textTertiary),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: colors.textTertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 空话题视图
class _EmptyTopicView extends StatelessWidget {
  const _EmptyTopicView();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.topic_rounded, size: 64, color: colors.textDisabled),
          const SizedBox(height: 16),
          Text(
            '暂无话题',
            style: TextStyle(fontSize: 16, color: colors.textTertiary),
          ),
        ],
      ),
    );
  }
}
