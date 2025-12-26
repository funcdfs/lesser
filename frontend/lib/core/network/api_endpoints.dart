import '../config/constants.dart';

class ApiEndpoints {
  // 使用环境配置的API基础URL
  static String get baseUrl {
    // 根据环境自动选择API地址
    if (AppConstants.isProduction) {
      // 生产环境使用API Gateway地址
      return AppConstants.apiBaseUrl;
    } else {
      // 开发环境可以根据平台自动选择地址
      // 对于移动设备，使用开发电脑的IP地址
      // 对于Web，使用相对路径或本地地址
      return 'http://192.168.31.168:8001/api';
    }
  }

  static const String health = '/health';
  static const String feeds = '/feeds/';

  // Authentication endpoints
  static const String register = '/users/register/';
  static const String login = '/users/login/';
  static const String logout = '/users/logout/';
  static const String profile = '/users/profile/';
}
