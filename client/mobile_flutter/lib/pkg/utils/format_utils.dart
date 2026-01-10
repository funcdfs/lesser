// 格式化工具函数
//
// 提供统一的时间、数量等格式化方法

// ============================================================================
// 时间格式化
// ============================================================================

/// 格式化时间 - 相对时间（刚刚、X分钟前、昨天等）
String formatTimeRelative(DateTime time) {
  final now = DateTime.now();
  final diff = now.difference(time);

  if (diff.inMinutes < 1) return '刚刚';
  if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
  if (diff.inHours < 24 && time.day == now.day) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
  // 使用 subtract 避免月初边界问题
  final yesterday = DateTime(
    now.year,
    now.month,
    now.day,
  ).subtract(const Duration(days: 1));
  final timeDate = DateTime(time.year, time.month, time.day);
  if (timeDate.year == yesterday.year &&
      timeDate.month == yesterday.month &&
      timeDate.day == yesterday.day) {
    return '昨天';
  }
  if (diff.inDays < 7) return '${diff.inDays}天前';
  if (time.year == now.year) return '${time.month}/${time.day}';
  return '${time.year}/${time.month}/${time.day}';
}

/// 格式化时间 - 仅时分（HH:mm）
String formatTimeHHmm(DateTime time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

/// 格式化时间 - 聊天列表样式
/// - 今天：显示时间 (HH:mm)
/// - 昨天：显示"昨天"
/// - 本周：显示星期几
/// - 今年：显示 X 月 X 日
/// - 更早：显示 X 年 X 月 X 日
String formatTimeChatList(DateTime time) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final timeDate = DateTime(time.year, time.month, time.day);
  final diffDays = today.difference(timeDate).inDays;

  if (diffDays == 0) {
    // 今天：显示时间
    return formatTimeHHmm(time);
  } else if (diffDays == 1) {
    return '昨天';
  } else if (diffDays < 7) {
    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return weekdays[time.weekday - 1];
  } else if (time.year == now.year) {
    // 今年：X 月 X 日
    return '${time.month} 月 ${time.day} 日';
  } else {
    // 更早：X 年 X 月 X 日
    return '${time.year} 年 ${time.month} 月 ${time.day} 日';
  }
}

/// 格式化日期 - 中文格式（今天、昨天、前天、X 月 X 日、X 年 X 月 X 日）
String formatDateChinese(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dateOnly = DateTime(date.year, date.month, date.day);
  final diff = today.difference(dateOnly).inDays;

  if (diff == 0) {
    return '今天';
  } else if (diff == 1) {
    return '昨天';
  } else if (diff == 2) {
    return '前天';
  } else if (date.year == now.year) {
    return '${date.month} 月 ${date.day} 日';
  } else {
    return '${date.year} 年 ${date.month} 月 ${date.day} 日';
  }
}

// ============================================================================
// 数量格式化
// ============================================================================

/// 格式化数量 - 中文风格（w 表示万）
String formatCountChinese(int count) {
  if (count < 0) return '-${formatCountChinese(-count)}';
  if (count >= 10000) return '${(count / 10000).toStringAsFixed(1)}w';
  if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
  return count.toString();
}

/// 格式化数量 - 英文风格（K 表示千）
String formatCountEnglish(int count) {
  if (count < 0) return '-${formatCountEnglish(-count)}';
  if (count >= 1000) {
    return '${(count / 1000).toStringAsFixed(count >= 10000 ? 0 : 1)}K';
  }
  return count.toString();
}

/// 格式化订阅者数量 - 中文风格（万）
String formatSubscriberCount(int count) {
  if (count >= 100000000) {
    // 1 亿以上
    return '${(count / 100000000).toStringAsFixed(1)}亿';
  } else if (count >= 10000) {
    return '${(count / 10000).toStringAsFixed(1)}万';
  }
  return count.toString();
}

// ============================================================================
// 文本处理
// ============================================================================

/// 截断文本
String truncateText(String text, int maxLength) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength)}...';
}
