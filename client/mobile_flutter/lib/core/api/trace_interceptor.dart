import 'dart:math';
import 'package:dio/dio.dart';
import '../utils/app_logger.dart';

class TraceInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Generate trace ID if not present
    String? traceId = options.headers['X-Trace-ID'];
    if (traceId == null || traceId.isEmpty) {
      traceId = _generateTraceId();
      options.headers['X-Trace-ID'] = traceId;
    }

    // Update global logger context
    log.traceId = traceId;

    handler.next(options);
  }

  String _generateTraceId() {
    final random = Random();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    return values.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
  }
}
