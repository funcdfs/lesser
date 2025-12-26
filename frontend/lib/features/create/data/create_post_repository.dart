import 'package:lesser/core/data/base_repository.dart';
import 'package:lesser/core/network/api_client.dart';
import 'package:lesser/features/feeds/domain/models/post.dart';

class CreatePostRepository extends BaseRepository {
  final ApiClient _apiClient;

  CreatePostRepository(this._apiClient);

  Future<Post> createPost({required String content, String? location}) async {
    return await safeApiCall(
      () => _apiClient.apiService.createPost({
        'content': content,
        if (location != null && location.isNotEmpty) 'location': location,
      }),
      mapper: (data) => Post.fromJson(data),
    );
  }
}
