import 'package:grpc/grpc.dart';
import '../../generated/protos/search/search.pbgrpc.dart';
import '../../generated/protos/common/common.pb.dart' as common;
import '../../generated/protos/post/post.pb.dart' as post_pb;
import 'grpc_client.dart';

/// Search gRPC 客户端
/// 封装搜索相关的 gRPC 调用
class SearchGrpcClient {
  SearchGrpcClient(this._manager) {
    _stub = SearchServiceClient(_manager.channel);
  }

  final GrpcClientManager _manager;
  late final SearchServiceClient _stub;

  /// 搜索帖子
  Future<SearchPostsResponse> searchPosts({
    required String query,
    post_pb.PostType? postType,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = SearchPostsRequest()
        ..query = query
        ..pagination = (common.Pagination()
          ..page = page
          ..pageSize = pageSize);
      if (postType != null) {
        request.postType = postType;
      }
      return await _stub.searchPosts(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'SearchPosts');
      rethrow;
    }
  }

  /// 搜索用户
  Future<SearchUsersResponse> searchUsers({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = SearchUsersRequest()
        ..query = query
        ..pagination = (common.Pagination()
          ..page = page
          ..pageSize = pageSize);
      return await _stub.searchUsers(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'SearchUsers');
      rethrow;
    }
  }
}
