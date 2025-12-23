import 'package:flutter/material.dart';
import 'screens/main_screen.dart';
import 'utils/logger/logger_service.dart';
import 'config/shadcn_theme.dart';

void main() {
  Log.i("App Init: Starting application...");
  runApp(const InviteFeedApp());
}

class InviteFeedApp extends StatelessWidget {
  const InviteFeedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Invite Feed',
      theme: ShadcnThemeData.lightTheme,
      home: const MainScreen(),
    );
  }
}
