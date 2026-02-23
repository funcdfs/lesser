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
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
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
        children: [_ThemeSwitchCard(isDark: isDark)],
      ),
    );
  }
}

/// 主题切换卡片
/// 点击触发 Circular Reveal 动画切换深色/浅色模式
class _ThemeSwitchCard extends StatefulWidget {
  const _ThemeSwitchCard({required this.isDark});

  final bool isDark;

  @override
  State<_ThemeSwitchCard> createState() => _ThemeSwitchCardState();
}

class _ThemeSwitchCardState extends State<_ThemeSwitchCard> {
  final _switchKey = GlobalKey();

  void _onTap() {
    // 动画期间禁止重复触发
    if (circularRevealController.isAnimating) return;

    // 获取开关中心位置作为动画起点
    final box = _switchKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      final center = box.localToGlobal(
        Offset(box.size.width / 2, box.size.height / 2),
      );
      toggleThemeWithReveal(context, center);
    } else {
      themeNotifier.toggle();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = widget.isDark;

    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // 图标切换动画
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: isDark
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Icon(
                Icons.light_mode_rounded,
                color: colors.textSecondary,
                size: 22,
              ),
              secondChild: Icon(
                Icons.dark_mode_rounded,
                color: colors.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '深色模式',
                style: TextStyle(fontSize: 15, color: colors.textPrimary),
              ),
            ),
            // 开关（禁用点击，由整个卡片处理）
            IgnorePointer(
              child: ToggleSwitch(
                key: _switchKey,
                value: isDark,
                onChanged: (_) {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
