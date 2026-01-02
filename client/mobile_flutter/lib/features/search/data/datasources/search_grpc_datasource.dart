import 'package:grpc/grpc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/grpc/search_grpc_client.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../feeds/data/models/feed_item_model.dart';
import 'search_remote_datasource.dart';

/// Search gRPC data source implementation
class SearchGrpcDataSourceImpl implements SearchRemoteDataSource {
  const SearchGrpcDataSourceImpl(this._client, this._prefs);

  final SearchGrpcClient _client;
  final SharedPreferences _prefs;

  @override
  Future<List<FeedItemModel>> searchPosts({
    required String query,
    String? postType,
    DateTime? fromDate,
    DateTime? toDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _client.searchPosts(
        query: query,
        page: page,
        pageSize: pageSize,
      );
      return response.posts.map((post) {
        return FeedItemModel.fromPostProto(post);
      }).toList();
    } on GrpcError catch (e) {
      throw _handleGrpcError(e);
    }
  }

  @override
  Future<List<UserModel>> searchUsers({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _client.searchUsers(
        query: query,
        page: page,
        pageSize: pageSize,
      );
      return response.users.map((profile) {
        return UserModel(
          id: profile.id,
          username: profile.username,
          email: profile.email,
          displayName: profile.hasDisplayName() ? profile.displayName : null,
          avatarUrl: profile.hasAvatarUrl() ? profile.avatarUrl : null,
          bio: profile.hasBio() ? profile.bio : null,
        );
      }).toList();
    } on GrpcError catch (e) {
      throw _handleGrpcError(e);
    }
  }

  AppException _handleGrpcError(GrpcError e) {
    switch (e.code) {
      case StatusCode.unauthenticated:
        return const UnauthorizedException();
      case StatusCode.notFound:
        return const NotFoundException();
      case StatusCode.unavailable:
      case StatusCode.deadlineExceeded:
        return const TimeoutException();
      default:
        return ServerException(statusCode: e.code);
    }
  }
}
