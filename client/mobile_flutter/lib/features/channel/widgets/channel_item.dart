// 频道列表项组件

import 'package:flutter/material.dart';
import '../../../pkg/ui/effects/effects.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../../../pkg/ui/widgets/widgets.dart';
import '../models/channel_models.dart';

/// 频道列表项 - 紧凑布局
/// 第一行：频道名 + 订阅数 | 时间 + 状态图标
/// 第二行：最后消息预览 | 未读徽章
class ChannelItem extends StatelessWidget {
  const ChannelItem({super.key, required this.channel, this.onTap});

  final ChannelModel channel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return TapScale(
      onTap: onTap,
      scale: TapScales.card,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: colors.surfaceBase,
          border: Border(bottom: BorderSide(color: colors.divider, width: 0.5)),
        ),
        child: Row(
          children: [
            // 头像（Hero 动画）
            Hero(
              tag: 'channel_avatar_${channel.id}',
              // 使用 placeholderBuilder 避免动画结束时的闪动
              placeholderBuilder: (context, heroSize, child) {
                return SizedBox(
                  width: heroSize.width,
                  height: heroSize.height,
                  child: child,
                );
              },
              flightShuttleBuilder: (context, anim, direction, fromCtx, toCtx) {
                // 使用目标 widget 作为飞行 shuttle，配合 FadeTransition 平滑过渡
                return FadeTransition(
                  opacity: anim,
                  child: Material(
                    color: Colors.transparent,
                    child: AvatarButton(
                      imageUrl: channel.avatarUrl,
                      size: 40,
                      placeholder: channel.name.isNotEmpty
                          ? channel.name[0]
                          : '#',
                    ),
                  ),
                );
              },
              child: AvatarButton(
                imageUrl: channel.avatarUrl,
                size: 40,
                placeholder: channel.name.isNotEmpty ? channel.name[0] : '#',
              ),
            ),
            const SizedBox(width: 12),

            // 中间内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 第一行：频道名 + 订阅数
                  _buildTitleRow(colors),
                  const SizedBox(height: 4),
                  // 第二行：最后消息预览
                  _buildMessageRow(colors),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // 右侧：时间 + 状态图标 + 未读数
            _buildRightColumn(colors),
          ],
        ),
      ),
    );
  }

  /// 第一行：频道名 + 订阅数徽章
  Widget _buildTitleRow(AppColorScheme colors) {
    return Row(
      children: [
        // 频道名称（Hero 动画）
        Flexible(
          child: Hero(
            tag: 'channel_name_${channel.id}',
            // 使用 placeholderBuilder 避免动画结束时的闪动
            placeholderBuilder: (context, heroSize, child) {
              return SizedBox(
                width: heroSize.width,
                height: heroSize.height,
                child: child,
              );
            },
            flightShuttleBuilder: (context, anim, direction, fromCtx, toCtx) {
              // 使用目标 widget 作为飞行 shuttle，配合 FadeTransition 平滑过渡
              return FadeTransition(
                opacity: anim,
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    channel.name,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              );
            },
            child: Material(
              color: Colors.transparent,
              child: Text(
                channel.name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        // 订阅数徽章（SVG 风格）
        SubscriberBadge(
          count: channel.subscriberCount,
          size: SubscriberBadgeSize.small,
        ),
      ],
    );
  }

  /// 第二行：最后消息预览
  Widget _buildMessageRow(AppColorScheme colors) {
    final hasMessage =
        channel.lastMessage != null && channel.lastMessage!.isNotEmpty;

    return Text(
      hasMessage ? channel.lastMessage! : '暂无消息',
      style: TextStyle(
        fontSize: 14,
        color: hasMessage ? colors.textSecondary : colors.textDisabled,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 右侧列：时间 + 状态图标 + 未读数
  Widget _buildRightColumn(AppColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 第一行：时间 + 状态图标
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 置顶图标
            if (channel.isPinned)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.push_pin_rounded,
                  size: 14,
                  color: colors.textTertiary,
                ),
              ),
            // 静音图标
            if (channel.isMuted)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.notifications_off_rounded,
                  size: 14,
                  color: colors.textTertiary,
                ),
              ),
            // 时间
            if (channel.lastMessageTime != null)
              Text(
                _formatTime(channel.lastMessageTime!),
                style: TextStyle(fontSize: 12, color: colors.textTertiary),
              ),
          ],
        ),
        const SizedBox(height: 6),
        // 第二行：未读数徽章
        if (channel.unreadCount > 0)
          UnreadBadge(count: channel.unreadCount, isMuted: channel.isMuted)
        else
          const SizedBox(height: 18), // 占位保持对齐
      ],
    );
  }

  /// 格式化时间
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays == 0) {
      // 今天：显示时间
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return '昨天';
    } else if (diff.inDays < 7) {
      const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      return weekdays[time.weekday - 1];
    } else {
      return '${time.month}/${time.day}';
    }
  }
}
