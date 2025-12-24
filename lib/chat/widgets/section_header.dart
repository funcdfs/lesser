import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// 列表区块标题（如：聊天、网络邻居）
class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ShadcnSpacing.xl,
        ShadcnSpacing.sm,
        ShadcnSpacing.xl,
        ShadcnSpacing.sm,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: ShadcnColors.mutedForeground,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
