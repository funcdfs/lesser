import 'package:flutter/material.dart';
import '../../../../pkg/ui/theme/theme.dart';

class TrackerSavedList extends StatelessWidget {
  const TrackerSavedList({
    super.key,
    required this.count,
    required this.labelPrefix,
    required this.baseColor,
  });

  final int count;
  final String labelPrefix;
  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 160,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: count,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            return Container(
              width: 100,
              decoration: BoxDecoration(
                color: baseColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                '$labelPrefix #$index',
                style: TextStyle(color: AppColors.of(context).textPrimary),
              ),
            );
          },
        ),
      ),
    );
  }
}
