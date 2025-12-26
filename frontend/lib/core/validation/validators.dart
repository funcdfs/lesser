import 'package:lesser/core/validation/validation_rules.dart';

/// Input validation functions
class Validators {
  // Private constructor to prevent instantiation
  Validators._();

  /// Validate email format
  /// Returns error message if invalid, null if valid
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '邮箱不能为空';
    }

    if (value.length < ValidationRules.minEmailLength) {
      return '邮箱长度至少为${ValidationRules.minEmailLength}个字符';
    }

    if (value.length > ValidationRules.maxEmailLength) {
      return '邮箱长度不能超过${ValidationRules.maxEmailLength}个字符';
    }

    if (!ValidationRules.emailRegex.hasMatch(value)) {
      return '请输入有效的邮箱地址';
    }

    return null;
  }

  /// Validate username format
  /// Returns error message if invalid, null if valid
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return '用户名不能为空';
    }

    if (value.length < ValidationRules.minUsernameLength) {
      return '用户名长度至少为${ValidationRules.minUsernameLength}个字符';
    }

    if (value.length > ValidationRules.maxUsernameLength) {
      return '用户名长度不能超过${ValidationRules.maxUsernameLength}个字符';
    }

    if (!ValidationRules.usernameRegex.hasMatch(value)) {
      return '用户名只能包含字母、数字和下划线';
    }

    return null;
  }

  /// Validate password strength
  /// Returns error message if invalid, null if valid
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '密码不能为空';
    }

    if (value.length < ValidationRules.minPasswordLength) {
      return '密码长度至少为${ValidationRules.minPasswordLength}个字符';
    }

    if (value.length > ValidationRules.maxPasswordLength) {
      return '密码长度不能超过${ValidationRules.maxPasswordLength}个字符';
    }

    // Simple length check - can be enhanced with regex for strength requirements
    if (!value.contains(RegExp(r'[a-zA-Z]'))) {
      return '密码必须包含字母';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return '密码必须包含数字';
    }

    return null;
  }

  /// Validate password confirmation
  /// Returns error message if passwords don't match, null if valid
  static String? validatePasswordConfirm(String? password, String? confirm) {
    if (confirm == null || confirm.isEmpty) {
      return '请确认密码';
    }

    if (password != confirm) {
      return '两次输入的密码不一致';
    }

    return null;
  }

  /// Validate post content
  /// Returns error message if invalid, null if valid
  static String? validatePostContent(String? value) {
    if (value == null || value.isEmpty) {
      return '内容不能为空';
    }

    // Check for whitespace-only content
    if (value.trim().isEmpty) {
      return '内容不能只包含空白字符';
    }

    if (value.length > ValidationRules.maxPostContentLength) {
      return '内容长度不能超过${ValidationRules.maxPostContentLength}个字符';
    }

    return null;
  }

  /// Validate non-empty text
  /// Returns error message if invalid, null if valid
  static String? validateNonEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName不能为空';
    }

    if (value.trim().isEmpty) {
      return '$fieldName不能只包含空白字符';
    }

    return null;
  }

  /// Validate text length
  /// Returns error message if invalid, null if valid
  static String? validateLength(
    String? value, {
    required int min,
    required int max,
    required String fieldName,
  }) {
    if (value == null) {
      return '$fieldName不能为空';
    }

    if (value.length < min) {
      return '$fieldName长度至少为$min个字符';
    }

    if (value.length > max) {
      return '$fieldName长度不能超过$max个字符';
    }

    return null;
  }

  /// Validate URL format
  /// Returns error message if invalid, null if valid
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL不能为空';
    }

    try {
      Uri.parse(value);
      return null;
    } catch (_) {
      return '请输入有效的URL';
    }
  }
}
