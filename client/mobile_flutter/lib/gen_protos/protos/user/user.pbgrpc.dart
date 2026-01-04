// This is a generated file - do not edit.
//
// Generated from user/user.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import '../common/common.pb.dart' as $1;
import 'user.pb.dart' as $0;

export 'user.pb.dart';

/// ============================================================================
/// UserService 用户服务
/// 提供用户资料管理、关注关系、屏蔽系统、隐私设置等功能
/// ============================================================================
@$pb.GrpcServiceName('user.UserService')
class UserServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  UserServiceClient(super.channel, {super.options, super.interceptors});

  /// ---- 用户资料 ----
  $grpc.ResponseFuture<$0.Profile> getProfile(
    $0.GetProfileRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getProfile, request, options: options);
  }

  $grpc.ResponseFuture<$0.Profile> getProfileByUsername(
    $0.GetProfileByUsernameRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getProfileByUsername, request, options: options);
  }

  $grpc.ResponseFuture<$0.Profile> updateProfile(
    $0.UpdateProfileRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateProfile, request, options: options);
  }

  $grpc.ResponseFuture<$0.BatchGetProfilesResponse> batchGetProfiles(
    $0.BatchGetProfilesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$batchGetProfiles, request, options: options);
  }

  /// ---- 关注系统 ----
  $grpc.ResponseFuture<$1.Empty> follow(
    $0.FollowRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$follow, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> unfollow(
    $0.UnfollowRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$unfollow, request, options: options);
  }

  $grpc.ResponseFuture<$0.FollowListResponse> getFollowers(
    $0.GetFollowersRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getFollowers, request, options: options);
  }

  $grpc.ResponseFuture<$0.FollowListResponse> getFollowing(
    $0.GetFollowingRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getFollowing, request, options: options);
  }

  $grpc.ResponseFuture<$0.CheckFollowingResponse> checkFollowing(
    $0.CheckFollowingRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$checkFollowing, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetRelationshipResponse> getRelationship(
    $0.GetRelationshipRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getRelationship, request, options: options);
  }

  $grpc.ResponseFuture<$0.FollowListResponse> getMutualFollowers(
    $0.GetMutualFollowersRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getMutualFollowers, request, options: options);
  }

  /// ---- 屏蔽系统 ----
  /// BlockType: HIDE_POSTS(不看他), HIDE_ME(不让他看我), BLOCK(拉黑，同时开启两者)
  $grpc.ResponseFuture<$1.Empty> block(
    $0.BlockRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$block, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> unblock(
    $0.UnblockRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$unblock, request, options: options);
  }

  $grpc.ResponseFuture<$0.BlockListResponse> getBlockList(
    $0.GetBlockListRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getBlockList, request, options: options);
  }

  $grpc.ResponseFuture<$0.CheckBlockedResponse> checkBlocked(
    $0.CheckBlockedRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$checkBlocked, request, options: options);
  }

  /// ---- 用户设置 ----
  $grpc.ResponseFuture<$0.UserSettings> getUserSettings(
    $0.GetUserSettingsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getUserSettings, request, options: options);
  }

  $grpc.ResponseFuture<$0.UserSettings> updateUserSettings(
    $0.UpdateUserSettingsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateUserSettings, request, options: options);
  }

  /// ---- 用户搜索 ----
  $grpc.ResponseFuture<$0.SearchUsersResponse> searchUsers(
    $0.SearchUsersRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$searchUsers, request, options: options);
  }

  // method descriptors

  static final _$getProfile =
      $grpc.ClientMethod<$0.GetProfileRequest, $0.Profile>(
          '/user.UserService/GetProfile',
          ($0.GetProfileRequest value) => value.writeToBuffer(),
          $0.Profile.fromBuffer);
  static final _$getProfileByUsername =
      $grpc.ClientMethod<$0.GetProfileByUsernameRequest, $0.Profile>(
          '/user.UserService/GetProfileByUsername',
          ($0.GetProfileByUsernameRequest value) => value.writeToBuffer(),
          $0.Profile.fromBuffer);
  static final _$updateProfile =
      $grpc.ClientMethod<$0.UpdateProfileRequest, $0.Profile>(
          '/user.UserService/UpdateProfile',
          ($0.UpdateProfileRequest value) => value.writeToBuffer(),
          $0.Profile.fromBuffer);
  static final _$batchGetProfiles = $grpc.ClientMethod<
          $0.BatchGetProfilesRequest, $0.BatchGetProfilesResponse>(
      '/user.UserService/BatchGetProfiles',
      ($0.BatchGetProfilesRequest value) => value.writeToBuffer(),
      $0.BatchGetProfilesResponse.fromBuffer);
  static final _$follow = $grpc.ClientMethod<$0.FollowRequest, $1.Empty>(
      '/user.UserService/Follow',
      ($0.FollowRequest value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$unfollow = $grpc.ClientMethod<$0.UnfollowRequest, $1.Empty>(
      '/user.UserService/Unfollow',
      ($0.UnfollowRequest value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$getFollowers =
      $grpc.ClientMethod<$0.GetFollowersRequest, $0.FollowListResponse>(
          '/user.UserService/GetFollowers',
          ($0.GetFollowersRequest value) => value.writeToBuffer(),
          $0.FollowListResponse.fromBuffer);
  static final _$getFollowing =
      $grpc.ClientMethod<$0.GetFollowingRequest, $0.FollowListResponse>(
          '/user.UserService/GetFollowing',
          ($0.GetFollowingRequest value) => value.writeToBuffer(),
          $0.FollowListResponse.fromBuffer);
  static final _$checkFollowing =
      $grpc.ClientMethod<$0.CheckFollowingRequest, $0.CheckFollowingResponse>(
          '/user.UserService/CheckFollowing',
          ($0.CheckFollowingRequest value) => value.writeToBuffer(),
          $0.CheckFollowingResponse.fromBuffer);
  static final _$getRelationship =
      $grpc.ClientMethod<$0.GetRelationshipRequest, $0.GetRelationshipResponse>(
          '/user.UserService/GetRelationship',
          ($0.GetRelationshipRequest value) => value.writeToBuffer(),
          $0.GetRelationshipResponse.fromBuffer);
  static final _$getMutualFollowers =
      $grpc.ClientMethod<$0.GetMutualFollowersRequest, $0.FollowListResponse>(
          '/user.UserService/GetMutualFollowers',
          ($0.GetMutualFollowersRequest value) => value.writeToBuffer(),
          $0.FollowListResponse.fromBuffer);
  static final _$block = $grpc.ClientMethod<$0.BlockRequest, $1.Empty>(
      '/user.UserService/Block',
      ($0.BlockRequest value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$unblock = $grpc.ClientMethod<$0.UnblockRequest, $1.Empty>(
      '/user.UserService/Unblock',
      ($0.UnblockRequest value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$getBlockList =
      $grpc.ClientMethod<$0.GetBlockListRequest, $0.BlockListResponse>(
          '/user.UserService/GetBlockList',
          ($0.GetBlockListRequest value) => value.writeToBuffer(),
          $0.BlockListResponse.fromBuffer);
  static final _$checkBlocked =
      $grpc.ClientMethod<$0.CheckBlockedRequest, $0.CheckBlockedResponse>(
          '/user.UserService/CheckBlocked',
          ($0.CheckBlockedRequest value) => value.writeToBuffer(),
          $0.CheckBlockedResponse.fromBuffer);
  static final _$getUserSettings =
      $grpc.ClientMethod<$0.GetUserSettingsRequest, $0.UserSettings>(
          '/user.UserService/GetUserSettings',
          ($0.GetUserSettingsRequest value) => value.writeToBuffer(),
          $0.UserSettings.fromBuffer);
  static final _$updateUserSettings =
      $grpc.ClientMethod<$0.UpdateUserSettingsRequest, $0.UserSettings>(
          '/user.UserService/UpdateUserSettings',
          ($0.UpdateUserSettingsRequest value) => value.writeToBuffer(),
          $0.UserSettings.fromBuffer);
  static final _$searchUsers =
      $grpc.ClientMethod<$0.SearchUsersRequest, $0.SearchUsersResponse>(
          '/user.UserService/SearchUsers',
          ($0.SearchUsersRequest value) => value.writeToBuffer(),
          $0.SearchUsersResponse.fromBuffer);
}

@$pb.GrpcServiceName('user.UserService')
abstract class UserServiceBase extends $grpc.Service {
  $core.String get $name => 'user.UserService';

  UserServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.GetProfileRequest, $0.Profile>(
        'GetProfile',
        getProfile_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetProfileRequest.fromBuffer(value),
        ($0.Profile value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetProfileByUsernameRequest, $0.Profile>(
        'GetProfileByUsername',
        getProfileByUsername_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetProfileByUsernameRequest.fromBuffer(value),
        ($0.Profile value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateProfileRequest, $0.Profile>(
        'UpdateProfile',
        updateProfile_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateProfileRequest.fromBuffer(value),
        ($0.Profile value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.BatchGetProfilesRequest,
            $0.BatchGetProfilesResponse>(
        'BatchGetProfiles',
        batchGetProfiles_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.BatchGetProfilesRequest.fromBuffer(value),
        ($0.BatchGetProfilesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.FollowRequest, $1.Empty>(
        'Follow',
        follow_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.FollowRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UnfollowRequest, $1.Empty>(
        'Unfollow',
        unfollow_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UnfollowRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetFollowersRequest, $0.FollowListResponse>(
            'GetFollowers',
            getFollowers_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetFollowersRequest.fromBuffer(value),
            ($0.FollowListResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetFollowingRequest, $0.FollowListResponse>(
            'GetFollowing',
            getFollowing_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetFollowingRequest.fromBuffer(value),
            ($0.FollowListResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CheckFollowingRequest,
            $0.CheckFollowingResponse>(
        'CheckFollowing',
        checkFollowing_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CheckFollowingRequest.fromBuffer(value),
        ($0.CheckFollowingResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetRelationshipRequest,
            $0.GetRelationshipResponse>(
        'GetRelationship',
        getRelationship_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetRelationshipRequest.fromBuffer(value),
        ($0.GetRelationshipResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetMutualFollowersRequest,
            $0.FollowListResponse>(
        'GetMutualFollowers',
        getMutualFollowers_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetMutualFollowersRequest.fromBuffer(value),
        ($0.FollowListResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.BlockRequest, $1.Empty>(
        'Block',
        block_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.BlockRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UnblockRequest, $1.Empty>(
        'Unblock',
        unblock_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UnblockRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetBlockListRequest, $0.BlockListResponse>(
            'GetBlockList',
            getBlockList_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetBlockListRequest.fromBuffer(value),
            ($0.BlockListResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.CheckBlockedRequest, $0.CheckBlockedResponse>(
            'CheckBlocked',
            checkBlocked_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.CheckBlockedRequest.fromBuffer(value),
            ($0.CheckBlockedResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetUserSettingsRequest, $0.UserSettings>(
        'GetUserSettings',
        getUserSettings_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetUserSettingsRequest.fromBuffer(value),
        ($0.UserSettings value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.UpdateUserSettingsRequest, $0.UserSettings>(
            'UpdateUserSettings',
            updateUserSettings_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.UpdateUserSettingsRequest.fromBuffer(value),
            ($0.UserSettings value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.SearchUsersRequest, $0.SearchUsersResponse>(
            'SearchUsers',
            searchUsers_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.SearchUsersRequest.fromBuffer(value),
            ($0.SearchUsersResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.Profile> getProfile_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetProfileRequest> $request) async {
    return getProfile($call, await $request);
  }

  $async.Future<$0.Profile> getProfile(
      $grpc.ServiceCall call, $0.GetProfileRequest request);

  $async.Future<$0.Profile> getProfileByUsername_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetProfileByUsernameRequest> $request) async {
    return getProfileByUsername($call, await $request);
  }

  $async.Future<$0.Profile> getProfileByUsername(
      $grpc.ServiceCall call, $0.GetProfileByUsernameRequest request);

  $async.Future<$0.Profile> updateProfile_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UpdateProfileRequest> $request) async {
    return updateProfile($call, await $request);
  }

  $async.Future<$0.Profile> updateProfile(
      $grpc.ServiceCall call, $0.UpdateProfileRequest request);

  $async.Future<$0.BatchGetProfilesResponse> batchGetProfiles_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.BatchGetProfilesRequest> $request) async {
    return batchGetProfiles($call, await $request);
  }

  $async.Future<$0.BatchGetProfilesResponse> batchGetProfiles(
      $grpc.ServiceCall call, $0.BatchGetProfilesRequest request);

  $async.Future<$1.Empty> follow_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.FollowRequest> $request) async {
    return follow($call, await $request);
  }

  $async.Future<$1.Empty> follow(
      $grpc.ServiceCall call, $0.FollowRequest request);

  $async.Future<$1.Empty> unfollow_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UnfollowRequest> $request) async {
    return unfollow($call, await $request);
  }

  $async.Future<$1.Empty> unfollow(
      $grpc.ServiceCall call, $0.UnfollowRequest request);

  $async.Future<$0.FollowListResponse> getFollowers_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetFollowersRequest> $request) async {
    return getFollowers($call, await $request);
  }

  $async.Future<$0.FollowListResponse> getFollowers(
      $grpc.ServiceCall call, $0.GetFollowersRequest request);

  $async.Future<$0.FollowListResponse> getFollowing_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetFollowingRequest> $request) async {
    return getFollowing($call, await $request);
  }

  $async.Future<$0.FollowListResponse> getFollowing(
      $grpc.ServiceCall call, $0.GetFollowingRequest request);

  $async.Future<$0.CheckFollowingResponse> checkFollowing_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CheckFollowingRequest> $request) async {
    return checkFollowing($call, await $request);
  }

  $async.Future<$0.CheckFollowingResponse> checkFollowing(
      $grpc.ServiceCall call, $0.CheckFollowingRequest request);

  $async.Future<$0.GetRelationshipResponse> getRelationship_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetRelationshipRequest> $request) async {
    return getRelationship($call, await $request);
  }

  $async.Future<$0.GetRelationshipResponse> getRelationship(
      $grpc.ServiceCall call, $0.GetRelationshipRequest request);

  $async.Future<$0.FollowListResponse> getMutualFollowers_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetMutualFollowersRequest> $request) async {
    return getMutualFollowers($call, await $request);
  }

  $async.Future<$0.FollowListResponse> getMutualFollowers(
      $grpc.ServiceCall call, $0.GetMutualFollowersRequest request);

  $async.Future<$1.Empty> block_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.BlockRequest> $request) async {
    return block($call, await $request);
  }

  $async.Future<$1.Empty> block(
      $grpc.ServiceCall call, $0.BlockRequest request);

  $async.Future<$1.Empty> unblock_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UnblockRequest> $request) async {
    return unblock($call, await $request);
  }

  $async.Future<$1.Empty> unblock(
      $grpc.ServiceCall call, $0.UnblockRequest request);

  $async.Future<$0.BlockListResponse> getBlockList_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetBlockListRequest> $request) async {
    return getBlockList($call, await $request);
  }

  $async.Future<$0.BlockListResponse> getBlockList(
      $grpc.ServiceCall call, $0.GetBlockListRequest request);

  $async.Future<$0.CheckBlockedResponse> checkBlocked_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CheckBlockedRequest> $request) async {
    return checkBlocked($call, await $request);
  }

  $async.Future<$0.CheckBlockedResponse> checkBlocked(
      $grpc.ServiceCall call, $0.CheckBlockedRequest request);

  $async.Future<$0.UserSettings> getUserSettings_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetUserSettingsRequest> $request) async {
    return getUserSettings($call, await $request);
  }

  $async.Future<$0.UserSettings> getUserSettings(
      $grpc.ServiceCall call, $0.GetUserSettingsRequest request);

  $async.Future<$0.UserSettings> updateUserSettings_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UpdateUserSettingsRequest> $request) async {
    return updateUserSettings($call, await $request);
  }

  $async.Future<$0.UserSettings> updateUserSettings(
      $grpc.ServiceCall call, $0.UpdateUserSettingsRequest request);

  $async.Future<$0.SearchUsersResponse> searchUsers_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SearchUsersRequest> $request) async {
    return searchUsers($call, await $request);
  }

  $async.Future<$0.SearchUsersResponse> searchUsers(
      $grpc.ServiceCall call, $0.SearchUsersRequest request);
}
