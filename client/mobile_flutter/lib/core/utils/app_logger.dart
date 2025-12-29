import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// 日志级别枚举，用于过滤
enum AppLogLevel { verbose, debug, info, warning, error, off }

/// 应用统一日志管理器
class AppLogger {
  AppLogger._();

  static final AppLogger _instance = AppLogger._();
  static AppLogger get instance => _instance;

  late Logger _logger;
  AppLogLevel _minLevel = kDebugMode ? AppLogLevel.debug : AppLogLevel.warning;

  /// 初始化日志管理器
  void init({AppLogLevel? minLevel}) {
    if (minLevel != null) {
      _minLevel = minLevel;
    }

    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 80,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      level: _mapLevel(_minLevel),
      filter: ProductionFilter(),
    );
  }

  Level _mapLevel(AppLogLevel level) {
    switch (level) {
      case AppLogLevel.verbose:
        return Level.trace;
      case AppLogLevel.debug:
        return Level.debug;
      case AppLogLevel.info:
        return Level.info;
      case AppLogLevel.warning:
        return Level.warning;
      case AppLogLevel.error:
        return Level.error;
      case AppLogLevel.off:
        return Level.off;
    }
  }

  /// 运行时设置最小日志级别
  void setLevel(AppLogLevel level) {
    _minLevel = level;
    init(minLevel: level);
  }

  /// 详细日志（最详细）
  void v(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(Level.trace, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// 调试日志
  void d(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(Level.debug, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// 信息日志
  void i(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(Level.info, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// 警告日志
  void w(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(Level.warning, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// 错误日志
  void e(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(Level.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  void _log(
    Level level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final formattedMessage = tag != null ? '[$tag] $message' : message;
    _logger.log(level, formattedMessage, error: error, stackTrace: stackTrace);
  }
}

/// 全局日志实例，方便使用
final log = AppLogger.instance;

/// 生产环境过滤器，遵循配置的日志级别
class ProductionFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return true; // 让 Logger 处理级别过滤
  }
}
