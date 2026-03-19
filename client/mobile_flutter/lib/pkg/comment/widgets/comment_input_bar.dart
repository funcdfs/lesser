// 评论输入栏组件
//
// 两行布局设计：
// Row 1: [↑↓ 导航] [--- 功能区(灵活) ---] [未读数]
// Row 2: [😀 表情] [输入框] [📎 附件] [⋯ 更多]
//
// 当输入框有文字时，附件/更多按钮消失，出现发送按钮（AnimatedSwitcher）
// 面板管理：表情面板显示在输入栏下方

import 'package:flutter/material.dart';
import '../../ui/theme/theme.dart';
import '../../ui/effects/effects.dart';
import '../../ui/widgets/unread_badge.dart';
import '../logic/scroll_controller.dart';
import '../models/comment_model.dart';
import '../utils.dart';
import 'attachment_panel.dart';
import 'emoji_panel.dart';
import 'more_menu.dart';

// ============================================================================
// 常量
// ============================================================================

const _kNavButtonSize = 26.0;
const _kNavIconSize = 16.0;
const _kActionIconSize = 22.0;
const _kSendButtonSize = 38.0;
const _kAnimDuration = Duration(milliseconds: 200);

// ============================================================================
// CommentInputBar — 主组件（StatefulWidget）
// ============================================================================

/// 评论输入栏
class CommentInputBar extends StatefulWidget {
  const CommentInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    this.scrollController,
    this.toolbarBuilder,
    this.replyTo,
    this.isSubmitting = false,
    this.onSubmit,
    this.onCancelReply,
    this.onEmojiSelected,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final CommentScrollController? scrollController;

  /// 导航行中间的功能区构建器
  ///
  /// 可注入任意 Widget，用于特殊场景下展示功能入口。
  /// 例如：翻译按钮、AI 助手入口、格式工具栏等。
  final WidgetBuilder? toolbarBuilder;

  final ReplyTarget? replyTo;
  final bool isSubmitting;
  final VoidCallback? onSubmit;
  final VoidCallback? onCancelReply;
  final void Function(String emoji)? onEmojiSelected;

  @override
  State<CommentInputBar> createState() => _CommentInputBarState();
}

class _CommentInputBarState extends State<CommentInputBar> {
  bool _hasText = false;
  bool _showEmojiPanel = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _hasText = widget.controller.text.trim().isNotEmpty;
  }

  @override
  void didUpdateWidget(CommentInputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
      _hasText = widget.controller.text.trim().isNotEmpty;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _toggleEmojiPanel() {
    setState(() => _showEmojiPanel = !_showEmojiPanel);
    // 打开表情面板时收起键盘，关闭时打开键盘
    if (_showEmojiPanel) {
      widget.focusNode.unfocus();
    } else {
      widget.focusNode.requestFocus();
    }
  }

  void _onEmojiSelected(String emoji) {
    // 将 emoji 插入输入框光标位置
    final controller = widget.controller;
    final selection = controller.selection;
    final text = controller.text;

    if (selection.isValid) {
      final newText = text.replaceRange(selection.start, selection.end, emoji);
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start + emoji.length,
        ),
      );
    } else {
      controller.text = text + emoji;
    }

    widget.onEmojiSelected?.call(emoji);
  }

  void _onAttachmentTap() {
    showAttachmentPanel(context);
  }

  void _onMoreTap(TapUpDetails details) {
    showMoreMenu(context, details.globalPosition);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 主容器
        Container(
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            border: Border(top: BorderSide(color: colors.divider, width: 0.5)),
          ),
          child: SafeArea(
            top: false,
            bottom: !_showEmojiPanel, // 表情面板打开时不留底部安全区
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Row 1: 导航行（有滚动控制器或有 toolbar 时显示）
                if (widget.scrollController != null ||
                    widget.toolbarBuilder != null)
                  _NavigationRow(
                    controller: widget.scrollController,
                    toolbarBuilder: widget.toolbarBuilder,
                  ),
                // 回复栏
                if (widget.replyTo != null)
                  _ReplyBar(
                    target: widget.replyTo!,
                    onCancel: widget.onCancelReply,
                  ),
                // Row 2: 输入行
                _InputRow(
                  hasText: _hasText,
                  showEmojiPanel: _showEmojiPanel,
                  isSubmitting: widget.isSubmitting,
                  focusNode: widget.focusNode,
                  controller: widget.controller,
                  replyTo: widget.replyTo,
                  onEmojiTap: _toggleEmojiPanel,
                  onAttachmentTap: _onAttachmentTap,
                  onMoreTap: _onMoreTap,
                  onSubmit: widget.onSubmit,
                ),
              ],
            ),
          ),
        ),
        // 表情面板
        if (_showEmojiPanel)
          EmojiPanel(onEmojiSelected: _onEmojiSelected),
      ],
    );
  }
}

// ============================================================================
// Row 1 — 导航行
// ============================================================================

/// 导航行：左侧置顶/置底 | 中间功能区 | 右侧未读数
class _NavigationRow extends StatelessWidget {
  const _NavigationRow({this.controller, this.toolbarBuilder});

  final CommentScrollController? controller;
  final WidgetBuilder? toolbarBuilder;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    // 构建中间功能区
    final toolbarContent = toolbarBuilder?.call(context);

    Widget buildRow(bool hasNav, bool hasUnread) {
      // 三者都没有时不渲染
      if (!hasNav && !hasUnread && toolbarContent == null) {
        return const SizedBox.shrink();
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
            child: Row(
              children: [
                // 左侧：导航按钮
                if (hasNav) ...[
                  if (controller!.canJumpToTop)
                    _NavButton(
                      icon: Icons.keyboard_arrow_up_rounded,
                      onTap: () => controller!.jumpToTop(context),
                      colors: colors,
                    ),
                  if (controller!.canJumpToTop && controller!.canJumpToBottom)
                    const SizedBox(width: 4),
                  if (controller!.canJumpToBottom)
                    _NavButton(
                      icon: Icons.keyboard_arrow_down_rounded,
                      onTap: () => controller!.jumpToBottom(context),
                      colors: colors,
                    ),
                ],
                // 中间：功能区（Expanded，灵活填充）
                if (toolbarContent != null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: toolbarContent,
                    ),
                  )
                else
                  const Spacer(),
                // 右侧：未读数
                if (hasUnread)
                  TapScale(
                    onTap: () => controller!.jumpToBottom(context),
                    scale: TapScales.small,
                    child: UnreadBadge(count: controller!.unreadCount),
                  ),
              ],
            ),
          ),
          // 分隔线
          Container(
            height: 0.5,
            color: colors.divider.withValues(alpha: 0.5),
          ),
        ],
      );
    }

    // 有 scrollController 时监听变化
    if (controller != null) {
      return ListenableBuilder(
        listenable: controller!,
        builder: (context, _) {
          return buildRow(controller!.isVisible, controller!.hasUnread);
        },
      );
    }

    // 无 scrollController，只有 toolbar
    return buildRow(false, false);
  }
}

// ============================================================================
// Row 2 — 输入行
// ============================================================================

/// 输入行：表情 → 输入框 → (附件/更多 | 发送按钮)
class _InputRow extends StatelessWidget {
  const _InputRow({
    required this.hasText,
    required this.showEmojiPanel,
    required this.isSubmitting,
    required this.focusNode,
    required this.controller,
    this.replyTo,
    this.onEmojiTap,
    this.onAttachmentTap,
    this.onMoreTap,
    this.onSubmit,
  });

  final bool hasText;
  final bool showEmojiPanel;
  final bool isSubmitting;
  final FocusNode focusNode;
  final TextEditingController controller;
  final ReplyTarget? replyTo;
  final VoidCallback? onEmojiTap;
  final VoidCallback? onAttachmentTap;
  final GestureTapUpCallback? onMoreTap;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 表情按钮
          _ActionButton(
            icon: showEmojiPanel
                ? Icons.keyboard_rounded
                : Icons.emoji_emotions_outlined,
            onTap: onEmojiTap,
            colors: colors,
          ),
          const SizedBox(width: 4),
          // 输入框
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 100),
              decoration: BoxDecoration(
                color: colors.surfaceBase,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                style: TextStyle(
                  fontSize: 15,
                  color: colors.textPrimary,
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  hintText: replyTo != null ? '回复...' : '发送评论...',
                  hintStyle: TextStyle(color: colors.textDisabled),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSubmit?.call(),
                onTap: () {
                  // 点击输入框时关闭表情面板
                  if (showEmojiPanel) {
                    onEmojiTap?.call();
                  }
                },
                maxLines: 4,
                minLines: 1,
              ),
            ),
          ),
          const SizedBox(width: 4),
          // 右侧区域：附件/更多 或 发送按钮
          // 使用 AnimatedContainer 平滑改变宽度，避免输入框宽度瞬间跳动
          AnimatedContainer(
            duration: _kAnimDuration,
            curve: Curves.easeOutCubic,
            width: hasText ? _kSendButtonSize : 74.0, // 36 + 2 + 36
            height: _kSendButtonSize,
            alignment: Alignment.centerRight,
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                // 附件/更多 按钮组
                AnimatedOpacity(
                  duration: _kAnimDuration,
                  curve: Curves.easeOut,
                  opacity: hasText ? 0.0 : 1.0,
                  child: IgnorePointer(
                    ignoring: hasText,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ActionButton(
                          icon: Icons.attach_file_rounded,
                          onTap: onAttachmentTap,
                          colors: colors,
                        ),
                        const SizedBox(width: 2),
                        GestureDetector(
                          onTapUp: onMoreTap,
                          behavior: HitTestBehavior.opaque,
                          child: SizedBox(
                            width: 36,
                            height: 36,
                            child: Icon(
                              Icons.more_horiz_rounded,
                              size: _kActionIconSize,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 发送按钮
                AnimatedScale(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  scale: hasText ? 1.0 : 0.0,
                  child: AnimatedOpacity(
                    duration: _kAnimDuration,
                    opacity: hasText ? 1.0 : 0.0,
                    child: IgnorePointer(
                      ignoring: !hasText,
                      child: _SendButton(
                        isSubmitting: isSubmitting,
                        onTap: onSubmit,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 子组件
// ============================================================================

/// 导航小按钮
class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.onTap,
    required this.colors,
  });

  final IconData icon;
  final VoidCallback onTap;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: onTap,
      scale: TapScales.small,
      child: Container(
        width: _kNavButtonSize,
        height: _kNavButtonSize,
        decoration: BoxDecoration(
          color: colors.textPrimary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(_kNavButtonSize / 2),
        ),
        child: Icon(icon, size: _kNavIconSize, color: colors.textSecondary),
      ),
    );
  }
}

/// 操作按钮（表情、附件等）
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    this.onTap,
    required this.colors,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(icon, size: _kActionIconSize, color: colors.textSecondary),
      ),
    );
  }
}

/// 发送按钮
class _SendButton extends StatelessWidget {
  const _SendButton({this.isSubmitting = false, this.onTap});

  final bool isSubmitting;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return TapScale(
      onTap: isSubmitting ? null : onTap,
      scale: TapScales.small,
      child: Container(
        width: _kSendButtonSize,
        height: _kSendButtonSize,
        decoration: BoxDecoration(
          color: colors.interactive,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colors.interactive.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isSubmitting
            ? Padding(
                padding: const EdgeInsets.all(10),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.surfaceElevated,
                ),
              )
            : Icon(
                Icons.arrow_upward_rounded,
                color: colors.surfaceElevated,
                size: 22,
              ),
      ),
    );
  }
}

/// 回复提示栏
class _ReplyBar extends StatelessWidget {
  const _ReplyBar({required this.target, this.onCancel});

  final ReplyTarget target;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final barColor = getNameColor(target.commentId);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 8, 0),
      child: Row(
        children: [
          Container(
            width: 2,
            height: 24,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '回复 ${target.authorName}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: barColor,
                  ),
                ),
                Text(
                  target.contentPreview,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.textTertiary,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onCancel,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: colors.textDisabled,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
