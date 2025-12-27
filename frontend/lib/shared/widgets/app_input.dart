import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

/// 输入框类型枚举
enum AppInputType {
  /// 普通文本输入
  text,

  /// 密码输入
  password,

  /// 邮箱输入
  email,

  /// 数字输入
  number,

  /// 多行文本输入
  multiline,
}

/// 输入框尺寸枚举
enum AppInputSize {
  /// 小尺寸
  small,

  /// 中等尺寸（默认）
  medium,

  /// 大尺寸
  large,
}

/// 统一输入框组件 - 封装 TDInput
///
/// 提供一致的输入框样式和行为，支持多种类型和状态。
/// 应用深色主题样式。
///
/// 示例用法:
/// ```dart
/// AppInput(
///   controller: _usernameController,
///   labelText: '用户名',
///   hintText: '请输入用户名',
///   prefixIcon: Icons.person,
/// )
/// ```
class AppInput extends StatefulWidget {
  /// 文本控制器
  final TextEditingController? controller;

  /// 标签文本（显示在输入框左侧）
  final String? labelText;

  /// 占位符文本
  final String? hintText;

  /// 错误提示文本
  final String? errorText;

  /// 帮助提示文本
  final String? helperText;

  /// 输入框类型
  final AppInputType type;

  /// 输入框尺寸
  final AppInputSize size;

  /// 是否禁用
  final bool isDisabled;

  /// 是否只读
  final bool isReadOnly;

  /// 前缀图标
  final IconData? prefixIcon;

  /// 前缀组件（与 prefixIcon 二选一）
  final Widget? prefix;

  /// 后缀图标
  final IconData? suffixIcon;

  /// 后缀组件（与 suffixIcon 二选一）
  final Widget? suffix;

  /// 文本变化回调
  final ValueChanged<String>? onChanged;

  /// 提交回调
  final ValueChanged<String>? onSubmitted;

  /// 焦点变化回调
  final ValueChanged<bool>? onFocusChanged;

  /// 点击回调
  final VoidCallback? onTap;

  /// 最大行数（仅 multiline 类型有效）
  final int? maxLines;

  /// 最小行数（仅 multiline 类型有效）
  final int? minLines;

  /// 最大长度
  final int? maxLength;

  /// 输入格式化器
  final List<TextInputFormatter>? inputFormatters;

  /// 键盘类型
  final TextInputType? keyboardType;

  /// 键盘动作按钮类型
  final TextInputAction? textInputAction;

  /// 是否自动获取焦点
  final bool autofocus;

  /// 焦点节点
  final FocusNode? focusNode;

  /// 是否显示清除按钮
  final bool showClearButton;

  /// 是否显示字数统计
  final bool showCounter;

  const AppInput({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.errorText,
    this.helperText,
    this.type = AppInputType.text,
    this.size = AppInputSize.medium,
    this.isDisabled = false,
    this.isReadOnly = false,
    this.prefixIcon,
    this.prefix,
    this.suffixIcon,
    this.suffix,
    this.onChanged,
    this.onSubmitted,
    this.onFocusChanged,
    this.onTap,
    this.maxLines,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.keyboardType,
    this.textInputAction,
    this.autofocus = false,
    this.focusNode,
    this.showClearButton = false,
    this.showCounter = false,
  });

  /// 工厂方法：创建普通文本输入框
  factory AppInput.text({
    Key? key,
    TextEditingController? controller,
    String? labelText,
    String? hintText,
    String? errorText,
    IconData? prefixIcon,
    IconData? suffixIcon,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    bool isDisabled = false,
    bool isReadOnly = false,
    bool showClearButton = false,
    int? maxLength,
  }) {
    return AppInput(
      key: key,
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      errorText: errorText,
      type: AppInputType.text,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      isDisabled: isDisabled,
      isReadOnly: isReadOnly,
      showClearButton: showClearButton,
      maxLength: maxLength,
    );
  }

  /// 工厂方法：创建密码输入框
  factory AppInput.password({
    Key? key,
    TextEditingController? controller,
    String? labelText,
    String? hintText,
    String? errorText,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    bool isDisabled = false,
    bool isReadOnly = false,
  }) {
    return AppInput(
      key: key,
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      errorText: errorText,
      type: AppInputType.password,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      isDisabled: isDisabled,
      isReadOnly: isReadOnly,
    );
  }

  /// 工厂方法：创建邮箱输入框
  factory AppInput.email({
    Key? key,
    TextEditingController? controller,
    String? labelText,
    String? hintText,
    String? errorText,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    bool isDisabled = false,
    bool isReadOnly = false,
    bool showClearButton = false,
  }) {
    return AppInput(
      key: key,
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      errorText: errorText,
      type: AppInputType.email,
      prefixIcon: Icons.email_outlined,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      isDisabled: isDisabled,
      isReadOnly: isReadOnly,
      showClearButton: showClearButton,
      keyboardType: TextInputType.emailAddress,
    );
  }

  /// 工厂方法：创建数字输入框
  factory AppInput.number({
    Key? key,
    TextEditingController? controller,
    String? labelText,
    String? hintText,
    String? errorText,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    bool isDisabled = false,
    bool isReadOnly = false,
    int? maxLength,
  }) {
    return AppInput(
      key: key,
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      errorText: errorText,
      type: AppInputType.number,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      isDisabled: isDisabled,
      isReadOnly: isReadOnly,
      maxLength: maxLength,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }

  /// 工厂方法：创建多行文本输入框
  factory AppInput.multiline({
    Key? key,
    TextEditingController? controller,
    String? labelText,
    String? hintText,
    String? errorText,
    ValueChanged<String>? onChanged,
    bool isDisabled = false,
    bool isReadOnly = false,
    int maxLines = 4,
    int minLines = 2,
    int? maxLength,
    bool showCounter = false,
  }) {
    return AppInput(
      key: key,
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      errorText: errorText,
      type: AppInputType.multiline,
      onChanged: onChanged,
      isDisabled: isDisabled,
      isReadOnly: isReadOnly,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      showCounter: showCounter,
    );
  }

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  late bool _obscureText;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.type == AppInputType.password;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    widget.onFocusChanged?.call(_focusNode.hasFocus);
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildInputField(hasError),
        if (hasError) _buildErrorText(),
        if (!hasError && widget.helperText != null) _buildHelperText(),
      ],
    );
  }

  Widget _buildInputField(bool hasError) {
    final isMultiline = widget.type == AppInputType.multiline;

    return TDInput(
      controller: widget.controller,
      leftLabel: widget.labelText,
      hintText: widget.hintText,
      type: widget.type == AppInputType.password
          ? TDInputType.special
          : TDInputType.normal,
      obscureText: _obscureText,
      backgroundColor: widget.isDisabled
          ? AppColors.disabledBackground
          : hasError
              ? AppColors.error.withValues(alpha: 0.05)
              : AppColors.surface,
      textStyle: TextStyle(
        color: widget.isDisabled
            ? AppColors.disabledForeground
            : AppColors.onSurface,
        fontSize: _getFontSize(),
      ),
      hintTextStyle: TextStyle(
        color: AppColors.mutedForeground,
        fontSize: _getFontSize(),
      ),
      readOnly: widget.isDisabled || widget.isReadOnly,
      autofocus: widget.autofocus,
      focusNode: _focusNode,
      maxLines: isMultiline ? (widget.maxLines ?? 4) : 1,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      leftIcon: _buildPrefixIcon(),
      rightBtn: _buildSuffixWidget(),
      needClear: widget.showClearButton && !widget.isDisabled && !widget.isReadOnly,
      inputDecoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: hasError
                ? AppColors.error
                : _isFocused
                    ? AppColors.brand
                    : AppColors.inputBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: hasError ? AppColors.error : AppColors.inputBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: hasError ? AppColors.error : AppColors.brand,
            width: 1.5,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: AppColors.disabledBackground,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: AppColors.error,
          ),
        ),
        contentPadding: _getContentPadding(),
        counterText: widget.showCounter ? null : '',
      ),
    );
  }

  Widget? _buildPrefixIcon() {
    if (widget.prefix != null) {
      return widget.prefix;
    }
    if (widget.prefixIcon != null) {
      return Icon(
        widget.prefixIcon,
        size: _getIconSize(),
        color: widget.isDisabled
            ? AppColors.disabledForeground
            : AppColors.mutedForeground,
      );
    }
    return null;
  }

  Widget? _buildSuffixWidget() {
    // 密码输入框显示切换按钮
    if (widget.type == AppInputType.password) {
      return GestureDetector(
        onTap: widget.isDisabled ? null : _toggleObscureText,
        child: Icon(
          _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: _getIconSize(),
          color: widget.isDisabled
              ? AppColors.disabledForeground
              : AppColors.mutedForeground,
        ),
      );
    }

    // 自定义后缀组件
    if (widget.suffix != null) {
      return widget.suffix;
    }

    // 后缀图标
    if (widget.suffixIcon != null) {
      return Icon(
        widget.suffixIcon,
        size: _getIconSize(),
        color: widget.isDisabled
            ? AppColors.disabledForeground
            : AppColors.mutedForeground,
      );
    }

    return null;
  }

  Widget _buildErrorText() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs, left: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 14,
            color: AppColors.error,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              widget.errorText!,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelperText() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs, left: AppSpacing.xs),
      child: Text(
        widget.helperText!,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.mutedForeground,
        ),
      ),
    );
  }

  double _getFontSize() {
    switch (widget.size) {
      case AppInputSize.small:
        return 13;
      case AppInputSize.medium:
        return 14;
      case AppInputSize.large:
        return 16;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case AppInputSize.small:
        return 16;
      case AppInputSize.medium:
        return 20;
      case AppInputSize.large:
        return 24;
    }
  }

  EdgeInsets _getContentPadding() {
    switch (widget.size) {
      case AppInputSize.small:
        return const EdgeInsets.symmetric(horizontal: 10, vertical: 8);
      case AppInputSize.medium:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 12);
      case AppInputSize.large:
        return const EdgeInsets.symmetric(horizontal: 14, vertical: 16);
    }
  }
}
