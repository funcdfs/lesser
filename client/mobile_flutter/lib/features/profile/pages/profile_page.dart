// 个人主页

import 'package:flutter/material.dart';
import '../../../main.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../../../pkg/ui/widgets/widgets.dart';
import 'test_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.surfaceBase,
      appBar: AppBar(
        title: Text(
          '我的',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: colors.surfaceBase,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.science_rounded),
            tooltip: '组件测试',
            color: colors.textTertiary,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TestPage()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // 主题切换
          _SettingCard(
            colors: colors,
            child: Row(
              children: [
                Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: colors.textSecondary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '深色模式',
                    style: TextStyle(fontSize: 15, color: colors.textPrimary),
                  ),
                ),
                ToggleSwitch(
                  value: isDark,
                  onChanged: (_) => themeNotifier.toggle(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({required this.colors, required this.child});

  final AppColorScheme colors;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
