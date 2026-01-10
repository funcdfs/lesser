// 频道消息组件
//
// Telegram Channel 风格：
// - 深色气泡，无边框
// - 反应标签在气泡内底部左侧
// - 浏览量和时间在气泡内底部右侧
// - 评论入口在气泡外下方

import 'package:flutter/material.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../../../pkg/ui/effects/effects.dart';
import '../../../pkg/ui/widgets/avatar_stack.dart';
import '../../../pkg/ui/widgets/dotted_divider.dart';
import '../../../pkg/ui/widgets/context_menu.dart';
import '../../../pkg/utils/format_utils.dart';
import '../models/channel_models.dart';

// ============================================================================
// 布局常量
// ============================================================================

/// 气泡布局常量
class _BubbleLayout {
  _BubbleLayout._();

  // 内边距
  static const EdgeInsets padding = EdgeInsets.fromLTRB(14, 12, 14, 10);

  // 圆角
  static const double borderRadius = 16.0;
  static const double connectedRadius = 4.0; // 连接评论入口时的小圆角
  static const double linkBorderRadius = 10.0;
  static const double reactionBorderRadius = 14.0;

  // 字体
  static const double contentFontSize = 15.0;
  static const double contentLineHeight = 1.45;
  static const double footerFontSize = 11.0;
}

/// 评论入口布局常量
class _CommentEntryLayout {
  _CommentEntryLayout._();

  static const EdgeInsets padding = EdgeInsets.fromLTRB(14, 9, 10, 11);
  static const EdgeInsets dividerPadding = EdgeInsets.symmetric(horizontal: 14);
  static const double avatarSize = 22.0;
}

/// 频道消息菜单操作类型
enum ChannelMessageMenuAction {
  save, // 保存
  forward, // 转发
  detail, // 详情
}

/// 频道消息气泡组件（Part1）
///
/// 只包含消息内容 + reactions + 浏览量时间，不包含评论入口。
/// 可独立复用于评论页头部等场景。
class ChannelMessageBubble extends StatelessWidget {
  const ChannelMessageBubble({
    super.key,
    required this.message,
    this.onTap,
    this.onLinkTap,
    this.onReactionTap,
    this.onLongPress,
    this.showBottomRadius = true, // 是否显示底部圆角（独立使用时为 true）
  });

  final ChannelMessageModel message;
  final VoidCallback? onTap;
  final ValueChanged<String>? onLinkTap;
  final ValueChanged<String>? onReactionTap;
  final void Function(LongPressStartDetails)? onLongPress;
  final bool showBottomRadius;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onLongPressStart: onLongPress,
      child: TapScale(
        onTap: onTap,
        scale: TapScales.large,
        haptic: false,
        child: Container(
          padding: _BubbleLayout.padding,
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(_BubbleLayout.borderRadius),
              topRight: const Radius.circular(_BubbleLayout.borderRadius),
              bottomLeft: Radius.circular(
                showBottomRadius
                    ? _BubbleLayout.borderRadius
                    : _BubbleLayout.connectedRadius,
              ),
              bottomRight: Radius.circular(
                showBottomRadius
                    ? _BubbleLayout.borderRadius
                    : _BubbleLayout.connectedRadius,
              ),
            ),
            // 精致边框
            border: Border.all(
              color: colors.divider.withValues(alpha: isDark ? 0.12 : 0.06),
              width: 0.5,
            ),
            // 微妙阴影
            boxShadow: [
              BoxShadow(
                color: colors.textPrimary.withValues(
                  alpha: isDark ? 0.1 : 0.04,
                ),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 内容
              _buildContent(colors),
              // 链接预览
              if (message.linkUrl != null) ...[
                const SizedBox(height: 10),
                _buildLink(colors),
              ],
              const SizedBox(height: 12),
              // 底部：反应 + 浏览量时间
              _buildFooter(colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(AppColorScheme colors) {
    return Text(
      message.content,
      style: TextStyle(
        fontSize: _BubbleLayout.contentFontSize,
        height: _BubbleLayout.contentLineHeight,
        color: colors.textPrimary,
        letterSpacing: 0.1,
      ),
    );
  }

  Widget _buildLink(AppColorScheme colors) {
    return TapScale(
      onTap: () => onLinkTap?.call(message.linkUrl!),
      scale: TapScales.card,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: colors.accentSoft,
          borderRadius: BorderRadius.circular(_BubbleLayout.linkBorderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.link_rounded, size: 15, color: colors.accent),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                message.linkTitle ?? message.linkUrl!,
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

  Widget _buildFooter(AppColorScheme colors) {
    final hasReactions = message.reactions.isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (hasReactions) Expanded(child: _buildReactions(colors)),
        if (!hasReactions) const Spacer(),
        _buildViewsAndTime(colors),
      ],
    );
  }

  Widget _buildReactions(AppColorScheme colors) {
    final reactions = message.reactions.take(4).toList();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: reactions.map((r) {
        return _ReactionChip(
          reaction: r,
          onTap: () => onReactionTap?.call(r.emoji),
        );
      }).toList(),
    );
  }

  Widget _buildViewsAndTime(AppColorScheme colors) {
    final isEdited =
        message.isEdited ||
        (message.updatedAt != null && message.updatedAt != message.createdAt);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.visibility_rounded, size: 13, color: colors.textDisabled),
        const SizedBox(width: 3),
        Text(
          formatCountEnglish(message.viewCount),
          style: TextStyle(
            fontSize: _BubbleLayout.footerFontSize,
            color: colors.textDisabled,
          ),
        ),
        if (isEdited) ...[
          const SizedBox(width: 4),
          Text(
            'edited',
            style: TextStyle(
              fontSize: _BubbleLayout.footerFontSize,
              color: colors.textDisabled,
            ),
          ),
        ],
        const SizedBox(width: 4),
        Text(
          formatTimeHHmm(message.createdAt),
          style: TextStyle(
            fontSize: _BubbleLayout.footerFontSize,
            color: colors.textDisabled,
          ),
        ),
      ],
    );
  }
}

/// 频道消息组件（完整版：Part1 + Part2）
class ChannelMessageWidget extends StatefulWidget {
  const ChannelMessageWidget({
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

  final ChannelMessageModel message;
  final VoidCallback? onTap;
  final ValueChanged<String>? onLinkTap;
  final ValueChanged<String>? onReactionTap;
  final VoidCallback? onCommentTap;
  final void Function(ChannelMessageMenuAction action)? onMenuAction;
  final bool isAdmin;
  final bool isHighlighted;
  final VoidCallback? onHighlightComplete;

  @override
  State<ChannelMessageWidget> createState() => _ChannelMessageWidgetState();
}

class _ChannelMessageWidgetState extends State<ChannelMessageWidget> {
  static const _quickEmojis = ['👍', '❤️', '🔥', '👏', '😢', '😡'];

  void _showContextMenu(LongPressStartDetails details) {
    final items = [
      const ContextMenuItem(
        icon: Icons.bookmark_outline_rounded,
        label: '保存',
        value: 'save',
      ),
      const ContextMenuItem(
        icon: Icons.shortcut_rounded,
        label: '转发',
        value: 'forward',
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
      quickEmojis: _quickEmojis,
      onSelected: (value) {
        final action = ChannelMessageMenuAction.values.firstWhere(
          (e) => e.name == value,
          orElse: () => ChannelMessageMenuAction.detail,
        );
        widget.onMenuAction?.call(action);
      },
      onEmojiSelected: widget.onReactionTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final maxWidth = MediaQuery.of(context).size.width * 0.87;
    final hasCommentEntry = widget.message.commentCount > 0;

    Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Part1: 消息气泡
                ChannelMessageBubble(
                  message: widget.message,
                  onTap: widget.onTap,
                  onLinkTap: widget.onLinkTap,
                  onReactionTap: widget.onReactionTap,
                  onLongPress: _showContextMenu,
                  showBottomRadius: !hasCommentEntry,
                ),
                // Part2: 评论入口
                if (hasCommentEntry) _buildCommentEntry(colors),
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

  Widget _buildCommentEntry(AppColorScheme colors) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TapScale(
      onTap: widget.onCommentTap,
      scale: TapScales.card,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(_BubbleLayout.borderRadius),
            bottomRight: Radius.circular(_BubbleLayout.borderRadius),
          ),
          border: Border.all(
            color: colors.divider.withValues(alpha: isDark ? 0.1 : 0.05),
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: _CommentEntryLayout.dividerPadding,
              child: DottedDivider(
                color: colors.divider.withValues(alpha: 0.5),
                strokeWidth: 1.0,
                dashWidth: 2.0,
                dashSpace: 3.0,
              ),
            ),
            Padding(
              padding: _CommentEntryLayout.padding,
              child: Row(
                children: [
                  if (widget.message.commentAvatars.isNotEmpty) ...[
                    AvatarStack(
                      avatarUrls: widget.message.commentAvatars
                          .take(3)
                          .toList(),
                      size: _CommentEntryLayout.avatarSize,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    '${widget.message.commentCount} 条评论',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: colors.textTertiary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 反应标签
class _ReactionChip extends StatelessWidget {
  const _ReactionChip({required this.reaction, this.onTap});

  final ReactionSummary reaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isSelected = reaction.isSelected;

    return TapScale(
      onTap: onTap,
      scale: TapScales.small,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.interactive.withValues(alpha: 0.15)
              : colors.surfaceBase.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(
            _BubbleLayout.reactionBorderRadius,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(reaction.emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              reaction.formattedCount,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? colors.interactive : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
