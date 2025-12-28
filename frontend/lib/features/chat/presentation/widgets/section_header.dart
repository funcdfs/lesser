import 'package:flutter/material.dart';
import '../../../../shared/theme/theme.dart';

/// 列表区块标题组件
///
/// 用于显示列表区块的标题，如"最近聊天"、"网络邻居"等。
/// 
/// 视觉规格（遵循 Requirements 2.1, 7.1-7.3）：
/// - 水平内边距：[AppSpacing.lg] (16px)
/// - 垂直内边距：[AppSpacing.sm] (8px)
/// - 字体大小：13px
/// - 字重：FontWeight.w600
/// - 颜色：[AppColors.mutedForeground]
/// - 字间距：0.5
/// 
/// 无障碍支持：
/// - 使用 [Semantics] 标记为标题
/// - 提供屏幕阅读器可访问的标题文本
/// 
/// 示例用法：
/// ```dart
/// SectionHeader(title: '最近聊天')
/// ```
class SectionHeader extends StatelessWidget {
  /// 标题文本
  final String title;

  /// 创建列表区块标题组件
  /// 
  /// [title] 要显示的标题文本
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.mutedForeground,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
