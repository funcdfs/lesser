// Lesser 社交平台客户端入口

import 'package:flutter/material.dart';
import 'features/channel/pages/channel_comment_page.dart';
import 'features/channel/pages/channel_detail_page.dart';
import 'features/home/pages/home_page.dart';
import 'pkg/link/link.dart';
import 'pkg/ui/theme/theme.dart';

void main() {
  runApp(const _App());
}

/// 全局导航键
final navigatorKey = GlobalKey<NavigatorState>();

/// 全局主题通知器
final themeNotifier = ThemeNotifier();

/// 公共主题配置，避免重复代码
ThemeData _applyCommonThemeConfig(ThemeData base) {
  return base.copyWith(
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    splashColor: Colors.transparent,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}

class _App extends StatefulWidget {
  const _App();

  @override
  State<_App> createState() => _AppState();
}

class _AppState extends State<_App> {
  @override
  void initState() {
    super.initState();
    _initLinkService();
  }

  /// 初始化深层链接服务
  void _initLinkService() {
    final dataSource = LinkMockDataSource();

    LinkService.instance.init(
      dataSource: dataSource,
      onNavigateToChannel: _navigateToChannel,
      onNavigateToMessage: _navigateToMessage,
      onNavigateToComment: _navigateToComment,
    );
  }

  /// 导航到频道
  Future<bool> _navigateToChannel(
    BuildContext context,
    String channelId,
  ) async {
    final navigator = Navigator.of(context);
    navigator.push(
      MaterialPageRoute(
        builder: (_) => ChannelDetailPage(channelId: channelId),
      ),
    );
    return true;
  }

  /// 导航到消息
  Future<bool> _navigateToMessage(
    BuildContext context,
    String channelId,
    String messageId, {
    bool highlightMessage = false,
  }) async {
    final navigator = Navigator.of(context);
    navigator.push(
      MaterialPageRoute(
        builder: (_) => ChannelDetailPage(
          channelId: channelId,
          highlightMessageId: highlightMessage ? messageId : null,
        ),
      ),
    );
    return true;
  }

  /// 导航到评论
  Future<bool> _navigateToComment(
    BuildContext context,
    String channelId,
    String messageId,
    String rootCommentId,
    String targetCommentId,
  ) async {
    final navigator = Navigator.of(context);

    // 导航到评论页面，传递根评论 ID 和目标评论 ID
    navigator.push(
      MaterialPageRoute(
        builder: (_) => ChannelCommentPage(
          messageId: messageId,
          channelId: channelId,
          rootCommentId: rootCommentId,
          targetCommentId: targetCommentId,
        ),
      ),
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeNotifier,
      builder: (context, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Lesser',
          debugShowCheckedModeBanner: false,
          themeMode: themeNotifier.isDark ? ThemeMode.dark : ThemeMode.light,
          themeAnimationDuration: const Duration(milliseconds: 1000),
          themeAnimationCurve: Curves.easeOutCubic,
          theme: _applyCommonThemeConfig(buildLightTheme()),
          darkTheme: _applyCommonThemeConfig(buildDarkTheme()),
          home: const HomePage(),
        );
      },
    );
  }
}
