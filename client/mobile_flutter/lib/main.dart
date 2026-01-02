import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_logger.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logger
  log.init();

  // Initialize dependencies
  await initializeDependencies();

  runApp(const ProviderScope(child: LesserApp()));
}

class LesserApp extends ConsumerStatefulWidget {
  const LesserApp({super.key});

  @override
  ConsumerState<LesserApp> createState() => _LesserAppState();
}

class _LesserAppState extends ConsumerState<LesserApp> {
  @override
  void initState() {
    super.initState();
    // App 启动时检查登录状态，如果已登录会自动连接 gRPC 双向流
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Lesser',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
