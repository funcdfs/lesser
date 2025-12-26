import 'package:flutter/material.dart';
import 'package:lesser/core/navigation/app_routes.dart';
import 'package:lesser/features/feeds/domain/models/post.dart';

/// 导航服务类
///
/// 封装所有应用内的导航逻辑，提供统一的导航接口
class NavigationService {
  /// 导航键
  static final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  /// 公开的导航键访问器
  static GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  /// 获取当前上下文
  static BuildContext? get currentContext => _navigatorKey.currentContext;

  /// 跳转到登录页
  static Future<void> navigateToLogin() {
    return _navigatorKey.currentState!.pushReplacementNamed(AppRoutes.login);
  }

  /// 跳转到主页面
  static Future<void> navigateToMain() {
    return _navigatorKey.currentState!.pushReplacementNamed(AppRoutes.main);
  }

  /// 跳转到帖子详情页
  ///
  /// [post] 帖子对象
  static Future<void> navigateToPostDetail(Post post) {
    return _navigatorKey.currentState!.pushNamed(
      AppRoutes.postDetail,
      arguments: post,
    );
  }

  /// 返回上一页
  static void goBack() {
    _navigatorKey.currentState?.pop();
  }

  /// 替换当前路由
  static Future<void> replace(String routeName, {Object? arguments}) {
    return _navigatorKey.currentState!.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  /// 移除所有路由并跳转到新路由
  static Future<void> resetAndNavigateTo(
    String routeName, {
    Object? arguments,
  }) {
    return _navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
}
