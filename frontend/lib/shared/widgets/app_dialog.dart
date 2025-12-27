import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import 'app_button.dart';

/// 对话框类型枚举
enum AppDialogType {
  /// 确认对话框 - 带确认和取消按钮
  confirm,

  /// 警告对话框 - 仅带确认按钮
  alert,

  /// 危险对话框 - 红色确认按钮
  danger,
}

/// 统一对话框工具类 - 基于 TDesign 风格
///
/// 提供一致的对话框样式和行为，应用深色主题样式。
///
/// 示例用法:
/// ```dart
/// // 确认对话框
/// final result = await AppDialog.confirm(
///   context: context,
///   title: '确认操作',
///   content: '确定要执行此操作吗？',
/// );
///
/// // 警告对话框
/// await AppDialog.alert(
///   context: context,
///   title: '提示',
///   content: '操作已完成',
/// );
///
/// // 自定义对话框
/// await AppDialog.custom(
///   context: context,
///   title: '自定义标题',
///   child: MyCustomWidget(),
/// );
/// ```
class AppDialog {
  AppDialog._();

  /// 显示确认对话框
  ///
  /// 返回 `true` 表示用户点击了确认，`false` 或 `null` 表示取消
  ///
  /// [context] - BuildContext
  /// [title] - 对话框标题
  /// [content] - 对话框内容文本
  /// [confirmText] - 确认按钮文本，默认为 "确认"
  /// [cancelText] - 取消按钮文本，默认为 "取消"
  /// [isDanger] - 是否为危险操作（确认按钮显示为红色）
  /// [barrierDismissible] - 点击遮罩是否可关闭，默认为 true
  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    String? content,
    String confirmText = '确认',
    String cancelText = '取消',
    bool isDanger = false,
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: AppColors.overlay,
      builder: (BuildContext context) {
        return _AppDialogWidget(
          title: title,
          content: content,
          confirmText: confirmText,
          cancelText: cancelText,
          showCancelButton: true,
          isDanger: isDanger,
          onConfirm: () => Navigator.of(context).pop(true),
          onCancel: () => Navigator.of(context).pop(false),
        );
      },
    );
  }

  /// 显示警告/提示对话框
  ///
  /// 仅有一个确认按钮
  ///
  /// [context] - BuildContext
  /// [title] - 对话框标题
  /// [content] - 对话框内容文本
  /// [confirmText] - 确认按钮文本，默认为 "知道了"
  /// [barrierDismissible] - 点击遮罩是否可关闭，默认为 true
  static Future<void> alert({
    required BuildContext context,
    required String title,
    String? content,
    String confirmText = '知道了',
    bool barrierDismissible = true,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: AppColors.overlay,
      builder: (BuildContext context) {
        return _AppDialogWidget(
          title: title,
          content: content,
          confirmText: confirmText,
          showCancelButton: false,
          onConfirm: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  /// 显示自定义内容对话框
  ///
  /// [context] - BuildContext
  /// [title] - 对话框标题（可选）
  /// [child] - 自定义内容组件
  /// [actions] - 自定义操作按钮列表（可选）
  /// [barrierDismissible] - 点击遮罩是否可关闭，默认为 true
  /// [contentPadding] - 内容区域内边距
  static Future<T?> custom<T>({
    required BuildContext context,
    String? title,
    required Widget child,
    List<Widget>? actions,
    bool barrierDismissible = true,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: AppColors.overlay,
      builder: (BuildContext context) {
        return _AppDialogWidget(
          title: title,
          customContent: child,
          customActions: actions,
          contentPadding: contentPadding,
        );
      },
    );
  }

  /// 显示危险操作确认对话框
  ///
  /// 确认按钮为红色，用于删除等破坏性操作
  ///
  /// [context] - BuildContext
  /// [title] - 对话框标题
  /// [content] - 对话框内容文本
  /// [confirmText] - 确认按钮文本，默认为 "删除"
  /// [cancelText] - 取消按钮文本，默认为 "取消"
  /// [barrierDismissible] - 点击遮罩是否可关闭，默认为 true
  static Future<bool?> danger({
    required BuildContext context,
    required String title,
    String? content,
    String confirmText = '删除',
    String cancelText = '取消',
    bool barrierDismissible = true,
  }) {
    return confirm(
      context: context,
      title: title,
      content: content,
      confirmText: confirmText,
      cancelText: cancelText,
      isDanger: true,
      barrierDismissible: barrierDismissible,
    );
  }

  /// 显示输入对话框
  ///
  /// 返回用户输入的文本，取消返回 null
  ///
  /// [context] - BuildContext
  /// [title] - 对话框标题
  /// [hintText] - 输入框提示文本
  /// [initialValue] - 初始值
  /// [confirmText] - 确认按钮文本，默认为 "确认"
  /// [cancelText] - 取消按钮文本，默认为 "取消"
  /// [maxLines] - 最大行数，默认为 1
  /// [barrierDismissible] - 点击遮罩是否可关闭，默认为 true
  static Future<String?> input({
    required BuildContext context,
    required String title,
    String? hintText,
    String? initialValue,
    String confirmText = '确认',
    String cancelText = '取消',
    int maxLines = 1,
    bool barrierDismissible = true,
  }) {
    final controller = TextEditingController(text: initialValue);

    return showDialog<String>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: AppColors.overlay,
      builder: (BuildContext context) {
        return _AppDialogWidget(
          title: title,
          customContent: TDInput(
            controller: controller,
            hintText: hintText,
            maxLines: maxLines,
            backgroundColor: AppColors.input,
            textStyle: TextStyle(color: AppColors.onSurface),
            hintTextStyle: TextStyle(color: AppColors.onSurfaceVariant),
            autofocus: true,
          ),
          confirmText: confirmText,
          cancelText: cancelText,
          showCancelButton: true,
          onConfirm: () => Navigator.of(context).pop(controller.text),
          onCancel: () => Navigator.of(context).pop(null),
        );
      },
    ).then((value) {
      controller.dispose();
      return value;
    });
  }
}

/// 对话框内部组件
class _AppDialogWidget extends StatelessWidget {
  final String? title;
  final String? content;
  final Widget? customContent;
  final String? confirmText;
  final String? cancelText;
  final bool showCancelButton;
  final bool isDanger;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final List<Widget>? customActions;
  final EdgeInsetsGeometry? contentPadding;

  const _AppDialogWidget({
    this.title,
    this.content,
    this.customContent,
    this.confirmText,
    this.cancelText,
    this.showCancelButton = false,
    this.isDanger = false,
    this.onConfirm,
    this.onCancel,
    this.customActions,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.dialog,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 280,
          maxWidth: 400,
        ),
        child: Padding(
          padding: contentPadding ?? AppSpacing.allXl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              if (title != null) ...[
                Text(
                  title!,
                  style: TextStyle(
                    color: AppColors.foreground,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpacing.md),
              ],

              // 内容
              if (customContent != null)
                customContent!
              else if (content != null)
                Text(
                  content!,
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

              // 操作按钮
              if (customActions != null || onConfirm != null) ...[
                SizedBox(height: AppSpacing.xl),
                _buildActions(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    if (customActions != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: customActions!
            .map((action) => Padding(
                  padding: EdgeInsets.only(left: AppSpacing.sm),
                  child: action,
                ))
            .toList(),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (showCancelButton && cancelText != null) ...[
          AppButton.text(
            text: cancelText!,
            onPressed: onCancel,
          ),
          SizedBox(width: AppSpacing.sm),
        ],
        if (confirmText != null)
          isDanger
              ? AppButton.danger(
                  text: confirmText!,
                  onPressed: onConfirm,
                  size: AppButtonSize.small,
                )
              : AppButton.primary(
                  text: confirmText!,
                  onPressed: onConfirm,
                  size: AppButtonSize.small,
                ),
      ],
    );
  }
}
