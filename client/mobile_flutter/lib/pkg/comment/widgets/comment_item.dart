// 评论项组件

import 'package:flutter/material.dart';
import '../../ui/widgets/avatar_button.dart';
import '../../ui/widgets/context_menu.dart';
import '../models/comment_model.dart';
import '../utils.dart';
import 'comment_bubble.dart';
import 'comment_actions.dart';
import 'comment_highlight.dart';

/// 评论菜单操作类型
enum CommentMenuAction {
  reply, // 回复
  copy, // 复制
  copyLink, // 复制链接
  forward, // 转发
  forwardNoQuote, // 无引用转发
  save, // 保存消息
  share, // 分享
  detail, // 详情
}

/// 评论项组件
class CommentItem extends StatelessWidget {
  const CommentItem({
    super.key,
    required this.comment,
    required this.descendantCount,
    this.isPinned = false,
    this.showViewReplies = true,
    this.isHighlighted = false,
    this.onMenuAction,
    this.onLikeTap,
    this.onViewReplies,
    this.onHighlightComplete,
  });

  final CommentModel comment;
  final int descendantCount;
  final bool isPinned;
  final bool showViewReplies; // 是否显示展开回复按钮
  final bool isHighlighted; // 是否高亮显示（深层链接导航时）
  final void Function(CommentMenuAction action)? onMenuAction;
  final VoidCallback? onLikeTap;
  final VoidCallback? onViewReplies;
  final VoidCallback? onHighlightComplete; // 高亮动画完成回调

  /// 显示上下文菜单（点按触发）
  void _showContextMenu(BuildContext context, TapUpDetails details) {
    // 已删除的评论不显示菜单
    if (comment.isDeleted) return;

    final items = [
      const ContextMenuItem(
        icon: Icons.reply_rounded,
        label: '回复',
        value: 'reply',
      ),
      const ContextMenuItem(
        icon: Icons.copy_rounded,
        label: '复制',
        value: 'copy',
      ),
      const ContextMenuItem(
        icon: Icons.link_rounded,
        label: '复制链接',
        value: 'copyLink',
      ),
      const ContextMenuItem(
        icon: Icons.shortcut_rounded,
        label: '转发',
        value: 'forward',
      ),
      const ContextMenuItem(
        icon: Icons.forward_rounded,
        label: '无引用转发',
        value: 'forwardNoQuote',
      ),
      const ContextMenuItem(
        icon: Icons.bookmark_outline_rounded,
        label: '保存消息',
        value: 'save',
      ),
      const ContextMenuItem(
        icon: Icons.share_rounded,
        label: '分享',
        value: 'share',
      ),
      const ContextMenuItem(
        icon: Icons.info_outline_rounded,
        label: '详情',
        value: 'detail',
      ),
    ];

    showContextMenu(
      context: context,
      position: details.globalPosition,
      items: items,
      onSelected: (value) {
        final action = CommentMenuAction.values.firstWhere(
          (e) => e.name == value,
          orElse: () => CommentMenuAction.reply,
        );
        onMenuAction?.call(action);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final nameColor = getNameColor(comment.author.id);
    final screenWidth = MediaQuery.of(context).size.width;
    final maxBubbleWidth = screenWidth * 0.75;
    const minBubbleWidth = 120.0;

    // 计算回复按钮状态
    final replyState = _getReplyState();

    Widget content = GestureDetector(
      onTapUp: (details) => _showContextMenu(context, details),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: AvatarButton(
                imageUrl: comment.author.avatarUrl,
                size: 32,
                placeholder: comment.author.displayName.isNotEmpty
                    ? comment.author.displayName[0]
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            // 气泡
            ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: minBubbleWidth,
                maxWidth: maxBubbleWidth,
              ),
              child: CommentBubble(
                displayName: comment.author.displayName,
                username: comment.author.username,
                roleLabel: comment.author.roleLabel,
                isVerified: comment.author.isVerified,
                createdAt: comment.createdAt,
                content: comment.content,
                nameColor: nameColor,
                replyTo: comment.replyTo,
                isPinned: isPinned,
                isDeleted: comment.isDeleted,
                trailing: CommentActions(
                  likeCount: comment.likeCount,
                  replyCount: showViewReplies ? descendantCount : 0,
                  isLiked: comment.isLiked,
                  replyState: replyState,
                  onLikeTap: onLikeTap,
                  onReplyTap: replyState.canExpand ? onViewReplies : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // 如果需要高亮，包裹高亮动画组件
    if (isHighlighted) {
      content = CommentHighlight(
        isHighlighted: true,
        onHighlightComplete: onHighlightComplete,
        child: content,
      );
    }

    return content;
  }

  /// 计算回复按钮状态
  ReplyButtonState _getReplyState() {
    // 已删除 - 禁用
    if (comment.isDeleted) {
      return ReplyButtonState.disabled;
    }
    // 不显示展开（根评论）- 隐藏
    if (!showViewReplies) {
      return ReplyButtonState.hidden;
    }
    // 被封禁 - 禁止
    if (comment.interactionState == CommentIconState.banned) {
      return ReplyButtonState.banned;
    }
    // 允许展开（可进入该评论的线程）
    return ReplyButtonState.expandable;
  }
}
