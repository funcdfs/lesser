import 'package:flutter/material.dart';
import './app.dart';
import '../features/test/presentation/screens/api_test_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
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
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/main':
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case '/api-test':
        return MaterialPageRoute(builder: (_) => const ApiTestScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
