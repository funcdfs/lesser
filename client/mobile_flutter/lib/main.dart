// Lesser 社交平台客户端入口

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'features/subject/pages/subject_comment_page.dart';
import 'features/subject/pages/subject_detail_page.dart';
import 'features/home/pages/home_page.dart';
import 'pkg/comment/comment_page.dart';
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
  const duration = CircularRevealAnim.duration;
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
      onNavigateToChannel: _navigateToSubject,
      onNavigateToMessage: _navigateToPost,
      onNavigateToComment: _navigateToComment, // Update other methods similarly if needed
    );
  }

  Future<bool> _navigateToSubject(
    BuildContext context,
    String subjectId,
  ) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SubjectDetailPage(subjectId: subjectId),
      ),
    );
    return true;
  }

  Future<bool> _navigateToPost(
    BuildContext context,
    String subjectId,
    String postId, {
    bool highlightMessage = false,
  }) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SubjectDetailPage(
          subjectId: subjectId,
          highlightPostId: highlightMessage ? postId : null,
        ),
      ),
    );
    return true;
  }

  Future<bool> _navigateToComment(
    BuildContext context,
    String subjectId,
    String postId,
    String rootCommentId,
    String targetCommentId, {
    LinkNavigateMode mode = LinkNavigateMode.push,
  }) async {
    if (mode == LinkNavigateMode.replace) {
      // replace 模式：在当前页面内瞬移到目标位置
      return CommentPage.navigateInPlace(targetCommentId);
    }

    // push 模式：创建新的总览层页面
    // 注意：不传递 rootCommentId，这样会打开总览层而不是线程视图
    // targetCommentId 用于滚动定位和高亮
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SubjectCommentPage(
          postId: postId,
          subjectId: subjectId,
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
