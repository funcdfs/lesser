import 'package:flutter/material.dart';
import '../../config/shadcn_theme.dart';

/// Shadcn-style chip/tag component
class ShadcnChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;

  const ShadcnChip({
    super.key,
    required this.label,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding ?? const EdgeInsets.symmetric(
        horizontal: ShadcnSpacing.lg,
        vertical: ShadcnSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? ShadcnColors.secondary,
        borderRadius: BorderRadius.circular(ShadcnRadius.md),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor ?? ShadcnColors.foreground,
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ShadcnRadius.md),
        child: content,
      );
    }

    return content;
  }
}

/// Badge component for counts/notifications
class ShadcnBadge extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;

  const ShadcnBadge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? ShadcnColors.destructive,
        borderRadius: BorderRadius.circular(ShadcnRadius.full),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
