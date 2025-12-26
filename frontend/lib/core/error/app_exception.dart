/// Base exception class for the application
sealed class AppException implements Exception {
  final String message;

  AppException({required this.message});

  /// User-friendly error message to display in UI
  String get userMessage => message;

  @override
  String toString() => message;
}

/// Network-related exceptions
class NetworkException extends AppException {
  final int? statusCode;
  final String? responseBody;

  NetworkException({
    required super.message,
    this.statusCode,
    this.responseBody,
  });

  factory NetworkException.fromStatusCode(
    int statusCode, {
    String? responseBody,
  }) {
    final message = switch (statusCode) {
      400 => '请求参数错误',
      401 => '未授权，请重新登录',
      403 => '禁止访问',
      404 => '请求的资源不存在',
      409 => '请求冲突',
      422 => '无法处理的实体',
      429 => '请求过于频繁，请稍候',
      500 => '服务器内部错误',
      502 => '网关错误',
      503 => '服务暂不可用',
      _ => '请求失败，请重试',
    };

    return NetworkException(
      message: message,
      statusCode: statusCode,
      responseBody: responseBody,
    );
  }

  factory NetworkException.connectionError() {
    return NetworkException(message: '网络连接失败，请检查您的网络设置');
  }

  factory NetworkException.timeout() {
    return NetworkException(message: '请求超时，请重试');
  }

  @override
  String get userMessage => message;
}

/// Authentication error types
enum AuthErrorType {
  invalidCredentials('用户名或密码错误'),
  tokenExpired('登录已过期，请重新登录'),
  tokenInvalid('凭证无效'),
  forbidden('无权限访问'),
  accountLocked('账户已被锁定'),
  userNotFound('用户不存在'),
  emailTaken('邮箱已被注册'),
  usernameTaken('用户名已被使用'),
  unknown('认证错误');

  final String message;
  const AuthErrorType(this.message);
}

/// Authentication-related exceptions
class AuthException extends AppException {
  final AuthErrorType type;

  AuthException({required this.type, String? customMessage})
    : super(message: customMessage ?? type.message);

  @override
  String get userMessage => message;
}

/// Validation-related exceptions
class ValidationException extends AppException {
  final Map<String, String> fieldErrors;

  ValidationException({required this.fieldErrors, String? message})
    : super(message: message ?? '数据验证失败');

  @override
  String get userMessage {
    if (fieldErrors.isEmpty) {
      return message;
    }
    return fieldErrors.values.first;
  }
}

/// Parse/Serialization exceptions
class ParseException extends AppException {
  final String? source;

  ParseException({required super.message, this.source});

  factory ParseException.fromJson(String? source) {
    return ParseException(message: 'JSON解析失败', source: source);
  }

  @override
  String get userMessage => '数据格式错误，请稍后重试';
}

/// Generic unknown exception wrapper
class UnknownException extends AppException {
  final Exception? originalException;

  UnknownException({super.message = '发生未知错误', this.originalException});

  @override
  String get userMessage => '发生错误，请稍后重试';
}
