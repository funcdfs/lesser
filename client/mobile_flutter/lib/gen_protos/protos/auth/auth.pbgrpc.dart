// This is a generated file - do not edit.
//
// Generated from auth/auth.proto.

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
import 'auth.pb.dart' as $0;

export 'auth.pb.dart';

/// AuthService 认证服务
/// 处理用户登录、注册、Token 管理
/// Gateway 启动时获取公钥用于本地 JWT 验签
@$pb.GrpcServiceName('auth.AuthService')
class AuthServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  AuthServiceClient(super.channel, {super.options, super.interceptors});

  /// 用户注册（低频，强一致）
  $grpc.ResponseFuture<$0.AuthResponse> register(
    $0.RegisterRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$register, request, options: options);
  }

  /// 用户登录（低频，强一致）
  $grpc.ResponseFuture<$0.AuthResponse> login(
    $0.LoginRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$login, request, options: options);
  }

  /// 登出并使 Token 失效
  $grpc.ResponseFuture<$1.Empty> logout(
    $0.LogoutRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$logout, request, options: options);
  }

  /// 使用 Refresh Token 刷新 Access Token
  $grpc.ResponseFuture<$0.AuthResponse> refreshToken(
    $0.RefreshRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$refreshToken, request, options: options);
  }

  /// 获取 JWT 公钥（Gateway 启动时调用，用于本地验签）
  $grpc.ResponseFuture<$0.GetPublicKeyResponse> getPublicKey(
    $0.GetPublicKeyRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getPublicKey, request, options: options);
  }

  /// 封禁用户（管理接口）
  $grpc.ResponseFuture<$0.BanUserResponse> banUser(
    $0.BanUserRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$banUser, request, options: options);
  }

  /// 检查用户是否被封禁
  $grpc.ResponseFuture<$0.CheckBannedResponse> checkBanned(
    $0.CheckBannedRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$checkBanned, request, options: options);
  }

  /// 根据 ID 获取用户信息
  $grpc.ResponseFuture<$0.User> getUser(
    $0.GetUserRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getUser, request, options: options);
  }

  // method descriptors

  static final _$register =
      $grpc.ClientMethod<$0.RegisterRequest, $0.AuthResponse>(
          '/auth.AuthService/Register',
          ($0.RegisterRequest value) => value.writeToBuffer(),
          $0.AuthResponse.fromBuffer);
  static final _$login = $grpc.ClientMethod<$0.LoginRequest, $0.AuthResponse>(
      '/auth.AuthService/Login',
      ($0.LoginRequest value) => value.writeToBuffer(),
      $0.AuthResponse.fromBuffer);
  static final _$logout = $grpc.ClientMethod<$0.LogoutRequest, $1.Empty>(
      '/auth.AuthService/Logout',
      ($0.LogoutRequest value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$refreshToken =
      $grpc.ClientMethod<$0.RefreshRequest, $0.AuthResponse>(
          '/auth.AuthService/RefreshToken',
          ($0.RefreshRequest value) => value.writeToBuffer(),
          $0.AuthResponse.fromBuffer);
  static final _$getPublicKey =
      $grpc.ClientMethod<$0.GetPublicKeyRequest, $0.GetPublicKeyResponse>(
          '/auth.AuthService/GetPublicKey',
          ($0.GetPublicKeyRequest value) => value.writeToBuffer(),
          $0.GetPublicKeyResponse.fromBuffer);
  static final _$banUser =
      $grpc.ClientMethod<$0.BanUserRequest, $0.BanUserResponse>(
          '/auth.AuthService/BanUser',
          ($0.BanUserRequest value) => value.writeToBuffer(),
          $0.BanUserResponse.fromBuffer);
  static final _$checkBanned =
      $grpc.ClientMethod<$0.CheckBannedRequest, $0.CheckBannedResponse>(
          '/auth.AuthService/CheckBanned',
          ($0.CheckBannedRequest value) => value.writeToBuffer(),
          $0.CheckBannedResponse.fromBuffer);
  static final _$getUser = $grpc.ClientMethod<$0.GetUserRequest, $0.User>(
      '/auth.AuthService/GetUser',
      ($0.GetUserRequest value) => value.writeToBuffer(),
      $0.User.fromBuffer);
}

@$pb.GrpcServiceName('auth.AuthService')
abstract class AuthServiceBase extends $grpc.Service {
  $core.String get $name => 'auth.AuthService';

  AuthServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.RegisterRequest, $0.AuthResponse>(
        'Register',
        register_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RegisterRequest.fromBuffer(value),
        ($0.AuthResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.LoginRequest, $0.AuthResponse>(
        'Login',
        login_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LoginRequest.fromBuffer(value),
        ($0.AuthResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.LogoutRequest, $1.Empty>(
        'Logout',
        logout_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LogoutRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RefreshRequest, $0.AuthResponse>(
        'RefreshToken',
        refreshToken_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RefreshRequest.fromBuffer(value),
        ($0.AuthResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetPublicKeyRequest, $0.GetPublicKeyResponse>(
            'GetPublicKey',
            getPublicKey_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetPublicKeyRequest.fromBuffer(value),
            ($0.GetPublicKeyResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.BanUserRequest, $0.BanUserResponse>(
        'BanUser',
        banUser_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.BanUserRequest.fromBuffer(value),
        ($0.BanUserResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.CheckBannedRequest, $0.CheckBannedResponse>(
            'CheckBanned',
            checkBanned_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.CheckBannedRequest.fromBuffer(value),
            ($0.CheckBannedResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetUserRequest, $0.User>(
        'GetUser',
        getUser_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetUserRequest.fromBuffer(value),
        ($0.User value) => value.writeToBuffer()));
  }

  $async.Future<$0.AuthResponse> register_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RegisterRequest> $request) async {
    return register($call, await $request);
  }

  $async.Future<$0.AuthResponse> register(
      $grpc.ServiceCall call, $0.RegisterRequest request);

  $async.Future<$0.AuthResponse> login_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.LoginRequest> $request) async {
    return login($call, await $request);
  }

  $async.Future<$0.AuthResponse> login(
      $grpc.ServiceCall call, $0.LoginRequest request);

  $async.Future<$1.Empty> logout_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.LogoutRequest> $request) async {
    return logout($call, await $request);
  }

  $async.Future<$1.Empty> logout(
      $grpc.ServiceCall call, $0.LogoutRequest request);

  $async.Future<$0.AuthResponse> refreshToken_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RefreshRequest> $request) async {
    return refreshToken($call, await $request);
  }

  $async.Future<$0.AuthResponse> refreshToken(
      $grpc.ServiceCall call, $0.RefreshRequest request);

  $async.Future<$0.GetPublicKeyResponse> getPublicKey_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetPublicKeyRequest> $request) async {
    return getPublicKey($call, await $request);
  }

  $async.Future<$0.GetPublicKeyResponse> getPublicKey(
      $grpc.ServiceCall call, $0.GetPublicKeyRequest request);

  $async.Future<$0.BanUserResponse> banUser_Pre($grpc.ServiceCall $call,
      $async.Future<$0.BanUserRequest> $request) async {
    return banUser($call, await $request);
  }

  $async.Future<$0.BanUserResponse> banUser(
      $grpc.ServiceCall call, $0.BanUserRequest request);

  $async.Future<$0.CheckBannedResponse> checkBanned_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CheckBannedRequest> $request) async {
    return checkBanned($call, await $request);
  }

  $async.Future<$0.CheckBannedResponse> checkBanned(
      $grpc.ServiceCall call, $0.CheckBannedRequest request);

  $async.Future<$0.User> getUser_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetUserRequest> $request) async {
    return getUser($call, await $request);
  }

  $async.Future<$0.User> getUser(
      $grpc.ServiceCall call, $0.GetUserRequest request);
}
