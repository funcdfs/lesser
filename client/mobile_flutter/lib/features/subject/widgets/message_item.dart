// =============================================================================
// 剧集消息组件 - Message Item
// =============================================================================
//
// Telegram Channel 风格的消息气泡组件，支持文本、链接、反应和评论入口。
//
// ## 视觉设计
// - 深色/浅色自适应气泡
// - 精致边框和微妙阴影
// - 反应标签在气泡内底部左侧
// - 浏览量和时间在气泡内底部右侧
// - 评论入口在气泡外下方（与气泡视觉连接）
//
// =============================================================================

import 'package:flutter/material.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../../../pkg/ui/effects/effects.dart';
import '../../../pkg/ui/widgets/avatar_stack.dart';
import '../../../pkg/ui/widgets/dotted_divider.dart';
import '../../../pkg/ui/widgets/context_menu.dart';
import '../../../pkg/utils/format_utils.dart';
import '../models/subject_models.dart';
import 'subject_constants.dart';

// =============================================================================
// 布局常量
// =============================================================================

abstract final class BubbleLayout {
  static const EdgeInsets padding = EdgeInsets.fromLTRB(14, 12, 14, 10);
  static const double borderRadius = 16.0;
  static const double connectedRadius = 4.0;
  static const double linkBorderRadius = 10.0;
  static const double reactionBorderRadius = 14.0;
  static const double contentFontSize = 15.0;
  static const double contentLineHeight = 1.45;
  static const double footerFontSize = 11.0;
}

abstract final class CommentEntryLayout {
  static const EdgeInsets padding = EdgeInsets.fromLTRB(14, 9, 10, 11);
  static const EdgeInsets dividerPadding = EdgeInsets.symmetric(horizontal: 14);
  static const double avatarSize = 22.0;
}

// =============================================================================
// 菜单操作类型
// =============================================================================

enum MessageMenuAction {
  save,
  forward,
  detail,
}

// =============================================================================
// 消息气泡组件 (MessageBubble)
// =============================================================================

/// 剧集消息气泡组件
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    this.onTap,
    this.onLinkTap,
    this.onReactionTap,
    this.onLongPress,
    this.showBottomRadius = true,
  });

  final MessageModel message;
  final VoidCallback? onTap;
  final ValueChanged<String>? onLinkTap;
  final ValueChanged<String>? onReactionTap;
  final void Function(LongPressStartDetails)? onLongPress;
  final bool showBottomRadius;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final linkUrl = message.linkUrl;

    return GestureDetector(
      onLongPressStart: onLongPress,
      child: TapScale(
        onTap: onTap,
        scale: TapScales.large,
        haptic: false,
        child: _BubbleContainer(
          colors: colors,
          isDark: isDark,
          showBottomRadius: showBottomRadius,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _MessageContent(content: message.content, colors: colors),
              if (linkUrl != null) ...[
                const SizedBox(height: 10),
                _LinkPreview(
                  linkUrl: linkUrl,
                  linkTitle: message.linkTitle,
                  colors: colors,
                  onTap: onLinkTap,
                ),
              ],
              const SizedBox(height: 12),
              _MessageFooter(
                message: message,
                colors: colors,
                onReactionTap: onReactionTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BubbleContainer extends StatelessWidget {
  const _BubbleContainer({
    required this.colors,
    required this.isDark,
    required this.showBottomRadius,
    required this.child,
  });

  final AppColorScheme colors;
  final bool isDark;
  final bool showBottomRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: BubbleLayout.padding,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(BubbleLayout.borderRadius),
          topRight: const Radius.circular(BubbleLayout.borderRadius),
          bottomLeft: Radius.circular(
            showBottomRadius ? BubbleLayout.borderRadius : BubbleLayout.connectedRadius,
          ),
          bottomRight: Radius.circular(
            showBottomRadius ? BubbleLayout.borderRadius : BubbleLayout.connectedRadius,
          ),
        ),
        border: Border.all(
          color: colors.divider.withValues(alpha: isDark ? 0.12 : 0.06),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: isDark ? 0.1 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MessageContent extends StatelessWidget {
  const _MessageContent({required this.content, required this.colors});
  final String content;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Text(
      content,
      style: TextStyle(
        fontSize: BubbleLayout.contentFontSize,
        height: BubbleLayout.contentLineHeight,
        color: colors.textPrimary,
        letterSpacing: 0.1,
      ),
    );
  }
}

class _LinkPreview extends StatelessWidget {
  const _LinkPreview({required this.linkUrl, this.linkTitle, required this.colors, this.onTap});
  final String linkUrl;
  final String? linkTitle;
  final AppColorScheme colors;
  final ValueChanged<String>? onTap;

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: () => onTap?.call(linkUrl),
      scale: TapScales.card,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: colors.accentSoft,
          borderRadius: BorderRadius.circular(BubbleLayout.linkBorderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.link_rounded, size: 15, color: colors.accent),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                linkTitle ?? linkUrl,
                style: TextStyle(
                  fontSize: 13,
                  color: colors.accent,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageFooter extends StatelessWidget {
  const _MessageFooter({required this.message, required this.colors, this.onReactionTap});
  final MessageModel message;
  final AppColorScheme colors;
  final ValueChanged<String>? onReactionTap;

  @override
  Widget build(BuildContext context) {
    final hasReactions = message.hasReactions;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (hasReactions)
          Expanded(
            child: _ReactionList(
              reactions: message.displayReactions,
              onReactionTap: onReactionTap,
            ),
          )
        else
          const Spacer(),
        _ViewsAndTime(message: message, colors: colors),
      ],
    );
  }
}

class _ReactionList extends StatelessWidget {
  const _ReactionList({required this.reactions, this.onReactionTap});
  final List<ReactionSummary> reactions;
  final ValueChanged<String>? onReactionTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        for (final r in reactions) _ReactionChip(reaction: r, onEmojiTap: onReactionTap),
      ],
    );
  }
}

class _ViewsAndTime extends StatelessWidget {
  const _ViewsAndTime({required this.message, required this.colors});
  final MessageModel message;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final isEdited = message.isEdited || (message.updatedAt != null && message.updatedAt != message.createdAt);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.visibility_rounded, size: 13, color: colors.textDisabled),
        const SizedBox(width: 3),
        Text(
          formatCountEnglish(message.viewCount),
          style: TextStyle(fontSize: BubbleLayout.footerFontSize, color: colors.textDisabled),
        ),
        if (isEdited) ...[
          const SizedBox(width: 4),
          Text(
            'edited',
            style: TextStyle(fontSize: BubbleLayout.footerFontSize, color: colors.textDisabled),
          ),
        ],
        const SizedBox(width: 4),
        Text(
          formatTimeHHmm(message.createdAt),
          style: TextStyle(fontSize: BubbleLayout.footerFontSize, color: colors.textDisabled),
        ),
      ],
    );
  }
}

// =============================================================================
// 完整消息项组件 (MessageItem)
// =============================================================================

const _quickEmojis = ['👍', '❤️', '🔥', '👏', '😢', '😡'];

/// 剧集消息项组件
class MessageItem extends StatefulWidget {
  const MessageItem({
    super.key,
    required this.message,
    this.onTap,
    this.onLinkTap,
    this.onReactionTap,
    this.onCommentTap,
    this.onMenuAction,
    this.isAdmin = false,
    this.isHighlighted = false,
    this.onHighlightComplete,
  });

  final MessageModel message;
  final VoidCallback? onTap;
  final ValueChanged<String>? onLinkTap;
  final ValueChanged<String>? onReactionTap;
  final VoidCallback? onCommentTap;
  final void Function(MessageMenuAction action)? onMenuAction;
  final bool isAdmin;
  final bool isHighlighted;
  final VoidCallback? onHighlightComplete;

  @override
  State<MessageItem> createState() => _MessageItemState();
}

class _MessageItemState extends State<MessageItem> {
  static const _menuItems = [
    ContextMenuItem(icon: Icons.bookmark_outline_rounded, label: '保存', value: 'save'),
    ContextMenuItem(icon: Icons.reply_rounded, label: '转发', value: 'forward'),
    ContextMenuItem(icon: Icons.info_outline_rounded, label: '详情', value: 'detail'),
  ];

  static const _menuActionMap = {
    'save': MessageMenuAction.save,
    'forward': MessageMenuAction.forward,
    'detail': MessageMenuAction.detail,
  };

  void _showContextMenu(LongPressStartDetails details) {
    showContextMenu(
      context: context,
      position: details.globalPosition,
      items: _menuItems,
      quickEmojis: _quickEmojis,
      onSelected: _handleMenuSelection,
      onEmojiSelected: widget.onReactionTap,
    );
  }

  void _handleMenuSelection(String value) {
    final action = _menuActionMap[value] ?? MessageMenuAction.detail;
    widget.onMenuAction?.call(action);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final maxWidth = MediaQuery.sizeOf(context).width * SubjectLayoutConstants.messageMaxWidthRatio;
    final hasCommentEntry = widget.message.hasComments;

    Widget content = Padding(
      padding: SubjectLayoutConstants.messagePadding,
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                MessageBubble(
                  message: widget.message,
                  onTap: widget.onTap,
                  onLinkTap: widget.onLinkTap,
                  onReactionTap: widget.onReactionTap,
                  onLongPress: _showContextMenu,
                  showBottomRadius: !hasCommentEntry,
                ),
                if (hasCommentEntry)
                  _CommentEntry(message: widget.message, colors: colors, onTap: widget.onCommentTap),
              ],
            ),
          ),
        ),
      ),
    );

    if (widget.isHighlighted) {
      content = HighlightEffect(
        isHighlighted: true,
        onHighlightComplete: widget.onHighlightComplete,
        child: content,
      );
    }

    return content;
  }
}

class _CommentEntry extends StatelessWidget {
  const _CommentEntry({required this.message, required this.colors, this.onTap});
  final MessageModel message;
  final AppColorScheme colors;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TapScale(
      onTap: onTap,
      scale: TapScales.card,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(BubbleLayout.borderRadius),
            bottomRight: Radius.circular(BubbleLayout.borderRadius),
          ),
          border: Border.all(color: colors.divider.withValues(alpha: isDark ? 0.1 : 0.05), width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: CommentEntryLayout.dividerPadding,
              child: DottedDivider(
                color: colors.divider.withValues(alpha: 0.5),
                strokeWidth: 1.0,
                dashWidth: 2.0,
                dashSpace: 3.0,
              ),
            ),
            Padding(
              padding: CommentEntryLayout.padding,
              child: Row(
                children: [
                  if (message.commentAvatars.isNotEmpty) ...[
                    AvatarStack(avatarUrls: message.commentAvatars.take(3).toList(), size: CommentEntryLayout.avatarSize),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    '${message.commentCount} 条评论',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.textSecondary),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded, size: 18, color: colors.textTertiary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReactionChip extends StatelessWidget {
  const _ReactionChip({required this.reaction, this.onEmojiTap});
  final ReactionSummary reaction;
  final ValueChanged<String>? onEmojiTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isSelected = reaction.isSelected;
    return TapScale(
      onTap: onEmojiTap != null ? () => onEmojiTap?.call(reaction.emoji) : null,
      scale: TapScales.small,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? colors.interactive.withValues(alpha: 0.15) : colors.surfaceBase.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(BubbleLayout.reactionBorderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(reaction.emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              reaction.formattedCount,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isSelected ? colors.interactive : colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
