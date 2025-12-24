import 'package:flutter/material.dart';
import '../../../../shared/theme/theme.dart';

class NetworkNeighborsWidget extends StatelessWidget {
  const NetworkNeighborsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
          child: Text(
            '网络邻居',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.mutedForeground,
                ),
          ),
        ),
        ListTile(
          leading: const CircleAvatar(
            backgroundColor: AppColors.secondary,
            child: Icon(Icons.group_outlined, color: AppColors.foreground),
          ),
          title: const Text('附近的人'),
          subtitle: Text('发现周围的朋友', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mutedForeground)),
          trailing: const Icon(Icons.chevron_right, color: AppColors.mutedForeground),
          onTap: () {},
        ),
      ],
    );
  }
}
