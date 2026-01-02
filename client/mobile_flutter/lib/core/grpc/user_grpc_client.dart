import 'package:grpc/grpc.dart';
import '../../generated/protos/user/user.pbgrpc.dart';
import '../../generated/protos/common/common.pb.dart' as common;
import 'grpc_client.dart';

/// User gRPC 客户端
/// 封装用户相关的 gRPC 调用（个人资料、关注等）
class UserGrpcClient {
  UserGrpcClient(this._manager) {
    _stub = UserServiceClient(_manager.channel);
  }

  final GrpcClientManager _manager;
  late final UserServiceClient _stub;

  /// 获取用户资料
  Future<Profile> getProfile({required String userId}) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = GetProfileRequest()..userId = userId;
      return await _stub.getProfile(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'GetProfile');
      rethrow;
    }
  }

  /// 更新用户资料
  Future<Profile> updateProfile({
    required String userId,
    String? displayName,
    String? avatarUrl,
    String? bio,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = UpdateProfileRequest()..userId = userId;
      if (displayName != null) request.displayName = displayName;
      if (avatarUrl != null) request.avatarUrl = avatarUrl;
      if (bio != null) request.bio = bio;
      return await _stub.updateProfile(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'UpdateProfile');
      rethrow;
    }
  }

  /// 关注用户
  Future<void> follow({
    required String followerId,
    required String followingId,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = FollowRequest()
        ..followerId = followerId
        ..followingId = followingId;
      await _stub.follow(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'Follow');
      rethrow;
    }
  }

  /// 取消关注
  Future<void> unfollow({
    required String followerId,
    required String followingId,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = UnfollowRequest()
        ..followerId = followerId
        ..followingId = followingId;
      await _stub.unfollow(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'Unfollow');
      rethrow;
    }
  }

  /// 获取粉丝列表
  Future<FollowListResponse> getFollowers({
    required String userId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = GetFollowersRequest()
        ..userId = userId
        ..pagination = (common.Pagination()
          ..page = page
          ..pageSize = pageSize);
      return await _stub.getFollowers(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'GetFollowers');
      rethrow;
    }
  }

  /// 获取关注列表
  Future<FollowListResponse> getFollowing({
    required String userId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = GetFollowingRequest()
        ..userId = userId
        ..pagination = (common.Pagination()
          ..page = page
          ..pageSize = pageSize);
      return await _stub.getFollowing(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'GetFollowing');
      rethrow;
    }
  }

  /// 检查是否关注
  Future<bool> checkFollowing({
    required String followerId,
    required String followingId,
  }) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = CheckFollowingRequest()
        ..followerId = followerId
        ..followingId = followingId;
      final response = await _stub.checkFollowing(request, options: options);
      return response.isFollowing;
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'CheckFollowing');
      rethrow;
    }
  }
}
