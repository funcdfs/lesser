// =============================================================================
// 剧集动态组件
// =============================================================================
//
// Telegram Channel 风格的动态气泡组件，支持文本、链接、反应和评论入口。
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
// SeriesPost (完整版)
// ├── SubjectPostBubble (Part1: 可独立复用)
// │   ├── 动态内容
// │   ├── 链接预览（可选）
// │   └── 底部：反应 + 浏览量/时间
// └── 评论入口 (Part2: 有评论时显示)
//     ├── 虚线分隔符
//     └── 评论者头像 + 评论数
// ```
//
// ## 复用场景
//
// - `SubjectPost` - 动态列表中使用
// - `SubjectPostBubble` - 评论页头部单独使用
//

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

/// 剧集动态菜单操作类型
enum SubjectPostMenuAction {
  /// 保存动态
  save,

  /// 转发动态
  forward,

  /// 查看详情
  detail,
}

// =============================================================================
// 动态气泡组件（Part1）
// =============================================================================

/// 剧集动态气泡组件
///
/// 只包含动态内容、链接预览、反应和浏览量/时间，不包含评论入口。
/// 可独立复用于评论页头部等场景。
///
/// ## 参数
///
/// - [post] 动态数据
/// - [showBottomRadius] 是否显示底部圆角，独立使用时为 true，
///   与评论入口连接时为 false
class SubjectPostBubble extends StatelessWidget {
  const SubjectPostBubble({
    super.key,
    required this.post,
    this.onTap,
    this.onLinkTap,
    this.onReactionTap,
    this.onLongPress,
    this.showBottomRadius = true,
  });

  /// 动态数据
  final SubjectPostModel post;

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
    final linkUrl = post.linkUrl;

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
              _PostContent(content: post.content, colors: colors),
              if (linkUrl != null) ...[
                const SizedBox(height: 10),
                _LinkPreview(
                  linkUrl: linkUrl,
                  linkTitle: post.linkTitle,
                  colors: colors,
                  onTap: onLinkTap,
                ),
              ],
              const SizedBox(height: 12),
              _PostFooter(
                post: post,
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

/// 气泡容器组件
///
/// 封装气泡的装饰样式，包括背景色、圆角、边框和阴影。
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

/// 动态文本内容
class _PostContent extends StatelessWidget {
  const _PostContent({required this.content, required this.colors});

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

/// 链接预览卡片
class _LinkPreview extends StatelessWidget {
  const _LinkPreview({
    required this.linkUrl,
    this.linkTitle,
    required this.colors,
    this.onTap,
  });

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

/// 动态底部区域（反应 + 浏览量/时间）
class _PostFooter extends StatelessWidget {
  const _PostFooter({
    required this.post,
    required this.colors,
    this.onReactionTap,
  });

  final SubjectPostModel post;
  final AppColorScheme colors;
  final ValueChanged<String>? onReactionTap;

  @override
  Widget build(BuildContext context) {
    final hasReactions = post.hasReactions;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (hasReactions)
          Expanded(
            child: _ReactionList(
              reactions: post.displayReactions,
              onReactionTap: onReactionTap,
            ),
          )
        else
          const Spacer(),
        _ViewsAndTime(post: post, colors: colors),
      ],
    );
  }
}

/// 反应列表组件
///
/// 从 _PostFooter 中拆分出来，避免在 build 方法中创建闭包。
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
        for (final r in reactions)
          _ReactionChip(reaction: r, onEmojiTap: onReactionTap),
      ],
    );
  }
}

/// 浏览量和时间组件
///
/// 从 _PostFooter 中拆分出来，提高可读性和可维护性。
class _ViewsAndTime extends StatelessWidget {
  const _ViewsAndTime({required this.post, required this.colors});

  final SubjectPostModel post;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final isEdited =
        post.isEdited ||
        (post.updatedAt != null && post.updatedAt != post.createdAt);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.visibility_rounded, size: 13, color: colors.textDisabled),
        const SizedBox(width: 3),
        Text(
          formatCountEnglish(post.viewCount),
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
          formatTimeHHmm(post.createdAt),
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
// 完整动态组件
// =============================================================================

/// 快速表情列表（顶层常量，避免每次 build 重复创建）
const _quickEmojis = ['👍', '❤️', '🔥', '👏', '😢', '😡'];

/// 剧集动态组件（完整版）
///
/// 包含动态气泡和评论入口，用于动态列表中显示。
/// 支持高亮效果（用于深层链接导航）和上下文菜单。
class SubjectPost extends StatefulWidget {
  const SubjectPost({
    super.key,
    required this.post,
    this.onTap,
    this.onLinkTap,
    this.onReactionTap,
    this.onCommentTap,
    this.onMenuAction,
    this.isAdmin = false,
    this.isHighlighted = false,
    this.onHighlightComplete,
  });

  /// 动态数据
  final SubjectPostModel post;

  /// 点击回调
  final VoidCallback? onTap;

  /// 链接点击回调
  final ValueChanged<String>? onLinkTap;

  /// 反应点击回调
  final ValueChanged<String>? onReactionTap;

  /// 评论入口点击回调
  final VoidCallback? onCommentTap;

  /// 菜单操作回调
  final void Function(SubjectPostMenuAction action)? onMenuAction;

  /// 是否是管理员（影响菜单选项）
  final bool isAdmin;

  /// 是否高亮显示（用于深层链接导航）
  final bool isHighlighted;

  /// 高亮动画完成回调
  final VoidCallback? onHighlightComplete;

  @override
  State<SubjectPost> createState() => _SubjectPostState();
}

class _SubjectPostState extends State<SubjectPost> {
  /// 菜单项列表（静态常量，避免每次调用重复创建）
  static const _menuItems = [
    ContextMenuItem(
      icon: Icons.bookmark_outline_rounded,
      label: '保存',
      value: 'save',
    ),
    ContextMenuItem(icon: Icons.reply_rounded, label: '转发', value: 'forward'),
    ContextMenuItem(
      icon: Icons.info_outline_rounded,
      label: '详情',
      value: 'detail',
    ),
  ];

  /// 菜单操作映射表（静态常量，避免每次查找时遍历）
  static const _menuActionMap = {
    'save': SubjectPostMenuAction.save,
    'forward': SubjectPostMenuAction.forward,
    'detail': SubjectPostMenuAction.detail,
  };

  /// 显示上下文菜单
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

  /// 处理菜单选择
  void _handleMenuSelection(String value) {
    final action = _menuActionMap[value] ?? SubjectPostMenuAction.detail;
    widget.onMenuAction?.call(action);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final maxWidth =
        MediaQuery.sizeOf(context).width *
        SubjectLayoutConstants.messageMaxWidthRatio;
    final hasCommentEntry = widget.post.hasComments;

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
                // Part1: 动态气泡
                SubjectPostBubble(
                  post: widget.post,
                  onTap: widget.onTap,
                  onLinkTap: widget.onLinkTap,
                  onReactionTap: widget.onReactionTap,
                  onLongPress: _showContextMenu,
                  showBottomRadius: !hasCommentEntry,
                ),
                // Part2: 评论入口（有评论时显示）
                if (hasCommentEntry)
                  _CommentEntry(
                    post: widget.post,
                    colors: colors,
                    onTap: widget.onCommentTap,
                  ),
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
}

/// 评论入口组件
///
/// 从 _SeriesPostState 中拆分出来，提高可读性和可维护性。
/// 显示评论者头像堆叠、评论数和箭头图标。
class _CommentEntry extends StatelessWidget {
  const _CommentEntry({
    required this.post,
    required this.colors,
    this.onTap,
  });

  final SubjectPostModel post;
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
                  if (post.commentAvatars.isNotEmpty) ...[
                    AvatarStack(
                      avatarUrls: post.commentAvatars.take(3).toList(),
                      size: CommentEntryLayout.avatarSize,
                    ),
                    const SizedBox(width: 8),
                  ],
                  // 评论数
                  Text(
                    '${post.commentCount} 条评论',
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
/// 内部处理点击回调，避免父组件为每个 chip 创建闭包。
class _ReactionChip extends StatelessWidget {
  const _ReactionChip({required this.reaction, this.onEmojiTap});

  final ReactionSummary reaction;

  /// emoji 点击回调，传入 emoji 字符串
  final ValueChanged<String>? onEmojiTap;

  void _handleTap() {
    onEmojiTap?.call(reaction.emoji);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isSelected = reaction.isSelected;

    return TapScale(
      onTap: onEmojiTap != null ? _handleTap : null,
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
