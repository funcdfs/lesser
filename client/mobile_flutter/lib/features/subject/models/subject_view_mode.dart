// =============================================================================
// 剧集视图模式枚举
// =============================================================================
//
// 定义剧集详情页的两种视图模式：
// - Telegram 风格：纯消息流，按时间排序
// - Discord 风格：话题分组，每个话题内包含消息

/// 剧集视图模式
enum SubjectViewMode {
  /// Telegram 风格：纯消息流
  telegram,

  /// Discord 风格：话题分组
  discord,
}

/// 视图模式扩展方法
extension SubjectViewModeExtension on SubjectViewMode {
  /// 是否是 Discord 模式
  bool get isDiscord => this == SubjectViewMode.discord;

  /// 是否是 Telegram 模式
  bool get isTelegram => this == SubjectViewMode.telegram;

  /// 获取显示名称
  String get displayName {
    switch (this) {
      case SubjectViewMode.telegram:
        return 'Telegram 风格';
      case SubjectViewMode.discord:
        return 'Discord 风格';
    }
  }

  /// 获取图标
  String get icon {
    switch (this) {
      case SubjectViewMode.telegram:
        return '💬';
      case SubjectViewMode.discord:
        return '📋';
    }
  }
}
