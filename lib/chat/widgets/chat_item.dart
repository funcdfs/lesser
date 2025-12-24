import 'package:flutter/material.dart';
import '../../common/widgets/shadcn/shadcn_list_tile.dart';
import '../../common/widgets/shadcn/shadcn_icon_container.dart';
import '../../theme/theme.dart';
import '../../common/widgets/shadcn/shadcn_chip.dart';

/// 单个聊天会话/功能项样式
class ChatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;
  final int unreadCount;
  final bool showArrow;

  const ChatItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.unreadCount,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return ShadcnListTile(
      padding: const EdgeInsets.symmetric(
        horizontal: ShadcnSpacing.lg,
        vertical: ShadcnSpacing.md,
      ),
      leading: ShadcnIconContainer(
        icon: icon,
        iconColor: ShadcnColors.mutedForeground,
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
                color: ShadcnColors.mutedForeground,
              ),
            ),
          if (unreadCount > 0) ...[
            const SizedBox(height: 4),
            ShadcnBadge(
              text: unreadCount > 99 ? '99+' : unreadCount.toString(),
            ),
          ] else if (showArrow)
            const Icon(
              Icons.chevron_right,
              color: ShadcnColors.mutedForeground,
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
