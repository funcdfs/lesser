import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// Toast 类型枚举
enum AppToastType {
  /// 成功提示
  success,

  /// 错误提示
  error,

  /// 信息提示
  info,

  /// 警告提示
  warning,

  /// 加载中
  loading,
}

/// 统一 Toast 工具类 - 基于 TDesign 风格
///
/// 提供一致的 Toast 提示样式和行为，应用深色主题样式。
///
/// 示例用法:
/// ```dart
/// // 成功提示
/// AppToast.success(context, '操作成功');
///
/// // 错误提示
/// AppToast.error(context, '操作失败');
///
/// // 信息提示
/// AppToast.info(context, '这是一条信息');
///
/// // 警告提示
/// AppToast.warning(context, '请注意');
///
/// // 加载中
/// AppToast.loading(context, '加载中...');
/// ```
class AppToast {
  AppToast._();

  /// 默认显示时长
  static const Duration _defaultDuration = Duration(milliseconds: 2000);

  /// 显示成功提示
  ///
  /// [context] - BuildContext
  /// [message] - 提示消息
  /// [duration] - 显示时长，默认 2000ms
  static void success(
    BuildContext context,
    String message, {
    Duration duration = _defaultDuration,
  }) {
    _show(
      context,
      message: message,
      type: AppToastType.success,
      duration: duration,
    );
  }

  /// 显示错误提示
  ///
  /// [context] - BuildContext
  /// [message] - 提示消息
  /// [duration] - 显示时长，默认 2000ms
  static void error(
    BuildContext context,
    String message, {
    Duration duration = _defaultDuration,
  }) {
    _show(
      context,
      message: message,
      type: AppToastType.error,
      duration: duration,
    );
  }

  /// 显示信息提示
  ///
  /// [context] - BuildContext
  /// [message] - 提示消息
  /// [duration] - 显示时长，默认 2000ms
  static void info(
    BuildContext context,
    String message, {
    Duration duration = _defaultDuration,
  }) {
    _show(
      context,
      message: message,
      type: AppToastType.info,
      duration: duration,
    );
  }

  /// 显示警告提示
  ///
  /// [context] - BuildContext
  /// [message] - 提示消息
  /// [duration] - 显示时长，默认 2000ms
  static void warning(
    BuildContext context,
    String message, {
    Duration duration = _defaultDuration,
  }) {
    _show(
      context,
      message: message,
      type: AppToastType.warning,
      duration: duration,
    );
  }

  /// 显示加载中提示
  ///
  /// [context] - BuildContext
  /// [message] - 提示消息，默认为 "加载中..."
  ///
  /// 注意：加载中提示不会自动消失，需要手动关闭
  static void loading(
    BuildContext context, [
    String message = '加载中...',
  ]) {
    _show(
      context,
      message: message,
      type: AppToastType.loading,
      duration: Duration.zero, // 不自动消失
    );
  }

  /// 显示自定义 Toast
  ///
  /// [context] - BuildContext
  /// [message] - 提示消息
  /// [icon] - 自定义图标
  /// [duration] - 显示时长，Duration.zero 表示不自动消失
  static void custom(
    BuildContext context, {
    required String message,
    IconData? icon,
    Duration duration = _defaultDuration,
  }) {
    if (icon != null) {
      TDToast.showIconText(
        message,
        icon: icon,
        context: context,
        duration: duration,
      );
    } else {
      TDToast.showText(
        message,
        context: context,
        duration: duration,
      );
    }
  }

  /// 内部方法：显示 Toast
  static void _show(
    BuildContext context, {
    required String message,
    required AppToastType type,
    required Duration duration,
  }) {
    switch (type) {
      case AppToastType.success:
        TDToast.showSuccess(
          message,
          context: context,
          duration: duration,
        );
        break;
      case AppToastType.error:
        TDToast.showFail(
          message,
          context: context,
          duration: duration,
        );
        break;
      case AppToastType.info:
        TDToast.showText(
          message,
          context: context,
          duration: duration,
        );
        break;
      case AppToastType.warning:
        TDToast.showWarning(
          message,
          context: context,
          duration: duration,
        );
        break;
      case AppToastType.loading:
        TDToast.showLoading(
          context: context,
          text: message,
        );
        break;
    }
  }
}
