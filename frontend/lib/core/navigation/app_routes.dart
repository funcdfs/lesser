import 'package:flutter/material.dart';
import 'package:lesser/features/auth/presentation/screens/login_screen.dart';
import 'package:lesser/features/auth/domain/models/user.dart';
import 'package:lesser/features/feeds/presentation/screens/post_detail_screen.dart';
import 'package:lesser/features/feeds/domain/models/post.dart';
import 'package:lesser/app/app.dart';

/// 应用路由名称常量类
class AppRoutes {
  static const String login = '/';
  static const String register = '/register';
  static const String main = '/main';
  static const String apiTest = '/api-test';
  static const String postDetail = '/post-detail';
}

/// 应用路由生成器
///
/// 根据路由名称生成对应的Route对象
class AppRouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.main:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case AppRoutes.postDetail:
        final post = settings.arguments as Post;
        return MaterialPageRoute(
          builder: (_) => PostDetailScreen(post: post),
          fullscreenDialog: true,
        );
      default:
        return _errorRoute(settings.name);
    }
  }

  static Route<dynamic> _errorRoute(String? routeName) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('错误')),
        body: Center(child: Text('未找到路由: $routeName')),
      ),
    );
  }
}
