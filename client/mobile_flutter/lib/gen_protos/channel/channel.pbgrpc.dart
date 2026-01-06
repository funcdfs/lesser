// This is a generated file - do not edit.
//
// Generated from channel/channel.proto.

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
import 'channel.pb.dart' as $0;

export 'channel.pb.dart';

/// ChannelService 广播频道服务
/// 处理频道管理、内容发布、订阅管理
/// 类似 Telegram Channel，支持单向广播模式
@$pb.GrpcServiceName('channel.ChannelService')
class ChannelServiceClient extends $grpc.Client {
  ChannelServiceClient(super.channel, {super.options, super.interceptors});

  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  /// 创建频道
  $grpc.ResponseFuture<$0.Channel> createChannel(
    $0.CreateChannelRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createChannel, request, options: options);
  }

  /// 获取频道信息
  $grpc.ResponseFuture<$0.Channel> getChannel(
    $0.GetChannelRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getChannel, request, options: options);
  }

  /// 更新频道信息（仅管理员）
  $grpc.ResponseFuture<$0.Channel> updateChannel(
    $0.UpdateChannelRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateChannel, request, options: options);
  }

  /// 删除频道（仅所有者）
  $grpc.ResponseFuture<$1.Empty> deleteChannel(
    $0.DeleteChannelRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteChannel, request, options: options);
  }

  /// 获取用户订阅的频道列表
  $grpc.ResponseFuture<$0.ChannelsResponse> getSubscribedChannels(
    $0.GetSubscribedChannelsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getSubscribedChannels, request, options: options);
  }

  /// 获取用户管理的频道列表
  $grpc.ResponseFuture<$0.ChannelsResponse> getOwnedChannels(
    $0.GetOwnedChannelsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getOwnedChannels, request, options: options);
  }

  /// 搜索频道
  $grpc.ResponseFuture<$0.ChannelsResponse> searchChannels(
    $0.SearchChannelsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$searchChannels, request, options: options);
  }

  /// 订阅频道
  $grpc.ResponseFuture<$1.Empty> subscribe(
    $0.SubscribeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$subscribe, request, options: options);
  }

  /// 取消订阅
  $grpc.ResponseFuture<$1.Empty> unsubscribe(
    $0.UnsubscribeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$unsubscribe, request, options: options);
  }

  /// 获取频道订阅者列表
  $grpc.ResponseFuture<$0.SubscribersResponse> getSubscribers(
    $0.GetSubscribersRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getSubscribers, request, options: options);
  }

  /// 检查是否已订阅
  $grpc.ResponseFuture<$0.CheckSubscriptionResponse> checkSubscription(
    $0.CheckSubscriptionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$checkSubscription, request, options: options);
  }

  /// 添加管理员（仅所有者）
  $grpc.ResponseFuture<$1.Empty> addAdmin(
    $0.AddAdminRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$addAdmin, request, options: options);
  }

  /// 移除管理员（仅所有者）
  $grpc.ResponseFuture<$1.Empty> removeAdmin(
    $0.RemoveAdminRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$removeAdmin, request, options: options);
  }

  /// 获取管理员列表
  $grpc.ResponseFuture<$0.AdminsResponse> getAdmins(
    $0.GetAdminsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getAdmins, request, options: options);
  }

  /// 发布频道内容（仅管理员）
  $grpc.ResponseFuture<$0.ChannelPost> publishPost(
    $0.PublishPostRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$publishPost, request, options: options);
  }

  /// 获取频道内容列表
  $grpc.ResponseFuture<$0.PostsResponse> getPosts(
    $0.GetPostsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getPosts, request, options: options);
  }

  /// 获取单个内容详情
  $grpc.ResponseFuture<$0.ChannelPost> getPost(
    $0.GetPostRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getPost, request, options: options);
  }

  /// 编辑频道内容（仅作者或管理员）
  $grpc.ResponseFuture<$0.ChannelPost> editPost(
    $0.EditPostRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$editPost, request, options: options);
  }

  /// 删除频道内容（仅作者或管理员）
  $grpc.ResponseFuture<$1.Empty> deletePost(
    $0.DeletePostRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deletePost, request, options: options);
  }

  /// 置顶内容（仅管理员）
  $grpc.ResponseFuture<$1.Empty> pinPost(
    $0.PinPostRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$pinPost, request, options: options);
  }

  /// 取消置顶（仅管理员）
  $grpc.ResponseFuture<$1.Empty> unpinPost(
    $0.UnpinPostRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$unpinPost, request, options: options);
  }

  /// 双向流：实时频道更新
  $grpc.ResponseStream<$0.ChannelServerEvent> streamUpdates(
    $async.Stream<$0.ChannelClientEvent> request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$streamUpdates, request, options: options);
  }

  // method descriptors

  static final _$createChannel =
      $grpc.ClientMethod<$0.CreateChannelRequest, $0.Channel>(
    '/channel.ChannelService/CreateChannel',
    ($0.CreateChannelRequest value) => value.writeToBuffer(),
    $0.Channel.fromBuffer,
  );
  static final _$getChannel =
      $grpc.ClientMethod<$0.GetChannelRequest, $0.Channel>(
    '/channel.ChannelService/GetChannel',
    ($0.GetChannelRequest value) => value.writeToBuffer(),
    $0.Channel.fromBuffer,
  );
  static final _$updateChannel =
      $grpc.ClientMethod<$0.UpdateChannelRequest, $0.Channel>(
    '/channel.ChannelService/UpdateChannel',
    ($0.UpdateChannelRequest value) => value.writeToBuffer(),
    $0.Channel.fromBuffer,
  );
  static final _$deleteChannel =
      $grpc.ClientMethod<$0.DeleteChannelRequest, $1.Empty>(
    '/channel.ChannelService/DeleteChannel',
    ($0.DeleteChannelRequest value) => value.writeToBuffer(),
    $1.Empty.fromBuffer,
  );
  static final _$getSubscribedChannels =
      $grpc.ClientMethod<$0.GetSubscribedChannelsRequest, $0.ChannelsResponse>(
    '/channel.ChannelService/GetSubscribedChannels',
    ($0.GetSubscribedChannelsRequest value) => value.writeToBuffer(),
    $0.ChannelsResponse.fromBuffer,
  );
  static final _$getOwnedChannels =
      $grpc.ClientMethod<$0.GetOwnedChannelsRequest, $0.ChannelsResponse>(
    '/channel.ChannelService/GetOwnedChannels',
    ($0.GetOwnedChannelsRequest value) => value.writeToBuffer(),
    $0.ChannelsResponse.fromBuffer,
  );
  static final _$searchChannels =
      $grpc.ClientMethod<$0.SearchChannelsRequest, $0.ChannelsResponse>(
    '/channel.ChannelService/SearchChannels',
    ($0.SearchChannelsRequest value) => value.writeToBuffer(),
    $0.ChannelsResponse.fromBuffer,
  );
  static final _$subscribe = $grpc.ClientMethod<$0.SubscribeRequest, $1.Empty>(
    '/channel.ChannelService/Subscribe',
    ($0.SubscribeRequest value) => value.writeToBuffer(),
    $1.Empty.fromBuffer,
  );
  static final _$unsubscribe =
      $grpc.ClientMethod<$0.UnsubscribeRequest, $1.Empty>(
    '/channel.ChannelService/Unsubscribe',
    ($0.UnsubscribeRequest value) => value.writeToBuffer(),
    $1.Empty.fromBuffer,
  );
  static final _$getSubscribers =
      $grpc.ClientMethod<$0.GetSubscribersRequest, $0.SubscribersResponse>(
    '/channel.ChannelService/GetSubscribers',
    ($0.GetSubscribersRequest value) => value.writeToBuffer(),
    $0.SubscribersResponse.fromBuffer,
  );
  static final _$checkSubscription = $grpc.ClientMethod<
      $0.CheckSubscriptionRequest, $0.CheckSubscriptionResponse>(
    '/channel.ChannelService/CheckSubscription',
    ($0.CheckSubscriptionRequest value) => value.writeToBuffer(),
    $0.CheckSubscriptionResponse.fromBuffer,
  );
  static final _$addAdmin = $grpc.ClientMethod<$0.AddAdminRequest, $1.Empty>(
    '/channel.ChannelService/AddAdmin',
    ($0.AddAdminRequest value) => value.writeToBuffer(),
    $1.Empty.fromBuffer,
  );
  static final _$removeAdmin =
      $grpc.ClientMethod<$0.RemoveAdminRequest, $1.Empty>(
    '/channel.ChannelService/RemoveAdmin',
    ($0.RemoveAdminRequest value) => value.writeToBuffer(),
    $1.Empty.fromBuffer,
  );
  static final _$getAdmins =
      $grpc.ClientMethod<$0.GetAdminsRequest, $0.AdminsResponse>(
    '/channel.ChannelService/GetAdmins',
    ($0.GetAdminsRequest value) => value.writeToBuffer(),
    $0.AdminsResponse.fromBuffer,
  );
  static final _$publishPost =
      $grpc.ClientMethod<$0.PublishPostRequest, $0.ChannelPost>(
    '/channel.ChannelService/PublishPost',
    ($0.PublishPostRequest value) => value.writeToBuffer(),
    $0.ChannelPost.fromBuffer,
  );
  static final _$getPosts =
      $grpc.ClientMethod<$0.GetPostsRequest, $0.PostsResponse>(
    '/channel.ChannelService/GetPosts',
    ($0.GetPostsRequest value) => value.writeToBuffer(),
    $0.PostsResponse.fromBuffer,
  );
  static final _$getPost =
      $grpc.ClientMethod<$0.GetPostRequest, $0.ChannelPost>(
    '/channel.ChannelService/GetPost',
    ($0.GetPostRequest value) => value.writeToBuffer(),
    $0.ChannelPost.fromBuffer,
  );
  static final _$editPost =
      $grpc.ClientMethod<$0.EditPostRequest, $0.ChannelPost>(
    '/channel.ChannelService/EditPost',
    ($0.EditPostRequest value) => value.writeToBuffer(),
    $0.ChannelPost.fromBuffer,
  );
  static final _$deletePost =
      $grpc.ClientMethod<$0.DeletePostRequest, $1.Empty>(
    '/channel.ChannelService/DeletePost',
    ($0.DeletePostRequest value) => value.writeToBuffer(),
    $1.Empty.fromBuffer,
  );
  static final _$pinPost = $grpc.ClientMethod<$0.PinPostRequest, $1.Empty>(
    '/channel.ChannelService/PinPost',
    ($0.PinPostRequest value) => value.writeToBuffer(),
    $1.Empty.fromBuffer,
  );
  static final _$unpinPost = $grpc.ClientMethod<$0.UnpinPostRequest, $1.Empty>(
    '/channel.ChannelService/UnpinPost',
    ($0.UnpinPostRequest value) => value.writeToBuffer(),
    $1.Empty.fromBuffer,
  );
  static final _$streamUpdates =
      $grpc.ClientMethod<$0.ChannelClientEvent, $0.ChannelServerEvent>(
    '/channel.ChannelService/StreamUpdates',
    ($0.ChannelClientEvent value) => value.writeToBuffer(),
    $0.ChannelServerEvent.fromBuffer,
  );
}

@$pb.GrpcServiceName('channel.ChannelService')
abstract class ChannelServiceBase extends $grpc.Service {
  ChannelServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.CreateChannelRequest, $0.Channel>(
        'CreateChannel',
        createChannel_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CreateChannelRequest.fromBuffer(value),
        ($0.Channel value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetChannelRequest, $0.Channel>(
        'GetChannel',
        getChannel_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetChannelRequest.fromBuffer(value),
        ($0.Channel value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateChannelRequest, $0.Channel>(
        'UpdateChannel',
        updateChannel_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateChannelRequest.fromBuffer(value),
        ($0.Channel value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteChannelRequest, $1.Empty>(
        'DeleteChannel',
        deleteChannel_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DeleteChannelRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetSubscribedChannelsRequest,
            $0.ChannelsResponse>(
        'GetSubscribedChannels',
        getSubscribedChannels_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetSubscribedChannelsRequest.fromBuffer(value),
        ($0.ChannelsResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetOwnedChannelsRequest, $0.ChannelsResponse>(
            'GetOwnedChannels',
            getOwnedChannels_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetOwnedChannelsRequest.fromBuffer(value),
            ($0.ChannelsResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.SearchChannelsRequest, $0.ChannelsResponse>(
            'SearchChannels',
            searchChannels_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.SearchChannelsRequest.fromBuffer(value),
            ($0.ChannelsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SubscribeRequest, $1.Empty>(
        'Subscribe',
        subscribe_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SubscribeRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UnsubscribeRequest, $1.Empty>(
        'Unsubscribe',
        unsubscribe_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UnsubscribeRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetSubscribersRequest, $0.SubscribersResponse>(
            'GetSubscribers',
            getSubscribers_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetSubscribersRequest.fromBuffer(value),
            ($0.SubscribersResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CheckSubscriptionRequest,
            $0.CheckSubscriptionResponse>(
        'CheckSubscription',
        checkSubscription_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CheckSubscriptionRequest.fromBuffer(value),
        ($0.CheckSubscriptionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AddAdminRequest, $1.Empty>(
        'AddAdmin',
        addAdmin_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.AddAdminRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RemoveAdminRequest, $1.Empty>(
        'RemoveAdmin',
        removeAdmin_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.RemoveAdminRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetAdminsRequest, $0.AdminsResponse>(
        'GetAdmins',
        getAdmins_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetAdminsRequest.fromBuffer(value),
        ($0.AdminsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PublishPostRequest, $0.ChannelPost>(
        'PublishPost',
        publishPost_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.PublishPostRequest.fromBuffer(value),
        ($0.ChannelPost value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetPostsRequest, $0.PostsResponse>(
        'GetPosts',
        getPosts_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetPostsRequest.fromBuffer(value),
        ($0.PostsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetPostRequest, $0.ChannelPost>(
        'GetPost',
        getPost_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetPostRequest.fromBuffer(value),
        ($0.ChannelPost value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.EditPostRequest, $0.ChannelPost>(
        'EditPost',
        editPost_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.EditPostRequest.fromBuffer(value),
        ($0.ChannelPost value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeletePostRequest, $1.Empty>(
        'DeletePost',
        deletePost_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DeletePostRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PinPostRequest, $1.Empty>(
        'PinPost',
        pinPost_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.PinPostRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UnpinPostRequest, $1.Empty>(
        'UnpinPost',
        unpinPost_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UnpinPostRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ChannelClientEvent, $0.ChannelServerEvent>(
            'StreamUpdates',
            streamUpdates,
            true,
            true,
            ($core.List<$core.int> value) =>
                $0.ChannelClientEvent.fromBuffer(value),
            ($0.ChannelServerEvent value) => value.writeToBuffer()));
  }
  $core.String get $name => 'channel.ChannelService';

  $async.Future<$0.Channel> createChannel_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.CreateChannelRequest> $request,
  ) async {
    return createChannel($call, await $request);
  }

  $async.Future<$0.Channel> createChannel(
    $grpc.ServiceCall call,
    $0.CreateChannelRequest request,
  );

  $async.Future<$0.Channel> getChannel_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.GetChannelRequest> $request,
  ) async {
    return getChannel($call, await $request);
  }

  $async.Future<$0.Channel> getChannel(
    $grpc.ServiceCall call,
    $0.GetChannelRequest request,
  );

  $async.Future<$0.Channel> updateChannel_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.UpdateChannelRequest> $request,
  ) async {
    return updateChannel($call, await $request);
  }

  $async.Future<$0.Channel> updateChannel(
    $grpc.ServiceCall call,
    $0.UpdateChannelRequest request,
  );

  $async.Future<$1.Empty> deleteChannel_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.DeleteChannelRequest> $request,
  ) async {
    return deleteChannel($call, await $request);
  }

  $async.Future<$1.Empty> deleteChannel(
    $grpc.ServiceCall call,
    $0.DeleteChannelRequest request,
  );

  $async.Future<$0.ChannelsResponse> getSubscribedChannels_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.GetSubscribedChannelsRequest> $request,
  ) async {
    return getSubscribedChannels($call, await $request);
  }

  $async.Future<$0.ChannelsResponse> getSubscribedChannels(
    $grpc.ServiceCall call,
    $0.GetSubscribedChannelsRequest request,
  );

  $async.Future<$0.ChannelsResponse> getOwnedChannels_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.GetOwnedChannelsRequest> $request,
  ) async {
    return getOwnedChannels($call, await $request);
  }

  $async.Future<$0.ChannelsResponse> getOwnedChannels(
    $grpc.ServiceCall call,
    $0.GetOwnedChannelsRequest request,
  );

  $async.Future<$0.ChannelsResponse> searchChannels_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.SearchChannelsRequest> $request,
  ) async {
    return searchChannels($call, await $request);
  }

  $async.Future<$0.ChannelsResponse> searchChannels(
    $grpc.ServiceCall call,
    $0.SearchChannelsRequest request,
  );

  $async.Future<$1.Empty> subscribe_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.SubscribeRequest> $request,
  ) async {
    return subscribe($call, await $request);
  }

  $async.Future<$1.Empty> subscribe(
    $grpc.ServiceCall call,
    $0.SubscribeRequest request,
  );

  $async.Future<$1.Empty> unsubscribe_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.UnsubscribeRequest> $request,
  ) async {
    return unsubscribe($call, await $request);
  }

  $async.Future<$1.Empty> unsubscribe(
    $grpc.ServiceCall call,
    $0.UnsubscribeRequest request,
  );

  $async.Future<$0.SubscribersResponse> getSubscribers_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.GetSubscribersRequest> $request,
  ) async {
    return getSubscribers($call, await $request);
  }

  $async.Future<$0.SubscribersResponse> getSubscribers(
    $grpc.ServiceCall call,
    $0.GetSubscribersRequest request,
  );

  $async.Future<$0.CheckSubscriptionResponse> checkSubscription_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.CheckSubscriptionRequest> $request,
  ) async {
    return checkSubscription($call, await $request);
  }

  $async.Future<$0.CheckSubscriptionResponse> checkSubscription(
    $grpc.ServiceCall call,
    $0.CheckSubscriptionRequest request,
  );

  $async.Future<$1.Empty> addAdmin_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.AddAdminRequest> $request,
  ) async {
    return addAdmin($call, await $request);
  }

  $async.Future<$1.Empty> addAdmin(
    $grpc.ServiceCall call,
    $0.AddAdminRequest request,
  );

  $async.Future<$1.Empty> removeAdmin_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.RemoveAdminRequest> $request,
  ) async {
    return removeAdmin($call, await $request);
  }

  $async.Future<$1.Empty> removeAdmin(
    $grpc.ServiceCall call,
    $0.RemoveAdminRequest request,
  );

  $async.Future<$0.AdminsResponse> getAdmins_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.GetAdminsRequest> $request,
  ) async {
    return getAdmins($call, await $request);
  }

  $async.Future<$0.AdminsResponse> getAdmins(
    $grpc.ServiceCall call,
    $0.GetAdminsRequest request,
  );

  $async.Future<$0.ChannelPost> publishPost_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.PublishPostRequest> $request,
  ) async {
    return publishPost($call, await $request);
  }

  $async.Future<$0.ChannelPost> publishPost(
    $grpc.ServiceCall call,
    $0.PublishPostRequest request,
  );

  $async.Future<$0.PostsResponse> getPosts_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.GetPostsRequest> $request,
  ) async {
    return getPosts($call, await $request);
  }

  $async.Future<$0.PostsResponse> getPosts(
    $grpc.ServiceCall call,
    $0.GetPostsRequest request,
  );

  $async.Future<$0.ChannelPost> getPost_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.GetPostRequest> $request,
  ) async {
    return getPost($call, await $request);
  }

  $async.Future<$0.ChannelPost> getPost(
    $grpc.ServiceCall call,
    $0.GetPostRequest request,
  );

  $async.Future<$0.ChannelPost> editPost_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.EditPostRequest> $request,
  ) async {
    return editPost($call, await $request);
  }

  $async.Future<$0.ChannelPost> editPost(
    $grpc.ServiceCall call,
    $0.EditPostRequest request,
  );

  $async.Future<$1.Empty> deletePost_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.DeletePostRequest> $request,
  ) async {
    return deletePost($call, await $request);
  }

  $async.Future<$1.Empty> deletePost(
    $grpc.ServiceCall call,
    $0.DeletePostRequest request,
  );

  $async.Future<$1.Empty> pinPost_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.PinPostRequest> $request,
  ) async {
    return pinPost($call, await $request);
  }

  $async.Future<$1.Empty> pinPost(
    $grpc.ServiceCall call,
    $0.PinPostRequest request,
  );

  $async.Future<$1.Empty> unpinPost_Pre(
    $grpc.ServiceCall $call,
    $async.Future<$0.UnpinPostRequest> $request,
  ) async {
    return unpinPost($call, await $request);
  }

  $async.Future<$1.Empty> unpinPost(
    $grpc.ServiceCall call,
    $0.UnpinPostRequest request,
  );

  $async.Stream<$0.ChannelServerEvent> streamUpdates(
    $grpc.ServiceCall call,
    $async.Stream<$0.ChannelClientEvent> request,
  );
}
