/// 应用全局常量定义
class AppConstants {
  // 文本常量
  static const String labelMore = '更多';
  static const String labelShare = '分享';
  static const String labelDelete = '删除';
  static const String labelReport = '举报';
  static const String labelReadMore = '全文';
  static const String labelReadLess = '收起';
  static const String labelNoComments = '暂无评论';
  static const String labelLoadMore = '加载更多';

  // 时间相关常量
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 400);
  static const Duration animationDurationLong = Duration(milliseconds: 600);

  // UI 相关常量
  static const int maxImageDisplayCount = 50;
  static const int defaultPostMaxLines = 3;
  static const double defaultPostImageHeight = 300;
  static const double postCardImageCarouselWidth = 250;
  static const double postCardImageCarouselHeight = 300;

  // 布局相关常量
  static const double desktopMinWidth = 640;
  static const double narrowLayoutWidth = 280;
  static const double maxContentWidth = 900;
  static const double sidebarWidth = 88;

  // 时间相关常量
  static const int minuteInSeconds = 60;
  static const int hourInSeconds = 3600;
  static const int dayInSeconds = 86400;
  static const int weekInSeconds = 604800;
  static const int monthInSeconds = 2592000;
  static const int yearInSeconds = 31536000;
}

/// 页面路由常量
class RouteConstants {
  static const String home = '/';
  static const String search = '/search';
  static const String post = '/post';
  static const String chat = '/chat';
  static const String profile = '/profile';
  static const String postDetail = '/post/:id';
}

/// 功能标志常量
class FeatureFlags {
  static const bool enablePostCreation = true;
  static const bool enableComments = true;
  static const bool enableSharing = true;
  static const bool enableBookmarking = true;
  static const bool enableDarkMode = false;
}
