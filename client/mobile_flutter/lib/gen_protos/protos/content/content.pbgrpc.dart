// This is a generated file - do not edit.
//
// Generated from content/content.proto.

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

import 'content.pb.dart' as $0;

export 'content.pb.dart';

/// ContentService 内容服务
@$pb.GrpcServiceName('content.ContentService')
class ContentServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  ContentServiceClient(super.channel, {super.options, super.interceptors});

  /// 基础 CRUD
  $grpc.ResponseFuture<$0.CreateContentResponse> createContent(
    $0.CreateContentRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createContent, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetContentResponse> getContent(
    $0.GetContentRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getContent, request, options: options);
  }

  $grpc.ResponseFuture<$0.UpdateContentResponse> updateContent(
    $0.UpdateContentRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateContent, request, options: options);
  }

  $grpc.ResponseFuture<$0.DeleteContentResponse> deleteContent(
    $0.DeleteContentRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteContent, request, options: options);
  }

  /// 列表查询
  $grpc.ResponseFuture<$0.ListContentsResponse> listContents(
    $0.ListContentsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listContents, request, options: options);
  }

  $grpc.ResponseFuture<$0.BatchGetContentsResponse> batchGetContents(
    $0.BatchGetContentsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$batchGetContents, request, options: options);
  }

  /// 草稿管理
  $grpc.ResponseFuture<$0.GetUserDraftsResponse> getUserDrafts(
    $0.GetUserDraftsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getUserDrafts, request, options: options);
  }

  $grpc.ResponseFuture<$0.PublishDraftResponse> publishDraft(
    $0.PublishDraftRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$publishDraft, request, options: options);
  }

  /// 回复/评论
  $grpc.ResponseFuture<$0.GetRepliesResponse> getReplies(
    $0.GetRepliesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getReplies, request, options: options);
  }

  /// Story 专用
  $grpc.ResponseFuture<$0.GetUserStoriesResponse> getUserStories(
    $0.GetUserStoriesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getUserStories, request, options: options);
  }

  /// 置顶
  $grpc.ResponseFuture<$0.PinContentResponse> pinContent(
    $0.PinContentRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$pinContent, request, options: options);
  }

  // method descriptors

  static final _$createContent =
      $grpc.ClientMethod<$0.CreateContentRequest, $0.CreateContentResponse>(
          '/content.ContentService/CreateContent',
          ($0.CreateContentRequest value) => value.writeToBuffer(),
          $0.CreateContentResponse.fromBuffer);
  static final _$getContent =
      $grpc.ClientMethod<$0.GetContentRequest, $0.GetContentResponse>(
          '/content.ContentService/GetContent',
          ($0.GetContentRequest value) => value.writeToBuffer(),
          $0.GetContentResponse.fromBuffer);
  static final _$updateContent =
      $grpc.ClientMethod<$0.UpdateContentRequest, $0.UpdateContentResponse>(
          '/content.ContentService/UpdateContent',
          ($0.UpdateContentRequest value) => value.writeToBuffer(),
          $0.UpdateContentResponse.fromBuffer);
  static final _$deleteContent =
      $grpc.ClientMethod<$0.DeleteContentRequest, $0.DeleteContentResponse>(
          '/content.ContentService/DeleteContent',
          ($0.DeleteContentRequest value) => value.writeToBuffer(),
          $0.DeleteContentResponse.fromBuffer);
  static final _$listContents =
      $grpc.ClientMethod<$0.ListContentsRequest, $0.ListContentsResponse>(
          '/content.ContentService/ListContents',
          ($0.ListContentsRequest value) => value.writeToBuffer(),
          $0.ListContentsResponse.fromBuffer);
  static final _$batchGetContents = $grpc.ClientMethod<
          $0.BatchGetContentsRequest, $0.BatchGetContentsResponse>(
      '/content.ContentService/BatchGetContents',
      ($0.BatchGetContentsRequest value) => value.writeToBuffer(),
      $0.BatchGetContentsResponse.fromBuffer);
  static final _$getUserDrafts =
      $grpc.ClientMethod<$0.GetUserDraftsRequest, $0.GetUserDraftsResponse>(
          '/content.ContentService/GetUserDrafts',
          ($0.GetUserDraftsRequest value) => value.writeToBuffer(),
          $0.GetUserDraftsResponse.fromBuffer);
  static final _$publishDraft =
      $grpc.ClientMethod<$0.PublishDraftRequest, $0.PublishDraftResponse>(
          '/content.ContentService/PublishDraft',
          ($0.PublishDraftRequest value) => value.writeToBuffer(),
          $0.PublishDraftResponse.fromBuffer);
  static final _$getReplies =
      $grpc.ClientMethod<$0.GetRepliesRequest, $0.GetRepliesResponse>(
          '/content.ContentService/GetReplies',
          ($0.GetRepliesRequest value) => value.writeToBuffer(),
          $0.GetRepliesResponse.fromBuffer);
  static final _$getUserStories =
      $grpc.ClientMethod<$0.GetUserStoriesRequest, $0.GetUserStoriesResponse>(
          '/content.ContentService/GetUserStories',
          ($0.GetUserStoriesRequest value) => value.writeToBuffer(),
          $0.GetUserStoriesResponse.fromBuffer);
  static final _$pinContent =
      $grpc.ClientMethod<$0.PinContentRequest, $0.PinContentResponse>(
          '/content.ContentService/PinContent',
          ($0.PinContentRequest value) => value.writeToBuffer(),
          $0.PinContentResponse.fromBuffer);
}

@$pb.GrpcServiceName('content.ContentService')
abstract class ContentServiceBase extends $grpc.Service {
  $core.String get $name => 'content.ContentService';

  ContentServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.CreateContentRequest, $0.CreateContentResponse>(
            'CreateContent',
            createContent_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.CreateContentRequest.fromBuffer(value),
            ($0.CreateContentResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetContentRequest, $0.GetContentResponse>(
        'GetContent',
        getContent_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetContentRequest.fromBuffer(value),
        ($0.GetContentResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.UpdateContentRequest, $0.UpdateContentResponse>(
            'UpdateContent',
            updateContent_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.UpdateContentRequest.fromBuffer(value),
            ($0.UpdateContentResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.DeleteContentRequest, $0.DeleteContentResponse>(
            'DeleteContent',
            deleteContent_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.DeleteContentRequest.fromBuffer(value),
            ($0.DeleteContentResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ListContentsRequest, $0.ListContentsResponse>(
            'ListContents',
            listContents_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ListContentsRequest.fromBuffer(value),
            ($0.ListContentsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.BatchGetContentsRequest,
            $0.BatchGetContentsResponse>(
        'BatchGetContents',
        batchGetContents_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.BatchGetContentsRequest.fromBuffer(value),
        ($0.BatchGetContentsResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetUserDraftsRequest, $0.GetUserDraftsResponse>(
            'GetUserDrafts',
            getUserDrafts_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetUserDraftsRequest.fromBuffer(value),
            ($0.GetUserDraftsResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.PublishDraftRequest, $0.PublishDraftResponse>(
            'PublishDraft',
            publishDraft_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.PublishDraftRequest.fromBuffer(value),
            ($0.PublishDraftResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetRepliesRequest, $0.GetRepliesResponse>(
        'GetReplies',
        getReplies_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetRepliesRequest.fromBuffer(value),
        ($0.GetRepliesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetUserStoriesRequest,
            $0.GetUserStoriesResponse>(
        'GetUserStories',
        getUserStories_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetUserStoriesRequest.fromBuffer(value),
        ($0.GetUserStoriesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PinContentRequest, $0.PinContentResponse>(
        'PinContent',
        pinContent_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.PinContentRequest.fromBuffer(value),
        ($0.PinContentResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.CreateContentResponse> createContent_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CreateContentRequest> $request) async {
    return createContent($call, await $request);
  }

  $async.Future<$0.CreateContentResponse> createContent(
      $grpc.ServiceCall call, $0.CreateContentRequest request);

  $async.Future<$0.GetContentResponse> getContent_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetContentRequest> $request) async {
    return getContent($call, await $request);
  }

  $async.Future<$0.GetContentResponse> getContent(
      $grpc.ServiceCall call, $0.GetContentRequest request);

  $async.Future<$0.UpdateContentResponse> updateContent_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.UpdateContentRequest> $request) async {
    return updateContent($call, await $request);
  }

  $async.Future<$0.UpdateContentResponse> updateContent(
      $grpc.ServiceCall call, $0.UpdateContentRequest request);

  $async.Future<$0.DeleteContentResponse> deleteContent_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.DeleteContentRequest> $request) async {
    return deleteContent($call, await $request);
  }

  $async.Future<$0.DeleteContentResponse> deleteContent(
      $grpc.ServiceCall call, $0.DeleteContentRequest request);

  $async.Future<$0.ListContentsResponse> listContents_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListContentsRequest> $request) async {
    return listContents($call, await $request);
  }

  $async.Future<$0.ListContentsResponse> listContents(
      $grpc.ServiceCall call, $0.ListContentsRequest request);

  $async.Future<$0.BatchGetContentsResponse> batchGetContents_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.BatchGetContentsRequest> $request) async {
    return batchGetContents($call, await $request);
  }

  $async.Future<$0.BatchGetContentsResponse> batchGetContents(
      $grpc.ServiceCall call, $0.BatchGetContentsRequest request);

  $async.Future<$0.GetUserDraftsResponse> getUserDrafts_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetUserDraftsRequest> $request) async {
    return getUserDrafts($call, await $request);
  }

  $async.Future<$0.GetUserDraftsResponse> getUserDrafts(
      $grpc.ServiceCall call, $0.GetUserDraftsRequest request);

  $async.Future<$0.PublishDraftResponse> publishDraft_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.PublishDraftRequest> $request) async {
    return publishDraft($call, await $request);
  }

  $async.Future<$0.PublishDraftResponse> publishDraft(
      $grpc.ServiceCall call, $0.PublishDraftRequest request);

  $async.Future<$0.GetRepliesResponse> getReplies_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetRepliesRequest> $request) async {
    return getReplies($call, await $request);
  }

  $async.Future<$0.GetRepliesResponse> getReplies(
      $grpc.ServiceCall call, $0.GetRepliesRequest request);

  $async.Future<$0.GetUserStoriesResponse> getUserStories_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetUserStoriesRequest> $request) async {
    return getUserStories($call, await $request);
  }

  $async.Future<$0.GetUserStoriesResponse> getUserStories(
      $grpc.ServiceCall call, $0.GetUserStoriesRequest request);

  $async.Future<$0.PinContentResponse> pinContent_Pre($grpc.ServiceCall $call,
      $async.Future<$0.PinContentRequest> $request) async {
    return pinContent($call, await $request);
  }

  $async.Future<$0.PinContentResponse> pinContent(
      $grpc.ServiceCall call, $0.PinContentRequest request);
}
