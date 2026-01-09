// 评论组件工具函数

import 'package:flutter/material.dart';

/// 用户名颜色池
const _nameColors = [
  Color(0xFFD4726A),
  Color(0xFF6B9E78),
  Color(0xFF5B8EC9),
  Color(0xFFD4A056),
  Color(0xFF9B7BB8),
  Color(0xFF4AAFB8),
  Color(0xFFCB7A9E),
  Color(0xFF8BAD6E),
];

/// 根据 ID 获取用户名颜色
Color getNameColor(String id) {
  return _nameColors[id.hashCode.abs() % _nameColors.length];
}

/// 格式化数量显示
String formatCount(int count) {
  if (count >= 10000) return '${(count / 10000).toStringAsFixed(1)}w';
  if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
  return count.toString();
}

/// 格式化时间显示
String formatTime(DateTime time) {
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

/// 截断文本
String truncateText(String text, int maxLength) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength)}...';
}
