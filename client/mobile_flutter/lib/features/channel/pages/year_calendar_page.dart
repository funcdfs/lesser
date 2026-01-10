// =============================================================================
// 年历选择页面 - Year Calendar Page
// =============================================================================
//
// ## 设计目的
// 提供完整的年历视图，用于在频道消息中快速定位到指定日期。
// 有消息的日期会高亮显示，点击可跳转到对应日期的消息。
//
// ## 视觉设计
// - 顶部固定星期标题行
// - 按月份分组显示日期网格
// - 有消息的日期使用强调色
// - 今天使用边框标识
// - 选中日期使用柔和背景色
// - 未来日期使用禁用色
//
// ## 性能优化
// - 使用 ListView.builder 懒加载月份
// - 月份 GlobalKey 懒加载，仅在需要时创建
// - 使用 Wrap 替代 GridView 避免嵌套滚动性能问题
// - 只渲染到当前月份，不渲染未来月份
//
// ## 交互设计
// - 页面打开时自动滚动到初始日期所在月份
// - 点击有消息的日期触发回调并关闭页面
// - 未来日期和无消息日期不可点击
//
// =============================================================================

import 'package:flutter/material.dart';
import '../../../pkg/ui/effects/effects.dart';
import '../../../pkg/ui/theme/theme.dart';

/// 年历选择页面
///
/// 显示从最早消息日期到当前日期的完整年历，
/// 有消息的日期会高亮显示，点击可跳转到对应日期的消息。
///
/// ## 参数说明
/// - [initialDate]: 初始选中日期（页面打开时滚动到此日期）
/// - [messageDates]: 有消息的日期集合（用于高亮显示）
/// - [onDateSelected]: 日期选择回调
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
  late int _startYear; // 起始年份（最早消息所在年）
  late int _endYear; // 结束年份（当前年）
  late int _endMonth; // 结束月份（当前月）

  // 月份 GlobalKey 懒加载缓存
  // 仅在需要滚动定位时创建，避免预先创建大量 Key
  final Map<String, GlobalKey> _monthKeys = {};

  /// 获取或创建指定年月的 GlobalKey（懒加载）
  GlobalKey _getMonthKey(int year, int month) {
    final key = '$year-$month';
    return _monthKeys.putIfAbsent(key, () => GlobalKey());
  }

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
    // 使用懒加载方式获取 key
    final key = _getMonthKey(date.year, date.month);
    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        alignment: 0.3,
        duration: AnimDurations.slow,
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
    final totalCells = daysInMonth + startWeekday - 1;

    return Column(
      key: _getMonthKey(year, month),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 月份标题
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 12),
          child: Text(
            '$year年$month月',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
        ),
        // 日期网格 - 使用 Wrap 替代 GridView 避免嵌套滚动性能问题
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _MonthGrid(
            year: year,
            month: month,
            daysInMonth: daysInMonth,
            startWeekday: startWeekday,
            totalCells: totalCells,
            today: today,
            initialDate: widget.initialDate,
            messageDates: widget.messageDates,
            onDateSelected: widget.onDateSelected,
          ),
        ),
      ],
    );
  }
}

/// 月份日期网格组件
///
/// 使用 Wrap 替代 GridView，避免嵌套滚动带来的性能问题。
/// 每个月份的日期按 7 列排列，周一为第一列。
///
/// ## 日期状态
/// - hasMessage: 有消息，使用强调色，可点击
/// - isToday: 今天，使用边框标识
/// - isSelected: 选中日期，使用柔和背景色
/// - isFuture: 未来日期，使用禁用色，不可点击
class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.year,
    required this.month,
    required this.daysInMonth,
    required this.startWeekday,
    required this.totalCells,
    required this.today,
    required this.initialDate,
    required this.messageDates,
    required this.onDateSelected,
  });

  final int year;
  final int month;
  final int daysInMonth;
  final int startWeekday;
  final int totalCells;
  final DateTime today;
  final DateTime initialDate;
  final Set<DateTime> messageDates;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 计算每个单元格的宽度（7 列）
        final cellWidth = constraints.maxWidth / 7;

        return Wrap(
          children: List.generate(totalCells, (index) {
            // 填充空白
            if (index < startWeekday - 1) {
              return SizedBox(width: cellWidth, height: cellWidth);
            }

            final day = index - startWeekday + 2;
            final date = DateTime(year, month, day);
            final dateOnly = DateTime(date.year, date.month, date.day);

            // 是否有消息
            final hasMessage = messageDates.contains(dateOnly);
            // 是否是今天
            final isToday = dateOnly == today;
            // 是否是选中日期
            final isSelected =
                dateOnly ==
                DateTime(initialDate.year, initialDate.month, initialDate.day);
            // 是否是未来日期
            final isFuture = dateOnly.isAfter(today);

            final canTap = !isFuture && hasMessage;
            final cell = _DayCell(
              day: day,
              hasMessage: hasMessage,
              isToday: isToday,
              isSelected: isSelected,
              isFuture: isFuture,
              size: cellWidth,
            );

            // 只有可点击的日期才添加缩放效果
            if (canTap) {
              return TapScale(
                onTap: () => onDateSelected(date),
                scale: TapScales.small,
                child: cell,
              );
            }
            return cell;
          }),
        );
      },
    );
  }
}

/// 日期单元格组件
///
/// 根据日期状态显示不同的样式：
/// - 有消息：强调色文字，可点击
/// - 今天：边框标识
/// - 选中：柔和背景色
/// - 未来：禁用色文字
class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.hasMessage,
    required this.isToday,
    required this.isSelected,
    required this.isFuture,
    required this.size,
  });

  final int day;
  final bool hasMessage;
  final bool isToday;
  final bool isSelected;
  final bool isFuture;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    Color textColor;
    Color? bgColor;
    FontWeight fontWeight = FontWeight.normal;
    Border? border;

    if (isFuture) {
      textColor = colors.textDisabled;
    } else if (isToday) {
      // 今天：使用边框标识
      textColor = hasMessage ? colors.accent : colors.textSecondary;
      fontWeight = FontWeight.w600;
      border = Border.all(color: colors.accent, width: 1.5);
      if (isSelected && hasMessage) {
        bgColor = colors.accentSoft;
      }
    } else if (hasMessage) {
      textColor = colors.accent;
      fontWeight = FontWeight.w600;
      if (isSelected) {
        bgColor = colors.accentSoft;
      }
    } else {
      textColor = colors.textTertiary;
    }

    return SizedBox(
      width: size,
      height: size,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: border,
        ),
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
      ),
    );
  }
}
