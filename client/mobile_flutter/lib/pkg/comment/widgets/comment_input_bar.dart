// 评论输入栏组件
//
// 简洁的底部输入栏设计

import 'package:flutter/material.dart';
import '../../ui/theme/theme.dart';
import '../../ui/effects/effects.dart';
import '../models/comment_model.dart';
import '../utils.dart';

/// 评论输入栏
class CommentInputBar extends StatelessWidget {
  const CommentInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    this.replyTo,
    this.isSubmitting = false,
    this.onSubmit,
    this.onCancelReply,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ReplyTarget? replyTo;
  final bool isSubmitting;
  final VoidCallback? onSubmit;
  final VoidCallback? onCancelReply;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border(top: BorderSide(color: colors.divider, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (replyTo != null)
              _ReplyBar(target: replyTo!, onCancel: onCancelReply),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
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
                        maxLines: 4,
                        minLines: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _SendButton(isSubmitting: isSubmitting, onTap: onSubmit),
                ],
              ),
            ),
          ],
        ),
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
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colors.interactive,
          shape: BoxShape.circle,
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
                size: 20,
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
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 0),
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
