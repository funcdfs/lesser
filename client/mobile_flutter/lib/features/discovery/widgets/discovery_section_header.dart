import 'package:flutter/material.dart';
import '../../../../pkg/ui/theme/theme.dart';

class DiscoverySectionHeader extends StatelessWidget {
  const DiscoverySectionHeader({
    super.key,
    required this.title,
    this.actionLabel = "更多",
  });

  final String title;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.of(context).textPrimary,
              ),
            ),
            Text(
              actionLabel,
              style: TextStyle(color: AppColors.of(context).textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}
