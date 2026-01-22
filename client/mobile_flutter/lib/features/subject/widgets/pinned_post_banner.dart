// =============================================================================
// 置顶动态横幅组件 - Pinned Post Banner Widget
// =============================================================================
//
// ## 设计目的
// 在剧集详情页顶部显示置顶动态，提供快速访问重要信息的入口。
// 支持点击查看详情和关闭横幅两种操作。
//
// ## 视觉设计
// - 图钉图标使用强调色背景
// - 动态预览单行显示，超出部分省略
// - 可选的关闭按钮
// - 底部细线分隔
//
// ## 交互设计
// - 点击整个横幅可查看置顶动态详情
// - 点击关闭按钮可隐藏横幅（不影响置顶状态）
// - 支持 TapScale 缩放反馈
//
// ## 使用示例
// ```dart
// PinnedPostBanner(
//   content: series.pinnedPost!.content,
//   onTap: () => _scrollToPinnedPost(),
//   onClose: () => setState(() => _showPinnedBanner = false),
// )
// ```
//
// =============================================================================

import 'package:flutter/material.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../../../pkg/ui/effects/effects.dart';

/// 置顶动态横幅
///
/// ## 参数说明
/// - [content]: 置顶动态内容预览
/// - [onTap]: 点击横幅回调（可选）
/// - [onClose]: 关闭按钮回调（可选，不传则不显示关闭按钮）
class PinnedPostBanner extends StatelessWidget {
  const PinnedPostBanner({
    super.key,
    required this.content,
    this.onTap,
    this.onClose,
  });

  final String content;
  final VoidCallback? onTap;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return TapScale(
      onTap: onTap,
      scale: TapScales.large,
      haptic: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          border: Border(bottom: BorderSide(color: colors.divider, width: 0.5)),
        ),
        child: Row(
          children: [
            // 图钉图标 - 使用强调色
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: colors.accentSoft,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.push_pin_rounded,
                size: 16,
                color: colors.accent,
              ),
            ),
            const SizedBox(width: 12),

            // 动态预览
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '置顶动态',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.accent,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    content,
                    style: TextStyle(fontSize: 13, color: colors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // 关闭按钮
            if (onClose != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onClose,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: colors.textTertiary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
