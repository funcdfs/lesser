// This is a generated file - do not edit.
//
// Generated from search/search.proto.

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

import 'search.pb.dart' as $0;

export 'search.pb.dart';

/// SearchService 搜索服务
@$pb.GrpcServiceName('search.SearchService')
class SearchServiceClient extends $grpc.Client {
  SearchServiceClient(super.channel, {super.options, super.interceptors});

  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  $grpc.ResponseFuture<$0.SearchPostsResponse> searchPosts(
    $0.SearchPostsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$searchPosts, request, options: options);
  }

  $grpc.ResponseFuture<$0.SearchUsersResponse> searchUsers(
    $0.SearchUsersRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$searchUsers, request, options: options);
  }

  // method descriptors

  static final _$searchPosts =
      $grpc.ClientMethod<$0.SearchPostsRequest, $0.SearchPostsResponse>(
    '/search.SearchService/SearchPosts',
    ($0.SearchPostsRequest value) => value.writeToBuffer(),
    $0.SearchPostsResponse.fromBuffer,
  );
  static final _$searchUsers =
      $grpc.ClientMethod<$0.SearchUsersRequest, $0.SearchUsersResponse>(
    '/search.SearchService/SearchUsers',
    ($0.SearchUsersRequest value) => value.writeToBuffer(),
    $0.SearchUsersResponse.fromBuffer,
  );
}

@$pb.GrpcServiceName('search.SearchService')
abstract class SearchServiceBase extends $grpc.Service {
  SearchServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.SearchPostsRequest, $0.SearchPostsResponse>(
            'SearchPosts',
            searchPosts_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.SearchPostsRequest.fromBuffer(value),
            ($0.SearchPostsResponse value) => value.writeToBuffer()));
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
  $core.String get $name => 'search.SearchService';

  $async.Future<$0.SearchPostsResponse> searchPosts_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.SearchPostsRequest> $request,
  ) async {
    return searchPosts($call, await $request);
  }

  $async.Future<$0.SearchPostsResponse> searchPosts(
    $grpc.ServiceCall call,
    $0.SearchPostsRequest request,
  );

  $async.Future<$0.SearchUsersResponse> searchUsers_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.SearchUsersRequest> $request,
  ) async {
    return searchUsers($call, await $request);
  }

  $async.Future<$0.SearchUsersResponse> searchUsers(
    $grpc.ServiceCall call,
    $0.SearchUsersRequest request,
  );
}
