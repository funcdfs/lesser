import 'package:flutter/material.dart' hide Badge;
import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/list_tile.dart';
import '../../../../shared/widgets/icon_container.dart';
import '../../../../shared/widgets/chip.dart';

/// 单个聊天会话/功能项样式
class ChatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;
  final int unreadCount;
  final bool showArrow;
  final bool isMuted;

  const ChatItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
    this.unreadCount = 0,
    this.showArrow = false,
    this.isMuted = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      leading: IconContainer(
        icon: icon,
        iconColor: AppColors.mutedForeground,
        size: 48,
      ),
      title: title,
      subtitle: subtitle,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (time.isNotEmpty)
            Text(
              time,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.mutedForeground,
              ),
            ),
          if (unreadCount > 0) ...[
            const SizedBox(height: 4),
            Badge(
              text: unreadCount > 99 ? '99+' : unreadCount.toString(),
              backgroundColor: isMuted
                  ? AppColors.mutedForeground
                  : AppColors.destructive,
            ),
          ] else if (isMuted) ...[
            const SizedBox(height: 4),
            const Icon(
              Icons.notifications_off_outlined,
              color: AppColors.mutedForeground,
              size: 16,
            ),
          ] else if (showArrow)
            const Icon(
              Icons.chevron_right,
              color: AppColors.mutedForeground,
              size: 18,
            ),
        ],
      ),
      onTap: () {
        // TODO: 跳转至聊天详情页
      },
    );
  }
}
