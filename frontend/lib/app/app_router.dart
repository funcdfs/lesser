import 'package:flutter/material.dart';
import './app.dart';
// import 'package:go_router/go_router.dart'; // User recommended go_router

/// 路由管理类
///
/// 负责全局页面跳转定义
///
/// 目前使用基础的 MaterialPageRoute，推荐未来集成 go_router
class AppRouter {
  /// 生成路由
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const MainScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
