// =============================================================================
// 日期分隔符组件 - Date Separator Widget
// =============================================================================
//
// ## 设计目的
// 在动态列表中显示日期分隔，帮助用户快速定位时间线。
// 点击可打开年历选择器，实现日期跳转功能。
//
// ## 视觉设计
// - 居中胶囊样式，使用强调色柔和背景
// - 中文日期格式（如"2025年1月8日"）
// - 点击时有缩放反馈效果
//
// ## 交互功能
// - 点击打开年历选择页面
// - 年历中高亮显示有动态的日期
// - 选择日期后回调通知父组件进行滚动定位
//
// ## 使用示例
// ```dart
// DateSeparator(
//   date: DateTime(2025, 1, 8),
//   messageDates: {DateTime(2025, 1, 8), DateTime(2025, 1, 7)},
//   onDateSelected: (date) => _scrollToDate(date),
// )
// ```
//
// =============================================================================

import 'package:flutter/material.dart';
import '../../../pkg/ui/effects/tap_scale.dart';
import '../../../pkg/ui/animation/animation.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../../../pkg/utils/format_utils.dart';
import '../pages/year_calendar_page.dart';
import 'subject_constants.dart';

/// 日期分隔符
///
/// 居中胶囊样式，点击可打开年历选择器跳转到指定日期。
///
/// ## 参数说明
/// - [date]: 当前分隔符显示的日期
/// - [messageDates]: 有动态的日期集合，用于年历高亮显示
/// - [onDateSelected]: 日期选择回调，用于通知父组件进行滚动定位
class DateSeparator extends StatelessWidget {
  const DateSeparator({
    super.key,
    required this.date,
    this.messageDates = const {},
    this.onDateSelected,
  });

  final DateTime date;

  /// 有动态的日期列表（用于年历高亮），默认为空集合
  final Set<DateTime> messageDates;

  /// 日期选择回调
  final ValueChanged<DateTime>? onDateSelected;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Padding(
      padding: DateSeparatorLayout.padding,
      child: Center(
        child: TapScale(
          onTap: () => _showYearCalendar(context),
          scale: TapScales.medium,
          child: Container(
            padding: DateSeparatorLayout.chipPadding,
            decoration: BoxDecoration(
              color: colors.accentSoft.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(
                DateSeparatorLayout.borderRadius,
              ),
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
  ///
  /// 使用自定义 PageRouteBuilder 实现从底部滑入的过渡动画。
  /// 动画参数从 YearCalendarAnim 常量类获取，保持一致性。
  void _showYearCalendar(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            YearCalendarPage(
              initialDate: date,
              messageDates: messageDates,
              onDateSelected: (selectedDate) {
                Navigator.of(context).pop();
                onDateSelected?.call(selectedDate);
              },
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: YearCalendarAnim.slideBegin,
                  end: YearCalendarAnim.slideEnd,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: AnimCurves.standard,
                  ),
                ),
            child: child,
          );
        },
        transitionDuration: YearCalendarAnim.transitionDuration,
      ),
    );
  }
}
