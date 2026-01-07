// Lesser 社交平台客户端入口

import 'package:flutter/material.dart';
import 'features/home/pages/home_page.dart';
import 'pkg/ui/theme/theme.dart';

void main() => runApp(const _App());

/// 全局主题通知器
final themeNotifier = ThemeNotifier();

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
          theme: buildLightTheme().copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),
          darkTheme: buildDarkTheme().copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),
          home: const HomePage(),
        );
      },
    );
  }
}
