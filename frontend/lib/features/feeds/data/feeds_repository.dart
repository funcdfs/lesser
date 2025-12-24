import 'package:lesser/core/data/base_repository.dart';
import 'package:lesser/core/network/api_client.dart';
import 'package:lesser/core/network/api_endpoints.dart';
import 'package:lesser/features/feeds/domain/models/post.dart';

class FeedsRepository extends BaseRepository {
  final ApiClient _apiClient;

  FeedsRepository(this._apiClient);

  Future<List<Post>> getFeeds() async {
    return safeApiCall(
      () => _apiClient.dio.get(ApiEndpoints.feeds),
      mapper: (data) => (data as List).map((e) => Post.fromJson(e)).toList(),
    );
  }
}
