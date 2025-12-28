import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Log level enum for filtering
enum AppLogLevel { verbose, debug, info, warning, error, off }

/// Centralized logger for the app
class AppLogger {
  AppLogger._();

  static final AppLogger _instance = AppLogger._();
  static AppLogger get instance => _instance;

  late Logger _logger;
  AppLogLevel _minLevel = kDebugMode ? AppLogLevel.debug : AppLogLevel.warning;

  /// Initialize the logger
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

  /// Set minimum log level at runtime
  void setLevel(AppLogLevel level) {
    _minLevel = level;
    init(minLevel: level);
  }

  /// Verbose log (most detailed)
  void v(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(Level.trace, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Debug log
  void d(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(Level.debug, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Info log
  void i(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(Level.info, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Warning log
  void w(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(Level.warning, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Error log
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

/// Global logger instance for convenience
final log = AppLogger.instance;

/// Production filter that respects the configured level
class ProductionFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return true; // Let Logger handle level filtering
  }
}
