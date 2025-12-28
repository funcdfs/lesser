import 'package:flutter/material.dart' hide Badge;
import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/list_tile.dart';
import '../../../../shared/widgets/icon_container.dart';
import '../../../../shared/widgets/chip.dart';
import 'chat_type_badge.dart';

/// 聊天类型枚举
/// 
/// 用于区分不同类型的聊天会话：
/// - [group]：群聊，多人参与的聊天
/// - [channel]：频道，公开或私有的广播频道
/// - [private]：私聊，一对一的私人对话
enum ChatType { 
  /// 群聊 - 多人参与的聊天
  group, 
  /// 频道 - 公开或私有的广播频道
  channel, 
  /// 私聊 - 一对一的私人对话
  private 
}

/// 单个聊天会话/功能项组件
///
/// 显示聊天会话项，包含头像、标题、副标题、时间和未读徽章。
/// 
/// 视觉规格（遵循 Requirements 7.1-7.6）：
/// - 内边距：水平 [AppSpacing.lg] (16px)，垂直 [AppSpacing.md] (12px)
/// - 头像：48px 圆形
/// - 标题：14px，[AppColors.foreground]，FontWeight.w500
/// - 副标题：13px，[AppColors.mutedForeground]，单行省略
/// - 时间：12px，[AppColors.mutedForeground]
/// - 未读徽章：[AppColors.info] 背景，白色文字
/// 
/// 无障碍支持：
/// - 使用 [Semantics] 提供完整的会话描述
/// - 包含标题、副标题、时间和未读数信息
/// 
/// 示例用法：
/// ```dart
/// ChatItem(
///   chatType: ChatType.group,
///   icon: Icons.group,
///   iconColor: AppColors.info,
///   title: '技术交流群',
///   subtitle: '小明: 大家好！',
///   time: '10:30',
///   unreadCount: 5,
/// )
/// ```
/// 
/// 参见：
/// - [ChatTypeBadge] - 聊天类型标识组件
/// - [formatUnreadCount] - 未读数格式化函数
class ChatItem extends StatelessWidget {
  /// 图标（当没有头像时显示）
  final IconData icon;
  
  /// 图标颜色
  final Color iconColor;
  
  /// 聊天标题（用户名/群名/频道名）
  final String title;
  
  /// 副标题（最后一条消息）
  final String subtitle;
  
  /// 时间显示
  final String time;
  
  /// 未读消息数
  /// 
  /// - 0 或负数：不显示未读徽章
  /// - 1-99：显示实际数字
  /// - 100+：显示 "99+"
  final int unreadCount;
  
  /// 是否显示箭头
  final bool showArrow;
  
  /// 是否静音
  /// 
  /// 静音时未读徽章使用 [AppColors.mutedForeground] 背景
  final bool isMuted;
  
  /// 聊天类型
  /// 
  /// 决定 [ChatTypeBadge] 显示的图标
  final ChatType chatType;
  
  /// 是否有头像
  final bool hasAvatar;
  
  /// 头像 URL
  final String? avatarUrl;
  
  /// 点击回调
  final VoidCallback? onTap;

  /// 创建聊天会话项组件
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
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _buildAccessibilityLabel(),
      button: true,
      child: AppListTile(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            // 头像：48px 圆形
            hasAvatar && avatarUrl != null
                ? CircleAvatar(
                    radius: 24, // 48px diameter
                    backgroundImage: NetworkImage(avatarUrl!),
                  )
                : IconContainer(
                    icon: icon,
                    iconColor: AppColors.mutedForeground,
                    size: 48,
                  ),
            // 聊天类型徽章：位于头像右下角
            Positioned(
              bottom: 0,
              right: 0,
              child: ChatTypeBadge(chatType: chatType),
            ),
          ],
        ),
        title: title,
        subtitle: subtitle,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 时间：12px，AppColors.mutedForeground
            if (time.isNotEmpty)
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mutedForeground,
                ),
              ),
            // 未读徽章：AppColors.info 背景
            if (unreadCount > 0) ...[
              const SizedBox(height: AppSpacing.xs),
              Badge(
                text: formatUnreadCount(unreadCount),
                backgroundColor: isMuted
                    ? AppColors.mutedForeground
                    : AppColors.info,
              ),
            ] else if (isMuted) ...[
              const SizedBox(height: AppSpacing.xs),
              Icon(
                Icons.notifications_off_outlined,
                color: AppColors.mutedForeground,
                size: 16,
                semanticLabel: '已静音',
              ),
            ] else if (showArrow)
              Icon(
                Icons.chevron_right,
                color: AppColors.mutedForeground,
                size: 18,
                semanticLabel: '查看详情',
              ),
          ],
        ),
        onTap: onTap ?? () {
          // TODO: 跳转至聊天详情页
        },
      ),
    );
  }

  /// 构建无障碍标签
  String _buildAccessibilityLabel() {
    final buffer = StringBuffer();
    buffer.write(title);
    
    if (subtitle.isNotEmpty) {
      buffer.write('，$subtitle');
    }
    
    if (time.isNotEmpty) {
      buffer.write('，$time');
    }
    
    if (unreadCount > 0) {
      buffer.write('，${formatUnreadCount(unreadCount)}条未读消息');
    }
    
    if (isMuted) {
      buffer.write('，已静音');
    }
    
    return buffer.toString();
  }
}

/// 格式化未读消息数量
/// 
/// 根据 Requirements 2.8, 2.9 的规定：
/// - 如果 [count] <= 0，返回空字符串
/// - 如果 [count] > 99，返回 "99+"
/// - 否则返回数字字符串
/// 
/// 示例：
/// ```dart
/// formatUnreadCount(0)   // ''
/// formatUnreadCount(50)  // '50'
/// formatUnreadCount(100) // '99+'
/// ```
String formatUnreadCount(int count) {
  if (count <= 0) return '';
  if (count > 99) return '99+';
  return count.toString();
}
