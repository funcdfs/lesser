// =============================================================================
// 评论通知项组件 - Subject Notification Item
// =============================================================================
//
// 显示评论点赞和回复的通知入口，设计风格与 SubjectItem 保持一致。
//
// ## 设计美学
// - 采用与 SubjectItem 相同的卡片容器和阴影
// - 左侧使用带有渐变背景的通知图标
// - 右侧显示通知摘要和未读状态
//
// =============================================================================

import 'package:flutter/material.dart';
import '../../../pkg/ui/effects/effects.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../models/subject_models.dart';

/// 剧集列表中的通知项
class SubjectNotificationItem extends StatelessWidget {
  const SubjectNotificationItem({
    super.key,
    required this.notifications,
    this.onTap,
  });

  /// 通知列表
  final List<CommentNotificationModel> notifications;

  /// 点击回调
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final unreadCount = notifications.where((n) => !n.isRead).length;
    
    // 计算点赞和回复的数量
    final likeCount = notifications.where((n) => n.type == CommentNotificationType.like).length;
    final replyCount = notifications.where((n) => n.type == CommentNotificationType.reply).length;

    return TapScale(
      onTap: onTap,
      scale: TapScales.card,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 列表项容器 (Card Container)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.divider.withValues(alpha: 0.12), width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: colors.accent.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildIcon(colors),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(colors),
                        const SizedBox(height: 4),
                        _buildSummary(colors, likeCount, replyCount),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.textDisabled,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          // 3. 右上角未读数 (Unread Badge at Top-Right)
          if (unreadCount > 0)
            Positioned(
              top: 0,
              right: 8,
              child: _buildUnreadBadge(unreadCount, colors),
            ),
        ],
      ),
    );
  }

  Widget _buildIcon(AppColorScheme colors) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.accent,
            colors.accent.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors.accent.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.notifications_active_rounded,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildHeader(AppColorScheme colors) {
    return Text(
      '评论通知',
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: colors.textPrimary,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildSummary(AppColorScheme colors, int likeCount, int replyCount) {
    final List<String> parts = [];
    if (replyCount > 0) parts.add('$replyCount 条新回复');
    if (likeCount > 0) parts.add('$likeCount 个新点赞');
    
    final summary = parts.isEmpty ? '暂无新通知' : parts.join('，');

    return Text(
      summary,
      style: TextStyle(
        fontSize: 13,
        color: colors.textSecondary,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildUnreadBadge(int count, AppColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          height: 1,
        ),
      ),
    );
  }
}
