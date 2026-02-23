import 'package:flutter/material.dart';
import '../../../../pkg/ui/effects/effects.dart';
import '../../../../pkg/ui/theme/theme.dart';

class TrackerTimeline extends StatelessWidget {
  const TrackerTimeline({super.key});

  static const _activities = [
    (
      title: 'Watched Scavengers Reign',
      subtitle: 'S1 · E2  "The Storm"',
      time: '2h ago',
      action: 'Watched',
      seed: 51,
    ),
    (
      title: 'Added to Watchlist',
      subtitle: 'The Last of Us · HBO',
      time: 'Yesterday',
      action: 'Saved',
      seed: 53,
    ),
    (
      title: 'Rated Breaking Bad',
      subtitle: '★★★★★  "Masterpiece"',
      time: '2 days ago',
      action: 'Rated',
      seed: 55,
    ),
    (
      title: 'Started Severance',
      subtitle: 'S1 · E1  "Good News About Hell"',
      time: 'Last week',
      action: 'Watching',
      seed: 57,
    ),
    (
      title: 'Finished Arcane S2',
      subtitle: 'Netflix Original · 9 Episodes',
      time: '2 weeks ago',
      action: 'Finished',
      seed: 59,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 区域标题
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_activities.length} events',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // 列表
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: _activities.asMap().entries.map((entry) {
                final i = entry.key;
                final act = entry.value;
                return _TimelineItem(
                  isLast: i == _activities.length - 1,
                  title: act.title,
                  subtitle: act.subtitle,
                  time: act.time,
                  action: act.action,
                  imageIndex: act.seed,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.isLast,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.action,
    required this.imageIndex,
  });

  final bool isLast;
  final String title;
  final String subtitle;
  final String time;
  final String action;
  final int imageIndex;

  Color _actionColor(AppColorScheme colors) {
    switch (action) {
      case 'Watched':
      case 'Finished':
        return colors.accent;
      case 'Saved':
        return const Color(0xFF7EB89A);
      case 'Rated':
        return const Color(0xFFD4A056);
      case 'Watching':
        return const Color(0xFF5B8EC9);
      default:
        return colors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final ac = _actionColor(colors);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 时间线
          SizedBox(
            width: 20,
            child: Column(
              children: [
                const SizedBox(height: 18),
                // 圆点
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: ac,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ac.withValues(alpha: 0.35),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: colors.divider,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // 内容卡片
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TapScale(
                onTap: () {},
                scale: TapScales.small,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colors.divider,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      // 海报缩略图
                      ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Image.network(
                          'https://picsum.photos/seed/$imageIndex/80/120',
                          width: 38,
                          height: 54,
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              width: 38,
                              height: 54,
                              decoration: BoxDecoration(
                                color: colors.accentSoft,
                                borderRadius: BorderRadius.circular(7),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => Container(
                            width: 38,
                            height: 54,
                            decoration: BoxDecoration(
                              color: colors.accentSoft,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Icon(
                              Icons.movie_outlined,
                              size: 16,
                              color: colors.accent.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // 文字信息
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 行为标签
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: ac.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                action,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: ac,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                                letterSpacing: -0.1,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: colors.textTertiary,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              time,
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.textDisabled,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
