import '../data/constants.dart';

/// 时间格式化工具类
///
/// 提供常用的相对/绝对时间格式化方法，统一应用内时间显示风格。
/// - 相对时间：如“刚刚 / 5分钟前 / 2小时前 / 3天前”
/// - 绝对时间：如“昨天 14:05 / 4月5日 09:30 / 2024年1月15日”
class TimeFormatter {
  /// 返回相对时间字符串（示例："刚刚"、"5分钟前"、"2小时前"）
  ///
  /// 规则：小于一分钟 => 刚刚；小于一小时 => x 分钟前；小于一天 => x 小时前；
  /// 小于一周 => x 天前；小于一月 => x 周前；小于一年 => x 个月前；否则 x 年前。
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
  /// 获取绝对时间字符串
  ///
  /// - 如果是今天：只显示时间（HH:mm）
  /// - 如果是昨天：显示 "昨天 HH:mm"
  /// - 如果是同年：显示 "M月D日 HH:mm"
  /// - 如果不是同年：显示 "YYYY年M月D日"
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
  /// 将时间格式化为 HH:mm 字符串
  static String _formatTimeOfDay(DateTime dateTime) {
    final hour = _padZero(dateTime.hour);
    final minute = _padZero(dateTime.minute);
    return '$hour:$minute';
  }

  /// 补零辅助方法
  /// 为小于10的数字补零，例如 9 -> "09"
  static String _padZero(int value) {
    return value.toString().padLeft(2, '0');
  }

  /// 获取简化的日期显示 (用于列表展示)
  /// 简化日期显示：今天显示时间，昨天显示"昨天"，同年显示"M/D"，否则显示"YYYY/M/D"
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
  /// 返回从指定时间到现在的毫秒差
  static int getMillisecondsSinceNow(DateTime dateTime) {
    return DateTime.now().difference(dateTime).inMilliseconds;
  }

  /// 判断是否是今天
  /// 判断给定时间是否为今天
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
  /// 判断是否为本月
  static bool isThisMonth(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year && dateTime.month == now.month;
  }

  /// 判断是否是本年
  /// 判断是否为今年
  static bool isThisYear(DateTime dateTime) {
    return dateTime.year == DateTime.now().year;
  }
}
