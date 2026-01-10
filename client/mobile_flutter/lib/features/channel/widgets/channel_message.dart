// =============================================================================
// 频道消息组件
// =============================================================================
//
// Telegram Channel 风格的消息气泡组件，支持文本、链接、反应和评论入口。
//
// ## 视觉设计
//
// - 深色/浅色自适应气泡
// - 精致边框和微妙阴影
// - 反应标签在气泡内底部左侧
// - 浏览量和时间在气泡内底部右侧
// - 评论入口在气泡外下方（与气泡视觉连接）
//
// ## 组件结构
//
// ```
// ChannelMessage (完整版)
// ├── ChannelMessageBubble (Part1: 可独立复用)
// │   ├── 消息内容
// │   ├── 链接预览（可选）
// │   └── 底部：反应 + 浏览量/时间
// └── 评论入口 (Part2: 有评论时显示)
//     ├── 虚线分隔符
//     └── 评论者头像 + 评论数
// ```
//
// ## 复用场景
//
// - `ChannelMessage` - 消息列表中使用
// - `ChannelMessageBubble` - 评论页头部单独使用

import 'package:flutter/material.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../../../pkg/ui/effects/effects.dart';
import '../../../pkg/ui/widgets/avatar_stack.dart';
import '../../../pkg/ui/widgets/dotted_divider.dart';
import '../../../pkg/ui/widgets/context_menu.dart';
import '../../../pkg/utils/format_utils.dart';
import '../models/channel_models.dart';
import 'channel_constants.dart';

// =============================================================================
// 布局常量
// =============================================================================

/// 气泡布局常量
abstract final class BubbleLayout {
  /// 气泡内边距
  static const EdgeInsets padding = EdgeInsets.fromLTRB(14, 12, 14, 10);

  /// 标准圆角
  static const double borderRadius = 16.0;

  /// 连接评论入口时的小圆角（视觉上连接两部分）
  static const double connectedRadius = 4.0;

  /// 链接预览卡片圆角
  static const double linkBorderRadius = 10.0;

  /// 反应标签圆角
  static const double reactionBorderRadius = 14.0;

  /// 内容字体大小
  static const double contentFontSize = 15.0;

  /// 内容行高
  static const double contentLineHeight = 1.45;

  /// 底部信息字体大小
  static const double footerFontSize = 11.0;
}

/// 评论入口布局常量
abstract final class CommentEntryLayout {
  /// 内容区内边距
  static const EdgeInsets padding = EdgeInsets.fromLTRB(14, 9, 10, 11);

  /// 分隔线内边距
  static const EdgeInsets dividerPadding = EdgeInsets.symmetric(horizontal: 14);

  /// 评论者头像大小
  static const double avatarSize = 22.0;
}

// =============================================================================
// 菜单操作类型
// =============================================================================

/// 频道消息菜单操作类型
enum ChannelMessageMenuAction {
  /// 保存消息
  save,

  /// 转发消息
  forward,

  /// 查看详情
  detail,
}

// =============================================================================
// 消息气泡组件（Part1）
// =============================================================================

/// 频道消息气泡组件
///
/// 只包含消息内容、链接预览、反应和浏览量/时间，不包含评论入口。
/// 可独立复用于评论页头部等场景。
///
/// ## 参数
///
/// - [message] 消息数据
/// - [showBottomRadius] 是否显示底部圆角，独立使用时为 true，
///   与评论入口连接时为 false
class ChannelMessageBubble extends StatelessWidget {
  const ChannelMessageBubble({
    super.key,
    required this.message,
    this.onTap,
    this.onLinkTap,
    this.onReactionTap,
    this.onLongPress,
    this.showBottomRadius = true,
  });

  /// 消息数据
  final ChannelMessageModel message;

  /// 点击回调
  final VoidCallback? onTap;

  /// 链接点击回调
  final ValueChanged<String>? onLinkTap;

  /// 反应点击回调
  final ValueChanged<String>? onReactionTap;

  /// 长按回调（用于显示上下文菜单）
  final void Function(LongPressStartDetails)? onLongPress;

  /// 是否显示底部圆角
  ///
  /// - true: 独立使用时，四角都是圆角
  /// - false: 与评论入口连接时，底部使用小圆角
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
          padding: BubbleLayout.padding,
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(BubbleLayout.borderRadius),
              topRight: const Radius.circular(BubbleLayout.borderRadius),
              bottomLeft: Radius.circular(
                showBottomRadius
                    ? BubbleLayout.borderRadius
                    : BubbleLayout.connectedRadius,
              ),
              bottomRight: Radius.circular(
                showBottomRadius
                    ? BubbleLayout.borderRadius
                    : BubbleLayout.connectedRadius,
              ),
            ),
            border: Border.all(
              color: colors.divider.withValues(alpha: isDark ? 0.12 : 0.06),
              width: 0.5,
            ),
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
              _buildContent(colors),
              if (message.linkUrl != null) ...[
                const SizedBox(height: 10),
                _buildLink(colors),
              ],
              const SizedBox(height: 12),
              _buildFooter(colors),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建消息文本内容
  Widget _buildContent(AppColorScheme colors) {
    return Text(
      message.content,
      style: TextStyle(
        fontSize: BubbleLayout.contentFontSize,
        height: BubbleLayout.contentLineHeight,
        color: colors.textPrimary,
        letterSpacing: 0.1,
      ),
    );
  }

  /// 构建链接预览卡片
  Widget _buildLink(AppColorScheme colors) {
    return TapScale(
      onTap: () => onLinkTap?.call(message.linkUrl!),
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

  /// 构建底部区域（反应 + 浏览量/时间）
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

  /// 构建反应标签列表
  Widget _buildReactions(AppColorScheme colors) {
    // 使用 model 层预计算的 displayReactions，避免每次 build 创建新列表
    final reactions = message.displayReactions;

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

  /// 构建浏览量和时间
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
            fontSize: BubbleLayout.footerFontSize,
            color: colors.textDisabled,
          ),
        ),
        if (isEdited) ...[
          const SizedBox(width: 4),
          Text(
            'edited',
            style: TextStyle(
              fontSize: BubbleLayout.footerFontSize,
              color: colors.textDisabled,
            ),
          ),
        ],
        const SizedBox(width: 4),
        Text(
          formatTimeHHmm(message.createdAt),
          style: TextStyle(
            fontSize: BubbleLayout.footerFontSize,
            color: colors.textDisabled,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// 完整消息组件
// =============================================================================

/// 快速表情列表（顶层常量，避免每次 build 重复创建）
const _quickEmojis = ['👍', '❤️', '🔥', '👏', '😢', '😡'];

/// 频道消息组件（完整版）
///
/// 包含消息气泡和评论入口，用于消息列表中显示。
/// 支持高亮效果（用于深层链接导航）和上下文菜单。
class ChannelMessage extends StatefulWidget {
  const ChannelMessage({
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

  /// 消息数据
  final ChannelMessageModel message;

  /// 点击回调
  final VoidCallback? onTap;

  /// 链接点击回调
  final ValueChanged<String>? onLinkTap;

  /// 反应点击回调
  final ValueChanged<String>? onReactionTap;

  /// 评论入口点击回调
  final VoidCallback? onCommentTap;

  /// 菜单操作回调
  final void Function(ChannelMessageMenuAction action)? onMenuAction;

  /// 是否是管理员（影响菜单选项）
  final bool isAdmin;

  /// 是否高亮显示（用于深层链接导航）
  final bool isHighlighted;

  /// 高亮动画完成回调
  final VoidCallback? onHighlightComplete;

  @override
  State<ChannelMessage> createState() => _ChannelMessageState();
}

class _ChannelMessageState extends State<ChannelMessage> {
  /// 显示上下文菜单
  void _showContextMenu(LongPressStartDetails details) {
    final items = [
      const ContextMenuItem(
        icon: Icons.bookmark_outline_rounded,
        label: '保存',
        value: 'save',
      ),
      const ContextMenuItem(
        icon: Icons.reply_rounded,
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
    final maxWidth =
        MediaQuery.of(context).size.width *
        ChannelLayoutConstants.messageMaxWidthRatio;
    final hasCommentEntry = widget.message.commentCount > 0;

    Widget content = Padding(
      padding: ChannelLayoutConstants.messagePadding,
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
                // Part2: 评论入口（有评论时显示）
                if (hasCommentEntry) _buildCommentEntry(colors),
              ],
            ),
          ),
        ),
      ),
    );

    // 高亮效果包装
    if (widget.isHighlighted) {
      content = HighlightEffect(
        isHighlighted: true,
        onHighlightComplete: widget.onHighlightComplete,
        child: content,
      );
    }

    return content;
  }

  /// 构建评论入口
  Widget _buildCommentEntry(AppColorScheme colors) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TapScale(
      onTap: widget.onCommentTap,
      scale: TapScales.card,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(BubbleLayout.borderRadius),
            bottomRight: Radius.circular(BubbleLayout.borderRadius),
          ),
          border: Border.all(
            color: colors.divider.withValues(alpha: isDark ? 0.1 : 0.05),
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 虚线分隔符
            Padding(
              padding: CommentEntryLayout.dividerPadding,
              child: DottedDivider(
                color: colors.divider.withValues(alpha: 0.5),
                strokeWidth: 1.0,
                dashWidth: 2.0,
                dashSpace: 3.0,
              ),
            ),
            // 评论信息
            Padding(
              padding: CommentEntryLayout.padding,
              child: Row(
                children: [
                  // 评论者头像堆叠
                  if (widget.message.commentAvatars.isNotEmpty) ...[
                    AvatarStack(
                      avatarUrls: widget.message.commentAvatars
                          .take(3)
                          .toList(),
                      size: CommentEntryLayout.avatarSize,
                    ),
                    const SizedBox(width: 8),
                  ],
                  // 评论数
                  Text(
                    '${widget.message.commentCount} 条评论',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  // 箭头图标
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

// =============================================================================
// 反应标签组件
// =============================================================================

/// 反应标签
///
/// 显示单个 emoji 反应及其数量，支持选中状态高亮。
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
            BubbleLayout.reactionBorderRadius,
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
