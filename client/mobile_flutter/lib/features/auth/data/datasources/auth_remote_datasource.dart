import '../models/token_model.dart';
import '../models/user_model.dart';

/// Auth remote data source interface
abstract class AuthRemoteDataSource {
  Future<({UserModel user, TokenModel tokens})> register({
    required String username,
    required String email,
    required String password,
    String? displayName,
  });

  Future<({UserModel user, TokenModel tokens})> login({
    required String email,
    required String password,
  });

  Future<void> logout(String accessToken);

  Future<UserModel> getCurrentUser();

  Future<String> refreshToken(String refreshToken);
}
