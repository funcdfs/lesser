import 'package:logger/logger.dart';
import 'unified_json_printer.dart';

/// 应用统一日志管理器
class AppLogger {
  AppLogger._();

  static final AppLogger _instance = AppLogger._();
  static AppLogger get instance => _instance;

  late Logger _logger;
  
  /// 全局上下文信息
  String? traceId;
  String? userId;

  /// 初始化日志管理器
  void init() {
    _logger = Logger(
      printer: UnifiedJsonPrinter(
        serviceName: 'mobile-flutter',
        getContext: () => {
          if (traceId != null) 'trace_id': traceId,
          if (userId != null) 'user_id': userId,
        },
      ),
      // 不在应用层做过滤，让外部工具（如 Dozzle/Logcat）处理
      level: Level.all,
      filter: ProductionFilter(),
    );
  }

  /// 详细日志（VERBOSE -> TRACE）
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

  void _log(Level level, String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    final msg = tag != null ? '[$tag] $message' : message;
    _logger.log(level, msg, error: error, stackTrace: stackTrace);
  }
}

/// 全局日志实例
final log = AppLogger.instance;

/// 生产环境过滤器，输出所有日志
class ProductionFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return true;
  }
}

