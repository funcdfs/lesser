import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../domain/entities/notification.dart';

class NotificationItem extends StatelessWidget {
  const NotificationItem({
    super.key,
    required this.notification,
    this.onTap,
  });

  final AppNotification notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: notification.isRead ? null : AppColors.primary.withOpacity(0.05),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildContent(),
                  const SizedBox(height: 4),
                  Text(
                    notification.createdAt.timeAgo,
                    style: TextStyle(
                      color: AppColors.textSecondaryLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData icon;
    Color color;

    switch (notification.type) {
      case NotificationType.like:
        icon = Icons.favorite;
        color = AppColors.like;
        break;
      case NotificationType.comment:
      case NotificationType.reply:
        icon = Icons.chat_bubble;
        color = AppColors.reply;
        break;
      case NotificationType.repost:
        icon = Icons.repeat;
        color = AppColors.repost;
        break;
      case NotificationType.follow:
        icon = Icons.person_add;
        color = AppColors.primary;
        break;
      case NotificationType.mention:
        icon = Icons.alternate_email;
        color = AppColors.primary;
        break;
      case NotificationType.bookmark:
        icon = Icons.bookmark;
        color = AppColors.bookmark;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildContent() {
    final actorName =
        notification.actor.displayName ?? notification.actor.username;
    String action;

    switch (notification.type) {
      case NotificationType.like:
        action = 'liked your post';
        break;
      case NotificationType.comment:
        action = 'commented on your post';
        break;
      case NotificationType.reply:
        action = 'replied to your comment';
        break;
      case NotificationType.repost:
        action = 'reposted your post';
        break;
      case NotificationType.follow:
        action = 'started following you';
        break;
      case NotificationType.mention:
        action = 'mentioned you';
        break;
      case NotificationType.bookmark:
        action = 'bookmarked your post';
        break;
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(color: AppColors.textPrimaryLight),
        children: [
          TextSpan(
            text: actorName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: ' $action'),
          if (notification.message != null) ...[
            const TextSpan(text: ': '),
            TextSpan(
              text: notification.message,
              style: TextStyle(color: AppColors.textSecondaryLight),
            ),
          ],
        ],
      ),
    );
  }
}
