import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

/// 环境配置管理器
///
/// 负责从 .env.dev 文件中读取配置参数
/// 在开发环境中通过 flutter_dotenv 加载
/// 在生产环境中使用构建参数或硬编码的默认值
class EnvironmentConfig {
  static final Logger _logger = Logger();

  /// 初始化环境配置（仅在开发环境调用）
  ///
  /// 使用方法：
  /// ```dart
  /// void main() {
  ///   if (!kReleaseMode) {
  ///     await EnvironmentConfig.init();
  ///   }
  ///   runApp(const MyApp());
  /// }
  /// ```
  static Future<void> init() async {
    try {
      // 从项目根目录加载 .env.dev
      await dotenv.load(fileName: '.env.dev');
      _logger.i('✓ 已加载环境配置: .env.dev');
    } catch (e) {
      // 如果找不到 .env.dev，尝试 .env
      try {
        await dotenv.load(fileName: '.env');
        _logger.i('✓ 已加载环境配置: .env');
      } catch (e2) {
        _logger.w('⚠ 未找到 .env 配置文件，使用默认配置');
      }
    }
  }

  /// 获取 API 基础 URL
  ///
  /// 优先级：
  /// 1. .env.dev 中的 API_BASE_URL
  /// 2. 默认开发地址 (http://localhost:9080/api)
  /// 3. 生产地址 (https://api.example.com)
  static String getApiBaseUrl() {
    return dotenv.env['API_BASE_URL'] ?? 'http://localhost:9080/api';
  }

  /// 获取 API 超时时间（毫秒）
  ///
  /// 默认值：30000ms（30秒）
  static int getApiTimeout() {
    final timeout = dotenv.env['API_TIMEOUT'];
    return timeout != null ? int.tryParse(timeout) ?? 30000 : 30000;
  }

  /// 获取是否为生产环境
  ///
  /// 默认值：false（开发环境）
  static bool isProduction() {
    final isProd = dotenv.env['IS_PRODUCTION'];
    return isProd?.toLowerCase() == 'true';
  }

  /// 获取调试日志级别
  ///
  /// 可选值：DEBUG, INFO, WARNING, ERROR
  /// 默认值：INFO
  static String getLogLevel() {
    return dotenv.env['LOG_LEVEL'] ?? 'INFO';
  }

  /// 获取数据库主机（用于本地开发测试）
  static String? getDatabaseHost() {
    return dotenv.env['DATABASE_HOST'];
  }

  /// 获取数据库端口（用于本地开发测试）
  static int? getDatabasePort() {
    final port = dotenv.env['DATABASE_PORT'];
    return port != null ? int.tryParse(port) : null;
  }

  /// 获取 APISIX 网关地址（开发环境）
  static String getApisixGateway() {
    return dotenv.env['APISIX_GATEWAY_URL'] ?? 'http://localhost:9080';
  }

  /// 获取 APISIX 管理 API 地址（开发环境）
  static String getApisixAdminApi() {
    return dotenv.env['APISIX_ADMIN_API'] ?? 'http://localhost:9180';
  }

  /// 打印所有已加载的环境变量（仅调试用）
  static void printAllEnv() {
    _logger.i('=== 环境配置 ===');
    dotenv.env.forEach((key, value) {
      // 隐藏敏感信息
      final displayValue = _shouldHideValue(key) ? '***' : value;
      _logger.i('$key=$displayValue');
    });
  }

  /// 检查是否应该隐藏敏感配置值
  static bool _shouldHideValue(String key) {
    final sensitiveKeys = ['PASSWORD', 'SECRET', 'TOKEN', 'KEY', 'CREDENTIAL'];
    return sensitiveKeys.any(
      (sensitive) => key.toUpperCase().contains(sensitive),
    );
  }
}
