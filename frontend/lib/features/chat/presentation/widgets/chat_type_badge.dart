import 'package:flutter/material.dart';
import '../../../../shared/theme/theme.dart';
import 'chat_item.dart';

/// 聊天类型标识组件
///
/// 显示在头像右下角，用于区分私聊、群聊和频道。
/// 
/// 类型显示规则：
/// - 群聊 ([ChatType.group])：显示双人图标 ([Icons.people_outline])
/// - 频道 ([ChatType.channel])：显示 # 图标 ([Icons.tag])
/// - 私聊 ([ChatType.private])：不显示徽章
///
/// 视觉规格（遵循 Requirements 7.1-7.3）：
/// - 尺寸：16x16px
/// - 背景：[AppColors.background]（带边框效果）
/// - 图标：10px，[AppColors.mutedForeground]
/// 
/// 无障碍支持：
/// - 使用 [Semantics] 提供屏幕阅读器描述
/// - 群聊标识为"群聊"，频道标识为"频道"
/// 
/// 示例用法：
/// ```dart
/// ChatTypeBadge(chatType: ChatType.group)
/// ```
/// 
/// 参见：
/// - [ChatItem] - 使用此组件显示聊天类型
/// - [ChatType] - 聊天类型枚举
class ChatTypeBadge extends StatelessWidget {
  /// 聊天类型
  /// 
  /// 决定显示哪种图标，或是否显示徽章
  final ChatType chatType;

  /// 创建聊天类型标识组件
  /// 
  /// [chatType] 指定聊天类型，决定显示的图标
  const ChatTypeBadge({super.key, required this.chatType});

  @override
  Widget build(BuildContext context) {
    // 私聊不显示徽章
    if (chatType == ChatType.private) {
      return const SizedBox.shrink();
    }

    return Semantics(
      label: _getAccessibilityLabel(),
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.background,
            width: 1.5,
          ),
        ),
        child: Center(
          child: _buildIcon(),
        ),
      ),
    );
  }

  /// 获取无障碍标签
  String _getAccessibilityLabel() {
    switch (chatType) {
      case ChatType.group:
        return '群聊';
      case ChatType.channel:
        return '频道';
      case ChatType.private:
        return '';
    }
  }

  /// 根据聊天类型构建对应图标
  Widget _buildIcon() {
    switch (chatType) {
      case ChatType.group:
        return Icon(
          Icons.people_outline,
          size: 10,
          color: AppColors.mutedForeground,
          semanticLabel: null, // 由父级 Semantics 处理
        );
      case ChatType.channel:
        return Icon(
          Icons.tag,
          size: 10,
          color: AppColors.mutedForeground,
          semanticLabel: null, // 由父级 Semantics 处理
        );
      case ChatType.private:
        // 私聊不显示，但为了完整性保留此分支
        return const SizedBox.shrink();
    }
  }
}
