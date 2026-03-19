// 评论气泡组件
//
// 设计原则：
// - 内容为中心，减少装饰性元素
// - 用户名颜色区分身份
// - 引用框简洁，左边框指示，点击可跳转到原评论
// - 精致的渐变边框和微妙阴影

import 'package:flutter/material.dart';
import '../../ui/theme/theme.dart';
import '../models/comment_model.dart';
import '../utils.dart';

/// 评论气泡组件
class CommentBubble extends StatelessWidget {
  const CommentBubble({
    super.key,
    required this.displayName,
    required this.username,
    required this.createdAt,
    required this.content,
    required this.nameColor,
    this.roleLabel,
    this.isVerified = false,
    this.replyTo,
    this.isPinned = false,
    this.isDeleted = false,
    this.isOwn = false,
    this.trailing,
    this.channelId,
    this.messageId,
    this.onQuoteTap,
  });

  final String displayName;
  final String username;
  final DateTime createdAt;
  final String content;
  final Color nameColor;
  final String? roleLabel;
  final bool isVerified;
  final ReplyTarget? replyTo;
  final bool isPinned;
  final bool isDeleted;
  final bool isOwn;
  final Widget? trailing;

  /// 频道 ID（用于构建回复引用的 Link）
  final String? channelId;

  /// 消息 ID（用于构建回复引用的 Link）
  final String? messageId;

  /// 引用点击回调
  final void Function(String commentId)? onQuoteTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 预计算颜色，避免在子组件中重复计算
    // 暗色模式下边框更明显，提供视觉分隔
    final borderColor = colors.divider.withValues(alpha: isDark ? 0.4 : 0.08);
    // 暗色模式下使用白色阴影增加层次感
    final shadowColor = isDark
        ? Colors.white.withValues(alpha: 0.03)
        : colors.textPrimary.withValues(alpha: 0.04);

    // 自己的评论使用 accent 淡色背景
    final bgColor = isOwn
        ? colors.accent.withValues(alpha: isDark ? 0.15 : 0.10)
        : colors.surfaceElevated;

    // 圆角方向：自己的评论右下小圆角，他人评论左下小圆角
    final borderRadius = isOwn
        ? const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(6),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(6),
            bottomRight: Radius.circular(18),
          );

    return Container(
      padding: const EdgeInsets.fromLTRB(11, 9, 11, 9),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: borderRadius,
        // 精致边框
        border: Border.all(color: borderColor, width: 0.5),
        // 微妙阴影
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 用户行 + 时间
          _UserRow(
            displayName: displayName,
            username: username,
            roleLabel: roleLabel,
            isVerified: isVerified,
            nameColor: nameColor,
            isPinned: isPinned,
            createdAt: createdAt,
          ),
          // 引用框（可点击跳转）
          if (replyTo != null)
            _QuoteBox(
              target: replyTo!,
              quoteColor: getNameColor(replyTo!.commentId),
              onTap: onQuoteTap != null
                  ? () => onQuoteTap!(replyTo!.commentId)
                  : null,
            ),
          // 内容
          const SizedBox(height: 5),
          _Content(content: content, isDeleted: isDeleted, trailing: trailing),
        ],
      ),
    );
  }
}

/// 用户行 - 用户信息 + 时间在同一行
class _UserRow extends StatelessWidget {
  const _UserRow({
    required this.displayName,
    required this.username,
    required this.nameColor,
    required this.createdAt,
    this.roleLabel,
    this.isVerified = false,
    this.isPinned = false,
  });

  final String displayName;
  final String username;
  final Color nameColor;
  final DateTime createdAt;
  final String? roleLabel;
  final bool isVerified;
  final bool isPinned;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    // 预计算角色标签背景色
    final roleBgColor = nameColor.withValues(alpha: 0.12);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 用户名 - 限制最大宽度防止溢出
        Flexible(
          child: Text(
            displayName,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: nameColor,
              height: 1.2,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        // @username
        if (username.isNotEmpty) ...[
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '@$username',
              style: TextStyle(
                fontSize: 11,
                color: colors.textTertiary,
                height: 1.2,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
        // 角色标签
        if (roleLabel != null) ...[
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: roleBgColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              roleLabel!,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: nameColor,
                height: 1.1,
              ),
            ),
          ),
        ],
        // 认证标识
        if (isVerified) ...[
          const SizedBox(width: 3),
          Icon(Icons.verified_rounded, size: 12, color: colors.comment),
        ],
        // 置顶标识
        if (isPinned) ...[
          const SizedBox(width: 4),
          Icon(Icons.push_pin_rounded, size: 10, color: colors.textDisabled),
        ],
        // 时间 - 与用户信息间隔
        const SizedBox(width: 8),
        Text(
          formatTime(createdAt),
          style: TextStyle(
            fontSize: 11,
            color: colors.textDisabled,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

/// 引用框 - 带背景色的左边框样式，点击可跳转到原评论
class _QuoteBox extends StatelessWidget {
  const _QuoteBox({required this.target, required this.quoteColor, this.onTap});

  final ReplyTarget target;
  final Color quoteColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    // 预计算颜色
    final bgColor = quoteColor.withValues(alpha: 0.08);
    final borderColor = quoteColor.withValues(alpha: 0.6);

    final content = Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border(left: BorderSide(color: borderColor, width: 3)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              target.authorName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: quoteColor,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              target.isDeleted ? '消息已删除' : target.contentPreview,
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
    );

    // 可跳转时添加点击效果
    if (onTap != null) {
      return Container(
        margin: const EdgeInsets.only(top: 6),
        child: GestureDetector(onTap: onTap, child: content),
      );
    }

    return Container(margin: const EdgeInsets.only(top: 6), child: content);
  }
}

/// 内容
class _Content extends StatelessWidget {
  const _Content({
    required this.content,
    this.isDeleted = false,
    this.trailing,
  });

  final String content;
  final bool isDeleted;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    if (isDeleted) {
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '该评论已删除',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: colors.textDisabled,
                height: 1.4,
              ),
            ),
            if (trailing != null) ...[
              const WidgetSpan(child: SizedBox(width: 8)),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: trailing!,
              ),
            ],
          ],
        ),
      );
    }

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: content,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: colors.textPrimary,
              letterSpacing: 0.1,
            ),
          ),
          if (trailing != null) ...[
            const WidgetSpan(child: SizedBox(width: 8)),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: trailing!,
            ),
          ],
        ],
      ),
    );
  }
}
