import 'package:lesser/core/data/base_repository.dart';
import 'package:lesser/core/network/api_client.dart';
import 'package:lesser/features/search/domain/models/hot_item.dart';
import 'package:lesser/features/search/domain/models/search_filter.dart';
import 'package:lesser/features/search/domain/models/search_result.dart';

class SearchRepository extends BaseRepository {
  final ApiClient _apiClient;

  SearchRepository(this._apiClient);

  /// Search for users, posts, and tags
  Future<SearchResult> search({
    required String query,
    SearchType type = SearchType.all,
    int page = 1,
    int limit = 20,
  }) async {
    return safeApiCall(
      () => _apiClient.apiService.search(query, type.name, page, limit),
      mapper: (data) => SearchResult.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Get hot list items
  Future<List<HotItem>> getHotList() async {
    return safeApiCall(
      () => _apiClient.apiService.getHotList(),
      mapper: (data) =>
          (data as List).map((e) => HotItem.fromJson(e)).toList(),
    );
  }

  /// Get hot tags
  Future<List<String>> getHotTags() async {
    return safeApiCall(
      () => _apiClient.apiService.getHotTags(),
      mapper: (data) => (data as List).cast<String>(),
    );
  }
}
