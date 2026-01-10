// =============================================================================
// 评论页脚手架 - Comment Page Scaffold Widget
// =============================================================================
//
// ## 设计目的
// 为评论相关页面提供统一的布局框架，包含 AppBar 和加载/错误状态处理。
// 减少重复代码，确保评论页面的视觉一致性。
//
// ## 状态处理
// - 加载中：显示居中的加载指示器
// - 错误状态：显示错误图标、提示文字和重试按钮
// - 正常状态：显示传入的 body 内容
//
// ## 使用示例
// ```dart
// CommentPageScaffold(
//   isLoading: _isLoading,
//   error: _error,
//   onRetry: _loadData,
//   body: CommentListView(...),
// )
// ```
//
// =============================================================================

import 'package:flutter/material.dart';
import '../../../pkg/ui/effects/effects.dart';
import '../../../pkg/ui/theme/theme.dart';

/// 评论页脚手架
///
/// 提供统一的 AppBar 和加载/错误状态处理。
///
/// ## 参数说明
/// - [body]: 主体内容 Widget
/// - [isLoading]: 是否显示加载状态
/// - [error]: 错误信息（非 null 时显示错误状态）
/// - [onRetry]: 重试按钮回调
class CommentPageScaffold extends StatelessWidget {
  const CommentPageScaffold({
    super.key,
    required this.body,
    this.isLoading = false,
    this.error,
    this.onRetry,
  });

  final Widget body;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.surfaceBase,
      appBar: AppBar(
        backgroundColor: colors.surfaceBase,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(colors),
    );
  }

  Widget _buildBody(AppColorScheme colors) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: colors.textTertiary,
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: colors.textDisabled,
            ),
            const SizedBox(height: 16),
            Text(
              '加载失败',
              style: TextStyle(fontSize: 16, color: colors.textTertiary),
            ),
            const SizedBox(height: 16),
            if (onRetry != null)
              TapScale(
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '重试',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colors.accent,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return body;
  }
}
