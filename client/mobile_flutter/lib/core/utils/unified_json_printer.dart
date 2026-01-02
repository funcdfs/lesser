import 'dart:convert';
import 'package:logger/logger.dart';

/// A [LogPrinter] that outputs logs in a unified JSON format.
class UnifiedJsonPrinter extends LogPrinter {
  UnifiedJsonPrinter({required this.serviceName, this.getContext});
  final String serviceName;
  final Map<String, dynamic> Function()? getContext;

  @override
  List<String> log(LogEvent event) {
    final timestamp = DateTime.now().toUtc().toIso8601String();
    final level = event.level.name.toUpperCase();

    final logMap = <String, dynamic>{
      'timestamp': timestamp,
      'level': level,
      'service': serviceName,
      'msg': event.message,
    };

    // Add context from the callback (e.g., trace_id, user_id)
    if (getContext != null) {
      logMap.addAll(getContext!());
    }

    // Add error information if present
    if (event.error != null) {
      logMap['error'] = event.error.toString();
    }
    if (event.stackTrace != null) {
      logMap['stacktrace'] = event.stackTrace.toString();
    }

    return [jsonEncode(logMap)];
  }
}
