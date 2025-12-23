import 'package:flutter/material.dart';
import '../config/shadcn_theme.dart';

/// 可展开/折叠的文本组件
/// 当文本行数超过指定的最大行数时，显示“全文”按钮，点击后可展开显示全部内容。
class ExpandableText extends StatefulWidget {
  /// 显示的文本内容
  final String text;

  /// 默认显示的最大行数
  final int maxLines;

  /// 文本样式
  final TextStyle? style;

  const ExpandableText({
    super.key,
    required this.text,
    this.maxLines = 3,
    this.style,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  /// 当前是否已展开
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 使用 TextPainter 来检测文本是否超过了最大行数
        final span = TextSpan(text: widget.text, style: widget.style);
        final tp = TextPainter(
          text: span,
          maxLines: widget.maxLines,
          textDirection: TextDirection.ltr,
        );
        tp.layout(maxWidth: constraints.maxWidth);

        // 检测完整文本的高度
        final checkTp = TextPainter(
          text: span,
          textDirection: TextDirection.ltr,
        );
        checkTp.layout(maxWidth: constraints.maxWidth);

        // 如果文本能够直接放得下，则直接显示
        if (checkTp.height <= tp.height) {
          return Text(widget.text, style: widget.style);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              maxLines: _isExpanded ? null : widget.maxLines,
              overflow: _isExpanded ? null : TextOverflow.ellipsis,
              style: widget.style,
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  _isExpanded ? '收起' : '全文',
                  style: TextStyle(
                    color: ShadcnColors.primary,
                    fontWeight: FontWeight.w500,
                    fontSize: (widget.style?.fontSize ?? 14),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
