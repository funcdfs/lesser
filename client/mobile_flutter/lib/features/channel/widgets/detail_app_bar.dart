// =============================================================================
// 频道详情页 AppBar - Detail App Bar Widget
// =============================================================================
//
// ## 设计目的
// 为频道详情页提供统一的毛玻璃效果 AppBar，包含返回按钮、频道信息和更多操作。
// 使用 Hero 动画实现从列表页到详情页的头像过渡效果。
//
// ## 视觉设计
// - 毛玻璃背景效果（FrostedAppBar）
// - 底部细线分隔
// - 频道头像支持 Hero 动画
// - 显示频道名称和订阅者数量
//
// ## 组件结构
// - leading: 返回按钮
// - title: 频道标题组件（头像 + 名称 + 订阅数）
// - actions: 更多操作按钮
//
// ## 使用示例
// ```dart
// DetailAppBar(
//   channel: _channel,
//   channelId: widget.channelId,
//   moreButtonKey: _moreButtonKey,
//   onBack: () => Navigator.pop(context),
//   onMoreTap: _showMoreMenu,
// )
// ```
//
// =============================================================================

import 'package:flutter/material.dart';
import '../../../pkg/ui/effects/effects.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../../../pkg/ui/widgets/widgets.dart';
import '../models/channel_model.dart';

/// 频道详情页毛玻璃 AppBar
///
/// ## 参数说明
/// - [channel]: 频道数据模型（可为 null，加载中状态）
/// - [channelId]: 频道 ID，用于 Hero 动画 tag
/// - [moreButtonKey]: 更多按钮的 GlobalKey，用于弹出菜单定位
/// - [onBack]: 返回按钮回调
/// - [onMoreTap]: 更多按钮回调
class DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DetailAppBar({
    super.key,
    required this.channel,
    required this.channelId,
    required this.moreButtonKey,
    required this.onBack,
    required this.onMoreTap,
  });

  final ChannelModel? channel;
  final String channelId;
  final GlobalKey moreButtonKey;
  final VoidCallback onBack;
  final VoidCallback onMoreTap;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return FrostedAppBar(
      blur: 20,
      opacity: 0.8,
      border: Border(bottom: BorderSide(color: colors.divider, width: 0.5)),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_rounded,
          size: 22,
          color: colors.textPrimary,
        ),
        onPressed: onBack,
      ),
      title: channel == null
          ? null
          : _ChannelTitle(channel: channel!, channelId: channelId),
      actions: [
        IconButton(
          key: moreButtonKey,
          icon: Icon(Icons.more_vert_rounded, color: colors.textPrimary),
          onPressed: onMoreTap,
        ),
      ],
    );
  }
}

/// 频道标题组件
///
/// 显示频道头像、名称和订阅者数量。
/// 头像使用 Hero 动画，实现从列表页到详情页的平滑过渡。
class _ChannelTitle extends StatelessWidget {
  const _ChannelTitle({required this.channel, required this.channelId});

  final ChannelModel channel;
  final String channelId;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Row(
      children: [
        // 头像 Hero
        Hero(
          tag: 'channel_avatar_$channelId',
          placeholderBuilder: (_, size, child) =>
              SizedBox(width: size.width, height: size.height, child: child),
          child: AvatarButton(
            imageUrl: channel.avatarUrl,
            size: 40,
            placeholder: channel.avatarPlaceholder,
            enableTapScale: false,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                channel.displayName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              SubscriberBadge(
                count: channel.subscriberCount,
                size: SubscriberBadgeSize.small,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
