// =============================================================================
// 消息列表视图 - Message List View Widget
// =============================================================================
//
// ## 设计目的
// 封装频道详情页的消息列表展示逻辑，支持日期分隔、消息高亮、滚动定位等功能。
// 将列表渲染逻辑从页面中抽离，提高代码可维护性。
//
// ## 核心功能
// - 混合列表：支持 DateTime（日期分隔符）和 ChannelMessageModel（消息）两种类型
// - 消息高亮：支持深层链接导航时高亮目标消息
// - 滚动定位：通过 HighlightController 实现精确滚动到指定消息
// - 淡入动画：列表加载完成后有淡入效果
//
// ## 依赖组件
// - MessageListController: 管理列表数据和日期分组
// - HighlightController: 管理消息高亮和滚动定位
// - DateSeparator: 日期分隔符组件
// - ChannelMessage: 消息气泡组件
//
// ## 使用示例
// ```dart
// MessageListView(
//   listController: _listController,
//   scrollController: _scrollController,
//   highlightController: _highlightController,
//   highlightedMessageId: _highlightedMessageId,
//   topPadding: topPadding,
//   onHighlightComplete: _highlightController.onHighlightComplete,
//   onCommentTap: _openCommentPage,
//   onMenuAction: _handleMenuAction,
//   onReactionTap: (emoji) {},
//   onDateSelected: _scrollToDate,
// )
// ```
//
// =============================================================================

import 'package:flutter/material.dart';
import '../../../pkg/ui/effects/effects.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../models/channel_message_model.dart';
import 'channel_message.dart';
import 'date_separator.dart';
import 'message_list_controller.dart';

/// 消息列表视图
///
/// ## 参数说明
/// - [listController]: 列表数据控制器，提供混合列表项和日期集合
/// - [scrollController]: 滚动控制器，用于滚动定位
/// - [highlightController]: 高亮控制器，管理消息高亮状态
/// - [highlightedMessageId]: 当前高亮的消息 ID
/// - [topPadding]: 顶部内边距（考虑 AppBar 和置顶横幅）
/// - [onHighlightComplete]: 高亮动画完成回调
/// - [onCommentTap]: 评论按钮点击回调
/// - [onMenuAction]: 消息菜单操作回调
/// - [onReactionTap]: 反应按钮点击回调
/// - [onDateSelected]: 日期选择回调（从年历选择器）
class MessageListView extends StatelessWidget {
  const MessageListView({
    super.key,
    required this.listController,
    required this.scrollController,
    required this.highlightController,
    required this.highlightedMessageId,
    required this.topPadding,
    required this.onHighlightComplete,
    required this.onCommentTap,
    required this.onMenuAction,
    required this.onReactionTap,
    required this.onDateSelected,
  });

  final MessageListController listController;
  final ScrollController scrollController;
  final HighlightController highlightController;
  final String? highlightedMessageId;
  final double topPadding;
  final VoidCallback onHighlightComplete;
  final void Function(ChannelMessageModel) onCommentTap;
  final void Function(ChannelMessageMenuAction, ChannelMessageModel)
  onMenuAction;
  final void Function(String) onReactionTap;
  final void Function(DateTime) onDateSelected;

  @override
  Widget build(BuildContext context) {
    final items = listController.listItems;
    final messageDates = listController.messageDates;

    if (items.isEmpty) {
      return const _EmptyMessageView();
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: FadeInAnim.startOpacity, end: FadeInAnim.endOpacity),
      duration: FadeInAnim.duration,
      curve: FadeInAnim.curve,
      builder: (context, opacity, child) {
        return Opacity(opacity: opacity, child: child);
      },
      child: ListView.builder(
        controller: scrollController,
        padding: EdgeInsets.only(top: topPadding, bottom: 8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          // 为每个列表项分配 GlobalKey，用于精确滚动定位
          final itemKey = highlightController.getKeyForIndex(index);

          if (item is DateItem) {
            return DateSeparator(
              key: itemKey,
              date: item.date,
              messageDates: messageDates,
              onDateSelected: onDateSelected,
            );
          } else if (item is MessageItem) {
            final message = item.message;
            final isHighlighted = highlightedMessageId == message.id;
            return ChannelMessage(
              key: itemKey,
              message: message,
              isHighlighted: isHighlighted,
              onHighlightComplete: isHighlighted ? onHighlightComplete : null,
              onCommentTap: () => onCommentTap(message),
              onMenuAction: (action) => onMenuAction(action, message),
              onReactionTap: onReactionTap,
            );
          }
          return SizedBox.shrink(key: itemKey);
        },
      ),
    );
  }
}

/// 空消息视图
///
/// 当频道没有消息时显示的占位视图，包含图标和提示文字。
class _EmptyMessageView extends StatelessWidget {
  const _EmptyMessageView();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 64,
            color: colors.textDisabled,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无消息',
            style: TextStyle(fontSize: 16, color: colors.textTertiary),
          ),
        ],
      ),
    );
  }
}
