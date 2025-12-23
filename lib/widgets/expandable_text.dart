import 'package:flutter/material.dart';
import '../config/shadcn_theme.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
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
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use a TextPainter to determine if the text exceeds the max lines
        final span = TextSpan(text: widget.text, style: widget.style);
        final tp = TextPainter(
          text: span,
          maxLines: widget.maxLines,
          textDirection: TextDirection.ltr,
        );
        tp.layout(maxWidth: constraints.maxWidth);

        final checkTp = TextPainter(
          text: span,
          textDirection: TextDirection.ltr,
        );
        checkTp.layout(maxWidth: constraints.maxWidth);

        if (checkTp.height <= tp.height) {
          // Text fits within maxLines, just show it
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
                  _isExpanded ? '收起' : '全文', // Localized as per context
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
