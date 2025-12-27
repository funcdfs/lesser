import 'package:flutter/material.dart';
import 'package:lesser/shared/theme/theme.dart';

/// 徽章组件（用于显示数字、通知或简短状态）
class Badge extends StatelessWidget {
  /// 徽章显示的文本内容
  final String text;

  /// 背景颜色（可选，默认为 AppColors.destructive）
  final Color? backgroundColor;

  /// 文本颜色（可选，默认为白色）
  final Color? textColor;

  const Badge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.destructive,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor ?? AppColors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
