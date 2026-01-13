// 评论列表组件

import 'package:flutter/material.dart';
import '../../ui/effects/effects.dart';
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
    this.highlightHeader = false,
    this.channelId,
    this.messageId,
    this.messageHeader,
    this.headerBuilder,
    this.headerKey,
    this.onMenuAction,
    this.onLikeTap,
    this.onViewReplies,
    this.onHighlightComplete,
    this.onHeaderHighlightComplete,
    this.getCommentKey,
    this.onQuoteTap,
  });

  final CommentListState state;
  final ScrollController scrollController;
  final int Function(String commentId) getDescendantCount;
  final String? highlightedCommentId;

  /// 是否高亮 header
  final bool highlightHeader;

  /// 频道 ID（用于回复引用的 Link 跳转）
  final String? channelId;

  /// 消息 ID（用于回复引用的 Link 跳转）
  final String? messageId;

  final MessageHeaderData? messageHeader;
  final Widget Function(int commentCount)? headerBuilder;

  /// Header 的 GlobalKey（用于滚动定位，仅在使用默认 MessageHeader 时需要）
  final GlobalKey? headerKey;

  final void Function(CommentModel comment, CommentMenuAction action)?
  onMenuAction;
  final void Function(String commentId)? onLikeTap;
  final void Function(CommentModel comment)? onViewReplies;
  final VoidCallback? onHighlightComplete;

  /// Header 高亮完成回调
  final VoidCallback? onHeaderHighlightComplete;

  /// 获取评论的 GlobalKey（用于滚动定位）
  final GlobalKey Function(String commentId)? getCommentKey;

  /// 引用点击回调（跳转到被引用的评论）
  final void Function(String commentId)? onQuoteTap;

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
        // 性能优化
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true,
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
      // 性能优化
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
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
      final commentKey = getCommentKey?.call(comment.id);

      return Column(
        key: commentKey,
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
              channelId: channelId,
              messageId: messageId,
              onMenuAction: onMenuAction == null
                  ? null
                  : (action) => onMenuAction!(comment, action),
              onLikeTap: onLikeTap == null
                  ? null
                  : () => onLikeTap!(comment.id),
              onHighlightComplete: isHighlighted ? onHighlightComplete : null,
              onQuoteTap: onQuoteTap,
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
    final commentKey = getCommentKey?.call(comment.id);

    return CommentItem(
      key: commentKey,
      comment: comment,
      descendantCount: getDescendantCount(comment.id),
      isHighlighted: isHighlighted,
      channelId: channelId,
      messageId: messageId,
      onMenuAction: onMenuAction == null
          ? null
          : (action) => onMenuAction!(comment, action),
      onLikeTap: onLikeTap == null ? null : () => onLikeTap!(comment.id),
      onViewReplies: onViewReplies == null
          ? null
          : () => onViewReplies!(comment),
      onHighlightComplete: isHighlighted ? onHighlightComplete : null,
      onQuoteTap: onQuoteTap,
    );
  }

  /// 构建普通列表项
  Widget _buildListItem(int index, bool hasHeader, bool hasPinned) {
    // 第一项是头部（如果有）
    if (hasHeader && index == 0) {
      // 优先使用自定义 headerBuilder
      if (headerBuilder != null) {
        // 自定义 header 已经在外部包裹了 KeyedSubtree，这里包裹高亮效果
        return HighlightEffect(
          isHighlighted: highlightHeader,
          onHighlightComplete: onHeaderHighlightComplete,
          child: headerBuilder!(state.totalCount),
        );
      }
      // 否则使用默认的 MessageHeader，包裹高亮效果
      return KeyedSubtree(
        key: headerKey,
        child: HighlightEffect(
          isHighlighted: highlightHeader,
          onHighlightComplete: onHeaderHighlightComplete,
          child: MessageHeader(
            data: messageHeader!,
            commentCount: state.totalCount,
          ),
        ),
      );
    }

    // 调整索引（如果有头部）
    final adjustedIndex = hasHeader ? index - 1 : index;

    // 置顶评论
    if (hasPinned && adjustedIndex == 0) {
      final comment = state.pinnedComment!;
      final isHighlighted = highlightedCommentId == comment.id;
      final commentKey = getCommentKey?.call(comment.id);

      return CommentItem(
        key: commentKey,
        comment: comment,
        descendantCount: getDescendantCount(comment.id),
        isPinned: true,
        isHighlighted: isHighlighted,
        channelId: channelId,
        messageId: messageId,
        onMenuAction: onMenuAction == null
            ? null
            : (action) => onMenuAction!(comment, action),
        onLikeTap: onLikeTap == null ? null : () => onLikeTap!(comment.id),
        onViewReplies: onViewReplies == null
            ? null
            : () => onViewReplies!(comment),
        onHighlightComplete: isHighlighted ? onHighlightComplete : null,
        onQuoteTap: onQuoteTap,
      );
    }

    // 普通评论
    final commentIndex = hasPinned ? adjustedIndex - 1 : adjustedIndex;
    final comment = state.comments[commentIndex];
    final isHighlighted = highlightedCommentId == comment.id;
    final commentKey = getCommentKey?.call(comment.id);

    return CommentItem(
      key: commentKey,
      comment: comment,
      descendantCount: getDescendantCount(comment.id),
      isHighlighted: isHighlighted,
      channelId: channelId,
      messageId: messageId,
      onMenuAction: onMenuAction == null
          ? null
          : (action) => onMenuAction!(comment, action),
      onLikeTap: onLikeTap == null ? null : () => onLikeTap!(comment.id),
      onViewReplies: onViewReplies == null
          ? null
          : () => onViewReplies!(comment),
      onHighlightComplete: isHighlighted ? onHighlightComplete : null,
      onQuoteTap: onQuoteTap,
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
