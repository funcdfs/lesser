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
///
/// 注意：由于 TextSpan.recognizer 的限制，内联链接仅支持点击，不支持长按。
/// 如需长按功能，请使用 LinkPreview 组件。
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
      final tapRecognizer = TapGestureRecognizer()
        ..onTap = () => _handleLinkTap(context, url);
      _recognizers.add(tapRecognizer);

      spans.add(
        TextSpan(
          text: _formatLinkDisplay(url),
          style: linkStyle,
          recognizer: tapRecognizer,
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
    return switch (link.targetType) {
      LinkContentType.channel => '频道链接',
      LinkContentType.message => '消息链接',
      LinkContentType.comment => '评论链接',
      LinkContentType.user => '用户链接',
      LinkContentType.post => '帖子链接',
      LinkContentType.anchor => '锚点链接',
    };
  }

  /// 处理链接点击
  void _handleLinkTap(BuildContext context, String url) {
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

  /// 通用 URL 正则
  static final _urlPattern = RegExp(
    r'https?://[^\s\)\]\}]+',
    caseSensitive: false,
  );

  /// 检测文本中是否包含 lesser.app 链接
  static bool containsLink(String text) {
    return _linkPattern.hasMatch(text);
  }

  /// 检测文本中是否包含任意 URL
  static bool containsUrl(String text) {
    return _urlPattern.hasMatch(text);
  }

  /// 提取文本中的所有 lesser.app 链接
  static List<String> extractLinks(String text) {
    return _linkPattern.allMatches(text).map((m) => m.group(0)!).toList();
  }

  /// 提取文本中的所有 URL
  static List<String> extractUrls(String text) {
    return _urlPattern.allMatches(text).map((m) => m.group(0)!).toList();
  }

  /// 提取第一个 lesser.app 链接
  static String? extractFirstLink(String text) {
    final match = _linkPattern.firstMatch(text);
    return match?.group(0);
  }

  /// 提取第一个 URL
  static String? extractFirstUrl(String text) {
    final match = _urlPattern.firstMatch(text);
    return match?.group(0);
  }

  /// 将文本中的链接替换为指定内容
  static String replaceLinks(
    String text,
    String Function(String url) replacer,
  ) {
    return text.replaceAllMapped(_linkPattern, (m) => replacer(m.group(0)!));
  }

  /// 统计文本中的链接数量
  static int countLinks(String text) {
    return _linkPattern.allMatches(text).length;
  }
}
