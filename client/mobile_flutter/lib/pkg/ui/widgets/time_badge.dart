// 时间徽章组件

import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../../utils/format_utils.dart';

/// 时间徽章 - 精致的时间展示
///
/// - 今天：只显示时间 (14:30)
/// - 昨天：🕐 昨天
/// - 本周：📅 周三
/// - 今年：📆 1 月 8 日
/// - 更早：📆 2024 年 12 月 25 日
class TimeBadge extends StatelessWidget {
  const TimeBadge({
    super.key,
    required this.time,
    this.size = TimeBadgeSize.small,
  });

  final DateTime time;
  final TimeBadgeSize size;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final config = size._config;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final timeDate = DateTime(time.year, time.month, time.day);
    final diffDays = today.difference(timeDate).inDays;

    // 今天：只显示时间
    if (diffDays == 0) {
      return Text(
        formatTimeHHmm(time),
        style: TextStyle(fontSize: config.fontSize, color: colors.textTertiary),
      );
    }

    // 昨天/本周/更早：显示带图标的日期
    final (icon, text) = _getIconAndText(diffDays, time, now);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: config.iconSize, color: colors.textDisabled),
        SizedBox(width: config.spacing),
        Text(
          text,
          style: TextStyle(
            fontSize: config.fontSize,
            color: colors.textTertiary,
          ),
        ),
      ],
    );
  }

  (IconData, String) _getIconAndText(
    int diffDays,
    DateTime time,
    DateTime now,
  ) {
    if (diffDays == 1) {
      return (Icons.history_rounded, '昨天');
    } else if (diffDays < 7) {
      const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      return (Icons.calendar_today_rounded, weekdays[time.weekday - 1]);
    } else if (time.year == now.year) {
      return (Icons.event_rounded, '${time.month} 月 ${time.day} 日');
    } else {
      return (
        Icons.event_rounded,
        '${time.year} 年 ${time.month} 月 ${time.day} 日',
      );
    }
  }
}

/// 时间徽章尺寸
enum TimeBadgeSize {
  small(_TimeBadgeConfig(fontSize: 11, iconSize: 10, spacing: 2)),
  medium(_TimeBadgeConfig(fontSize: 12, iconSize: 11, spacing: 3));

  const TimeBadgeSize(this._config);
  final _TimeBadgeConfig _config;
}

class _TimeBadgeConfig {
  const _TimeBadgeConfig({
    required this.fontSize,
    required this.iconSize,
    required this.spacing,
  });

  final double fontSize;
  final double iconSize;
  final double spacing;
}
