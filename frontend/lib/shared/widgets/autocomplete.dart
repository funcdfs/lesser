import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Autocomplete 组件，基于 Flutter 原生 Autocomplete 实现
///
/// 用于提供输入建议和自动完成功能
class AppAutocomplete extends StatelessWidget {
  /// 建议选项列表
  final List<String> items;

  /// 提示文本
  final String? hint;

  /// 标签
  final Widget? label;

  /// 描述
  final Widget? description;

  /// 文本变化时的回调
  final ValueChanged<String>? onChanged;

  /// 选择选项时的回调
  final ValueChanged<String>? onSelected;

  /// 是否禁用
  final bool enabled;

  /// 初始值
  final String? initialValue;

  /// 控制器
  final TextEditingController? controller;

  const AppAutocomplete({
    super.key,
    required this.items,
    this.hint,
    this.label,
    this.description,
    this.onChanged,
    this.onSelected,
    this.enabled = true,
    this.initialValue,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          DefaultTextStyle(
            style: TextStyle(
              color: AppColors.foreground,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            child: label!,
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        Autocomplete<String>(
          initialValue: initialValue != null
              ? TextEditingValue(text: initialValue!)
              : null,
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return items.where((String option) {
              return option
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: onSelected,
          fieldViewBuilder: (
            BuildContext context,
            TextEditingController fieldController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted,
          ) {
            // Sync with external controller if provided
            if (controller != null && controller!.text != fieldController.text) {
              fieldController.text = controller!.text;
            }
            
            return TextField(
              controller: fieldController,
              focusNode: focusNode,
              enabled: enabled,
              onChanged: onChanged,
              style: TextStyle(color: AppColors.foreground),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: AppColors.mutedForeground),
                filled: true,
                fillColor: AppColors.input,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                  borderSide: BorderSide(color: AppColors.border.withAlpha(128)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
            );
          },
          optionsViewBuilder: (
            BuildContext context,
            AutocompleteOnSelected<String> onSelected,
            Iterable<String> options,
          ) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSpacing.md),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final String option = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(option),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          child: Text(
                            option,
                            style: TextStyle(color: AppColors.foreground),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        if (description != null) ...[
          const SizedBox(height: AppSpacing.xs),
          DefaultTextStyle(
            style: TextStyle(
              color: AppColors.mutedForeground,
              fontSize: 12,
            ),
            child: description!,
          ),
        ],
      ],
    );
  }
}
