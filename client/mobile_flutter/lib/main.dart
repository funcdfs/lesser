// Lesser 社交平台客户端入口

import 'package:flutter/material.dart';
import 'features/home/pages/home_page.dart';
import 'pkg/ui/theme/theme.dart';

void main() => runApp(const _App());

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

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeNotifier,
      builder: (context, _) {
        return MaterialApp(
          title: 'Lesser',
          debugShowCheckedModeBanner: false,
          themeMode: themeNotifier.isDark ? ThemeMode.dark : ThemeMode.light,
          // 主题切换过渡动画 - 1秒柔和过渡
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
