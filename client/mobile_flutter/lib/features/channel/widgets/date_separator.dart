// 日期分隔符组件

import 'package:flutter/material.dart';
import '../../../pkg/ui/effects/tap_scale.dart';
import '../../../pkg/ui/animation/animation.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../../../pkg/utils/format_utils.dart';
import 'year_calendar_page.dart';

/// 日期分隔符
///
/// 居中胶囊样式，点击可打开年历选择器跳转到指定日期。
class DateSeparator extends StatelessWidget {
  const DateSeparator({
    super.key,
    required this.date,
    this.messageDates,
    this.onDateSelected,
  });

  final DateTime date;

  /// 有消息的日期列表（用于年历高亮）
  final Set<DateTime>? messageDates;

  /// 日期选择回调
  final ValueChanged<DateTime>? onDateSelected;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: TapScale(
          onTap: () => _showYearCalendar(context),
          scale: TapScales.medium,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: colors.accentSoft.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              formatDateChinese(date),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colors.accent,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 显示年历选择器
  void _showYearCalendar(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            YearCalendarPage(
              initialDate: date,
              messageDates: messageDates ?? {},
              onDateSelected: (selectedDate) {
                Navigator.of(context).pop();
                onDateSelected?.call(selectedDate);
              },
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: AnimCurves.standard,
                  ),
                ),
            child: child,
          );
        },
        transitionDuration: AnimDurations.slow,
      ),
    );
  }
}
