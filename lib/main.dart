import 'package:flutter/material.dart';
import 'screens/main_screen.dart';
import 'utils/logger/logger_service.dart';
import 'config/shadcn_theme.dart';

void main() {
  // 记录应用启动日志
  Log.i("App Init: Starting application...");
  runApp(const InviteFeedApp());
}

/// 邀请流应用程序根组件
class InviteFeedApp extends StatelessWidget {
  const InviteFeedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Invite Feed',
      // 使用定义的 Shadcn 风主题
      theme: ShadcnThemeData.lightTheme,
      // 设置主屏幕（包含底部导航栏）
      home: const MainScreen(),
    );
  }
}
