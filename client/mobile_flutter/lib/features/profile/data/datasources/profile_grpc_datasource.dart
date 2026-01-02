import 'package:grpc/grpc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/grpc/user_grpc_client.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/profile_model.dart';
import 'profile_remote_datasource.dart';

/// Profile gRPC data source implementation
class ProfileGrpcDataSourceImpl implements ProfileRemoteDataSource {
  const ProfileGrpcDataSourceImpl(this._client, this._prefs);

  final UserGrpcClient _client;
  final SharedPreferences _prefs;

  String? get _currentUserId => _prefs.getString('user_id');

  @override
  Future<ProfileModel> getProfile(String userId) async {
    try {
      final response = await _client.getProfile(userId: userId);
      return ProfileModel.fromProto(response);
    } on GrpcError catch (e) {
      throw _handleGrpcError(e);
    }
  }

  @override
  Future<ProfileModel> getCurrentProfile() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const UnauthorizedException();
    }
    try {
      final response = await _client.getProfile(userId: userId);
      return ProfileModel.fromProto(response);
    } on GrpcError catch (e) {
      throw _handleGrpcError(e);
    }
  }

  @override
  Future<UserModel> updateProfile({
    String? displayName,
    String? bio,
    String? avatarUrl,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const UnauthorizedException();
    }
    try {
      final response = await _client.updateProfile(
        userId: userId,
        displayName: displayName,
        bio: bio,
        avatarUrl: avatarUrl,
      );
      return UserModel(
        id: response.id,
        username: response.username,
        email: response.email,
        displayName: response.hasDisplayName() ? response.displayName : null,
        avatarUrl: response.hasAvatarUrl() ? response.avatarUrl : null,
        bio: response.hasBio() ? response.bio : null,
        createdAt: response.hasCreatedAt()
            ? DateTime.fromMillisecondsSinceEpoch(
                response.createdAt.seconds.toInt() * 1000,
              )
            : null,
      );
    } on GrpcError catch (e) {
      throw _handleGrpcError(e);
    }
  }

  @override
  Future<void> followUser(String userId) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      throw const UnauthorizedException();
    }
    try {
      await _client.follow(
        followerId: currentUserId,
        followingId: userId,
      );
    } on GrpcError catch (e) {
      throw _handleGrpcError(e);
    }
  }

  @override
  Future<void> unfollowUser(String userId) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      throw const UnauthorizedException();
    }
    try {
      await _client.unfollow(
        followerId: currentUserId,
        followingId: userId,
      );
    } on GrpcError catch (e) {
      throw _handleGrpcError(e);
    }
  }

  @override
  Future<List<UserModel>> getFollowers({
    required String userId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _client.getFollowers(
        userId: userId,
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

  @override
  Future<List<UserModel>> getFollowing({
    required String userId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _client.getFollowing(
        userId: userId,
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
