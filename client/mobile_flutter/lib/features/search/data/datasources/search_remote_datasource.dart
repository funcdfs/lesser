import '../../../auth/data/models/user_model.dart';
import '../../../feeds/data/models/feed_item_model.dart';

/// Search remote data source interface
abstract class SearchRemoteDataSource {
  Future<List<FeedItemModel>> searchPosts({
    required String query,
    String? postType,
    DateTime? fromDate,
    DateTime? toDate,
    int page = 1,
    int pageSize = 20,
  });

  Future<List<UserModel>> searchUsers({
    required String query,
    int page = 1,
    int pageSize = 20,
  });
}
