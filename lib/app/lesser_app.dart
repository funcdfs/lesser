import 'package:flutter/material.dart';
import 'app_router.dart';
import 'app_theme.dart';

/// Lesser 应用主入口
///
/// 负责：
/// - 配置 MaterialApp
/// - 设置全局主题
/// - 配置路由
/// - 设置 Locale 和调试模式

class LesserApp extends StatelessWidget {
  const LesserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lesser',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.light,
      onGenerateRoute: AppRouter.generateRoute,
      home: const SizedBox(), // 实际的首页会通过路由加载
      debugShowCheckedModeBanner: false,
    );
  }
}
