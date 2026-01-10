// 数字翻页动画组件
// 当数字变化时，旧数字向上滑出并淡出，新数字从下方滑入并淡入

import 'package:flutter/material.dart';
import '../../utils/format_utils.dart';

class AnimatedCount extends StatefulWidget {
  const AnimatedCount({
    super.key,
    required this.count,
    this.style,
    this.duration = const Duration(milliseconds: 300),
  });

  final int count;
  final TextStyle? style;
  final Duration duration;

  @override
  State<AnimatedCount> createState() => _AnimatedCountState();
}

class _AnimatedCountState extends State<AnimatedCount>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _slideOut;
  late Animation<double> _slideIn;
  late Animation<double> _fadeOut;
  late Animation<double> _fadeIn;

  int _oldCount = 0;
  int _newCount = 0;
  bool _isIncreasing = true;

  @override
  void initState() {
    super.initState();
    _oldCount = widget.count;
    _newCount = widget.count;

    _ctrl = AnimationController(duration: widget.duration, vsync: this);

    // 旧数字：向上滑出 + 淡出
    _slideOut = Tween<double>(
      begin: 0,
      end: -1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _fadeOut = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));

    // 新数字：从下方滑入 + 淡入
    _slideIn = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _fadeIn = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedCount old) {
    super.didUpdateWidget(old);
    if (old.count != widget.count) {
      _oldCount = old.count;
      _newCount = widget.count;
      _isIncreasing = widget.count > old.count;
      _ctrl.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? const TextStyle(fontSize: 13);
    final height = (style.fontSize ?? 13) * 1.4;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        // 动画未开始或已完成，只显示当前数字
        if (!_ctrl.isAnimating && _ctrl.status != AnimationStatus.forward) {
          return Text(formatCountChinese(widget.count), style: style);
        }

        // 根据增减方向调整滑动方向
        final outOffset = _isIncreasing ? _slideOut.value : -_slideOut.value;
        final inOffset = _isIncreasing ? _slideIn.value : -_slideIn.value;

        return SizedBox(
          height: height,
          child: ClipRect(
            child: Stack(
              children: [
                // 旧数字滑出
                Transform.translate(
                  offset: Offset(0, outOffset * height),
                  child: Opacity(
                    opacity: _fadeOut.value,
                    child: Text(formatCountChinese(_oldCount), style: style),
                  ),
                ),
                // 新数字滑入
                Transform.translate(
                  offset: Offset(0, inOffset * height),
                  child: Opacity(
                    opacity: _fadeIn.value,
                    child: Text(formatCountChinese(_newCount), style: style),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
