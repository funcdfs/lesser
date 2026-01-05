// This is a generated file - do not edit.
//
// Generated from chat/chat.proto.

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

import 'chat.pb.dart' as $0;

export 'chat.pb.dart';

/// ChatService 聊天服务
/// 处理会话管理、消息收发、实时通信
@$pb.GrpcServiceName('chat.ChatService')
class ChatServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  ChatServiceClient(super.channel, {super.options, super.interceptors});

  /// 获取用户的所有会话
  $grpc.ResponseFuture<$0.ConversationsResponse> getConversations(
    $0.GetConversationsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getConversations, request, options: options);
  }

  /// 根据 ID 获取单个会话
  $grpc.ResponseFuture<$0.Conversation> getConversation(
    $0.GetConversationRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getConversation, request, options: options);
  }

  /// 创建新会话
  $grpc.ResponseFuture<$0.Conversation> createConversation(
    $0.CreateConversationRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createConversation, request, options: options);
  }

  /// 获取会话中的消息
  $grpc.ResponseFuture<$0.MessagesResponse> getMessages(
    $0.GetMessagesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getMessages, request, options: options);
  }

  /// 发送消息到会话
  $grpc.ResponseFuture<$0.Message> sendMessage(
    $0.SendMessageRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$sendMessage, request, options: options);
  }

  /// 标记单条消息为已读
  $grpc.ResponseFuture<$0.ReadReceipt> markAsRead(
    $0.MarkAsReadRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$markAsRead, request, options: options);
  }

  /// 标记会话中所有消息为已读
  $grpc.ResponseFuture<$0.BatchReadReceipt> markConversationAsRead(
    $0.MarkConversationAsReadRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$markConversationAsRead, request,
        options: options);
  }

  /// 批量获取多个会话的未读数
  $grpc.ResponseFuture<$0.GetUnreadCountsResponse> getUnreadCounts(
    $0.GetUnreadCountsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getUnreadCounts, request, options: options);
  }

  /// 双向流：实时事件（替代 WebSocket）
  /// 客户端通过此流订阅会话、发送消息、接收实时事件
  $grpc.ResponseStream<$0.ServerEvent> streamEvents(
    $async.Stream<$0.ClientEvent> request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$streamEvents, request, options: options);
  }

  // method descriptors

  static final _$getConversations =
      $grpc.ClientMethod<$0.GetConversationsRequest, $0.ConversationsResponse>(
          '/chat.ChatService/GetConversations',
          ($0.GetConversationsRequest value) => value.writeToBuffer(),
          $0.ConversationsResponse.fromBuffer);
  static final _$getConversation =
      $grpc.ClientMethod<$0.GetConversationRequest, $0.Conversation>(
          '/chat.ChatService/GetConversation',
          ($0.GetConversationRequest value) => value.writeToBuffer(),
          $0.Conversation.fromBuffer);
  static final _$createConversation =
      $grpc.ClientMethod<$0.CreateConversationRequest, $0.Conversation>(
          '/chat.ChatService/CreateConversation',
          ($0.CreateConversationRequest value) => value.writeToBuffer(),
          $0.Conversation.fromBuffer);
  static final _$getMessages =
      $grpc.ClientMethod<$0.GetMessagesRequest, $0.MessagesResponse>(
          '/chat.ChatService/GetMessages',
          ($0.GetMessagesRequest value) => value.writeToBuffer(),
          $0.MessagesResponse.fromBuffer);
  static final _$sendMessage =
      $grpc.ClientMethod<$0.SendMessageRequest, $0.Message>(
          '/chat.ChatService/SendMessage',
          ($0.SendMessageRequest value) => value.writeToBuffer(),
          $0.Message.fromBuffer);
  static final _$markAsRead =
      $grpc.ClientMethod<$0.MarkAsReadRequest, $0.ReadReceipt>(
          '/chat.ChatService/MarkAsRead',
          ($0.MarkAsReadRequest value) => value.writeToBuffer(),
          $0.ReadReceipt.fromBuffer);
  static final _$markConversationAsRead =
      $grpc.ClientMethod<$0.MarkConversationAsReadRequest, $0.BatchReadReceipt>(
          '/chat.ChatService/MarkConversationAsRead',
          ($0.MarkConversationAsReadRequest value) => value.writeToBuffer(),
          $0.BatchReadReceipt.fromBuffer);
  static final _$getUnreadCounts =
      $grpc.ClientMethod<$0.GetUnreadCountsRequest, $0.GetUnreadCountsResponse>(
          '/chat.ChatService/GetUnreadCounts',
          ($0.GetUnreadCountsRequest value) => value.writeToBuffer(),
          $0.GetUnreadCountsResponse.fromBuffer);
  static final _$streamEvents =
      $grpc.ClientMethod<$0.ClientEvent, $0.ServerEvent>(
          '/chat.ChatService/StreamEvents',
          ($0.ClientEvent value) => value.writeToBuffer(),
          $0.ServerEvent.fromBuffer);
}

@$pb.GrpcServiceName('chat.ChatService')
abstract class ChatServiceBase extends $grpc.Service {
  $core.String get $name => 'chat.ChatService';

  ChatServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.GetConversationsRequest,
            $0.ConversationsResponse>(
        'GetConversations',
        getConversations_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetConversationsRequest.fromBuffer(value),
        ($0.ConversationsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetConversationRequest, $0.Conversation>(
        'GetConversation',
        getConversation_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetConversationRequest.fromBuffer(value),
        ($0.Conversation value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.CreateConversationRequest, $0.Conversation>(
            'CreateConversation',
            createConversation_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.CreateConversationRequest.fromBuffer(value),
            ($0.Conversation value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetMessagesRequest, $0.MessagesResponse>(
        'GetMessages',
        getMessages_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetMessagesRequest.fromBuffer(value),
        ($0.MessagesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SendMessageRequest, $0.Message>(
        'SendMessage',
        sendMessage_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SendMessageRequest.fromBuffer(value),
        ($0.Message value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.MarkAsReadRequest, $0.ReadReceipt>(
        'MarkAsRead',
        markAsRead_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.MarkAsReadRequest.fromBuffer(value),
        ($0.ReadReceipt value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.MarkConversationAsReadRequest,
            $0.BatchReadReceipt>(
        'MarkConversationAsRead',
        markConversationAsRead_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.MarkConversationAsReadRequest.fromBuffer(value),
        ($0.BatchReadReceipt value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetUnreadCountsRequest,
            $0.GetUnreadCountsResponse>(
        'GetUnreadCounts',
        getUnreadCounts_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetUnreadCountsRequest.fromBuffer(value),
        ($0.GetUnreadCountsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ClientEvent, $0.ServerEvent>(
        'StreamEvents',
        streamEvents,
        true,
        true,
        ($core.List<$core.int> value) => $0.ClientEvent.fromBuffer(value),
        ($0.ServerEvent value) => value.writeToBuffer()));
  }

  $async.Future<$0.ConversationsResponse> getConversations_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetConversationsRequest> $request) async {
    return getConversations($call, await $request);
  }

  $async.Future<$0.ConversationsResponse> getConversations(
      $grpc.ServiceCall call, $0.GetConversationsRequest request);

  $async.Future<$0.Conversation> getConversation_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetConversationRequest> $request) async {
    return getConversation($call, await $request);
  }

  $async.Future<$0.Conversation> getConversation(
      $grpc.ServiceCall call, $0.GetConversationRequest request);

  $async.Future<$0.Conversation> createConversation_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CreateConversationRequest> $request) async {
    return createConversation($call, await $request);
  }

  $async.Future<$0.Conversation> createConversation(
      $grpc.ServiceCall call, $0.CreateConversationRequest request);

  $async.Future<$0.MessagesResponse> getMessages_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetMessagesRequest> $request) async {
    return getMessages($call, await $request);
  }

  $async.Future<$0.MessagesResponse> getMessages(
      $grpc.ServiceCall call, $0.GetMessagesRequest request);

  $async.Future<$0.Message> sendMessage_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SendMessageRequest> $request) async {
    return sendMessage($call, await $request);
  }

  $async.Future<$0.Message> sendMessage(
      $grpc.ServiceCall call, $0.SendMessageRequest request);

  $async.Future<$0.ReadReceipt> markAsRead_Pre($grpc.ServiceCall $call,
      $async.Future<$0.MarkAsReadRequest> $request) async {
    return markAsRead($call, await $request);
  }

  $async.Future<$0.ReadReceipt> markAsRead(
      $grpc.ServiceCall call, $0.MarkAsReadRequest request);

  $async.Future<$0.BatchReadReceipt> markConversationAsRead_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.MarkConversationAsReadRequest> $request) async {
    return markConversationAsRead($call, await $request);
  }

  $async.Future<$0.BatchReadReceipt> markConversationAsRead(
      $grpc.ServiceCall call, $0.MarkConversationAsReadRequest request);

  $async.Future<$0.GetUnreadCountsResponse> getUnreadCounts_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetUnreadCountsRequest> $request) async {
    return getUnreadCounts($call, await $request);
  }

  $async.Future<$0.GetUnreadCountsResponse> getUnreadCounts(
      $grpc.ServiceCall call, $0.GetUnreadCountsRequest request);

  $async.Stream<$0.ServerEvent> streamEvents(
      $grpc.ServiceCall call, $async.Stream<$0.ClientEvent> request);
}
