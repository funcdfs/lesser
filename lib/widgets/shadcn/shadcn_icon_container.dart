import 'package:flutter/material.dart';
import '../../config/shadcn_theme.dart';

/// Icon container with consistent styling
class ShadcnIconContainer extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final double size;

  const ShadcnIconContainer({
    super.key,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? ShadcnColors.foreground;
    final effectiveBackgroundColor =
        backgroundColor ?? effectiveIconColor.withValues(alpha: 0.1);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(ShadcnRadius.lg),
      ),
      child: Icon(icon, color: effectiveIconColor, size: size * 0.55),
    );
  }
}
