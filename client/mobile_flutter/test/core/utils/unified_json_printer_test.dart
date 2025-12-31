import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:test/test.dart';
import 'package:mobile_flutter/core/utils/unified_json_printer.dart';

void main() {
  test('UnifiedJsonPrinter outputs correct JSON format', () {
    final printer = UnifiedJsonPrinter(
      serviceName: 'test-service',
      getContext: () => {'trace_id': 'test-trace-id'},
    );

    final event = LogEvent(
      Level.info,
      'test message',
      error: 'test error',
      stackTrace: StackTrace.current,
    );

    final output = printer.log(event);
    expect(output.length, 1);

    final json = jsonDecode(output[0]) as Map<String, dynamic>;
    expect(json['service'], 'test-service');
    expect(json['level'], 'INFO');
    expect(json['msg'], 'test message');
    expect(json['trace_id'], 'test-trace-id');
    expect(json['timestamp'], isNotNull);
    expect(json['error'], 'test error');
    expect(json['stacktrace'], isNotNull);
  });
}
