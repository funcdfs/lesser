// 评论入口组件
//
// Telegram Channel 风格：头像堆叠 + 评论数 + 箭头
// 头像在左侧，箭头在右侧

import 'package:flutter/material.dart';
import '../../ui/theme/theme.dart';
import '../../ui/effects/effects.dart';
import '../../ui/widgets/avatar_stack.dart';
import '../../ui/widgets/dotted_divider.dart';

/// 评论入口组件
class CommentEntry extends StatelessWidget {
  const CommentEntry({
    super.key,
    required this.commentCount,
    this.avatarUrls = const [],
    this.maxAvatars = 3,
    this.avatarSize = 28,
    this.onTap,
    this.showBackground = true,
    this.showDivider = false,
  });

  final int commentCount;
  final List<String> avatarUrls;
  final int maxAvatars;
  final double avatarSize;
  final VoidCallback? onTap;
  final bool showBackground;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final hasComments = commentCount > 0;
    // 颜色：有评论时用强调色，无评论时用默认灰色
    final textColor = hasComments ? colors.accent : colors.textSecondary;

    return TapScale(
      onTap: onTap,
      scale: TapScales.card,
      child: Container(
        decoration: showBackground
            ? BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 点状分割线
            if (showDivider)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: DottedDivider(color: colors.divider),
              ),
            // 评论入口内容
            Padding(
              padding: EdgeInsets.fromLTRB(14, showDivider ? 10 : 12, 10, 12),
              child: Row(
                children: [
                  // 左侧：头像堆叠
                  if (avatarUrls.isNotEmpty) ...[
                    AvatarStack(
                      avatarUrls: avatarUrls.take(maxAvatars).toList(),
                      size: avatarSize,
                    ),
                    const SizedBox(width: 10),
                  ],
                  // 评论数量文字 - 中文
                  Text(
                    hasComments ? '$commentCount 条评论' : '发表评论',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  const Spacer(),
                  // 右侧：箭头
                  Icon(Icons.chevron_right_rounded, size: 22, color: textColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
