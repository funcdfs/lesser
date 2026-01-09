// 链接文本组件
//
// 自动识别文本中的 lesser.app 链接并渲染为可点击的内联卡片

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../ui/theme/theme.dart';
import '../link_parser.dart';
import '../link_service.dart';
import '../models/link_model.dart';

/// 链接文本组件
///
/// 自动识别文本中的 lesser.app 链接，将其渲染为可点击的高亮文本
/// 点击链接时调用 LinkService 进行导航
class LinkText extends StatefulWidget {
  const LinkText({
    super.key,
    required this.text,
    this.style,
    this.linkStyle,
    this.maxLines,
    this.overflow,
    this.onLinkTap,
  });

  /// 原始文本
  final String text;

  /// 普通文本样式
  final TextStyle? style;

  /// 链接文本样式
  final TextStyle? linkStyle;

  /// 最大行数
  final int? maxLines;

  /// 溢出处理
  final TextOverflow? overflow;

  /// 链接点击回调（可选，不提供则使用 LinkService）
  final void Function(String url)? onLinkTap;

  @override
  State<LinkText> createState() => _LinkTextState();
}

class _LinkTextState extends State<LinkText> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(LinkText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      // 文本变化时清理旧的 recognizers
      for (final recognizer in _recognizers) {
        recognizer.dispose();
      }
      _recognizers.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final defaultStyle =
        widget.style ??
        TextStyle(fontSize: 14, color: colors.textPrimary, height: 1.4);
    final defaultLinkStyle =
        widget.linkStyle ??
        TextStyle(
          fontSize: 14,
          color: colors.accent,
          height: 1.4,
          decoration: TextDecoration.underline,
          decorationColor: colors.accent.withValues(alpha: 0.5),
        );

    // 清理旧的 recognizers
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();

    final spans = _buildTextSpans(context, defaultStyle, defaultLinkStyle);

    return Text.rich(
      TextSpan(children: spans),
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }

  /// 构建文本 spans
  List<InlineSpan> _buildTextSpans(
    BuildContext context,
    TextStyle defaultStyle,
    TextStyle linkStyle,
  ) {
    final spans = <InlineSpan>[];
    final linkPattern = RegExp(
      r'https?://lesser\.app/[^\s\)\]\}]+',
      caseSensitive: false,
    );

    int lastEnd = 0;
    for (final match in linkPattern.allMatches(widget.text)) {
      // 添加链接前的普通文本
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(
            text: widget.text.substring(lastEnd, match.start),
            style: defaultStyle,
          ),
        );
      }

      // 添加链接
      final url = match.group(0)!;
      final recognizer = TapGestureRecognizer()
        ..onTap = () => _handleLinkTap(context, url);
      _recognizers.add(recognizer);

      spans.add(
        TextSpan(
          text: _formatLinkDisplay(url),
          style: linkStyle,
          recognizer: recognizer,
        ),
      );

      lastEnd = match.end;
    }

    // 添加剩余的普通文本
    if (lastEnd < widget.text.length) {
      spans.add(
        TextSpan(text: widget.text.substring(lastEnd), style: defaultStyle),
      );
    }

    return spans;
  }

  /// 格式化链接显示文本
  String _formatLinkDisplay(String url) {
    final link = LinkParser.parse(url);
    if (link == null) return url;

    // 根据链接类型生成简短显示文本（简洁风格，无 emoji）
    switch (link.targetType) {
      case LinkContentType.channel:
        return '频道链接';
      case LinkContentType.message:
        return '消息链接';
      case LinkContentType.comment:
        return '评论链接';
      case LinkContentType.user:
        return '用户链接';
      case LinkContentType.post:
        return '帖子链接';
    }
  }

  /// 处理链接点击
  void _handleLinkTap(BuildContext context, String url) {
    // 触感反馈
    HapticFeedback.lightImpact();

    if (widget.onLinkTap != null) {
      widget.onLinkTap!(url);
      return;
    }

    // 使用 LinkService 导航
    if (LinkService.instance.isInitialized) {
      LinkService.instance.navigate(context, url);
    }
  }
}

/// 链接检测工具
class LinkDetector {
  LinkDetector._();

  /// lesser.app 链接正则
  static final _linkPattern = RegExp(
    r'https?://lesser\.app/[^\s\)\]\}]+',
    caseSensitive: false,
  );

  /// 检测文本中是否包含 lesser.app 链接
  static bool containsLink(String text) {
    return _linkPattern.hasMatch(text);
  }

  /// 提取文本中的所有 lesser.app 链接
  static List<String> extractLinks(String text) {
    return _linkPattern.allMatches(text).map((m) => m.group(0)!).toList();
  }

  /// 提取第一个链接
  static String? extractFirstLink(String text) {
    final match = _linkPattern.firstMatch(text);
    return match?.group(0);
  }
}
