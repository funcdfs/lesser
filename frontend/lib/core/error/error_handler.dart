import 'package:lesser/core/error/app_exception.dart';

/// Centralized error handling utility
class ErrorHandler {
  /// Handle exceptions and convert them to user-friendly messages
  static String getUserMessage(Exception exception) {
    if (exception is AppException) {
      return exception.userMessage;
    }
    return '发生错误，请稍后重试';
  }

  /// Handle network exceptions
  static NetworkException handleNetworkError(Exception exception) {
    if (exception is NetworkException) {
      return exception;
    }
    return NetworkException.connectionError();
  }

  /// Handle auth exceptions
  static AuthException handleAuthError(Exception exception) {
    if (exception is AuthException) {
      return exception;
    }
    return AuthException(type: AuthErrorType.unknown);
  }

  /// Handle validation exceptions
  static ValidationException handleValidationError(
    Map<String, String> fieldErrors, {
    String? customMessage,
  }) {
    return ValidationException(
      fieldErrors: fieldErrors,
      message: customMessage,
    );
  }

  /// Log error (can be extended to send to analytics service)
  static void logError(
    Exception exception, {
    String? context,
    StackTrace? stackTrace,
  }) {
    // TODO: Implement logging to analytics service
    // In production, use a proper logging service like logger package
    // For now, errors are silently captured for analytics integration
  }

  /// Convert HTTP status code to appropriate exception
  static AppException handleHttpError(int statusCode, {String? responseBody}) {
    return switch (statusCode) {
      400 => NetworkException(
        message: '请求参数错误',
        statusCode: statusCode,
        responseBody: responseBody,
      ),
      401 => AuthException(type: AuthErrorType.tokenExpired),
      403 => AuthException(type: AuthErrorType.forbidden),
      404 => NetworkException(message: '请求的资源不存在', statusCode: statusCode),
      409 => AuthException(
        type: AuthErrorType.invalidCredentials,
        customMessage: '用户名或邮箱已被使用',
      ),
      422 => ValidationException(
        fieldErrors: {'server': '数据验证失败'},
        message: '提交的数据不符合要求',
      ),
      >= 500 => NetworkException(
        message: '服务器错误，请稍后重试',
        statusCode: statusCode,
      ),
      _ => NetworkException(message: '请求失败，请重试', statusCode: statusCode),
    };
  }
}
