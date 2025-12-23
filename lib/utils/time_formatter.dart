import 'constants.dart';

/// 时间格式化工具类
class TimeFormatter {
  /// 获取相对时间字符串 (如 "2小时前", "3分钟前")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    final seconds = difference.inSeconds;

    if (seconds < AppConstants.minuteInSeconds) {
      return '刚刚';
    } else if (seconds < AppConstants.hourInSeconds) {
      final minutes = seconds ~/ AppConstants.minuteInSeconds;
      return '$minutes分钟前';
    } else if (seconds < AppConstants.dayInSeconds) {
      final hours = seconds ~/ AppConstants.hourInSeconds;
      return '$hours小时前';
    } else if (seconds < AppConstants.weekInSeconds) {
      final days = seconds ~/ AppConstants.dayInSeconds;
      return '$days天前';
    } else if (seconds < AppConstants.monthInSeconds) {
      final weeks = seconds ~/ AppConstants.weekInSeconds;
      return '$weeks周前';
    } else if (seconds < AppConstants.yearInSeconds) {
      final months = seconds ~/ AppConstants.monthInSeconds;
      return '$months个月前';
    } else {
      final years = seconds ~/ AppConstants.yearInSeconds;
      return '$years年前';
    }
  }

  /// 获取绝对时间字符串 (如 "2024年1月15日", "14:30")
  /// 今天显示时间，其他日期显示完整日期或简化格式
  static String formatAbsoluteTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateDay == today) {
      // 今天显示时间
      return _formatTimeOfDay(dateTime);
    } else if (dateDay.add(const Duration(days: 1)) == today) {
      // 昨天显示 "昨天 HH:mm"
      return '昨天 ${_formatTimeOfDay(dateTime)}';
    } else if (dateTime.year == now.year) {
      // 同年显示 "M月D日 HH:mm"
      return '${dateTime.month}月${dateTime.day}日 ${_formatTimeOfDay(dateTime)}';
    } else {
      // 不同年显示 "YYYY年M月D日"
      return '${dateTime.year}年${dateTime.month}月${dateTime.day}日';
    }
  }

  /// 格式化时间部分 (HH:mm 或 HH:mm:ss)
  static String _formatTimeOfDay(DateTime dateTime) {
    final hour = _padZero(dateTime.hour);
    final minute = _padZero(dateTime.minute);
    return '$hour:$minute';
  }

  /// 补零辅助方法
  static String _padZero(int value) {
    return value.toString().padLeft(2, '0');
  }

  /// 获取简化的日期显示 (用于列表展示)
  static String formatSimpleDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateDay == today) {
      return _formatTimeOfDay(dateTime);
    } else if (dateDay.add(const Duration(days: 1)) == today) {
      return '昨天';
    } else if (dateTime.year == now.year) {
      return '${dateTime.month}/${dateTime.day}';
    } else {
      return '${dateTime.year}/${dateTime.month}/${dateTime.day}';
    }
  }

  /// 获取时间戳距离现在的差值（毫秒）
  static int getMillisecondsSinceNow(DateTime dateTime) {
    return DateTime.now().difference(dateTime).inMilliseconds;
  }

  /// 判断是否是今天
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  /// 判断是否是昨天
  static bool isYesterday(DateTime dateTime) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day;
  }

  /// 判断是否是本周
  static bool isThisWeek(DateTime dateTime) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    return dateTime.isAfter(weekStart) && dateTime.isBefore(weekEnd);
  }

  /// 判断是否是本月
  static bool isThisMonth(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year && dateTime.month == now.month;
  }

  /// 判断是否是本年
  static bool isThisYear(DateTime dateTime) {
    return dateTime.year == DateTime.now().year;
  }
}
