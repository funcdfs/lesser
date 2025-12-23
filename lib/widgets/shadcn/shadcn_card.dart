import 'package:flutter/material.dart';
import '../../config/shadcn_theme.dart';

class ShadcnCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const ShadcnCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: ShadcnColors.card,
        borderRadius: BorderRadius.circular(ShadcnRadius.lg),
        border: Border.all(color: ShadcnColors.border),
        boxShadow: ShadcnShadows.subtle,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ShadcnRadius.lg),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(ShadcnSpacing.lg),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ShadcnRadius.lg),
        child: card,
      );
    }
    return card;
  }
}

