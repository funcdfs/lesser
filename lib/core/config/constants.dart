/// 全局常量配置
///
/// 负责：
/// - 尺寸常量
/// - 分页大小
/// - 环境配置
/// - API 基础配置
///
/// ❌ 不允许放业务字段（业务常量应在各 feature 内部定义）
class AppConstants {
  AppConstants._();

  // ============================================================================
  // 环境配置
  // ============================================================================

  /// 应用名称
  static const String appName = 'Lesser';

  /// 应用版本
  static const String appVersion = '1.0.0';

  /// 是否为生产环境
  static const bool isProduction = false;

  /// 是否为调试模式
  static const bool isDebugMode = !isProduction;

  // ============================================================================
  // API 配置
  // ============================================================================

  /// API 基础 URL
  static const String apiBaseUrl = 'https://api.example.com';

  /// 连接超时时间（毫秒）
  static const int connectTimeout = 30000;

  /// 请求超时时间（毫秒）
  static const int requestTimeout = 30000;

  /// 接收超时时间（毫秒）
  static const int receiveTimeout = 30000;

  // ============================================================================
  // 分页配置
  // ============================================================================

  /// 默认页大小（Feed 列表、评论列表等）
  static const int defaultPageSize = 20;

  /// Feed 列表页大小
  static const int feedPageSize = 20;

  /// 评论列表页大小
  static const int commentPageSize = 15;

  /// 好友列表页大小
  static const int friendsPageSize = 25;

  // ============================================================================
  // 缓存配置
  // ============================================================================

  /// 图片缓存有效期（天）
  static const int imageCacheDays = 30;

  /// 数据缓存有效期（小时）
  static const int dataCacheHours = 24;

  // ============================================================================
  // UI 尺寸配置
  // ============================================================================

  /// 最大内容宽度（用于平板和桌面端）
  static const double maxContentWidth = 1200;

  /// 侧边栏宽度（桌面端）
  static const double sidebarWidth = 300;

  /// 导航栏高度
  static const double navigationBarHeight = 56;

  /// 应用栏高度
  static const double appBarHeight = 56;

  // ============================================================================
  // 动画配置
  // ============================================================================

  /// 默认动画时长（毫秒）
  static const int defaultAnimationDuration = 300;

  /// 快速动画时长（毫秒）
  static const int fastAnimationDuration = 200;

  /// 慢速动画时长（毫秒）
  static const int slowAnimationDuration = 500;

  // ============================================================================
  // 验证规则
  // ============================================================================

  /// 用户名最小长度
  static const int usernameMinLength = 3;

  /// 用户名最大长度
  static const int usernameMaxLength = 20;

  /// 密码最小长度
  static const int passwordMinLength = 8;

  /// 邮箱最大长度
  static const int emailMaxLength = 255;

  /// Bio/描述最大长度
  static const int bioMaxLength = 160;

  /// 帖子标题最小长度
  static const int postTitleMinLength = 1;

  /// 帖子标题最大长度
  static const int postTitleMaxLength = 200;

  /// 帖子内容最大长度
  static const int postContentMaxLength = 5000;

  // ============================================================================
  // 限流配置
  // ============================================================================

  /// 发表评论的最小间隔（秒）
  static const int commentRateLimitSeconds = 1;

  /// 发表帖子的最小间隔（秒）
  static const int postRateLimitSeconds = 3;

  /// 点赞操作的最小间隔（毫秒）
  static const int likeRateLimitMs = 500;
}
