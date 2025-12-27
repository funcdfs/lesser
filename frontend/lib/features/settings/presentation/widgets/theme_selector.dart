import 'package:flutter/material.dart';
import 'package:lesser/shared/theme/theme.dart';

/// Widget for selecting theme mode (light/dark/system)
class ThemeSelector extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onChanged;

  const ThemeSelector({
    super.key,
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildOption(
          context,
          ThemeMode.system,
          '跟随系统',
          Icons.brightness_auto_outlined,
        ),
        _buildOption(
          context,
          ThemeMode.light,
          '浅色模式',
          Icons.light_mode_outlined,
        ),
        _buildOption(
          context,
          ThemeMode.dark,
          '深色模式',
          Icons.dark_mode_outlined,
        ),
      ],
    );
  }

  Widget _buildOption(
    BuildContext context,
    ThemeMode mode,
    String label,
    IconData icon,
  ) {
    final isSelected = currentMode == mode;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => onChanged(mode),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.mutedForeground,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.foreground,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}
