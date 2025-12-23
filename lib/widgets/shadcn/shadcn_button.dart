import 'package:flutter/material.dart';
import '../../config/shadcn_theme.dart';

enum ShadcnButtonVariant { primary, secondary, ghost, outline }

class ShadcnButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final ShadcnButtonVariant variant;
  final IconData? icon;
  final double? size;

  const ShadcnButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.variant = ShadcnButtonVariant.primary,
    this.icon,
    this.size,
  });

  // Ghost Icon Button Factory
  factory ShadcnButton.ghost({
    required VoidCallback onPressed,
    required IconData icon,
    Color? color,
    double? size,
  }) {
    return ShadcnButton(
      onPressed: onPressed,
      variant: ShadcnButtonVariant.ghost,
      size: size,
      child: Icon(icon, size: size ?? 20, color: color ?? ShadcnColors.mutedForeground),
    );
  }

  // Ghost Text + Icon Button Factory
  factory ShadcnButton.ghostText({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    Color? color,
  }) {
    return ShadcnButton(
      onPressed: onPressed,
      variant: ShadcnButtonVariant.ghost,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color ?? ShadcnColors.mutedForeground),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color ?? ShadcnColors.mutedForeground,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color foregroundColor;
    Border? border;

    switch (variant) {
      case ShadcnButtonVariant.primary:
        backgroundColor = ShadcnColors.primary;
        foregroundColor = ShadcnColors.primaryForeground;
        break;
      case ShadcnButtonVariant.secondary:
        backgroundColor = ShadcnColors.secondary;
        foregroundColor = ShadcnColors.secondaryForeground;
        break;
      case ShadcnButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = ShadcnColors.foreground;
        break;
      case ShadcnButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = ShadcnColors.foreground;
        border = Border.all(color: ShadcnColors.border);
        break;
    }

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(ShadcnRadius.md),
      clipBehavior: Clip.antiAlias,
      shape: border != null
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ShadcnRadius.md),
              side: BorderSide(color: ShadcnColors.border))
          : null,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: variant == ShadcnButtonVariant.ghost
              ? const EdgeInsets.all(8)
              : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: DefaultTextStyle(
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
