import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Register use case
class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, User>> call(RegisterParams params) {
    return _repository.register(
      username: params.username,
      email: params.email,
      password: params.password,
      displayName: params.displayName,
    );
  }
}

/// Register parameters
class RegisterParams {
  const RegisterParams({
    required this.username,
    required this.email,
    required this.password,
    this.displayName,
  });

  final String username;
  final String email;
  final String password;
  final String? displayName;
}
