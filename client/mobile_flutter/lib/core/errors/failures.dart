import 'package:equatable/equatable.dart';

/// Base failure class
abstract class Failure extends Equatable {
  const Failure({this.message = 'An unexpected error occurred'});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Server failure
class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Server error occurred'});
}

/// Network failure
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection'});
}

/// Cache failure
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache error occurred'});
}

/// Authentication failure
class AuthFailure extends Failure {
  const AuthFailure({super.message = 'Authentication failed'});
}

/// Validation failure
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

/// Not found failure
class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'Resource not found'});
}

/// Unauthorized failure
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message = 'Unauthorized access'});
}

/// Forbidden failure
class ForbiddenFailure extends Failure {
  const ForbiddenFailure({super.message = 'Access forbidden'});
}

/// Timeout failure
class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message = 'Request timed out'});
}

/// Unknown failure
class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'An unknown error occurred'});
}
