// Lesser 社交平台客户端入口

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'features/channel/pages/channel_comment_page.dart';
import 'features/channel/pages/channel_detail_page.dart';
import 'features/home/pages/home_page.dart';
import 'pkg/link/link.dart';
import 'pkg/ui/theme/theme.dart';

void main() {
  runApp(const _App());
}

// ============================================================================
// 全局状态
// ============================================================================

/// 全局导航键
final navigatorKey = GlobalKey<NavigatorState>();

/// HomePage Key，保持状态稳定
final homePageKey = GlobalKey();

/// 主题通知器
final themeNotifier = ThemeNotifier();

/// Circular Reveal 动画控制器
final circularRevealController = CircularRevealController();

/// 截图边界 Key
final screenshotKey = GlobalKey();

// ============================================================================
// 主题切换
// ============================================================================

/// 触发主题切换（带 Circular Reveal 动画）
void toggleThemeWithReveal(BuildContext context, Offset origin) {
  if (circularRevealController.isAnimating) return;

  // 获取截图边界
  final boundary =
      screenshotKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
  if (boundary == null) {
    themeNotifier.toggle();
    return;
  }

  // 同步生成模糊截图
  final blurredImage = createBlurredScreenshot(boundary);
  if (blurredImage == null) {
    themeNotifier.toggle();
    return;
  }

  // 启动动画
  circularRevealController.startAnimation(
    origin: origin,
    targetIsDark: !themeNotifier.isDark,
    blurredImage: blurredImage,
  );

  // 切换主题
  themeNotifier.toggle();

  // 执行动画帧
  final duration = CircularRevealAnim.duration;
  final startTime = DateTime.now();

  void tick() {
    final elapsed = DateTime.now().difference(startTime);
    final t = (elapsed.inMilliseconds / duration.inMilliseconds).clamp(
      0.0,
      1.0,
    );
    final curved = CircularRevealAnim.curve.transform(t);
    circularRevealController.updateProgress(curved);

    if (t < 1.0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => tick());
    } else {
      circularRevealController.endAnimation();
    }
  }

  WidgetsBinding.instance.addPostFrameCallback((_) => tick());
}

// ============================================================================
// 应用入口
// ============================================================================

/// 公共主题配置
ThemeData _applyCommonConfig(ThemeData base) {
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

  void _initLinkService() {
    LinkService.instance.init(
      dataSource: LinkMockDataSource(),
      onNavigateToChannel: _navigateToChannel,
      onNavigateToMessage: _navigateToMessage,
      onNavigateToComment: _navigateToComment,
    );
  }

  Future<bool> _navigateToChannel(
    BuildContext context,
    String channelId,
  ) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChannelDetailPage(channelId: channelId),
      ),
    );
    return true;
  }

  Future<bool> _navigateToMessage(
    BuildContext context,
    String channelId,
    String messageId, {
    bool highlightMessage = false,
  }) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChannelDetailPage(
          channelId: channelId,
          highlightMessageId: highlightMessage ? messageId : null,
        ),
      ),
    );
    return true;
  }

  Future<bool> _navigateToComment(
    BuildContext context,
    String channelId,
    String messageId,
    String rootCommentId,
    String targetCommentId,
  ) async {
    Navigator.of(context).push(
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
        final theme = themeNotifier.isDark
            ? _applyCommonConfig(buildDarkTheme())
            : _applyCommonConfig(buildLightTheme());

        return RepaintBoundary(
          key: screenshotKey,
          child: ListenableBuilder(
            listenable: circularRevealController,
            builder: (context, _) {
              return CircularRevealOverlay(
                controller: circularRevealController,
                child: MaterialApp(
                  navigatorKey: navigatorKey,
                  title: 'Lesser',
                  debugShowCheckedModeBanner: false,
                  theme: theme,
                  home: HomePage(key: homePageKey),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
