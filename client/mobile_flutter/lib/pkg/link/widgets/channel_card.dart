// 频道名片组件
//
// 用于显示频道的预览信息和订阅入口，以模态框形式展示

import 'package:flutter/material.dart';

import '../../ui/effects/effects.dart';
import '../../ui/theme/theme.dart';
import '../../ui/widgets/avatar_button.dart';
import '../../ui/widgets/subscriber_badge.dart';

/// 频道名片组件
///
/// 以模态框形式显示频道的基本信息，包括头像、名称、描述、订阅数等
/// 提供订阅/取消订阅按钮和打开频道入口
class ChannelCard extends StatefulWidget {
  const ChannelCard({
    super.key,
    required this.channelId,
    required this.channelName,
    this.description,
    this.avatarUrl,
    this.subscriberCount = 0,
    this.isSubscribed = false,
    this.onSubscribe,
    this.onOpen,
  });

  /// 频道 ID
  final String channelId;

  /// 频道名称
  final String channelName;

  /// 频道描述
  final String? description;

  /// 频道头像 URL
  final String? avatarUrl;

  /// 订阅者数量
  final int subscriberCount;

  /// 是否已订阅
  final bool isSubscribed;

  /// 订阅/取消订阅回调
  final VoidCallback? onSubscribe;

  /// 打开频道回调
  final VoidCallback? onOpen;

  /// 显示频道名片模态框
  static Future<void> show(
    BuildContext context, {
    required String channelId,
    required String channelName,
    String? description,
    String? avatarUrl,
    int subscriberCount = 0,
    bool isSubscribed = false,
    VoidCallback? onSubscribe,
    VoidCallback? onOpen,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ChannelCard(
        channelId: channelId,
        channelName: channelName,
        description: description,
        avatarUrl: avatarUrl,
        subscriberCount: subscriberCount,
        isSubscribed: isSubscribed,
        onSubscribe: onSubscribe,
        onOpen: onOpen,
      ),
    );
  }

  @override
  State<ChannelCard> createState() => _ChannelCardState();
}

class _ChannelCardState extends State<ChannelCard> {
  late bool _isSubscribed;

  @override
  void initState() {
    super.initState();
    _isSubscribed = widget.isSubscribed;
  }

  @override
  void didUpdateWidget(ChannelCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSubscribed != widget.isSubscribed) {
      _isSubscribed = widget.isSubscribed;
    }
  }

  void _handleSubscribe() {
    setState(() {
      _isSubscribed = !_isSubscribed;
    });
    widget.onSubscribe?.call();
  }

  void _handleOpen() {
    Navigator.of(context).pop();
    widget.onOpen?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.only(bottom: bottomPadding + 16),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽指示器
            _buildDragHandle(colors),
            // 频道信息
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(colors),
                  const SizedBox(height: 16),
                  _buildDescription(colors),
                  const SizedBox(height: 20),
                  _buildActions(colors),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建拖拽指示器
  Widget _buildDragHandle(AppColorScheme colors) {
    return Container(
      width: 36,
      height: 4,
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: colors.textTertiary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// 构建头部（头像、名称、订阅数）
  Widget _buildHeader(AppColorScheme colors) {
    // 获取频道名称首字母作为占位符
    final placeholder = widget.channelName.isNotEmpty
        ? widget.channelName[0].toUpperCase()
        : null;

    return Row(
      children: [
        // 头像
        AvatarButton(
          imageUrl: widget.avatarUrl,
          size: 56,
          placeholder: placeholder,
        ),
        const SizedBox(width: 14),
        // 名称和订阅数
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.channelName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                  height: 1.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              SubscriberBadge(
                count: widget.subscriberCount,
                size: SubscriberBadgeSize.medium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建描述区域
  Widget _buildDescription(AppColorScheme colors) {
    final description = widget.description;
    if (description == null || description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.textPrimary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        description,
        style: TextStyle(
          fontSize: 14,
          color: colors.textSecondary,
          height: 1.5,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// 构建操作按钮区域
  Widget _buildActions(AppColorScheme colors) {
    return Row(
      children: [
        // 订阅按钮
        Expanded(child: _buildSubscribeButton(colors)),
        const SizedBox(width: 12),
        // 打开频道按钮
        Expanded(child: _buildOpenButton(colors)),
      ],
    );
  }

  /// 构建订阅按钮
  Widget _buildSubscribeButton(AppColorScheme colors) {
    final isSubscribed = _isSubscribed;
    final buttonColor = isSubscribed ? colors.surfaceBase : colors.accent;
    final textColor = isSubscribed ? colors.textSecondary : Colors.white;
    final borderColor = isSubscribed ? colors.divider : Colors.transparent;

    return TapScale(
      onTap: _handleSubscribe,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSubscribed ? Icons.check_rounded : Icons.add_rounded,
                size: 18,
                color: textColor,
              ),
              const SizedBox(width: 4),
              Text(
                isSubscribed ? '已订阅' : '订阅',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建打开频道按钮
  Widget _buildOpenButton(AppColorScheme colors) {
    return TapScale(
      onTap: _handleOpen,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: colors.surfaceBase,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: colors.divider, width: 1),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.open_in_new_rounded,
                size: 18,
                color: colors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '打开频道',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
