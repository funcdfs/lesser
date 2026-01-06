// This is a generated file - do not edit.
//
// Generated from feed/feed.proto.

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
import 'feed.pb.dart' as $0;

export 'feed.pb.dart';

/// FeedService Feed 服务
/// 提供 Feed 流获取和内容交互功能
@$pb.GrpcServiceName('feed.FeedService')
class FeedServiceClient extends $grpc.Client {
  FeedServiceClient(super.channel, {super.options, super.interceptors});

  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  /// ---- Feed 流 ----
  $grpc.ResponseFuture<$0.GetFollowingFeedResponse> getFollowingFeed(
    $0.GetFollowingFeedRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getFollowingFeed, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetRecommendFeedResponse> getRecommendFeed(
    $0.GetRecommendFeedRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getRecommendFeed, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetUserFeedResponse> getUserFeed(
    $0.GetUserFeedRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getUserFeed, request, options: options);
  }

  /// ---- 交互操作 ----
  $grpc.ResponseFuture<$1.Empty> like(
    $0.LikeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$like, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> unlike(
    $0.UnlikeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$unlike, request, options: options);
  }

  $grpc.ResponseFuture<$0.Comment> createComment(
    $0.CreateCommentRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createComment, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> deleteComment(
    $0.DeleteCommentRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteComment, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListCommentsResponse> listComments(
    $0.ListCommentsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listComments, request, options: options);
  }

  $grpc.ResponseFuture<$0.Repost> createRepost(
    $0.RepostRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createRepost, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> bookmark(
    $0.BookmarkRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$bookmark, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> unbookmark(
    $0.UnbookmarkRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$unbookmark, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListBookmarksResponse> listBookmarks(
    $0.ListBookmarksRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listBookmarks, request, options: options);
  }

  // method descriptors

  static final _$getFollowingFeed = $grpc.ClientMethod<
      $0.GetFollowingFeedRequest, $0.GetFollowingFeedResponse>(
    '/feed.FeedService/GetFollowingFeed',
    ($0.GetFollowingFeedRequest value) => value.writeToBuffer(),
    $0.GetFollowingFeedResponse.fromBuffer,
  );
  static final _$getRecommendFeed = $grpc.ClientMethod<
      $0.GetRecommendFeedRequest, $0.GetRecommendFeedResponse>(
    '/feed.FeedService/GetRecommendFeed',
    ($0.GetRecommendFeedRequest value) => value.writeToBuffer(),
    $0.GetRecommendFeedResponse.fromBuffer,
  );
  static final _$getUserFeed =
      $grpc.ClientMethod<$0.GetUserFeedRequest, $0.GetUserFeedResponse>(
    '/feed.FeedService/GetUserFeed',
    ($0.GetUserFeedRequest value) => value.writeToBuffer(),
    $0.GetUserFeedResponse.fromBuffer,
  );
  static final _$like = $grpc.ClientMethod<$0.LikeRequest, $1.Empty>(
    '/feed.FeedService/Like',
    ($0.LikeRequest value) => value.writeToBuffer(),
    $1.Empty.fromBuffer,
  );
  static final _$unlike = $grpc.ClientMethod<$0.UnlikeRequest, $1.Empty>(
    '/feed.FeedService/Unlike',
    ($0.UnlikeRequest value) => value.writeToBuffer(),
    $1.Empty.fromBuffer,
  );
  static final _$createComment =
      $grpc.ClientMethod<$0.CreateCommentRequest, $0.Comment>(
    '/feed.FeedService/CreateComment',
    ($0.CreateCommentRequest value) => value.writeToBuffer(),
    $0.Comment.fromBuffer,
  );
  static final _$deleteComment =
      $grpc.ClientMethod<$0.DeleteCommentRequest, $1.Empty>(
    '/feed.FeedService/DeleteComment',
    ($0.DeleteCommentRequest value) => value.writeToBuffer(),
    $1.Empty.fromBuffer,
  );
  static final _$listComments =
      $grpc.ClientMethod<$0.ListCommentsRequest, $0.ListCommentsResponse>(
    '/feed.FeedService/ListComments',
    ($0.ListCommentsRequest value) => value.writeToBuffer(),
    $0.ListCommentsResponse.fromBuffer,
  );
  static final _$createRepost = $grpc.ClientMethod<$0.RepostRequest, $0.Repost>(
    '/feed.FeedService/CreateRepost',
    ($0.RepostRequest value) => value.writeToBuffer(),
    $0.Repost.fromBuffer,
  );
  static final _$bookmark = $grpc.ClientMethod<$0.BookmarkRequest, $1.Empty>(
    '/feed.FeedService/Bookmark',
    ($0.BookmarkRequest value) => value.writeToBuffer(),
    $1.Empty.fromBuffer,
  );
  static final _$unbookmark =
      $grpc.ClientMethod<$0.UnbookmarkRequest, $1.Empty>(
    '/feed.FeedService/Unbookmark',
    ($0.UnbookmarkRequest value) => value.writeToBuffer(),
    $1.Empty.fromBuffer,
  );
  static final _$listBookmarks =
      $grpc.ClientMethod<$0.ListBookmarksRequest, $0.ListBookmarksResponse>(
    '/feed.FeedService/ListBookmarks',
    ($0.ListBookmarksRequest value) => value.writeToBuffer(),
    $0.ListBookmarksResponse.fromBuffer,
  );
}

@$pb.GrpcServiceName('feed.FeedService')
abstract class FeedServiceBase extends $grpc.Service {
  FeedServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.GetFollowingFeedRequest,
            $0.GetFollowingFeedResponse>(
        'GetFollowingFeed',
        getFollowingFeed_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetFollowingFeedRequest.fromBuffer(value),
        ($0.GetFollowingFeedResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetRecommendFeedRequest,
            $0.GetRecommendFeedResponse>(
        'GetRecommendFeed',
        getRecommendFeed_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetRecommendFeedRequest.fromBuffer(value),
        ($0.GetRecommendFeedResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetUserFeedRequest, $0.GetUserFeedResponse>(
            'GetUserFeed',
            getUserFeed_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetUserFeedRequest.fromBuffer(value),
            ($0.GetUserFeedResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.LikeRequest, $1.Empty>(
        'Like',
        like_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LikeRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UnlikeRequest, $1.Empty>(
        'Unlike',
        unlike_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UnlikeRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CreateCommentRequest, $0.Comment>(
        'CreateComment',
        createComment_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CreateCommentRequest.fromBuffer(value),
        ($0.Comment value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteCommentRequest, $1.Empty>(
        'DeleteComment',
        deleteComment_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DeleteCommentRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ListCommentsRequest, $0.ListCommentsResponse>(
            'ListComments',
            listComments_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ListCommentsRequest.fromBuffer(value),
            ($0.ListCommentsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RepostRequest, $0.Repost>(
        'CreateRepost',
        createRepost_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RepostRequest.fromBuffer(value),
        ($0.Repost value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.BookmarkRequest, $1.Empty>(
        'Bookmark',
        bookmark_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.BookmarkRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UnbookmarkRequest, $1.Empty>(
        'Unbookmark',
        unbookmark_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UnbookmarkRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ListBookmarksRequest, $0.ListBookmarksResponse>(
            'ListBookmarks',
            listBookmarks_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ListBookmarksRequest.fromBuffer(value),
            ($0.ListBookmarksResponse value) => value.writeToBuffer()));
  }
  $core.String get $name => 'feed.FeedService';

  $async.Future<$0.GetFollowingFeedResponse> getFollowingFeed_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.GetFollowingFeedRequest> $request,
  ) async {
    return getFollowingFeed($call, await $request);
  }

  $async.Future<$0.GetFollowingFeedResponse> getFollowingFeed(
    $grpc.ServiceCall call,
    $0.GetFollowingFeedRequest request,
  );

  $async.Future<$0.GetRecommendFeedResponse> getRecommendFeed_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.GetRecommendFeedRequest> $request,
  ) async {
    return getRecommendFeed($call, await $request);
  }

  $async.Future<$0.GetRecommendFeedResponse> getRecommendFeed(
    $grpc.ServiceCall call,
    $0.GetRecommendFeedRequest request,
  );

  $async.Future<$0.GetUserFeedResponse> getUserFeed_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.GetUserFeedRequest> $request,
  ) async {
    return getUserFeed($call, await $request);
  }

  $async.Future<$0.GetUserFeedResponse> getUserFeed(
    $grpc.ServiceCall call,
    $0.GetUserFeedRequest request,
  );

  $async.Future<$1.Empty> like_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.LikeRequest> $request,
  ) async {
    return like($call, await $request);
  }

  $async.Future<$1.Empty> like($grpc.ServiceCall call, $0.LikeRequest request);

  $async.Future<$1.Empty> unlike_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.UnlikeRequest> $request,
  ) async {
    return unlike($call, await $request);
  }

  $async.Future<$1.Empty> unlike(
    $grpc.ServiceCall call,
    $0.UnlikeRequest request,
  );

  $async.Future<$0.Comment> createComment_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.CreateCommentRequest> $request,
  ) async {
    return createComment($call, await $request);
  }

  $async.Future<$0.Comment> createComment(
    $grpc.ServiceCall call,
    $0.CreateCommentRequest request,
  );

  $async.Future<$1.Empty> deleteComment_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.DeleteCommentRequest> $request,
  ) async {
    return deleteComment($call, await $request);
  }

  $async.Future<$1.Empty> deleteComment(
    $grpc.ServiceCall call,
    $0.DeleteCommentRequest request,
  );

  $async.Future<$0.ListCommentsResponse> listComments_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.ListCommentsRequest> $request,
  ) async {
    return listComments($call, await $request);
  }

  $async.Future<$0.ListCommentsResponse> listComments(
    $grpc.ServiceCall call,
    $0.ListCommentsRequest request,
  );

  $async.Future<$0.Repost> createRepost_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.RepostRequest> $request,
  ) async {
    return createRepost($call, await $request);
  }

  $async.Future<$0.Repost> createRepost(
    $grpc.ServiceCall call,
    $0.RepostRequest request,
  );

  $async.Future<$1.Empty> bookmark_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.BookmarkRequest> $request,
  ) async {
    return bookmark($call, await $request);
  }

  $async.Future<$1.Empty> bookmark(
    $grpc.ServiceCall call,
    $0.BookmarkRequest request,
  );

  $async.Future<$1.Empty> unbookmark_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.UnbookmarkRequest> $request,
  ) async {
    return unbookmark($call, await $request);
  }

  $async.Future<$1.Empty> unbookmark(
    $grpc.ServiceCall call,
    $0.UnbookmarkRequest request,
  );

  $async.Future<$0.ListBookmarksResponse> listBookmarks_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.ListBookmarksRequest> $request,
  ) async {
    return listBookmarks($call, await $request);
  }

  $async.Future<$0.ListBookmarksResponse> listBookmarks(
    $grpc.ServiceCall call,
    $0.ListBookmarksRequest request,
  );
}
