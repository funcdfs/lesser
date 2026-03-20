// =============================================================================
// 评论通知详情页 - Comment Notification Detail Page
// =============================================================================

import 'package:flutter/material.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../../../pkg/ui/effects/effects.dart';
import '../../../pkg/utils/format_utils.dart';
import '../models/subject_models.dart';
import '../data_access/mock/subject_mock_data.dart';
import 'subject_comment_page.dart';

/// 评论通知详情页
class CommentNotificationPage extends StatelessWidget {
  const CommentNotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final sortedNotifications = [...mockCommentNotifications]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      backgroundColor: colors.surfaceBase,
      appBar: AppBar(
        backgroundColor: colors.surfaceBase,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '评论通知',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: colors.divider),
        ),
      ),
      body: ListView.separated(
        itemCount: sortedNotifications.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        separatorBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(left: 72),
          child: Divider(height: 0.5, color: colors.divider.withValues(alpha: 0.5)),
        ),
        itemBuilder: (context, index) {
          return _NotificationItem(notification: sortedNotifications[index]);
        },
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({required this.notification});

  final CommentNotificationModel notification;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isReply = notification.type == CommentNotificationType.reply;

    return TapScale(
      onTap: () {
        // 导航到评论详情页
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SubjectCommentPage(
              postId: notification.postId,
              subjectId: notification.subjectId,
              // 这里可以传递 targetCommentId 进行定位
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户头像
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: notification.fromUserAvatar != null
                    ? DecorationImage(
                        image: NetworkImage(notification.fromUserAvatar!),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: colors.surfaceElevated,
              ),
              child: notification.fromUserAvatar == null
                  ? Icon(Icons.person_rounded, color: colors.textDisabled)
                  : null,
            ),
            const SizedBox(width: 12),
            // 内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: notification.fromUserName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: isReply ? ' 回复了你的评论' : ' 点赞了你的评论',
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (notification.contentPreview.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.surfaceElevated,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        notification.contentPreview,
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.textPrimary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    formatTimeRelative(notification.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            // 图标指示器
            _buildTypeIcon(colors, isReply),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeIcon(AppColorScheme colors, bool isReply) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: (isReply ? colors.interactive : Colors.pinkAccent).withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isReply ? Icons.reply_rounded : Icons.favorite_rounded,
        size: 14,
        color: isReply ? colors.interactive : Colors.pinkAccent,
      ),
    );
  }
}
