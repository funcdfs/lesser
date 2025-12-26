import 'package:flutter/material.dart';
import '../core/navigation/navigation_service.dart';
import '../core/navigation/app_routes.dart';
// import 'package:go_router/go_router.dart'; // User recommended go_router

/// 应用路由配置
///
/// 整合导航服务和路由生成器
class AppRouter {
  /// 获取路由生成器
  static RouteFactory get routeGenerator => AppRouteGenerator.generateRoute;

  /// 获取导航键
  static GlobalKey<NavigatorState> get navigatorKey =>
      NavigationService.navigatorKey;
}
