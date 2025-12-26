import 'package:lesser/core/data/base_repository.dart';
import 'package:lesser/core/network/api_client.dart';
import 'package:lesser/features/feeds/domain/models/post.dart';

class FeedsRepository extends BaseRepository {
  final ApiClient _apiClient;

  FeedsRepository(this._apiClient);

  Future<List<Post>> getFeeds({int page = 1, int limit = 20}) async {
    return safeApiCall(
      () => _apiClient.apiService.getFeeds(page, limit),
      mapper: (data) => (data as List).map((e) => Post.fromJson(e)).toList(),
    );
  }
}
