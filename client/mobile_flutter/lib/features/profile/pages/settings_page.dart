import 'package:flutter/material.dart';
import '../../../main.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../../../pkg/ui/widgets/widgets.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.surfaceBase,
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
        backgroundColor: colors.surfaceBase,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionTitle(title: '外观'),
          const SizedBox(height: 8),
          _ThemeSwitchCard(isDark: isDark),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: colors.textTertiary,
        ),
      ),
    );
  }
}

class _ThemeSwitchCard extends StatefulWidget {
  const _ThemeSwitchCard({required this.isDark});

  final bool isDark;

  @override
  State<_ThemeSwitchCard> createState() => _ThemeSwitchCardState();
}

class _ThemeSwitchCardState extends State<_ThemeSwitchCard> {
  final _switchKey = GlobalKey();

  void _onTap() {
    if (circularRevealController.isAnimating) return;

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
