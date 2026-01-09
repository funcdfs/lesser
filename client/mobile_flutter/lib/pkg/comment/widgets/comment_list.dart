// 评论列表组件

import 'package:flutter/material.dart';
import '../../ui/theme/theme.dart';
import '../models/comment_model.dart';
import 'comment_item.dart';
import 'message_header.dart';

/// 评论列表组件
class CommentList extends StatelessWidget {
  const CommentList({
    super.key,
    required this.state,
    required this.scrollController,
    required this.getDescendantCount,
    this.highlightedCommentId,
    this.messageHeader,
    this.headerBuilder,
    this.onMenuAction,
    this.onLikeTap,
    this.onViewReplies,
    this.onHighlightComplete,
  });

  final CommentListState state;
  final ScrollController scrollController;
  final int Function(String commentId) getDescendantCount;
  final String? highlightedCommentId; // 需要高亮的评论 ID
  final MessageHeaderData? messageHeader; // 消息头部数据（非线程视图时显示）
  final Widget Function(int commentCount)? headerBuilder; // 自定义头部构建器
  final void Function(CommentModel comment, CommentMenuAction action)?
  onMenuAction;
  final void Function(String commentId)? onLikeTap;
  final void Function(CommentModel comment)? onViewReplies;
  final VoidCallback? onHighlightComplete; // 高亮动画完成回调

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: colors.textDisabled,
        ),
      );
    }

    // 线程视图：即使没有子评论也要显示 rootComment
    final isThreadView = state.isThreadView;
    if (isThreadView) {
      // 线程视图：rootComment + 子评论列表
      final itemCount = state.comments.length + 1;
      return ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(vertical: 6),
        itemCount: itemCount,
        itemBuilder: (context, index) => _buildThreadItem(context, index),
      );
    }

    // 非线程视图：消息头部 + 评论列表
    final hasHeader = messageHeader != null || headerBuilder != null;
    final hasPinned = state.pinnedComment != null;

    // 计算总项数：头部(1) + 置顶评论(0或1) + 普通评论
    final itemCount =
        (hasHeader ? 1 : 0) + (hasPinned ? 1 : 0) + state.comments.length;

    // 如果没有头部且列表为空，显示空状态
    if (!hasHeader && state.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 40,
              color: colors.textDisabled,
            ),
            const SizedBox(height: 10),
            Text(
              '暂无评论',
              style: TextStyle(fontSize: 14, color: colors.textTertiary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 6),
      itemCount: itemCount,
      itemBuilder: (context, index) =>
          _buildListItem(index, hasHeader, hasPinned),
    );
  }

  /// 构建线程视图项
  Widget _buildThreadItem(BuildContext context, int index) {
    final colors = AppColors.of(context);

    // 根评论 - 带背景 + 精致分隔符
    if (index == 0) {
      final comment = state.rootComment!;
      final replyCount = state.comments.length;
      final isHighlighted = highlightedCommentId == comment.id;

      return Column(
        children: [
          // 根评论区域 - 带淡色背景
          Container(
            margin: const EdgeInsets.fromLTRB(6, 0, 6, 0),
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CommentItem(
              comment: comment,
              descendantCount: getDescendantCount(comment.id),
              showViewReplies: false,
              isHighlighted: isHighlighted,
              onMenuAction: (action) => onMenuAction?.call(comment, action),
              onLikeTap: () => onLikeTap?.call(comment.id),
              onHighlightComplete: isHighlighted ? onHighlightComplete : null,
            ),
          ),
          // 精致分隔符 - 回复指示器
          _RepliesDivider(replyCount: replyCount),
        ],
      );
    }

    // 子评论
    final comment = state.comments[index - 1];
    final isHighlighted = highlightedCommentId == comment.id;
    return CommentItem(
      comment: comment,
      descendantCount: getDescendantCount(comment.id),
      isHighlighted: isHighlighted,
      onMenuAction: (action) => onMenuAction?.call(comment, action),
      onLikeTap: () => onLikeTap?.call(comment.id),
      onViewReplies: () => onViewReplies?.call(comment),
      onHighlightComplete: isHighlighted ? onHighlightComplete : null,
    );
  }

  /// 构建普通列表项
  Widget _buildListItem(int index, bool hasHeader, bool hasPinned) {
    // 第一项是头部（如果有）
    if (hasHeader && index == 0) {
      // 优先使用自定义 headerBuilder
      if (headerBuilder != null) {
        return headerBuilder!(state.totalCount);
      }
      // 否则使用默认的 MessageHeader
      return MessageHeader(
        data: messageHeader!,
        commentCount: state.totalCount,
      );
    }

    // 调整索引（如果有头部）
    final adjustedIndex = hasHeader ? index - 1 : index;

    // 置顶评论
    if (hasPinned && adjustedIndex == 0) {
      final comment = state.pinnedComment!;
      final isHighlighted = highlightedCommentId == comment.id;
      return CommentItem(
        comment: comment,
        descendantCount: getDescendantCount(comment.id),
        isPinned: true,
        isHighlighted: isHighlighted,
        onMenuAction: (action) => onMenuAction?.call(comment, action),
        onLikeTap: () => onLikeTap?.call(comment.id),
        onViewReplies: () => onViewReplies?.call(comment),
        onHighlightComplete: isHighlighted ? onHighlightComplete : null,
      );
    }

    // 普通评论
    final commentIndex = hasPinned ? adjustedIndex - 1 : adjustedIndex;
    final comment = state.comments[commentIndex];
    final isHighlighted = highlightedCommentId == comment.id;
    return CommentItem(
      comment: comment,
      descendantCount: getDescendantCount(comment.id),
      isHighlighted: isHighlighted,
      onMenuAction: (action) => onMenuAction?.call(comment, action),
      onLikeTap: () => onLikeTap?.call(comment.id),
      onViewReplies: () => onViewReplies?.call(comment),
      onHighlightComplete: isHighlighted ? onHighlightComplete : null,
    );
  }
}

/// 回复分隔符 - 使用公共组件
class _RepliesDivider extends StatelessWidget {
  const _RepliesDivider({required this.replyCount});

  final int replyCount;

  @override
  Widget build(BuildContext context) {
    return CountDivider(count: replyCount, label: '条回复');
  }
}
