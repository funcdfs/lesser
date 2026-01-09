// 评论气泡组件
//
// 设计原则：
// - 内容为中心，减少装饰性元素
// - 用户名颜色区分身份
// - 引用框简洁，左边框指示
// - 气泡宽度由三者中最宽的决定：用户行、内容行、操作按钮行

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
    this.trailing,
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
  final Widget? trailing; // 内嵌到内容末尾的组件（如点赞、回复按钮）

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    // 使用 IntrinsicWidth 让气泡宽度由最宽的子元素决定
    return IntrinsicWidth(
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 用户行 + 时间（同一行，时间在右侧）
            _UserRow(
              displayName: displayName,
              username: username,
              roleLabel: roleLabel,
              isVerified: isVerified,
              nameColor: nameColor,
              isPinned: isPinned,
              createdAt: createdAt,
            ),
            // 引用框
            if (replyTo != null)
              _QuoteBox(
                target: replyTo!,
                quoteColor: getNameColor(replyTo!.commentId),
              ),
            // 内容
            const SizedBox(height: 4),
            _Content(
              content: content,
              isDeleted: isDeleted,
              trailing: trailing,
            ),
          ],
        ),
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

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 用户名
        Text(
          displayName,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: nameColor,
            height: 1.2,
          ),
        ),
        // @username
        if (username.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(
            '@$username',
            style: TextStyle(
              fontSize: 11,
              color: colors.textTertiary,
              height: 1.2,
            ),
          ),
        ],
        // 角色标签
        if (roleLabel != null) ...[
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: nameColor.withValues(alpha: 0.12),
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

/// 引用框 - 带背景色的左边框样式
class _QuoteBox extends StatelessWidget {
  const _QuoteBox({required this.target, required this.quoteColor});

  final ReplyTarget target;
  final Color quoteColor;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: quoteColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border(
          left: BorderSide(color: quoteColor.withValues(alpha: 0.6), width: 3),
        ),
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
