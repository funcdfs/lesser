import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/config/environment_config.dart';
import 'shared/utils/logger_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 开发环境加载 .env 配置
  if (!kReleaseMode) {
    await EnvironmentConfig.init();
  }
  
  // 记录应用启动日志
  Log.i("App Init: Starting application...");
  runApp(const ProviderScope(child: LesserApp()));
}
