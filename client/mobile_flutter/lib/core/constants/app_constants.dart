/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'Lesser';
  static const String appVersion = '1.0.0';

  // gRPC Configuration
  // 使用 adb reverse 端口转发时，Android 设备可以通过 localhost 访问电脑上的服务
  // 运行命令: adb reverse tcp:50053 tcp:50053 && adb reverse tcp:50052 tcp:50052
  static const String grpcHost = 'localhost';
  static const int grpcPort = 50053; // Gateway gRPC 端口
  static const int chatGrpcPort = 50052; // Chat Service gRPC 端口（双向流）

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Cache
  static const Duration cacheExpiration = Duration(minutes: 5);

  // Post types
  static const String postTypeStory = 'story';
  static const String postTypeShort = 'short';
  static const String postTypeColumn = 'column';

  // Story expiration
  static const Duration storyExpiration = Duration(hours: 24);

  // Validation
  static const int minPasswordLength = 8;
  static const int maxUsernameLength = 30;
  static const int maxBioLength = 160;
  static const int maxShortPostLength = 280;
  static const int maxColumnTitleLength = 100;
}
