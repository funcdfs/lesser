import 'package:flutter/material.dart';
import '../../../../shared/theme/theme.dart';

/// 通知类型枚举
/// 
/// 定义消息页面顶部通知分类栏的四种通知类型：
/// - [likes]：喜欢通知
/// - [replies]：回复通知
/// - [bookmarks]：收藏通知
/// - [follows]：关注通知
enum NotificationType {
  /// 喜欢通知 - 显示心形图标
  likes,
  /// 回复通知 - 显示聊天气泡图标
  replies,
  /// 收藏通知 - 显示书签图标
  bookmarks,
  /// 关注通知 - 显示添加用户图标
  follows,
}

/// 通知分类栏组件
/// 
/// 显示四个通知类型入口：喜欢、回复、收藏、关注。
/// 
/// 视觉规格（遵循 Requirements 1.1-1.5, 7.1-7.3）：
/// - 容器：水平排列，等间距分布
/// - 图标容器：56x56px，圆角 [AppRadius.xl] (16px)，背景 [AppColors.secondary]
/// - 图标：28px，颜色 [AppColors.foreground]
/// - 标签：12px，颜色 [AppColors.foreground]，间距 [AppSpacing.sm] (8px)
/// 
/// 无障碍支持：
/// - 每个通知项使用 [Semantics] 提供按钮语义
/// - 包含通知类型的描述标签
/// 
/// 示例用法：
/// ```dart
/// NotificationBar(
///   onTap: (type) {
///     switch (type) {
///       case NotificationType.likes:
///         // 跳转到喜欢列表
///         break;
///       // ...
///     }
///   },
/// )
/// ```
/// 
/// 参见：
/// - [NotificationType] - 通知类型枚举
class NotificationBar extends StatelessWidget {
  /// 点击回调，参数为通知类型
  /// 
  /// 当用户点击某个通知入口时触发
  final void Function(NotificationType type)? onTap;

  /// 创建通知分类栏组件
  const NotificationBar({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNotifyItem(
            context,
            Icons.favorite_border,
            '喜欢',
            NotificationType.likes,
          ),
          _buildNotifyItem(
            context,
            Icons.chat_bubble_outline,
            '回复',
            NotificationType.replies,
          ),
          _buildNotifyItem(
            context,
            Icons.bookmark_border,
            '收藏',
            NotificationType.bookmarks,
          ),
          _buildNotifyItem(
            context,
            Icons.person_add_alt_1_outlined,
            '关注',
            NotificationType.follows,
          ),
        ],
      ),
    );
  }

  /// 构建单个通知项
  /// 
  /// [context] - 构建上下文
  /// [icon] - 显示的图标
  /// [label] - 显示的标签文本
  /// [type] - 通知类型，用于点击回调
  Widget _buildNotifyItem(
    BuildContext context,
    IconData icon,
    String label,
    NotificationType type,
  ) {
    return Semantics(
      label: '$label通知',
      button: true,
      child: GestureDetector(
        onTap: onTap != null ? () => onTap!(type) : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Icon(
                icon,
                color: AppColors.foreground,
                size: 28,
                semanticLabel: null, // 由父级 Semantics 处理
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.foreground,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 向后兼容的别名
/// 
/// 已弃用，请使用 [NotificationBar] 代替
@Deprecated('使用 NotificationBar 代替')
typedef NotifyWidget = NotificationBar;
