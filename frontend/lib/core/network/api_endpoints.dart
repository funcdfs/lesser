import '../config/constants.dart';

class ApiEndpoints {
  // 使用环境配置的API基础URL
  static String get baseUrl {
    // 根据环境自动选择API地址
    if (AppConstants.isProduction) {
      // 生产环境使用API Gateway地址
      return AppConstants.apiBaseUrl;
    } else {
      // 开发环境使用APISIX网关
      return 'http://127.0.0.1:9080/api';
    }
  }

  static const String health = '/health';
  static const String feeds = '/feeds/';

  // Authentication endpoints
  static const String register = '/users/register/';
  static const String login = '/users/login/';
  static const String logout = '/users/logout/';
  static const String profile = '/users/profile/';

  // Comments endpoints
  static const String comments = '/comments/';
  static String postComments(String postId) => '/feeds/$postId/comments/';

  // Post interactions endpoints
  static String postLike(String postId) => '/feeds/$postId/like/';
  static String postBookmark(String postId) => '/feeds/$postId/bookmark/';

  // Search endpoints
  static const String search = '/search/';
  static const String hotList = '/search/hot-list/';
  static const String hotTags = '/search/hot-tags/';
}
