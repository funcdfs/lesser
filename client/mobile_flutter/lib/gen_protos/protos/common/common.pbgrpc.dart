// This is a generated file - do not edit.
//
// Generated from common/common.proto.

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

import 'common.pb.dart' as $0;

export 'common.pb.dart';

/// Health check service for service discovery
@$pb.GrpcServiceName('common.HealthService')
class HealthServiceClient extends $grpc.Client {
  HealthServiceClient(super.channel, {super.options, super.interceptors});

  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  /// Check service health
  $grpc.ResponseFuture<$0.HealthCheckResponse> check(
    $0.HealthCheckRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$check, request, options: options);
  }

  /// Watch service health changes (streaming)
  $grpc.ResponseStream<$0.HealthCheckResponse> watch(
    $0.HealthCheckRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
      _$watch,
      $async.Stream.fromIterable([request]),
      options: options,
    );
  }

  // method descriptors

  static final _$check =
      $grpc.ClientMethod<$0.HealthCheckRequest, $0.HealthCheckResponse>(
    '/common.HealthService/Check',
    ($0.HealthCheckRequest value) => value.writeToBuffer(),
    $0.HealthCheckResponse.fromBuffer,
  );
  static final _$watch =
      $grpc.ClientMethod<$0.HealthCheckRequest, $0.HealthCheckResponse>(
    '/common.HealthService/Watch',
    ($0.HealthCheckRequest value) => value.writeToBuffer(),
    $0.HealthCheckResponse.fromBuffer,
  );
}

@$pb.GrpcServiceName('common.HealthService')
abstract class HealthServiceBase extends $grpc.Service {
  HealthServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.HealthCheckRequest, $0.HealthCheckResponse>(
            'Check',
            check_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.HealthCheckRequest.fromBuffer(value),
            ($0.HealthCheckResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.HealthCheckRequest, $0.HealthCheckResponse>(
            'Watch',
            watch_Pre,
            false,
            true,
            ($core.List<$core.int> value) =>
                $0.HealthCheckRequest.fromBuffer(value),
            ($0.HealthCheckResponse value) => value.writeToBuffer()));
  }
  $core.String get $name => 'common.HealthService';

  $async.Future<$0.HealthCheckResponse> check_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.HealthCheckRequest> $request,
  ) async {
    return check($call, await $request);
  }

  $async.Future<$0.HealthCheckResponse> check(
    $grpc.ServiceCall call,
    $0.HealthCheckRequest request,
  );

  $async.Stream<$0.HealthCheckResponse> watch_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.HealthCheckRequest> $request,
  ) async* {
    yield* watch($call, await $request);
  }

  $async.Stream<$0.HealthCheckResponse> watch(
    $grpc.ServiceCall call,
    $0.HealthCheckRequest request,
  );
}
