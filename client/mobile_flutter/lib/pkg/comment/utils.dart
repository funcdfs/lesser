// 评论组件工具函数
//
// 重新导出公共工具函数，保持向后兼容

import 'dart:ui' show Color;

export '../utils/format_utils.dart'
    show formatCountChinese, formatTimeRelative, truncateText;
export '../ui/theme/app_theme.dart' show NameColors;

// 为了向后兼容，提供别名
import '../utils/format_utils.dart' as utils;
import '../ui/theme/app_theme.dart';

/// 格式化数量显示（向后兼容别名）
String formatCount(int count) => utils.formatCountChinese(count);

/// 格式化时间显示（向后兼容别名）
String formatTime(DateTime time) => utils.formatTimeRelative(time);

/// 根据 ID 获取用户名颜色（向后兼容别名）
Color getNameColor(String id) => NameColors.fromId(id);
