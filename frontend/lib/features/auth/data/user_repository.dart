import 'package:lesser/core/data/base_repository.dart';
import 'package:lesser/core/network/api_client.dart';
import 'package:lesser/core/network/api_endpoints.dart';
import 'package:lesser/features/auth/domain/models/user.dart';

class UserRepository extends BaseRepository {
  final ApiClient _apiClient;

  UserRepository(this._apiClient);

  Future<User> getProfile() async {
    return safeApiCall(
      () => _apiClient.dio.get(ApiEndpoints.profile),
      mapper: (data) => User.fromJson(data),
    );
  }
}
