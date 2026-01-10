// =============================================================================
// 频道列表项组件
// =============================================================================
//
// 显示频道列表中的单个频道项，包含头像、名称、订阅数、最后消息和状态信息。
//
// ## 布局结构
//
// ```
// ┌─────────────────────────────────────────────────────────────┐
// │  [头像]  │  频道名称  订阅数      │  📌 🔕  时间           │
// │         │  最后消息预览...       │        未读数          │
// └─────────────────────────────────────────────────────────────┘
// ```
//
// ## 特性
//
// - Hero 动画：头像支持与详情页的共享元素过渡
// - 状态图标：显示置顶、静音状态
// - 未读徽章：显示未读消息数量
//
// ## 组件拆分
//
// 为保持代码清晰，将列表项拆分为多个私有 Widget：
// - `_ChannelAvatar` - 头像（带 Hero）
// - `_Content` - 中间内容区
// - `_LastMessage` - 最后消息预览
// - `_Trailing` - 右侧状态区

import 'package:flutter/material.dart';
import '../../../pkg/ui/effects/effects.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../../../pkg/ui/widgets/widgets.dart';
import '../models/channel_models.dart';
import 'channel_constants.dart';

/// 频道列表项
///
/// 显示频道的基本信息和状态，点击可进入频道详情页。
class ChannelItem extends StatelessWidget {
  const ChannelItem({
    super.key,
    required this.channel,
    this.uiState,
    this.onTap,
  });

  /// 频道数据
  final ChannelModel channel;

  /// UI 状态（未读数、静音、置顶）
  final ChannelUIState? uiState;

  /// 点击回调
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return TapScale(
      onTap: onTap,
      scale: TapScales.card,
      child: Container(
        padding: ChannelItemLayout.padding,
        decoration: BoxDecoration(
          color: colors.surfaceBase,
          border: Border(bottom: BorderSide(color: colors.divider, width: 0.5)),
        ),
        child: Row(
          children: [
            _ChannelAvatar(channel: channel),
            const SizedBox(width: ChannelItemLayout.avatarSpacing),
            Expanded(
              child: _Content(channel: channel, colors: colors),
            ),
            const SizedBox(width: ChannelItemLayout.trailingSpacing),
            _Trailing(channel: channel, uiState: uiState, colors: colors),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 私有子组件
// =============================================================================

/// 频道头像
///
/// 使用 Hero 动画实现与详情页的共享元素过渡。
class _ChannelAvatar extends StatelessWidget {
  const _ChannelAvatar({required this.channel});

  final ChannelModel channel;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'channel_avatar_${channel.id}',
      // placeholderBuilder 保持 child 可见，避免动画结束时闪烁
      placeholderBuilder: (_, size, child) =>
          SizedBox(width: size.width, height: size.height, child: child),
      child: AvatarButton(
        imageUrl: channel.avatarUrl,
        size: ChannelItemLayout.avatarSize,
        placeholder: channel.avatarPlaceholder,
        enableTapScale: false,
      ),
    );
  }
}

/// 中间内容区
///
/// 显示频道名称、订阅数和最后消息预览。
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
        // 第一行：频道名 + 订阅数
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
        const SizedBox(height: ChannelItemLayout.titleSpacing),
        // 第二行：最后消息预览
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
    final hasMessage = channel.hasLastMessage;

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

/// 右侧状态区
///
/// 显示时间、状态图标（置顶、静音）和未读徽章。
class _Trailing extends StatelessWidget {
  const _Trailing({required this.channel, this.uiState, required this.colors});

  final ChannelModel channel;
  final ChannelUIState? uiState;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final isPinned = uiState?.isPinned ?? false;
    final isMuted = uiState?.isMuted ?? false;
    final unreadCount = uiState?.unreadCount ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 第一行：状态图标 + 时间
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPinned)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.push_pin_rounded,
                  size: 13,
                  color: colors.textDisabled,
                ),
              ),
            if (isMuted)
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
        // 第二行：未读徽章或占位
        if (unreadCount > 0)
          UnreadBadge(count: unreadCount, isMuted: isMuted)
        else
          const SizedBox(height: ChannelItemLayout.unreadBadgeHeight),
      ],
    );
  }
}
