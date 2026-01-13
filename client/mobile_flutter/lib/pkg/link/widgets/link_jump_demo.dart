// Link 快速跳转演示组件
//
// 提供两个可点击的文字 Link，用于测试 Link 系统的跳转功能

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../ui/theme/theme.dart';
import '../../ui/widgets/loading_dots.dart';
import '../link_parser.dart';
import '../link_service.dart';

/// Link 跳转演示组件
///
/// 显示两个可点击的 Link：
/// - 跳转到第一条评论（顶部）
/// - 跳转到最后一条评论（底部）
///
/// 使用方式：
/// ```dart
/// LinkJumpDemo(
///   channelId: 'test',
///   messageId: 'post_1',
///   topCommentId: 'c1',
///   bottomCommentId: 'c1_r1_r1_r1_r1',
/// )
/// ```
class LinkJumpDemo extends StatelessWidget {
  const LinkJumpDemo({
    super.key,
    required this.channelId,
    required this.messageId,
    required this.topCommentId,
    required this.bottomCommentId,
    this.topLabel = '跳转到第一条评论',
    this.bottomLabel = '跳转到最后一条评论',
  });

  /// 频道 ID
  final String channelId;

  /// 消息 ID
  final String messageId;

  /// 顶部评论 ID
  final String topCommentId;

  /// 底部评论 ID
  final String bottomCommentId;

  /// 顶部链接标签
  final String topLabel;

  /// 底部链接标签
  final String bottomLabel;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题
          Row(
            children: [
              Icon(Icons.link_rounded, size: 16, color: colors.accent),
              const SizedBox(width: 6),
              Text(
                'Link 跳转测试',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 跳转链接
          _LinkItem(
            label: topLabel,
            url: LinkParser.buildCommentUrl(channelId, messageId, topCommentId),
            icon: Icons.vertical_align_top_rounded,
            colors: colors,
          ),
          const SizedBox(height: 8),
          _LinkItem(
            label: bottomLabel,
            url: LinkParser.buildCommentUrl(
              channelId,
              messageId,
              bottomCommentId,
            ),
            icon: Icons.vertical_align_bottom_rounded,
            colors: colors,
          ),
        ],
      ),
    );
  }
}

/// 单个 Link 项
class _LinkItem extends StatefulWidget {
  const _LinkItem({
    required this.label,
    required this.url,
    required this.icon,
    required this.colors,
  });

  final String label;
  final String url;
  final IconData icon;
  final AppColorScheme colors;

  @override
  State<_LinkItem> createState() => _LinkItemState();
}

class _LinkItemState extends State<_LinkItem> {
  bool _isLoading = false;

  Future<void> _handleTap() async {
    if (_isLoading) return;

    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);

    try {
      final result = await LinkService.instance.navigate(context, widget.url);

      if (!mounted) return;

      // 显示结果提示
      final message = switch (result) {
        LinkNavigateResult.success => '跳转成功',
        LinkNavigateResult.notInitialized => 'LinkService 未初始化',
        LinkNavigateResult.invalidLink => '无效的链接',
        LinkNavigateResult.notFound => '内容不存在',
        LinkNavigateResult.unsupported => '不支持的链接类型',
        LinkNavigateResult.failed => '跳转失败',
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: widget.colors.accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(widget.icon, size: 18, color: widget.colors.accent),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: widget.colors.accent,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.url,
                    style: TextStyle(
                      fontSize: 11,
                      color: widget.colors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (_isLoading)
              LoadingDots.mini(color: widget.colors.accent)
            else
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: widget.colors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}

/// 内联 Link 文本
///
/// 可嵌入到任意文本中的可点击 Link
///
/// 使用方式：
/// ```dart
/// Text.rich(
///   TextSpan(
///     children: [
///       TextSpan(text: '点击 '),
///       WidgetSpan(
///         child: InlineLinkText(
///           text: '这里',
///           url: 'https://lesser.app/channel/test/message/post_1/comment/c1',
///         ),
///       ),
///       TextSpan(text: ' 跳转到评论'),
///     ],
///   ),
/// )
/// ```
class InlineLinkText extends StatefulWidget {
  const InlineLinkText({
    super.key,
    required this.text,
    required this.url,
    this.style,
  });

  /// 显示文本
  final String text;

  /// 链接 URL
  final String url;

  /// 文本样式（可选）
  final TextStyle? style;

  @override
  State<InlineLinkText> createState() => _InlineLinkTextState();
}

class _InlineLinkTextState extends State<InlineLinkText> {
  bool _isLoading = false;

  Future<void> _handleTap() async {
    if (_isLoading) return;

    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);

    try {
      await LinkService.instance.navigate(context, widget.url);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final baseStyle =
        widget.style ??
        TextStyle(
          fontSize: 14,
          color: colors.accent,
          fontWeight: FontWeight.w500,
        );

    return GestureDetector(
      onTap: _handleTap,
      child: _isLoading
          ? LoadingDots.mini(color: colors.accent)
          : Text(
              widget.text,
              style: baseStyle.copyWith(
                decoration: TextDecoration.underline,
                decorationColor: colors.accent.withValues(alpha: 0.5),
              ),
            ),
    );
  }
}

/// 简单的 Link 文本按钮
///
/// 独立的可点击 Link 文本，带有加载状态
class LinkTextButton extends StatefulWidget {
  const LinkTextButton({
    super.key,
    required this.text,
    required this.url,
    this.icon,
    this.onResult,
  });

  /// 显示文本
  final String text;

  /// 链接 URL
  final String url;

  /// 前置图标（可选）
  final IconData? icon;

  /// 跳转结果回调
  final void Function(LinkNavigateResult result)? onResult;

  @override
  State<LinkTextButton> createState() => _LinkTextButtonState();
}

class _LinkTextButtonState extends State<LinkTextButton> {
  bool _isLoading = false;

  Future<void> _handleTap() async {
    if (_isLoading) return;

    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);

    try {
      final result = await LinkService.instance.navigate(context, widget.url);
      widget.onResult?.call(result);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, size: 16, color: colors.accent),
              const SizedBox(width: 4),
            ],
            if (_isLoading)
              LoadingDots.mini(color: colors.accent)
            else
              Text(
                widget.text,
                style: TextStyle(
                  fontSize: 14,
                  color: colors.accent,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                  decorationColor: colors.accent.withValues(alpha: 0.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
