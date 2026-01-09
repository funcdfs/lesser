// 消息头部组件
//
// 在评论列表顶部显示原始消息内容

import 'package:flutter/material.dart';
import '../../ui/theme/theme.dart';
import '../../ui/widgets/avatar_button.dart';
import '../../ui/widgets/count_divider.dart';
import '../utils.dart';

// 导出公共组件供外部使用
export '../../ui/widgets/count_divider.dart';

/// 消息头部数据
class MessageHeaderData {
  const MessageHeaderData({
    required this.content,
    this.authorName,
    this.authorAvatarUrl,
    this.createdAt,
    this.viewCount,
  });

  final String content;
  final String? authorName;
  final String? authorAvatarUrl;
  final DateTime? createdAt;
  final int? viewCount;
}

/// 消息头部组件
///
/// 在评论列表顶部显示原始消息，类似 Twitter 的帖子详情页
class MessageHeader extends StatelessWidget {
  const MessageHeader({
    super.key,
    required this.data,
    required this.commentCount,
  });

  final MessageHeaderData data;
  final int commentCount;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 消息内容区域 - 带淡色背景
        // 注意：外边距由父容器控制，组件只定义内边距
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.accent.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 作者信息（如果有）
              if (data.authorName != null) ...[
                Row(
                  children: [
                    // 头像 - 使用公共 AvatarButton 组件
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: AvatarButton(
                        imageUrl: data.authorAvatarUrl,
                        size: 28,
                        placeholder: data.authorName?.isNotEmpty == true
                            ? data.authorName![0].toUpperCase()
                            : null,
                      ),
                    ),
                    // 作者名
                    Text(
                      data.authorName!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    // 时间 - 复用 utils 中的格式化函数
                    if (data.createdAt != null)
                      Text(
                        formatTime(data.createdAt!),
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textTertiary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
              // 消息内容
              Text(
                data.content,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: colors.textPrimary,
                ),
              ),
              // 浏览量（如果有）
              if (data.viewCount != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.visibility_rounded,
                      size: 14,
                      color: colors.textDisabled,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formatCount(data.viewCount!),
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textDisabled,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        // 评论分隔符 - 直接使用公共组件
        CountDivider(count: commentCount, label: '条评论'),
      ],
    );
  }
}
