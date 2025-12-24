import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'shared/utils/logger_service.dart';

void main() {
  // 记录应用启动日志
  Log.i("App Init: Starting application...");
  runApp(const ProviderScope(child: LesserApp()));
}
