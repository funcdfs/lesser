import 'package:flutter/material.dart';
import '../../../../pkg/ui/theme/theme.dart';

/// 区域标题组件
class DiscoverySectionHeader extends StatelessWidget {
  const DiscoverySectionHeader({
    super.key,
    required this.title,
    this.showViewAll = false,
    this.onViewAllTap,
  });

  final String title;
  final bool showViewAll;
  final VoidCallback? onViewAllTap;

  @override
  Widget build(BuildContext context) {
    final accentColor = AppColors.of(context).accent;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
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
            if (showViewAll)
              GestureDetector(
                onTap: onViewAllTap,
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: accentColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
