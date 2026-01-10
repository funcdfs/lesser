// 年历选择页面

import 'package:flutter/material.dart';
import '../../../pkg/ui/effects/effects.dart';
import '../../../pkg/ui/theme/theme.dart';

/// 年历选择页面
///
/// 显示从最早消息日期到当前日期的完整年历，
/// 有消息的日期会高亮显示，点击可跳转到对应日期的消息。
class YearCalendarPage extends StatefulWidget {
  const YearCalendarPage({
    super.key,
    required this.initialDate,
    required this.messageDates,
    required this.onDateSelected,
  });

  final DateTime initialDate;
  final Set<DateTime> messageDates;
  final ValueChanged<DateTime> onDateSelected;

  @override
  State<YearCalendarPage> createState() => _YearCalendarPageState();
}

class _YearCalendarPageState extends State<YearCalendarPage> {
  late ScrollController _scrollController;
  late int _startYear;
  late int _endYear;

  // 每个月的 key，用于定位
  final Map<String, GlobalKey> _monthKeys = {};

  late int _endMonth; // 结束月份（当前月）

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // 计算年份范围：从最早消息到当前
    final now = DateTime.now();
    _endYear = now.year;
    _endMonth = now.month;

    if (widget.messageDates.isNotEmpty) {
      final earliest = widget.messageDates.reduce(
        (a, b) => a.isBefore(b) ? a : b,
      );
      _startYear = earliest.year;
    } else {
      _startYear = widget.initialDate.year;
    }

    // 确保至少显示 2 年
    if (_endYear - _startYear < 1) {
      _startYear = _endYear - 1;
    }

    // 生成月份 keys（只到当前月份）
    for (int year = _startYear; year <= _endYear; year++) {
      final maxMonth = (year == _endYear) ? _endMonth : 12;
      for (int month = 1; month <= maxMonth; month++) {
        _monthKeys['$year-$month'] = GlobalKey();
      }
    }

    // 延迟滚动到初始日期
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollToDate(widget.initialDate);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToDate(DateTime date) {
    final key = _monthKeys['${date.year}-${date.month}'];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        alignment: 0.3,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  /// 计算总月份数（只到当前月份）
  int _calculateTotalMonths() {
    if (_startYear == _endYear) {
      return _endMonth;
    }
    // 第一年的月份 + 中间年份 * 12 + 最后一年的月份
    const firstYearMonths = 12;
    final middleYears = _endYear - _startYear - 1;
    final lastYearMonths = _endMonth;
    return firstYearMonths + middleYears * 12 + lastYearMonths;
  }

  /// 根据索引获取年月
  (int, int) _getYearMonthFromIndex(int index) {
    int year = _startYear;
    int remaining = index;

    while (remaining >= 12 && year < _endYear) {
      remaining -= 12;
      year++;
    }

    // 最后一年只有 _endMonth 个月
    if (year == _endYear && remaining >= _endMonth) {
      remaining = _endMonth - 1;
    }

    return (year, remaining + 1);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.surfaceBase,
      appBar: AppBar(
        backgroundColor: colors.surfaceNav,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '日期',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 星期标题行
          _buildWeekdayHeader(colors),
          // 月份列表
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 32),
              itemCount: _calculateTotalMonths(),
              itemBuilder: (context, index) {
                final yearMonth = _getYearMonthFromIndex(index);
                return _buildMonthView(yearMonth.$1, yearMonth.$2, colors);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 星期标题行
  Widget _buildWeekdayHeader(AppColorScheme colors) {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: weekdays.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colors.textTertiary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 构建月份视图
  Widget _buildMonthView(int year, int month, AppColorScheme colors) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    // 周一为 1，周日为 7
    final startWeekday = firstDay.weekday;

    return Column(
      key: _monthKeys['$year-$month'],
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 月份标题
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 12),
          child: Text(
            '$month月 $year',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
        ),
        // 日期网格
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemCount: daysInMonth + startWeekday - 1,
          itemBuilder: (context, index) {
            // 填充空白
            if (index < startWeekday - 1) {
              return const SizedBox.shrink();
            }

            final day = index - startWeekday + 2;
            final date = DateTime(year, month, day);
            final dateOnly = DateTime(date.year, date.month, date.day);

            // 是否有消息
            final hasMessage = widget.messageDates.contains(dateOnly);
            // 是否是今天
            final isToday = dateOnly == today;
            // 是否是选中日期
            final isSelected =
                dateOnly ==
                DateTime(
                  widget.initialDate.year,
                  widget.initialDate.month,
                  widget.initialDate.day,
                );
            // 是否是未来日期
            final isFuture = dateOnly.isAfter(today);

            final canTap = !isFuture && hasMessage;
            final cell = _buildDayCell(
              day: day,
              hasMessage: hasMessage,
              isToday: isToday,
              isSelected: isSelected,
              isFuture: isFuture,
              colors: colors,
            );

            // 只有可点击的日期才添加缩放效果
            if (canTap) {
              return TapScale(
                onTap: () => widget.onDateSelected(date),
                scale: TapScales.small,
                child: cell,
              );
            }
            return cell;
          },
        ),
      ],
    );
  }

  /// 构建日期单元格
  Widget _buildDayCell({
    required int day,
    required bool hasMessage,
    required bool isToday,
    required bool isSelected,
    required bool isFuture,
    required AppColorScheme colors,
  }) {
    Color textColor;
    Color? bgColor;
    FontWeight fontWeight = FontWeight.normal;

    if (isFuture) {
      textColor = colors.textDisabled;
    } else if (hasMessage) {
      textColor = colors.accent;
      fontWeight = FontWeight.w600;
      if (isSelected) {
        bgColor = colors.accentSoft;
      }
    } else {
      textColor = colors.textTertiary;
    }

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Center(
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: 14,
            fontWeight: fontWeight,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
