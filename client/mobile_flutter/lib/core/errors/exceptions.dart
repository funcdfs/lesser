/// Base exception class
class AppException implements Exception {
  const AppException({this.message = 'An unexpected error occurred'});

  final String message;

  @override
  String toString() => message;
}

/// Server exception
class ServerException extends AppException {
  const ServerException({
    super.message = 'Server error occurred',
    this.statusCode,
  });

  final int? statusCode;
}

/// Network exception
class NetworkException extends AppException {
  const NetworkException({super.message = 'No internet connection'});
}

/// Cache exception
class CacheException extends AppException {
  const CacheException({super.message = 'Cache error occurred'});
}

/// Authentication exception
class AuthException extends AppException {
  const AuthException({super.message = 'Authentication failed'});
}

/// Validation exception
class ValidationException extends AppException {
  const ValidationException({required super.message});
}

/// Not found exception
class NotFoundException extends AppException {
  const NotFoundException({super.message = 'Resource not found'});
}

/// Unauthorized exception
class UnauthorizedException extends AppException {
  const UnauthorizedException({super.message = 'Unauthorized access'});
}

/// Forbidden exception
class ForbiddenException extends AppException {
  const ForbiddenException({super.message = 'Access forbidden'});
}

/// Timeout exception
class TimeoutException extends AppException {
  const TimeoutException({super.message = 'Request timed out'});
}
