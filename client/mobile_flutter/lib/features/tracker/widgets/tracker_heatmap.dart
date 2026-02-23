import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../pkg/ui/theme/theme.dart';

class TrackerHeatmap extends StatelessWidget {
  const TrackerHeatmap({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    const int weeks = 18;
    const int daysOffset = 3;

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.accentSoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Feb 2026',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colors.accentText,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Streak 条
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 12.5,
                  color: colors.textTertiary,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: '18 episodes this month  ·  '),
                  TextSpan(
                    text: '3-day streak ',
                    style: TextStyle(
                      color: colors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: '🔥'),
                ],
              ),
            ),
          ),

          // 热力图主体
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 星期标签列（精确对齐）
                SizedBox(
                  width: 28,
                  child: Column(
                    children: [
                      _dayLabel('Mon', colors, topOffset: 0),
                      _dayLabel('Wed', colors, topOffset: 32),
                      _dayLabel('Fri', colors, topOffset: 32),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                // 格子矩阵
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(weeks, (col) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 3),
                      child: Column(
                        children: List.generate(7, (row) {
                          final isFuture =
                              col == weeks - 1 && row > daysOffset;
                          final rand =
                              Random(col * 7 + row).nextDouble();

                          Color fill;
                          if (isFuture) {
                            fill = Colors.transparent;
                          } else if (rand > 0.82) {
                            fill = colors.accent;
                          } else if (rand > 0.64) {
                            fill = colors.accent.withValues(alpha: 0.55);
                          } else if (rand > 0.46) {
                            fill = colors.accent.withValues(alpha: 0.22);
                          } else {
                            fill = colors.surfaceElevated;
                          }

                          return Container(
                            width: 11,
                            height: 11,
                            margin: const EdgeInsets.only(bottom: 3),
                            decoration: BoxDecoration(
                              color: isFuture ? Colors.transparent : fill,
                              borderRadius: BorderRadius.circular(2.5),
                              border: isFuture
                                  ? null
                                  : Border.all(
                                      color:
                                          colors.divider.withValues(alpha: 0.5),
                                      width: 0.5,
                                    ),
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // 图例
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Less',
                  style: TextStyle(
                    fontSize: 10,
                    color: colors.textDisabled,
                  ),
                ),
                const SizedBox(width: 5),
                ...[ 
                  colors.surfaceElevated,
                  colors.accent.withValues(alpha: 0.22),
                  colors.accent.withValues(alpha: 0.55),
                  colors.accent,
                ].map(
                  (c) => Container(
                    width: 9,
                    height: 9,
                    margin: const EdgeInsets.only(left: 3),
                    decoration: BoxDecoration(
                      color: c,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        color: colors.divider.withValues(alpha: 0.5),
                        width: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'More',
                  style: TextStyle(
                    fontSize: 10,
                    color: colors.textDisabled,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// 星期标签（带精确顶部偏移）
  Widget _dayLabel(String label, AppColorScheme colors,
      {required double topOffset}) {
    return Padding(
      padding: EdgeInsets.only(top: topOffset),
      child: SizedBox(
        height: 14,
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              color: colors.textTertiary,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
    );
  }
}
