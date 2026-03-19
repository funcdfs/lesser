// =============================================================================
// 动态列表视图 - Post List View Widget
// =============================================================================
//
// ## 设计目的
// 封装剧集详情页的动态列表展示逻辑，支持日期分隔、动态高亮、滚动定位等功能。
// 将列表渲染逻辑从页面中抽离，提高代码可维护性。
//
// ## 核心功能
// - 混合列表：支持 DateTime（日期分隔符）和 MessageModel（动态）两种类型
// - 动态高亮：支持深层链接导航时高亮目标动态
// - 滚动定位：通过 HighlightController 实现精确滚动到指定动态
// - 淡入动画：列表加载完成后有淡入效果
//
// ## 依赖组件
// - PostListController: 管理列表数据和日期分组
// - HighlightController: 管理动态高亮和滚动定位
// - DateSeparator: 日期分隔符组件
// - MessageItem: 消息气泡组件
//
// =============================================================================

import 'package:flutter/material.dart';
import '../../../pkg/ui/effects/effects.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../models/message_model.dart';
import 'message_item.dart';
import 'date_separator.dart';
import 'post_list_controller.dart';

/// 动态列表视图 (普通 ListView 版本)
class PostListView extends StatelessWidget {
  const PostListView({
    super.key,
    required this.listController,
    required this.scrollController,
    required this.highlightController,
    required this.highlightedPostId,
    required this.topPadding,
    required this.onHighlightComplete,
    required this.onCommentTap,
    required this.onMenuAction,
    required this.onReactionTap,
    required this.onDateSelected,
  });

  final PostListController listController;
  final ScrollController scrollController;
  final HighlightController highlightController;
  final String? highlightedPostId;
  final double topPadding;
  final VoidCallback onHighlightComplete;
  final void Function(MessageModel) onCommentTap;
  final void Function(MessageMenuAction, MessageModel) onMenuAction;
  final void Function(String) onReactionTap;
  final void Function(DateTime) onDateSelected;

  @override
  Widget build(BuildContext context) {
    final items = listController.listItems;
    final postDates = listController.postDates;

    if (items.isEmpty) {
      return const _EmptyPostView();
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
          return _buildItem(context, items[index], postDates);
        },
      ),
    );
  }

  Widget _buildItem(BuildContext context, dynamic item, Set<DateTime> postDates) {
    if (item is DateItem) {
      return DateSeparator(
        key: ValueKey(item.date),
        date: item.date,
        messageDates: postDates,
        onDateSelected: onDateSelected,
      );
    } else if (item is PostItem) {
      final post = item.post;
      final isHighlighted = highlightedPostId == post.id;
      return MessageItem(
        key: isHighlighted ? ValueKey(post.id) : null,
        message: post,
        isHighlighted: isHighlighted,
        onHighlightComplete: isHighlighted ? onHighlightComplete : null,
        onCommentTap: () => onCommentTap(post),
        onMenuAction: (action) => onMenuAction(action, post),
        onReactionTap: onReactionTap,
      );
    }
    return const SizedBox.shrink();
  }
}

/// Sliver 版本的动态列表视图
class PostListViewSliver extends StatelessWidget {
  const PostListViewSliver({
    super.key,
    required this.listController,
    required this.highlightController,
    required this.highlightedPostId,
    required this.onHighlightComplete,
    required this.onCommentTap,
    required this.onMenuAction,
    required this.onReactionTap,
    required this.onDateSelected,
    required this.posts,
  });

  final PostListController listController;
  final HighlightController highlightController;
  final String? highlightedPostId;
  final VoidCallback onHighlightComplete;
  final void Function(MessageModel) onCommentTap;
  final void Function(MessageMenuAction, MessageModel) onMenuAction;
  final void Function(String) onReactionTap;
  final void Function(DateTime) onDateSelected;
  final List<MessageModel> posts;

  @override
  Widget build(BuildContext context) {
    final items = listController.listItems;
    final postDates = listController.postDates;

    if (items.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: _EmptyPostView(),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = items[index];
          if (item is DateItem) {
            return DateSeparator(
              key: ValueKey(item.date),
              date: item.date,
              messageDates: postDates,
              onDateSelected: onDateSelected,
            );
          } else if (item is PostItem) {
            final post = item.post;
            final isHighlighted = highlightedPostId == post.id;
            return MessageItem(
              key: isHighlighted ? ValueKey(post.id) : null,
              message: post,
              isHighlighted: isHighlighted,
              onHighlightComplete: isHighlighted ? onHighlightComplete : null,
              onCommentTap: () => onCommentTap(post),
              onMenuAction: (action) => onMenuAction(action, post),
              onReactionTap: onReactionTap,
            );
          }
          return const SizedBox.shrink();
        },
        childCount: items.length,
      ),
    );
  }
}

/// 空动态视图
class _EmptyPostView extends StatelessWidget {
  const _EmptyPostView();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dynamic_feed_rounded,
            size: 64,
            color: colors.textDisabled,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无动态',
            style: TextStyle(fontSize: 16, color: colors.textTertiary),
          ),
        ],
      ),
    );
  }
}
