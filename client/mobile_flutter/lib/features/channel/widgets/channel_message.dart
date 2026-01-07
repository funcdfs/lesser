// 频道消息组件 - Instagram Channel 风格

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../../../pkg/ui/effects/effects.dart';
import '../models/channel_models.dart';

/// 频道消息组件（Instagram Channel 风格）
class ChannelMessageWidget extends StatefulWidget {
  const ChannelMessageWidget({
    super.key,
    required this.message,
    this.onTap,
    this.onLinkTap,
    this.onReactionTap,
    this.onCommentTap,
    this.onSave,
    this.onForward,
    this.onDetail,
    this.isAdmin = false,
  });

  final ChannelPostModel message;
  final VoidCallback? onTap;
  final ValueChanged<String>? onLinkTap;
  final ValueChanged<String>? onReactionTap;
  final VoidCallback? onCommentTap;
  final VoidCallback? onSave;
  final VoidCallback? onForward;
  final VoidCallback? onDetail;
  final bool isAdmin;

  @override
  State<ChannelMessageWidget> createState() => _ChannelMessageWidgetState();
}

class _ChannelMessageWidgetState extends State<ChannelMessageWidget> {
  final GlobalKey _bubbleKey = GlobalKey();
  double? _bubbleWidth;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureBubbleWidth();
    });
  }

  void _measureBubbleWidth() {
    final renderBox =
        _bubbleKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && mounted) {
      setState(() {
        _bubbleWidth = renderBox.size.width;
      });
    }
  }

  /// 显示长按浮动菜单（在按压位置附近）
  void _showContextMenu(LongPressStartDetails details) {
    HapticFeedback.mediumImpact();

    final overlay = Overlay.of(context);
    final screenSize = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    // 菜单尺寸
    const menuWidth = 200.0;
    const menuHeight = 200.0;

    // 以按下位置为左上角，但确保不超出屏幕
    final tapPosition = details.globalPosition;

    // 水平位置：以点击位置为左边，但不超出右边界
    double left = tapPosition.dx;
    if (left + menuWidth > screenSize.width - 12) {
      left = screenSize.width - menuWidth - 12;
    }
    if (left < 12) left = 12;

    // 垂直位置：以点击位置为顶部，但不超出底部边界
    double top = tapPosition.dy;
    if (top + menuHeight > screenSize.height - padding.bottom - 12) {
      // 空间不够，显示在点击位置上方
      top = tapPosition.dy - menuHeight;
    }
    if (top < padding.top + 12) {
      top = padding.top + 12;
    }

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _FloatingContextMenu(
        left: left,
        top: top,
        onDismiss: () => overlayEntry.remove(),
        onSave: () {
          overlayEntry.remove();
          widget.onSave?.call();
        },
        onForward: () {
          overlayEntry.remove();
          widget.onForward?.call();
        },
        onDetail: () {
          overlayEntry.remove();
          widget.onDetail?.call();
        },
        onReaction: (emoji) {
          overlayEntry.remove();
          widget.onReactionTap?.call(emoji);
        },
      ),
    );

    overlay.insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final maxWidth = MediaQuery.of(context).size.width * 0.85;
    const minWidth = 200.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 消息气泡本体
          GestureDetector(
            onLongPressStart: _showContextMenu,
            child: TapScale(
              onTap: widget.onTap,
              scale: 0.99,
              haptic: false,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  minWidth: minWidth,
                ),
                child: IntrinsicWidth(
                  child: Container(
                    key: _bubbleKey,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: colors.textPrimary.withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                        BoxShadow(
                          color: colors.textPrimary.withValues(alpha: 0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildContent(colors),
                        if (widget.message.linkUrl != null) ...[
                          const SizedBox(height: 8),
                          _buildLink(colors),
                        ],
                        const SizedBox(height: 8),
                        _buildMeta(colors),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. 评论区入口
          if (widget.message.commentCount > 0) ...[
            const SizedBox(height: 6),
            _buildCommentBar(colors),
          ],

          // 3. 表情反应区
          if (widget.message.reactions.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildReactions(colors),
          ],
        ],
      ),
    );
  }

  Widget _buildContent(AppColorScheme colors) {
    return Text(
      widget.message.content,
      style: TextStyle(fontSize: 15, height: 1.5, color: colors.textPrimary),
    );
  }

  Widget _buildLink(AppColorScheme colors) {
    return TapScale(
      onTap: () => widget.onLinkTap?.call(widget.message.linkUrl!),
      scale: 0.98,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: colors.surfaceBase,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.divider, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.link_rounded, size: 16, color: colors.interactive),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                widget.message.linkTitle ?? widget.message.linkUrl!,
                style: TextStyle(fontSize: 13, color: colors.interactive),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeta(AppColorScheme colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.visibility_rounded, size: 14, color: colors.textTertiary),
        const SizedBox(width: 4),
        Text(
          _formatCount(widget.message.viewCount),
          style: TextStyle(fontSize: 12, color: colors.textTertiary),
        ),
        const SizedBox(width: 12),
        Text(
          _formatTime(widget.message.createdAt),
          style: TextStyle(fontSize: 12, color: colors.textTertiary),
        ),
      ],
    );
  }

  Widget _buildCommentBar(AppColorScheme colors) {
    final commentBar = TapScale(
      onTap: widget.onCommentTap,
      scale: 0.98,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colors.textPrimary.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.message.commentAvatars.isNotEmpty)
              _AvatarStack(avatars: widget.message.commentAvatars),
            if (widget.message.commentAvatars.isNotEmpty)
              const SizedBox(width: 8),
            Text(
              '${widget.message.commentCount} 条评论',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colors.interactive,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: colors.interactive,
            ),
          ],
        ),
      ),
    );

    if (_bubbleWidth != null) {
      return SizedBox(width: _bubbleWidth, child: commentBar);
    }
    return commentBar;
  }

  Widget _buildReactions(AppColorScheme colors) {
    final reactions = widget.message.reactions.take(5).toList();
    final remaining = widget.message.reactions.length > 5
        ? widget.message.reactions.length - 5
        : 0;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        ...reactions.map(
          (r) => _ReactionChip(
            reaction: r,
            onTap: () => widget.onReactionTap?.call(r.emoji),
          ),
        ),
        if (remaining > 0) _MoreReactionsChip(count: remaining),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}万';
    }
    return count.toString();
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

/// 浮动上下文菜单（在长按位置附近显示）
class _FloatingContextMenu extends StatelessWidget {
  const _FloatingContextMenu({
    required this.left,
    required this.top,
    required this.onDismiss,
    this.onSave,
    this.onForward,
    this.onDetail,
    this.onReaction,
  });

  final double left;
  final double top;
  final VoidCallback onDismiss;
  final VoidCallback? onSave;
  final VoidCallback? onForward;
  final VoidCallback? onDetail;
  final ValueChanged<String>? onReaction;

  static const _quickEmojis = ['👍', '❤️', '🔥', '👏', '😢', '😡'];

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Stack(
      children: [
        // 背景遮罩（点击关闭）
        Positioned.fill(
          child: GestureDetector(
            onTap: onDismiss,
            child: Container(color: colors.surfaceOverlay),
          ),
        ),

        // 浮动菜单
        Positioned(
          left: left,
          top: top,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Opacity(opacity: scale, child: child),
              );
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                  color: colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: colors.textPrimary.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 表情栏
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: _quickEmojis
                            .map(
                              (emoji) => _FloatingEmojiButton(
                                emoji: emoji,
                                onTap: () => onReaction?.call(emoji),
                              ),
                            )
                            .toList(),
                      ),
                    ),

                    Divider(height: 1, color: colors.divider),

                    // 操作按钮
                    _FloatingMenuItem(
                      icon: Icons.bookmark_border_rounded,
                      label: '保存',
                      onTap: onSave,
                    ),
                    _FloatingMenuItem(
                      icon: Icons.reply_rounded,
                      label: '转发',
                      onTap: onForward,
                    ),
                    _FloatingMenuItem(
                      icon: Icons.info_outline_rounded,
                      label: '详情',
                      onTap: onDetail,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 浮动菜单表情按钮
class _FloatingEmojiButton extends StatelessWidget {
  const _FloatingEmojiButton({required this.emoji, this.onTap});

  final String emoji;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: onTap,
      scale: 0.8,
      child: Text(emoji, style: const TextStyle(fontSize: 22)),
    );
  }
}

/// 浮动菜单项
class _FloatingMenuItem extends StatelessWidget {
  const _FloatingMenuItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return TapScale(
      onTap: onTap,
      scale: 0.98,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(16, 12, 16, isLast ? 14 : 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: colors.textSecondary),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(fontSize: 15, color: colors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

/// 头像堆叠组件
class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.avatars});

  final List<String> avatars;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final displayAvatars = avatars.take(5).toList();
    const size = 24.0;
    const overlap = 8.0;

    return SizedBox(
      width: size + (displayAvatars.length - 1) * (size - overlap),
      height: size,
      child: Stack(
        children: List.generate(displayAvatars.length, (index) {
          return Positioned(
            left: index * (size - overlap),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.surfaceElevated, width: 2),
              ),
              child: ClipOval(
                child: displayAvatars[index].isNotEmpty
                    ? Image.network(
                        displayAvatars[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _buildPlaceholder(colors),
                      )
                    : _buildPlaceholder(colors),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPlaceholder(AppColorScheme colors) {
    return Container(
      color: colors.surfaceBase,
      child: Icon(Icons.person_rounded, size: 14, color: colors.textTertiary),
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
      scale: 0.92,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: reaction.isSelected
              ? colors.interactive.withValues(alpha: 0.15)
              : colors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.textPrimary.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(reaction.emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              reaction.formattedCount,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 更多反应数量标签
class _MoreReactionsChip extends StatelessWidget {
  const _MoreReactionsChip({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        '+$count',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colors.textTertiary,
        ),
      ),
    );
  }
}
