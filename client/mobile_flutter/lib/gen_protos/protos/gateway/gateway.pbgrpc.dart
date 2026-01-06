// This is a generated file - do not edit.
//
// Generated from gateway/gateway.proto.

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

import 'gateway.pb.dart' as $0;

export 'gateway.pb.dart';

/// GatewayService API 网关服务
/// Gateway 只做：鉴权（JWT 本地验签）、限流、路由转发
/// 不处理任何业务逻辑
@$pb.GrpcServiceName('gateway.GatewayService')
class GatewayServiceClient extends $grpc.Client {
  GatewayServiceClient(super.channel, {super.options, super.interceptors});

  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  /// 健康检查
  $grpc.ResponseFuture<$0.HealthResponse> health(
    $0.HealthRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$health, request, options: options);
  }

  // method descriptors

  static final _$health =
      $grpc.ClientMethod<$0.HealthRequest, $0.HealthResponse>(
    '/gateway.GatewayService/Health',
    ($0.HealthRequest value) => value.writeToBuffer(),
    $0.HealthResponse.fromBuffer,
  );
}

@$pb.GrpcServiceName('gateway.GatewayService')
abstract class GatewayServiceBase extends $grpc.Service {
  GatewayServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.HealthRequest, $0.HealthResponse>(
        'Health',
        health_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.HealthRequest.fromBuffer(value),
        ($0.HealthResponse value) => value.writeToBuffer()));
  }
  $core.String get $name => 'gateway.GatewayService';

  $async.Future<$0.HealthResponse> health_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.HealthRequest> $request,
  ) async {
    return health($call, await $request);
  }

  $async.Future<$0.HealthResponse> health(
    $grpc.ServiceCall call,
    $0.HealthRequest request,
  );
}
