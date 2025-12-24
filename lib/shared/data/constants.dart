/// 应用全局常量定义
///
/// 说明：此文件集中声明了应用内可复用的常量，包含文本标签、
/// 动画时长、UI 尺寸、路由和功能开关等。统一管理有助于
/// 维护一致性、方便 i18n 与后续修改。
class AppConstants {
  // ==================== 文本常量 ====================
  /// 「更多」按钮文本
  static const String labelMore = '更多';

  /// 「分享」按钮文本
  static const String labelShare = '分享';

  /// 「删除」按钮文本
  static const String labelDelete = '删除';

  /// 「举报」按钮文本
  static const String labelReport = '举报';

  /// 展开全文按钮文本
  static const String labelReadMore = '全文';

  /// 折叠收起按钮文本
  static const String labelReadLess = '收起';

  /// 无评论提示文本
  static const String labelNoComments = '暂无评论';

  /// 加载更多提示文本
  static const String labelLoadMore = '加载更多';

  // ==================== 动画时长 ====================
  /// 短动画（用于微交互）
  static const Duration animationDurationShort = Duration(milliseconds: 200);

  /// 中等时长动画
  static const Duration animationDurationMedium = Duration(milliseconds: 400);

  /// 长动画（如点赞特效）
  static const Duration animationDurationLong = Duration(milliseconds: 600);

  // ==================== UI 相关常量 ====================
  /// 帖子图片最大显示数量（防止无限制展示）
  static const int maxImageDisplayCount = 50;

  /// 帖子默认折叠时最大显示行数
  static const int defaultPostMaxLines = 3;

  /// 帖子图片默认高度
  static const double defaultPostImageHeight = 300;

  /// 图片轮播单项宽度
  static const double postCardImageCarouselWidth = 250;

  /// 图片轮播高度
  static const double postCardImageCarouselHeight = 300;

  // ==================== 布局断点 ====================
  /// 桌面布局最小宽度断点（>= 640 使用桌面布局）
  static const double desktopMinWidth = 640;

  /// 窄屏布局断点（< 280 视为窄屏）
  static const double narrowLayoutWidth = 280;

  /// 主内容最大宽度
  static const double maxContentWidth = 900;

  /// 侧边栏固定宽度
  static const double sidebarWidth = 88;

  // ==================== 时间单位（秒） ====================
  static const int minuteInSeconds = 60;
  static const int hourInSeconds = 3600;
  static const int dayInSeconds = 86400;
  static const int weekInSeconds = 604800;
  static const int monthInSeconds = 2592000; // 30天
  static const int yearInSeconds = 31536000; // 365天
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
