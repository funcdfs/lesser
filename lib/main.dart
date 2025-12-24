import 'package:flutter/material.dart';
import 'common/navigation/main_screen.dart';
import 'common/utils/logger/logger_service.dart';
import 'common/config/shadcn_theme.dart';

void main() {
  // 记录应用启动日志
  Log.i("App Init: Starting application...");
  runApp(const LesserApp());
}

/// Lesser 应用程序根组件
class LesserApp extends StatelessWidget {
  const LesserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lesser',
      // 使用定义的 Shadcn 风主题
      theme: ShadcnThemeData.lightTheme,
      // 设置主屏幕（包含底部导航栏）
      home: const MainScreen(),
    );
  }
}
