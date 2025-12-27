import 'package:flutter/material.dart' hide Badge;
import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/list_tile.dart';
import '../../../../shared/widgets/icon_container.dart';
import '../../../../shared/widgets/chip.dart';

/// 聊天类型枚举
enum ChatType { group, channel, private }

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
  final ChatType chatType;
  final bool hasAvatar;
  final String? avatarUrl;

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
    required this.chatType,
    this.hasAvatar = false,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      leading: Stack(
        children: [
          hasAvatar && avatarUrl != null
              ? CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(avatarUrl!),
                )
              : IconContainer(
                  icon: icon,
                  iconColor: AppColors.mutedForeground,
                  size: 48,
                ),
          Positioned(bottom: 0, right: 0, child: _buildChatTypeBadge(chatType)),
        ],
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

  /// 构建聊天类型标识
  Widget _buildChatTypeBadge(ChatType type) {
    String text;
    Color color1;
    Color color2;

    switch (type) {
      case ChatType.group:
        text = 'Group';
        color1 = AppColors.info;
        color2 = AppColors.accentPurple;
        break;
      case ChatType.channel:
        text = 'Channel';
        color1 = AppColors.warning;
        color2 = AppColors.error;
        break;
      case ChatType.private:
        text = 'Private';
        color1 = AppColors.success;
        color2 = AppColors.teal;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: AppColors.background,
        ),
      ),
    );
  }
}
