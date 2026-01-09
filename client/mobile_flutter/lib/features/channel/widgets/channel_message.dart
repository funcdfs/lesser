// 频道消息组件 - Telegram Channel 风格
//
// 设计特点：
// - 深色气泡，无边框
// - 反应标签在气泡内底部左侧（带圆角背景）
// - 浏览量和时间在气泡内底部右侧
// - 评论入口在气泡外下方（头像堆叠 + 数量 + 箭头）

import 'package:flutter/material.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../../../pkg/ui/effects/effects.dart';
import '../../../pkg/ui/widgets/avatar_stack.dart';
import '../../../pkg/ui/widgets/dotted_divider.dart';
import '../../../pkg/ui/widgets/context_menu.dart';
import '../models/channel_models.dart';

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

    return GestureDetector(
      onLongPressStart: onLongPress,
      child: TapScale(
        onTap: onTap,
        scale: TapScales.large,
        haptic: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: Radius.circular(showBottomRadius ? 12 : 4),
              bottomRight: Radius.circular(showBottomRadius ? 12 : 4),
            ),
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
        fontSize: 14,
        height: 1.4,
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
          borderRadius: BorderRadius.circular(8),
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
          _formatCount(message.viewCount),
          style: TextStyle(fontSize: 11, color: colors.textDisabled),
        ),
        if (isEdited) ...[
          const SizedBox(width: 4),
          Text(
            'edited',
            style: TextStyle(fontSize: 11, color: colors.textDisabled),
          ),
        ],
        const SizedBox(width: 4),
        Text(
          _formatTime(message.createdAt),
          style: TextStyle(fontSize: 11, color: colors.textDisabled),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(count >= 10000 ? 0 : 1)}K';
    }
    return count.toString();
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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
    return TapScale(
      onTap: widget.onCommentTap,
      scale: TapScales.card,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: DottedDivider(
                color: colors.divider,
                strokeWidth: 1.5,
                dashWidth: 2.0,
                dashSpace: 3.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 10, 10),
              child: Row(
                children: [
                  if (widget.message.commentAvatars.isNotEmpty) ...[
                    AvatarStack(
                      avatarUrls: widget.message.commentAvatars
                          .take(3)
                          .toList(),
                      size: 22,
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
                    color: colors.textSecondary,
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

    return TapScale(
      onTap: onTap,
      scale: TapScales.small,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: reaction.isSelected
              ? colors.interactive.withValues(alpha: 0.15)
              : colors.surfaceBase.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
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
                color: reaction.isSelected
                    ? colors.interactive
                    : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
