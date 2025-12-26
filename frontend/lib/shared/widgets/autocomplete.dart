import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Autocomplete 组件，基于 forui 包实现
///
/// 用于提供输入建议和自动完成功能
class AppAutocomplete extends StatelessWidget {
  /// 建议选项列表
  final List<String> items;

  /// 控制输入和选择的对象
  final FAutocompleteControl control;

  /// 提示文本
  final String? hint;

  /// 标签
  final Widget? label;

  /// 描述
  final Widget? description;

  /// 文本变化时的回调
  final ValueChanged<TextEditingValue>? onChanged;

  /// 是否禁用
  final bool enabled;

  const AppAutocomplete({
    super.key,
    required this.items,
    this.control = const FAutocompleteControl.managed(),
    this.hint,
    this.label,
    this.description,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // 创建一个自定义的控制对象，如果提供了 onChanged 回调
    final autocompleteControl = onChanged != null
        ? FAutocompleteControl.managed(onChange: onChanged)
        : control;

    return FAutocomplete(
      items: items,
      control: autocompleteControl,
      hint: hint,
      label: label,
      description: description,
      enabled: enabled,
    );
  }
}
