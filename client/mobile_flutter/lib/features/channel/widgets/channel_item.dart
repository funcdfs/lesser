// 频道列表项组件

import 'package:flutter/material.dart';
import '../../../pkg/ui/effects/effects.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../../../pkg/ui/widgets/widgets.dart';
import '../models/channel_models.dart';

/// 频道列表项
///
/// 布局：头像 | 频道名+订阅数 / 最后消息 | 时间+状态 / 未读数
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colors.surfaceBase,
          border: Border(bottom: BorderSide(color: colors.divider, width: 0.5)),
        ),
        child: Row(
          children: [
            // 头像（带 Hero 动画）
            _ChannelAvatar(channel: channel),
            const SizedBox(width: 12),
            Expanded(
              child: _Content(channel: channel, colors: colors),
            ),
            const SizedBox(width: 8),
            _Trailing(channel: channel, colors: colors),
          ],
        ),
      ),
    );
  }
}

/// 频道头像（带 Hero 动画）
class _ChannelAvatar extends StatelessWidget {
  const _ChannelAvatar({required this.channel});

  final ChannelModel channel;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'channel_avatar_${channel.id}',
      // 保持 child 可见，避免动画结束时闪烁
      placeholderBuilder: (_, size, child) =>
          SizedBox(width: size.width, height: size.height, child: child),
      child: AvatarButton(
        imageUrl: channel.avatarUrl,
        size: 40,
        placeholder: channel.name.isNotEmpty ? channel.name[0] : '#',
        enableTapScale: false,
      ),
    );
  }
}

/// 中间内容：频道名 + 订阅数 / 最后消息
class _Content extends StatelessWidget {
  const _Content({required this.channel, required this.colors});

  final ChannelModel channel;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 频道名 + 订阅数
        Row(
          children: [
            Flexible(
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
            const SizedBox(width: 8),
            SubscriberBadge(count: channel.subscriberCount),
          ],
        ),
        const SizedBox(height: 5),
        // 最后消息
        _LastMessage(channel: channel, colors: colors),
      ],
    );
  }
}

/// 最后消息预览
class _LastMessage extends StatelessWidget {
  const _LastMessage({required this.channel, required this.colors});

  final ChannelModel channel;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
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
}

/// 右侧：时间 + 状态图标 / 未读数
class _Trailing extends StatelessWidget {
  const _Trailing({required this.channel, required this.colors});

  final ChannelModel channel;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 时间 + 状态图标
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (channel.isPinned)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.push_pin_rounded,
                  size: 13,
                  color: colors.textDisabled,
                ),
              ),
            if (channel.isMuted)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.notifications_off_rounded,
                  size: 13,
                  color: colors.textDisabled,
                ),
              ),
            if (channel.lastMessageTime != null)
              TimeBadge(
                time: channel.lastMessageTime!,
                size: TimeBadgeSize.medium,
              ),
          ],
        ),
        const SizedBox(height: 6),
        // 未读数
        if (channel.unreadCount > 0)
          UnreadBadge(count: channel.unreadCount, isMuted: channel.isMuted)
        else
          const SizedBox(height: 20),
      ],
    );
  }
}
