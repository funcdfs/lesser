import 'package:lesser/core/data/base_repository.dart';
import 'package:lesser/core/network/api_client.dart';
import 'package:lesser/features/auth/domain/models/user.dart';

class UserRepository extends BaseRepository {
  final ApiClient _apiClient;

  UserRepository(this._apiClient);

  Future<User> getProfile() async {
    return safeApiCall(
      () => _apiClient.apiService.getProfile(),
      mapper: (data) => User.fromJson(data),
    );
  }
}
