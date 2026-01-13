// 评论操作按钮
//
// 内嵌到内容末尾，圆润风格图标
// 点赞和回复都为 0 时不展示
//
/// 注意：此处的 _LikeButton 是评论区专用的轻量版本，
/// 与 pkg/ui/widgets/like_button.dart 的公共版本不同：
/// - 更小的尺寸（20px vs 24px）适配评论气泡内嵌布局
/// - 无烟花特效，保持评论区视觉简洁
/// - 与回复按钮共享相同的视觉风格
library;

import 'package:flutter/material.dart';
import '../../ui/theme/theme.dart';
import '../../ui/effects/effects.dart';
import '../../ui/widgets/icon_painter.dart';
import '../../ui/widgets/animated_count.dart';

// 爱心图标 path（24x24 viewBox）
const _heartPath =
    'M12 21.35L10.55 20.03C5.4 15.36 2 12.28 2 8.5C2 5.42 4.42 3 7.5 3C9.24 3 10.91 3.81 12 5.09C13.09 3.81 14.76 3 16.5 3C19.58 3 22 5.42 22 8.5C22 12.28 18.6 15.36 13.45 20.03L12 21.35Z';

// 气泡图标 path（24x24 viewBox）
const _bubblePath =
    'M21 11.5C21 16.19 16.97 20 12 20C10.81 20 9.66 19.8 8.62 19.45L3 21L4.5 16.5C3.55 15.1 3 13.37 3 11.5C3 6.81 7.03 3 12 3C16.97 3 21 6.81 21 11.5Z';

// 图标尺寸
const _iconSize = 20.0;

// 按钮间距
const _buttonSpacing = 7.0;

/// 回复按钮状态
enum ReplyButtonState {
  /// 隐藏 - 不显示按钮
  hidden,

  /// 可展开 - 有回复可以展开（主强调色）
  expandable,

  /// 禁用 - 评论已删除
  disabled,

  /// 被封禁 - 无法评论（显示禁止图标）
  banned,
}

/// 回复按钮状态扩展
extension ReplyButtonStateExtension on ReplyButtonState {
  bool get canExpand => this == ReplyButtonState.expandable;
  bool get isVisible => this != ReplyButtonState.hidden;
}

/// 评论操作按钮组件
class CommentActions extends StatelessWidget {
  const CommentActions({
    super.key,
    required this.likeCount,
    required this.replyCount,
    required this.isLiked,
    this.replyState = ReplyButtonState.hidden,
    this.onLikeTap,
    this.onReplyTap,
  });

  final int likeCount;
  final int replyCount;
  final bool isLiked;
  final ReplyButtonState replyState;
  final VoidCallback? onLikeTap;
  final VoidCallback? onReplyTap;

  @override
  Widget build(BuildContext context) {
    // 回复按钮：可见状态时显示
    final showReply = replyState.isVisible;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 点赞按钮（始终显示，提高用户互动）
        _LikeButton(count: likeCount, isLiked: isLiked, onTap: onLikeTap),
        if (showReply) const SizedBox(width: _buttonSpacing),
        // 回复按钮
        if (showReply)
          _ReplyButton(count: replyCount, state: replyState, onTap: onReplyTap),
      ],
    );
  }
}

/// 点赞按钮
///
/// 对于静态页面中不会改变位置、不会被动态删除的组件，Key 是多余的。
/// 不带 Key 可以稍微减少内存占用（在大型应用中遵循"非必要不增加"原则）。
class _LikeButton extends StatelessWidget {
  const _LikeButton({required this.count, required this.isLiked, this.onTap});

  final int count;
  final bool isLiked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final color = isLiked ? colors.like : colors.textDisabled;
    // 有点赞数或已点赞时显示数字
    final showCount = count > 0 || isLiked;

    return TapScale(
      onTap: onTap,
      scale: TapScales.small,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(
              size: const Size(_iconSize, _iconSize),
              painter: IconPainter(_heartPath, color, 1.2, fill: isLiked),
            ),
            // 有点赞数或已点赞时显示数字，否则只显示图标
            if (showCount) ...[
              const SizedBox(width: 3),
              AnimatedCount(
                count: count,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isLiked ? FontWeight.w600 : FontWeight.w400,
                  color: color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 回复按钮
class _ReplyButton extends StatelessWidget {
  const _ReplyButton({required this.count, required this.state, this.onTap});

  final int count;
  final ReplyButtonState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isBanned = state == ReplyButtonState.banned;
    final isDisabled = state == ReplyButtonState.disabled;
    final canTap = state.canExpand;
    final hasReplies = count > 0;

    // 颜色：有回复时用强调色，无回复时用默认灰色
    final color = hasReplies ? colors.accent : colors.textDisabled;

    // 直接使用 TapScale 提供视觉反馈和触感，移除隐形框
    return TapScale(
      onTap: canTap ? onTap : null,
      scale: TapScales.small,
      haptic: canTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Opacity(
          opacity: isDisabled ? 0.4 : 1.0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 气泡图标 + 禁止图标的叠加层
              SizedBox(
                width: _iconSize,
                height: _iconSize,
                child: Stack(
                  children: [
                    // 底层：气泡图标
                    CustomPaint(
                      size: const Size(_iconSize, _iconSize),
                      painter: IconPainter(_bubblePath, color, 1.2),
                    ),
                    // 叠加层：禁止斜线（仅在 banned 状态显示）
                    if (isBanned)
                      CustomPaint(
                        size: const Size(_iconSize, _iconSize),
                        painter: _BannedSlashPainter(colors.error),
                      ),
                  ],
                ),
              ),
              // 有回复时才显示数量
              if (hasReplies) ...[
                const SizedBox(width: 3),
                AnimatedCount(
                  count: count,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 禁止斜线绘制器 - 在图标上叠加红色斜线
class _BannedSlashPainter extends CustomPainter {
  const _BannedSlashPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // 从左上到右下的斜线
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.2)
      ..lineTo(size.width * 0.8, size.height * 0.8);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BannedSlashPainter oldDelegate) {
    return color != oldDelegate.color;
  }
}
