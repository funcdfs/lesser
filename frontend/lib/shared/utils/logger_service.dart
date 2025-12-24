import 'package:logger/logger.dart';

/// 全局日志服务
/// 
/// 使用方法:
/// ```dart
/// Log.d("Debug message");
/// Log.i("Info message");
/// Log.w("Warning message");
/// Log.e("Error message", error: errorInstance, stackTrace: stackTrace);
/// ```
class Log {
  Log._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // 展示多少层堆栈
      errorMethodCount: 8, // 错误时展示多少层堆栈
      lineLength: 120, // 每行宽度
      colors: true, // 彩色输出
      printEmojis: true, // 打印 emoji
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// Debug 日志 (详细调试信息)
  static void d(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Info 日志 (一般信息)
  static void i(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Warning 日志 (警告)
  static void w(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Error 日志 (错误)
  static void e(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Trace 日志 (追踪)
  static void t(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _logger.t(message, error: error, stackTrace: stackTrace);
  }

  /// Fatal 日志 (致命错误)
  static void f(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}
