// This is a generated file - do not edit.
//
// Generated from notification/notification.proto.

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
import 'notification.pb.dart' as $0;

export 'notification.pb.dart';

/// NotificationService 通知服务
@$pb.GrpcServiceName('notification.NotificationService')
class NotificationServiceClient extends $grpc.Client {
  NotificationServiceClient(super.channel, {super.options, super.interceptors});

  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  $grpc.ResponseFuture<$0.ListNotificationsResponse> list(
    $0.ListNotificationsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$list, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> read(
    $0.ReadNotificationRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$read, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> readAll(
    $0.ReadAllNotificationsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$readAll, request, options: options);
  }

  $grpc.ResponseFuture<$0.UnreadCountResponse> getUnreadCount(
    $0.GetUnreadCountRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getUnreadCount, request, options: options);
  }

  // method descriptors

  static final _$list = $grpc.ClientMethod<$0.ListNotificationsRequest,
      $0.ListNotificationsResponse>(
    '/notification.NotificationService/List',
    ($0.ListNotificationsRequest value) => value.writeToBuffer(),
    $0.ListNotificationsResponse.fromBuffer,
  );
  static final _$read =
      $grpc.ClientMethod<$0.ReadNotificationRequest, $1.Empty>(
    '/notification.NotificationService/Read',
    ($0.ReadNotificationRequest value) => value.writeToBuffer(),
    $1.Empty.fromBuffer,
  );
  static final _$readAll =
      $grpc.ClientMethod<$0.ReadAllNotificationsRequest, $1.Empty>(
    '/notification.NotificationService/ReadAll',
    ($0.ReadAllNotificationsRequest value) => value.writeToBuffer(),
    $1.Empty.fromBuffer,
  );
  static final _$getUnreadCount =
      $grpc.ClientMethod<$0.GetUnreadCountRequest, $0.UnreadCountResponse>(
    '/notification.NotificationService/GetUnreadCount',
    ($0.GetUnreadCountRequest value) => value.writeToBuffer(),
    $0.UnreadCountResponse.fromBuffer,
  );
}

@$pb.GrpcServiceName('notification.NotificationService')
abstract class NotificationServiceBase extends $grpc.Service {
  NotificationServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ListNotificationsRequest,
            $0.ListNotificationsResponse>(
        'List',
        list_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ListNotificationsRequest.fromBuffer(value),
        ($0.ListNotificationsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ReadNotificationRequest, $1.Empty>(
        'Read',
        read_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ReadNotificationRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ReadAllNotificationsRequest, $1.Empty>(
        'ReadAll',
        readAll_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ReadAllNotificationsRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetUnreadCountRequest, $0.UnreadCountResponse>(
            'GetUnreadCount',
            getUnreadCount_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetUnreadCountRequest.fromBuffer(value),
            ($0.UnreadCountResponse value) => value.writeToBuffer()));
  }
  $core.String get $name => 'notification.NotificationService';

  $async.Future<$0.ListNotificationsResponse> list_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.ListNotificationsRequest> $request,
  ) async {
    return list($call, await $request);
  }

  $async.Future<$0.ListNotificationsResponse> list(
    $grpc.ServiceCall call,
    $0.ListNotificationsRequest request,
  );

  $async.Future<$1.Empty> read_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.ReadNotificationRequest> $request,
  ) async {
    return read($call, await $request);
  }

  $async.Future<$1.Empty> read(
    $grpc.ServiceCall call,
    $0.ReadNotificationRequest request,
  );

  $async.Future<$1.Empty> readAll_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.ReadAllNotificationsRequest> $request,
  ) async {
    return readAll($call, await $request);
  }

  $async.Future<$1.Empty> readAll(
    $grpc.ServiceCall call,
    $0.ReadAllNotificationsRequest request,
  );

  $async.Future<$0.UnreadCountResponse> getUnreadCount_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.GetUnreadCountRequest> $request,
  ) async {
    return getUnreadCount($call, await $request);
  }

  $async.Future<$0.UnreadCountResponse> getUnreadCount(
    $grpc.ServiceCall call,
    $0.GetUnreadCountRequest request,
  );
}
