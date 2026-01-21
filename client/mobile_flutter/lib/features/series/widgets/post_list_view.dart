// =============================================================================
// 动态列表视图 - Post List View Widget
// =============================================================================
//
// ## 设计目的
// 封装剧集详情页的动态列表展示逻辑，支持日期分隔、动态高亮、滚动定位等功能。
// 将列表渲染逻辑从页面中抽离，提高代码可维护性。
//
// ## 核心功能
// - 混合列表：支持 DateTime（日期分隔符）和 SeriesPostModel（动态）两种类型
// - 动态高亮：支持深层链接导航时高亮目标动态
// - 滚动定位：通过 HighlightController 实现精确滚动到指定动态
// - 淡入动画：列表加载完成后有淡入效果
//
// ## 依赖组件
// - PostListController: 管理列表数据和日期分组
// - HighlightController: 管理动态高亮和滚动定位
// - DateSeparator: 日期分隔符组件
// - SeriesPost: 动态气泡组件
//
// ## 使用示例
// ```dart
// PostListView(
//   listController: _listController,
//   scrollController: _scrollController,
//   highlightController: _highlightController,
//   highlightedPostId: _highlightedPostId,
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
import '../models/series_post_model.dart';
import 'series_post.dart';
import 'date_separator.dart';
import 'post_list_controller.dart';

/// 动态列表视图
///
/// ## 参数说明
/// - [listController]: 列表数据控制器，提供混合列表项和日期集合
/// - [scrollController]: 滚动控制器，用于滚动定位
/// - [highlightController]: 高亮控制器，管理动态高亮状态
/// - [highlightedPostId]: 当前高亮的动态 ID
/// - [topPadding]: 顶部内边距（考虑 AppBar 和置顶横幅）
/// - [onHighlightComplete]: 高亮动画完成回调
/// - [onCommentTap]: 评论按钮点击回调
/// - [onMenuAction]: 动态菜单操作回调
/// - [onReactionTap]: 反应按钮点击回调
/// - [onDateSelected]: 日期选择回调（从年历选择器）
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
  final void Function(SeriesPostModel) onCommentTap;
  final void Function(SeriesPostMenuAction, SeriesPostModel)
  onMenuAction;
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
          final item = items[index];
          // 为每个列表项分配 GlobalKey，用于精确滚动定位
          final itemKey = highlightController.getKeyForIndex(index);

          if (item is DateItem) {
            return DateSeparator(
              key: itemKey,
              date: item.date,
              messageDates: postDates,
              onDateSelected: onDateSelected,
            );
          } else if (item is PostItem) {
            final post = item.post;
            final isHighlighted = highlightedPostId == post.id;
            return SeriesPost(
              key: itemKey,
              post: post,
              isHighlighted: isHighlighted,
              onHighlightComplete: isHighlighted ? onHighlightComplete : null,
              onCommentTap: () => onCommentTap(post),
              onMenuAction: (action) => onMenuAction(action, post),
              onReactionTap: onReactionTap,
            );
          }
          return SizedBox.shrink(key: itemKey);
        },
      ),
    );
  }
}

/// 空动态视图
///
/// 当剧集没有动态时显示的占位视图，包含图标和提示文字。
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
