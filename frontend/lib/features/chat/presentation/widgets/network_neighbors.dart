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
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Text(
            '网络邻居',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppColors.mutedForeground),
          ),
        ),

        // 我的好友
        ListTile(
          leading: const CircleAvatar(
            backgroundColor: AppColors.secondary,
            child: Icon(Icons.person_add_outlined, color: AppColors.foreground),
          ),
          title: const Text('我的好友'),
          subtitle: Text(
            '我的互关好友',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.mutedForeground),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.mutedForeground,
          ),
          onTap: () {},
        ),

        // 我的粉丝
        ListTile(
          leading: const CircleAvatar(
            backgroundColor: AppColors.secondary,
            child: Icon(Icons.people_outlined, color: AppColors.foreground),
          ),
          title: const Text('我的粉丝'),
          subtitle: Text(
            '关注我的人',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.mutedForeground),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.mutedForeground,
          ),
          onTap: () {},
        ),

        // 我的关注
        ListTile(
          leading: const CircleAvatar(
            backgroundColor: AppColors.secondary,
            child: Icon(
              Icons.follow_the_signs_outlined,
              color: AppColors.foreground,
            ),
          ),
          title: const Text('我的关注'),
          subtitle: Text(
            '我关注的人',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.mutedForeground),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.mutedForeground,
          ),
          onTap: () {},
        ),

        // 创建群聊
        ListTile(
          leading: const CircleAvatar(
            backgroundColor: AppColors.secondary,
            child: Icon(Icons.group_add_outlined, color: AppColors.foreground),
          ),
          title: const Text('创建群聊'),
          subtitle: Text(
            '创建新的群组聊天',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.mutedForeground),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.mutedForeground,
          ),
          onTap: () {},
        ),

        // 创建频道
        ListTile(
          leading: const CircleAvatar(
            backgroundColor: AppColors.secondary,
            child: Icon(Icons.campaign_outlined, color: AppColors.foreground),
          ),
          title: const Text('创建频道'),
          subtitle: Text(
            '创建新的频道',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.mutedForeground),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.mutedForeground,
          ),
          onTap: () {},
        ),

        // 添加好友
        ListTile(
          leading: const CircleAvatar(
            backgroundColor: AppColors.secondary,
            child: Icon(
              Icons.person_add_alt_outlined,
              color: AppColors.foreground,
            ),
          ),
          title: const Text('添加好友'),
          subtitle: Text(
            '通过ID或二维码添加',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.mutedForeground),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.mutedForeground,
          ),
          onTap: () {},
        ),

        // 附近的人
        ListTile(
          leading: const CircleAvatar(
            backgroundColor: AppColors.secondary,
            child: Icon(
              Icons.location_on_outlined,
              color: AppColors.foreground,
            ),
          ),
          title: const Text('附近的人'),
          subtitle: Text(
            '发现周围的朋友',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.mutedForeground),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.mutedForeground,
          ),
          onTap: () {},
        ),
      ],
    );
  }
}
