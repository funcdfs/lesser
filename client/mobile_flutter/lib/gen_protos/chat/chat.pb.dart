// This is a generated file - do not edit.
//
// Generated from chat/chat.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import '../common/common.pb.dart' as $1;
import 'chat.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'chat.pbenum.dart';

/// Conversation 会话实体
class Conversation extends $pb.GeneratedMessage {
  factory Conversation({
    $core.String? id,
    ConversationType? type,
    $core.String? name,
    $core.Iterable<$core.String>? memberIds,
    $core.String? creatorId,
    $1.Timestamp? createdAt,
    Message? lastMessage,
    $fixnum.Int64? unreadCount,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (type != null) result.type = type;
    if (name != null) result.name = name;
    if (memberIds != null) result.memberIds.addAll(memberIds);
    if (creatorId != null) result.creatorId = creatorId;
    if (createdAt != null) result.createdAt = createdAt;
    if (lastMessage != null) result.lastMessage = lastMessage;
    if (unreadCount != null) result.unreadCount = unreadCount;
    return result;
  }

  Conversation._();

  factory Conversation.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Conversation.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Conversation',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aE<ConversationType>(2, _omitFieldNames ? '' : 'type',
        enumValues: ConversationType.values)
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..pPS(4, _omitFieldNames ? '' : 'memberIds')
    ..aOS(5, _omitFieldNames ? '' : 'creatorId')
    ..aOM<$1.Timestamp>(6, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $1.Timestamp.create)
    ..aOM<Message>(7, _omitFieldNames ? '' : 'lastMessage',
        subBuilder: Message.create)
    ..aInt64(8, _omitFieldNames ? '' : 'unreadCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Conversation clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Conversation copyWith(void Function(Conversation) updates) =>
      super.copyWith((message) => updates(message as Conversation))
          as Conversation;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Conversation create() => Conversation._();
  @$core.override
  Conversation createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Conversation getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Conversation>(create);
  static Conversation? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  ConversationType get type => $_getN(1);
  @$pb.TagNumber(2)
  set type(ConversationType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get memberIds => $_getList(3);

  @$pb.TagNumber(5)
  $core.String get creatorId => $_getSZ(4);
  @$pb.TagNumber(5)
  set creatorId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCreatorId() => $_has(4);
  @$pb.TagNumber(5)
  void clearCreatorId() => $_clearField(5);

  @$pb.TagNumber(6)
  $1.Timestamp get createdAt => $_getN(5);
  @$pb.TagNumber(6)
  set createdAt($1.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasCreatedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearCreatedAt() => $_clearField(6);
  @$pb.TagNumber(6)
  $1.Timestamp ensureCreatedAt() => $_ensure(5);

  @$pb.TagNumber(7)
  Message get lastMessage => $_getN(6);
  @$pb.TagNumber(7)
  set lastMessage(Message value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasLastMessage() => $_has(6);
  @$pb.TagNumber(7)
  void clearLastMessage() => $_clearField(7);
  @$pb.TagNumber(7)
  Message ensureLastMessage() => $_ensure(6);

  @$pb.TagNumber(8)
  $fixnum.Int64 get unreadCount => $_getI64(7);
  @$pb.TagNumber(8)
  set unreadCount($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasUnreadCount() => $_has(7);
  @$pb.TagNumber(8)
  void clearUnreadCount() => $_clearField(8);
}

/// Message 消息实体
class Message extends $pb.GeneratedMessage {
  factory Message({
    $core.String? id,
    $core.String? conversationId,
    $core.String? senderId,
    $core.String? content,
    $core.String? messageType,
    $1.Timestamp? createdAt,
    $1.Timestamp? readAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (conversationId != null) result.conversationId = conversationId;
    if (senderId != null) result.senderId = senderId;
    if (content != null) result.content = content;
    if (messageType != null) result.messageType = messageType;
    if (createdAt != null) result.createdAt = createdAt;
    if (readAt != null) result.readAt = readAt;
    return result;
  }

  Message._();

  factory Message.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Message.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Message',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'conversationId')
    ..aOS(3, _omitFieldNames ? '' : 'senderId')
    ..aOS(4, _omitFieldNames ? '' : 'content')
    ..aOS(5, _omitFieldNames ? '' : 'messageType')
    ..aOM<$1.Timestamp>(6, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $1.Timestamp.create)
    ..aOM<$1.Timestamp>(7, _omitFieldNames ? '' : 'readAt',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Message clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Message copyWith(void Function(Message) updates) =>
      super.copyWith((message) => updates(message as Message)) as Message;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Message create() => Message._();
  @$core.override
  Message createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Message getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Message>(create);
  static Message? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get conversationId => $_getSZ(1);
  @$pb.TagNumber(2)
  set conversationId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConversationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearConversationId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get senderId => $_getSZ(2);
  @$pb.TagNumber(3)
  set senderId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSenderId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSenderId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get content => $_getSZ(3);
  @$pb.TagNumber(4)
  set content($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasContent() => $_has(3);
  @$pb.TagNumber(4)
  void clearContent() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get messageType => $_getSZ(4);
  @$pb.TagNumber(5)
  set messageType($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMessageType() => $_has(4);
  @$pb.TagNumber(5)
  void clearMessageType() => $_clearField(5);

  @$pb.TagNumber(6)
  $1.Timestamp get createdAt => $_getN(5);
  @$pb.TagNumber(6)
  set createdAt($1.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasCreatedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearCreatedAt() => $_clearField(6);
  @$pb.TagNumber(6)
  $1.Timestamp ensureCreatedAt() => $_ensure(5);

  @$pb.TagNumber(7)
  $1.Timestamp get readAt => $_getN(6);
  @$pb.TagNumber(7)
  set readAt($1.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasReadAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearReadAt() => $_clearField(7);
  @$pb.TagNumber(7)
  $1.Timestamp ensureReadAt() => $_ensure(6);
}

/// ReadReceipt 单条消息已读回执
class ReadReceipt extends $pb.GeneratedMessage {
  factory ReadReceipt({
    $core.String? messageId,
    $core.String? conversationId,
    $core.String? readerId,
    $1.Timestamp? readAt,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (conversationId != null) result.conversationId = conversationId;
    if (readerId != null) result.readerId = readerId;
    if (readAt != null) result.readAt = readAt;
    return result;
  }

  ReadReceipt._();

  factory ReadReceipt.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ReadReceipt.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReadReceipt',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messageId')
    ..aOS(2, _omitFieldNames ? '' : 'conversationId')
    ..aOS(3, _omitFieldNames ? '' : 'readerId')
    ..aOM<$1.Timestamp>(4, _omitFieldNames ? '' : 'readAt',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReadReceipt clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReadReceipt copyWith(void Function(ReadReceipt) updates) =>
      super.copyWith((message) => updates(message as ReadReceipt))
          as ReadReceipt;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReadReceipt create() => ReadReceipt._();
  @$core.override
  ReadReceipt createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ReadReceipt getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReadReceipt>(create);
  static ReadReceipt? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get messageId => $_getSZ(0);
  @$pb.TagNumber(1)
  set messageId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get conversationId => $_getSZ(1);
  @$pb.TagNumber(2)
  set conversationId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConversationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearConversationId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get readerId => $_getSZ(2);
  @$pb.TagNumber(3)
  set readerId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReaderId() => $_has(2);
  @$pb.TagNumber(3)
  void clearReaderId() => $_clearField(3);

  @$pb.TagNumber(4)
  $1.Timestamp get readAt => $_getN(3);
  @$pb.TagNumber(4)
  set readAt($1.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasReadAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearReadAt() => $_clearField(4);
  @$pb.TagNumber(4)
  $1.Timestamp ensureReadAt() => $_ensure(3);
}

/// BatchReadReceipt 批量已读回执
class BatchReadReceipt extends $pb.GeneratedMessage {
  factory BatchReadReceipt({
    $core.String? conversationId,
    $core.String? readerId,
    $core.Iterable<$core.String>? messageIds,
    $1.Timestamp? readAt,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (readerId != null) result.readerId = readerId;
    if (messageIds != null) result.messageIds.addAll(messageIds);
    if (readAt != null) result.readAt = readAt;
    return result;
  }

  BatchReadReceipt._();

  factory BatchReadReceipt.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BatchReadReceipt.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BatchReadReceipt',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOS(2, _omitFieldNames ? '' : 'readerId')
    ..pPS(3, _omitFieldNames ? '' : 'messageIds')
    ..aOM<$1.Timestamp>(4, _omitFieldNames ? '' : 'readAt',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BatchReadReceipt clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BatchReadReceipt copyWith(void Function(BatchReadReceipt) updates) =>
      super.copyWith((message) => updates(message as BatchReadReceipt))
          as BatchReadReceipt;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BatchReadReceipt create() => BatchReadReceipt._();
  @$core.override
  BatchReadReceipt createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BatchReadReceipt getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BatchReadReceipt>(create);
  static BatchReadReceipt? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get readerId => $_getSZ(1);
  @$pb.TagNumber(2)
  set readerId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReaderId() => $_has(1);
  @$pb.TagNumber(2)
  void clearReaderId() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get messageIds => $_getList(2);

  @$pb.TagNumber(4)
  $1.Timestamp get readAt => $_getN(3);
  @$pb.TagNumber(4)
  set readAt($1.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasReadAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearReadAt() => $_clearField(4);
  @$pb.TagNumber(4)
  $1.Timestamp ensureReadAt() => $_ensure(3);
}

/// GetConversationsRequest 获取会话列表请求
class GetConversationsRequest extends $pb.GeneratedMessage {
  factory GetConversationsRequest({
    $core.String? userId,
    $1.Pagination? pagination,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (pagination != null) result.pagination = pagination;
    return result;
  }

  GetConversationsRequest._();

  factory GetConversationsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetConversationsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetConversationsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOM<$1.Pagination>(2, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetConversationsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetConversationsRequest copyWith(
          void Function(GetConversationsRequest) updates) =>
      super.copyWith((message) => updates(message as GetConversationsRequest))
          as GetConversationsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetConversationsRequest create() => GetConversationsRequest._();
  @$core.override
  GetConversationsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetConversationsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetConversationsRequest>(create);
  static GetConversationsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.Pagination get pagination => $_getN(1);
  @$pb.TagNumber(2)
  set pagination($1.Pagination value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPagination() => $_has(1);
  @$pb.TagNumber(2)
  void clearPagination() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.Pagination ensurePagination() => $_ensure(1);
}

/// ConversationsResponse 会话列表响应
class ConversationsResponse extends $pb.GeneratedMessage {
  factory ConversationsResponse({
    $core.Iterable<Conversation>? conversations,
    $1.Pagination? pagination,
  }) {
    final result = create();
    if (conversations != null) result.conversations.addAll(conversations);
    if (pagination != null) result.pagination = pagination;
    return result;
  }

  ConversationsResponse._();

  factory ConversationsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConversationsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConversationsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..pPM<Conversation>(1, _omitFieldNames ? '' : 'conversations',
        subBuilder: Conversation.create)
    ..aOM<$1.Pagination>(2, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationsResponse copyWith(
          void Function(ConversationsResponse) updates) =>
      super.copyWith((message) => updates(message as ConversationsResponse))
          as ConversationsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationsResponse create() => ConversationsResponse._();
  @$core.override
  ConversationsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ConversationsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConversationsResponse>(create);
  static ConversationsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Conversation> get conversations => $_getList(0);

  @$pb.TagNumber(2)
  $1.Pagination get pagination => $_getN(1);
  @$pb.TagNumber(2)
  set pagination($1.Pagination value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPagination() => $_has(1);
  @$pb.TagNumber(2)
  void clearPagination() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.Pagination ensurePagination() => $_ensure(1);
}

/// GetConversationRequest 获取单个会话请求
class GetConversationRequest extends $pb.GeneratedMessage {
  factory GetConversationRequest({
    $core.String? conversationId,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    return result;
  }

  GetConversationRequest._();

  factory GetConversationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetConversationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetConversationRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetConversationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetConversationRequest copyWith(
          void Function(GetConversationRequest) updates) =>
      super.copyWith((message) => updates(message as GetConversationRequest))
          as GetConversationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetConversationRequest create() => GetConversationRequest._();
  @$core.override
  GetConversationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetConversationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetConversationRequest>(create);
  static GetConversationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);
}

/// CreateConversationRequest 创建会话请求
class CreateConversationRequest extends $pb.GeneratedMessage {
  factory CreateConversationRequest({
    ConversationType? type,
    $core.String? name,
    $core.Iterable<$core.String>? memberIds,
    $core.String? creatorId,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (name != null) result.name = name;
    if (memberIds != null) result.memberIds.addAll(memberIds);
    if (creatorId != null) result.creatorId = creatorId;
    return result;
  }

  CreateConversationRequest._();

  factory CreateConversationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateConversationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateConversationRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aE<ConversationType>(1, _omitFieldNames ? '' : 'type',
        enumValues: ConversationType.values)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..pPS(3, _omitFieldNames ? '' : 'memberIds')
    ..aOS(4, _omitFieldNames ? '' : 'creatorId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateConversationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateConversationRequest copyWith(
          void Function(CreateConversationRequest) updates) =>
      super.copyWith((message) => updates(message as CreateConversationRequest))
          as CreateConversationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateConversationRequest create() => CreateConversationRequest._();
  @$core.override
  CreateConversationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateConversationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateConversationRequest>(create);
  static CreateConversationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  ConversationType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(ConversationType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get memberIds => $_getList(2);

  @$pb.TagNumber(4)
  $core.String get creatorId => $_getSZ(3);
  @$pb.TagNumber(4)
  set creatorId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCreatorId() => $_has(3);
  @$pb.TagNumber(4)
  void clearCreatorId() => $_clearField(4);
}

/// GetMessagesRequest 获取消息列表请求
class GetMessagesRequest extends $pb.GeneratedMessage {
  factory GetMessagesRequest({
    $core.String? conversationId,
    $1.Pagination? pagination,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (pagination != null) result.pagination = pagination;
    return result;
  }

  GetMessagesRequest._();

  factory GetMessagesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMessagesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMessagesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOM<$1.Pagination>(2, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMessagesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMessagesRequest copyWith(void Function(GetMessagesRequest) updates) =>
      super.copyWith((message) => updates(message as GetMessagesRequest))
          as GetMessagesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMessagesRequest create() => GetMessagesRequest._();
  @$core.override
  GetMessagesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetMessagesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMessagesRequest>(create);
  static GetMessagesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.Pagination get pagination => $_getN(1);
  @$pb.TagNumber(2)
  set pagination($1.Pagination value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPagination() => $_has(1);
  @$pb.TagNumber(2)
  void clearPagination() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.Pagination ensurePagination() => $_ensure(1);
}

/// MessagesResponse 消息列表响应
class MessagesResponse extends $pb.GeneratedMessage {
  factory MessagesResponse({
    $core.Iterable<Message>? messages,
    $1.Pagination? pagination,
  }) {
    final result = create();
    if (messages != null) result.messages.addAll(messages);
    if (pagination != null) result.pagination = pagination;
    return result;
  }

  MessagesResponse._();

  factory MessagesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MessagesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MessagesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..pPM<Message>(1, _omitFieldNames ? '' : 'messages',
        subBuilder: Message.create)
    ..aOM<$1.Pagination>(2, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessagesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessagesResponse copyWith(void Function(MessagesResponse) updates) =>
      super.copyWith((message) => updates(message as MessagesResponse))
          as MessagesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessagesResponse create() => MessagesResponse._();
  @$core.override
  MessagesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MessagesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MessagesResponse>(create);
  static MessagesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Message> get messages => $_getList(0);

  @$pb.TagNumber(2)
  $1.Pagination get pagination => $_getN(1);
  @$pb.TagNumber(2)
  set pagination($1.Pagination value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPagination() => $_has(1);
  @$pb.TagNumber(2)
  void clearPagination() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.Pagination ensurePagination() => $_ensure(1);
}

/// SendMessageRequest 发送消息请求
class SendMessageRequest extends $pb.GeneratedMessage {
  factory SendMessageRequest({
    $core.String? conversationId,
    $core.String? senderId,
    $core.String? content,
    $core.String? messageType,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (senderId != null) result.senderId = senderId;
    if (content != null) result.content = content;
    if (messageType != null) result.messageType = messageType;
    return result;
  }

  SendMessageRequest._();

  factory SendMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SendMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendMessageRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOS(2, _omitFieldNames ? '' : 'senderId')
    ..aOS(3, _omitFieldNames ? '' : 'content')
    ..aOS(4, _omitFieldNames ? '' : 'messageType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendMessageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendMessageRequest copyWith(void Function(SendMessageRequest) updates) =>
      super.copyWith((message) => updates(message as SendMessageRequest))
          as SendMessageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendMessageRequest create() => SendMessageRequest._();
  @$core.override
  SendMessageRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SendMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendMessageRequest>(create);
  static SendMessageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get senderId => $_getSZ(1);
  @$pb.TagNumber(2)
  set senderId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSenderId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSenderId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get content => $_getSZ(2);
  @$pb.TagNumber(3)
  set content($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasContent() => $_has(2);
  @$pb.TagNumber(3)
  void clearContent() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get messageType => $_getSZ(3);
  @$pb.TagNumber(4)
  set messageType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMessageType() => $_has(3);
  @$pb.TagNumber(4)
  void clearMessageType() => $_clearField(4);
}

/// MarkAsReadRequest 标记单条消息已读请求
class MarkAsReadRequest extends $pb.GeneratedMessage {
  factory MarkAsReadRequest({
    $core.String? messageId,
    $core.String? userId,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (userId != null) result.userId = userId;
    return result;
  }

  MarkAsReadRequest._();

  factory MarkAsReadRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MarkAsReadRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MarkAsReadRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messageId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkAsReadRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkAsReadRequest copyWith(void Function(MarkAsReadRequest) updates) =>
      super.copyWith((message) => updates(message as MarkAsReadRequest))
          as MarkAsReadRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MarkAsReadRequest create() => MarkAsReadRequest._();
  @$core.override
  MarkAsReadRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MarkAsReadRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MarkAsReadRequest>(create);
  static MarkAsReadRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get messageId => $_getSZ(0);
  @$pb.TagNumber(1)
  set messageId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);
}

/// MarkConversationAsReadRequest 标记会话所有消息已读请求
class MarkConversationAsReadRequest extends $pb.GeneratedMessage {
  factory MarkConversationAsReadRequest({
    $core.String? conversationId,
    $core.String? userId,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (userId != null) result.userId = userId;
    return result;
  }

  MarkConversationAsReadRequest._();

  factory MarkConversationAsReadRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MarkConversationAsReadRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MarkConversationAsReadRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkConversationAsReadRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkConversationAsReadRequest copyWith(
          void Function(MarkConversationAsReadRequest) updates) =>
      super.copyWith(
              (message) => updates(message as MarkConversationAsReadRequest))
          as MarkConversationAsReadRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MarkConversationAsReadRequest create() =>
      MarkConversationAsReadRequest._();
  @$core.override
  MarkConversationAsReadRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MarkConversationAsReadRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MarkConversationAsReadRequest>(create);
  static MarkConversationAsReadRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);
}

/// GetUnreadCountsRequest 批量获取未读数请求
class GetUnreadCountsRequest extends $pb.GeneratedMessage {
  factory GetUnreadCountsRequest({
    $core.String? userId,
    $core.Iterable<$core.String>? conversationIds,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (conversationIds != null) result.conversationIds.addAll(conversationIds);
    return result;
  }

  GetUnreadCountsRequest._();

  factory GetUnreadCountsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetUnreadCountsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetUnreadCountsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..pPS(2, _omitFieldNames ? '' : 'conversationIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUnreadCountsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUnreadCountsRequest copyWith(
          void Function(GetUnreadCountsRequest) updates) =>
      super.copyWith((message) => updates(message as GetUnreadCountsRequest))
          as GetUnreadCountsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetUnreadCountsRequest create() => GetUnreadCountsRequest._();
  @$core.override
  GetUnreadCountsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetUnreadCountsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetUnreadCountsRequest>(create);
  static GetUnreadCountsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get conversationIds => $_getList(1);
}

/// UnreadCount 单个会话的未读数
class UnreadCount extends $pb.GeneratedMessage {
  factory UnreadCount({
    $core.String? conversationId,
    $fixnum.Int64? count,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (count != null) result.count = count;
    return result;
  }

  UnreadCount._();

  factory UnreadCount.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UnreadCount.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UnreadCount',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aInt64(2, _omitFieldNames ? '' : 'count')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnreadCount clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnreadCount copyWith(void Function(UnreadCount) updates) =>
      super.copyWith((message) => updates(message as UnreadCount))
          as UnreadCount;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnreadCount create() => UnreadCount._();
  @$core.override
  UnreadCount createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UnreadCount getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UnreadCount>(create);
  static UnreadCount? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get count => $_getI64(1);
  @$pb.TagNumber(2)
  set count($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearCount() => $_clearField(2);
}

/// GetUnreadCountsResponse 批量获取未读数响应
class GetUnreadCountsResponse extends $pb.GeneratedMessage {
  factory GetUnreadCountsResponse({
    $core.Iterable<UnreadCount>? unreadCounts,
  }) {
    final result = create();
    if (unreadCounts != null) result.unreadCounts.addAll(unreadCounts);
    return result;
  }

  GetUnreadCountsResponse._();

  factory GetUnreadCountsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetUnreadCountsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetUnreadCountsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..pPM<UnreadCount>(1, _omitFieldNames ? '' : 'unreadCounts',
        subBuilder: UnreadCount.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUnreadCountsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUnreadCountsResponse copyWith(
          void Function(GetUnreadCountsResponse) updates) =>
      super.copyWith((message) => updates(message as GetUnreadCountsResponse))
          as GetUnreadCountsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetUnreadCountsResponse create() => GetUnreadCountsResponse._();
  @$core.override
  GetUnreadCountsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetUnreadCountsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetUnreadCountsResponse>(create);
  static GetUnreadCountsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<UnreadCount> get unreadCounts => $_getList(0);
}

enum ClientEvent_Event {
  subscribe,
  unsubscribe,
  sendMessage,
  ping,
  typing,
  notSet
}

/// ClientEvent 客户端发送的事件
class ClientEvent extends $pb.GeneratedMessage {
  factory ClientEvent({
    SubscribeRequest? subscribe,
    UnsubscribeRequest? unsubscribe,
    SendMessageEvent? sendMessage,
    PingEvent? ping,
    TypingEvent? typing,
  }) {
    final result = create();
    if (subscribe != null) result.subscribe = subscribe;
    if (unsubscribe != null) result.unsubscribe = unsubscribe;
    if (sendMessage != null) result.sendMessage = sendMessage;
    if (ping != null) result.ping = ping;
    if (typing != null) result.typing = typing;
    return result;
  }

  ClientEvent._();

  factory ClientEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ClientEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, ClientEvent_Event> _ClientEvent_EventByTag =
      {
    1: ClientEvent_Event.subscribe,
    2: ClientEvent_Event.unsubscribe,
    3: ClientEvent_Event.sendMessage,
    4: ClientEvent_Event.ping,
    5: ClientEvent_Event.typing,
    0: ClientEvent_Event.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 4, 5])
    ..aOM<SubscribeRequest>(1, _omitFieldNames ? '' : 'subscribe',
        subBuilder: SubscribeRequest.create)
    ..aOM<UnsubscribeRequest>(2, _omitFieldNames ? '' : 'unsubscribe',
        subBuilder: UnsubscribeRequest.create)
    ..aOM<SendMessageEvent>(3, _omitFieldNames ? '' : 'sendMessage',
        subBuilder: SendMessageEvent.create)
    ..aOM<PingEvent>(4, _omitFieldNames ? '' : 'ping',
        subBuilder: PingEvent.create)
    ..aOM<TypingEvent>(5, _omitFieldNames ? '' : 'typing',
        subBuilder: TypingEvent.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientEvent copyWith(void Function(ClientEvent) updates) =>
      super.copyWith((message) => updates(message as ClientEvent))
          as ClientEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientEvent create() => ClientEvent._();
  @$core.override
  ClientEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ClientEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientEvent>(create);
  static ClientEvent? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  ClientEvent_Event whichEvent() => _ClientEvent_EventByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  void clearEvent() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  SubscribeRequest get subscribe => $_getN(0);
  @$pb.TagNumber(1)
  set subscribe(SubscribeRequest value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSubscribe() => $_has(0);
  @$pb.TagNumber(1)
  void clearSubscribe() => $_clearField(1);
  @$pb.TagNumber(1)
  SubscribeRequest ensureSubscribe() => $_ensure(0);

  @$pb.TagNumber(2)
  UnsubscribeRequest get unsubscribe => $_getN(1);
  @$pb.TagNumber(2)
  set unsubscribe(UnsubscribeRequest value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasUnsubscribe() => $_has(1);
  @$pb.TagNumber(2)
  void clearUnsubscribe() => $_clearField(2);
  @$pb.TagNumber(2)
  UnsubscribeRequest ensureUnsubscribe() => $_ensure(1);

  @$pb.TagNumber(3)
  SendMessageEvent get sendMessage => $_getN(2);
  @$pb.TagNumber(3)
  set sendMessage(SendMessageEvent value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasSendMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearSendMessage() => $_clearField(3);
  @$pb.TagNumber(3)
  SendMessageEvent ensureSendMessage() => $_ensure(2);

  @$pb.TagNumber(4)
  PingEvent get ping => $_getN(3);
  @$pb.TagNumber(4)
  set ping(PingEvent value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasPing() => $_has(3);
  @$pb.TagNumber(4)
  void clearPing() => $_clearField(4);
  @$pb.TagNumber(4)
  PingEvent ensurePing() => $_ensure(3);

  @$pb.TagNumber(5)
  TypingEvent get typing => $_getN(4);
  @$pb.TagNumber(5)
  set typing(TypingEvent value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasTyping() => $_has(4);
  @$pb.TagNumber(5)
  void clearTyping() => $_clearField(5);
  @$pb.TagNumber(5)
  TypingEvent ensureTyping() => $_ensure(4);
}

/// SubscribeRequest 订阅会话请求
class SubscribeRequest extends $pb.GeneratedMessage {
  factory SubscribeRequest({
    $core.String? conversationId,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    return result;
  }

  SubscribeRequest._();

  factory SubscribeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SubscribeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubscribeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeRequest copyWith(void Function(SubscribeRequest) updates) =>
      super.copyWith((message) => updates(message as SubscribeRequest))
          as SubscribeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubscribeRequest create() => SubscribeRequest._();
  @$core.override
  SubscribeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SubscribeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubscribeRequest>(create);
  static SubscribeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);
}

/// UnsubscribeRequest 取消订阅请求
class UnsubscribeRequest extends $pb.GeneratedMessage {
  factory UnsubscribeRequest({
    $core.String? conversationId,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    return result;
  }

  UnsubscribeRequest._();

  factory UnsubscribeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UnsubscribeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UnsubscribeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnsubscribeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnsubscribeRequest copyWith(void Function(UnsubscribeRequest) updates) =>
      super.copyWith((message) => updates(message as UnsubscribeRequest))
          as UnsubscribeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnsubscribeRequest create() => UnsubscribeRequest._();
  @$core.override
  UnsubscribeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UnsubscribeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UnsubscribeRequest>(create);
  static UnsubscribeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);
}

/// SendMessageEvent 通过流发送消息事件
class SendMessageEvent extends $pb.GeneratedMessage {
  factory SendMessageEvent({
    $core.String? conversationId,
    $core.String? content,
    $core.String? messageType,
    $core.String? clientMessageId,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (content != null) result.content = content;
    if (messageType != null) result.messageType = messageType;
    if (clientMessageId != null) result.clientMessageId = clientMessageId;
    return result;
  }

  SendMessageEvent._();

  factory SendMessageEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SendMessageEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendMessageEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOS(2, _omitFieldNames ? '' : 'content')
    ..aOS(3, _omitFieldNames ? '' : 'messageType')
    ..aOS(4, _omitFieldNames ? '' : 'clientMessageId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendMessageEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendMessageEvent copyWith(void Function(SendMessageEvent) updates) =>
      super.copyWith((message) => updates(message as SendMessageEvent))
          as SendMessageEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendMessageEvent create() => SendMessageEvent._();
  @$core.override
  SendMessageEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SendMessageEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendMessageEvent>(create);
  static SendMessageEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get content => $_getSZ(1);
  @$pb.TagNumber(2)
  set content($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasContent() => $_has(1);
  @$pb.TagNumber(2)
  void clearContent() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get messageType => $_getSZ(2);
  @$pb.TagNumber(3)
  set messageType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMessageType() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessageType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get clientMessageId => $_getSZ(3);
  @$pb.TagNumber(4)
  set clientMessageId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasClientMessageId() => $_has(3);
  @$pb.TagNumber(4)
  void clearClientMessageId() => $_clearField(4);
}

/// PingEvent 心跳事件
class PingEvent extends $pb.GeneratedMessage {
  factory PingEvent() => create();

  PingEvent._();

  factory PingEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PingEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PingEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PingEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PingEvent copyWith(void Function(PingEvent) updates) =>
      super.copyWith((message) => updates(message as PingEvent)) as PingEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PingEvent create() => PingEvent._();
  @$core.override
  PingEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PingEvent getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PingEvent>(create);
  static PingEvent? _defaultInstance;
}

/// TypingEvent 正在输入事件
class TypingEvent extends $pb.GeneratedMessage {
  factory TypingEvent({
    $core.String? conversationId,
    $core.bool? isTyping,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (isTyping != null) result.isTyping = isTyping;
    return result;
  }

  TypingEvent._();

  factory TypingEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TypingEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TypingEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOB(2, _omitFieldNames ? '' : 'isTyping')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TypingEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TypingEvent copyWith(void Function(TypingEvent) updates) =>
      super.copyWith((message) => updates(message as TypingEvent))
          as TypingEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TypingEvent create() => TypingEvent._();
  @$core.override
  TypingEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TypingEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TypingEvent>(create);
  static TypingEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get isTyping => $_getBF(1);
  @$pb.TagNumber(2)
  set isTyping($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIsTyping() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsTyping() => $_clearField(2);
}

enum ServerEvent_Event {
  newMessage,
  messageRead,
  conversationUpdate,
  unreadUpdate,
  userStatus,
  typingIndicator,
  subscribed,
  unsubscribed,
  pong,
  error,
  messageSent,
  notSet
}

/// ServerEvent 服务端推送的事件
class ServerEvent extends $pb.GeneratedMessage {
  factory ServerEvent({
    NewMessageEvent? newMessage,
    MessageReadEvent? messageRead,
    ConversationUpdateEvent? conversationUpdate,
    UnreadCountUpdateEvent? unreadUpdate,
    UserStatusEvent? userStatus,
    TypingIndicatorEvent? typingIndicator,
    SubscribedEvent? subscribed,
    UnsubscribedEvent? unsubscribed,
    PongEvent? pong,
    ErrorEvent? error,
    MessageSentEvent? messageSent,
  }) {
    final result = create();
    if (newMessage != null) result.newMessage = newMessage;
    if (messageRead != null) result.messageRead = messageRead;
    if (conversationUpdate != null)
      result.conversationUpdate = conversationUpdate;
    if (unreadUpdate != null) result.unreadUpdate = unreadUpdate;
    if (userStatus != null) result.userStatus = userStatus;
    if (typingIndicator != null) result.typingIndicator = typingIndicator;
    if (subscribed != null) result.subscribed = subscribed;
    if (unsubscribed != null) result.unsubscribed = unsubscribed;
    if (pong != null) result.pong = pong;
    if (error != null) result.error = error;
    if (messageSent != null) result.messageSent = messageSent;
    return result;
  }

  ServerEvent._();

  factory ServerEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ServerEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, ServerEvent_Event> _ServerEvent_EventByTag =
      {
    1: ServerEvent_Event.newMessage,
    2: ServerEvent_Event.messageRead,
    3: ServerEvent_Event.conversationUpdate,
    4: ServerEvent_Event.unreadUpdate,
    5: ServerEvent_Event.userStatus,
    6: ServerEvent_Event.typingIndicator,
    7: ServerEvent_Event.subscribed,
    8: ServerEvent_Event.unsubscribed,
    9: ServerEvent_Event.pong,
    10: ServerEvent_Event.error,
    11: ServerEvent_Event.messageSent,
    0: ServerEvent_Event.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ServerEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11])
    ..aOM<NewMessageEvent>(1, _omitFieldNames ? '' : 'newMessage',
        subBuilder: NewMessageEvent.create)
    ..aOM<MessageReadEvent>(2, _omitFieldNames ? '' : 'messageRead',
        subBuilder: MessageReadEvent.create)
    ..aOM<ConversationUpdateEvent>(
        3, _omitFieldNames ? '' : 'conversationUpdate',
        subBuilder: ConversationUpdateEvent.create)
    ..aOM<UnreadCountUpdateEvent>(4, _omitFieldNames ? '' : 'unreadUpdate',
        subBuilder: UnreadCountUpdateEvent.create)
    ..aOM<UserStatusEvent>(5, _omitFieldNames ? '' : 'userStatus',
        subBuilder: UserStatusEvent.create)
    ..aOM<TypingIndicatorEvent>(6, _omitFieldNames ? '' : 'typingIndicator',
        subBuilder: TypingIndicatorEvent.create)
    ..aOM<SubscribedEvent>(7, _omitFieldNames ? '' : 'subscribed',
        subBuilder: SubscribedEvent.create)
    ..aOM<UnsubscribedEvent>(8, _omitFieldNames ? '' : 'unsubscribed',
        subBuilder: UnsubscribedEvent.create)
    ..aOM<PongEvent>(9, _omitFieldNames ? '' : 'pong',
        subBuilder: PongEvent.create)
    ..aOM<ErrorEvent>(10, _omitFieldNames ? '' : 'error',
        subBuilder: ErrorEvent.create)
    ..aOM<MessageSentEvent>(11, _omitFieldNames ? '' : 'messageSent',
        subBuilder: MessageSentEvent.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServerEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServerEvent copyWith(void Function(ServerEvent) updates) =>
      super.copyWith((message) => updates(message as ServerEvent))
          as ServerEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ServerEvent create() => ServerEvent._();
  @$core.override
  ServerEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ServerEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ServerEvent>(create);
  static ServerEvent? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  @$pb.TagNumber(9)
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  ServerEvent_Event whichEvent() => _ServerEvent_EventByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  @$pb.TagNumber(9)
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  void clearEvent() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  NewMessageEvent get newMessage => $_getN(0);
  @$pb.TagNumber(1)
  set newMessage(NewMessageEvent value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasNewMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearNewMessage() => $_clearField(1);
  @$pb.TagNumber(1)
  NewMessageEvent ensureNewMessage() => $_ensure(0);

  @$pb.TagNumber(2)
  MessageReadEvent get messageRead => $_getN(1);
  @$pb.TagNumber(2)
  set messageRead(MessageReadEvent value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasMessageRead() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessageRead() => $_clearField(2);
  @$pb.TagNumber(2)
  MessageReadEvent ensureMessageRead() => $_ensure(1);

  @$pb.TagNumber(3)
  ConversationUpdateEvent get conversationUpdate => $_getN(2);
  @$pb.TagNumber(3)
  set conversationUpdate(ConversationUpdateEvent value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasConversationUpdate() => $_has(2);
  @$pb.TagNumber(3)
  void clearConversationUpdate() => $_clearField(3);
  @$pb.TagNumber(3)
  ConversationUpdateEvent ensureConversationUpdate() => $_ensure(2);

  @$pb.TagNumber(4)
  UnreadCountUpdateEvent get unreadUpdate => $_getN(3);
  @$pb.TagNumber(4)
  set unreadUpdate(UnreadCountUpdateEvent value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasUnreadUpdate() => $_has(3);
  @$pb.TagNumber(4)
  void clearUnreadUpdate() => $_clearField(4);
  @$pb.TagNumber(4)
  UnreadCountUpdateEvent ensureUnreadUpdate() => $_ensure(3);

  @$pb.TagNumber(5)
  UserStatusEvent get userStatus => $_getN(4);
  @$pb.TagNumber(5)
  set userStatus(UserStatusEvent value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasUserStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearUserStatus() => $_clearField(5);
  @$pb.TagNumber(5)
  UserStatusEvent ensureUserStatus() => $_ensure(4);

  @$pb.TagNumber(6)
  TypingIndicatorEvent get typingIndicator => $_getN(5);
  @$pb.TagNumber(6)
  set typingIndicator(TypingIndicatorEvent value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasTypingIndicator() => $_has(5);
  @$pb.TagNumber(6)
  void clearTypingIndicator() => $_clearField(6);
  @$pb.TagNumber(6)
  TypingIndicatorEvent ensureTypingIndicator() => $_ensure(5);

  @$pb.TagNumber(7)
  SubscribedEvent get subscribed => $_getN(6);
  @$pb.TagNumber(7)
  set subscribed(SubscribedEvent value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasSubscribed() => $_has(6);
  @$pb.TagNumber(7)
  void clearSubscribed() => $_clearField(7);
  @$pb.TagNumber(7)
  SubscribedEvent ensureSubscribed() => $_ensure(6);

  @$pb.TagNumber(8)
  UnsubscribedEvent get unsubscribed => $_getN(7);
  @$pb.TagNumber(8)
  set unsubscribed(UnsubscribedEvent value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasUnsubscribed() => $_has(7);
  @$pb.TagNumber(8)
  void clearUnsubscribed() => $_clearField(8);
  @$pb.TagNumber(8)
  UnsubscribedEvent ensureUnsubscribed() => $_ensure(7);

  @$pb.TagNumber(9)
  PongEvent get pong => $_getN(8);
  @$pb.TagNumber(9)
  set pong(PongEvent value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasPong() => $_has(8);
  @$pb.TagNumber(9)
  void clearPong() => $_clearField(9);
  @$pb.TagNumber(9)
  PongEvent ensurePong() => $_ensure(8);

  @$pb.TagNumber(10)
  ErrorEvent get error => $_getN(9);
  @$pb.TagNumber(10)
  set error(ErrorEvent value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasError() => $_has(9);
  @$pb.TagNumber(10)
  void clearError() => $_clearField(10);
  @$pb.TagNumber(10)
  ErrorEvent ensureError() => $_ensure(9);

  @$pb.TagNumber(11)
  MessageSentEvent get messageSent => $_getN(10);
  @$pb.TagNumber(11)
  set messageSent(MessageSentEvent value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasMessageSent() => $_has(10);
  @$pb.TagNumber(11)
  void clearMessageSent() => $_clearField(11);
  @$pb.TagNumber(11)
  MessageSentEvent ensureMessageSent() => $_ensure(10);
}

/// NewMessageEvent 新消息事件
class NewMessageEvent extends $pb.GeneratedMessage {
  factory NewMessageEvent({
    Message? message,
  }) {
    final result = create();
    if (message != null) result.message = message;
    return result;
  }

  NewMessageEvent._();

  factory NewMessageEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NewMessageEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NewMessageEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aOM<Message>(1, _omitFieldNames ? '' : 'message',
        subBuilder: Message.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NewMessageEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NewMessageEvent copyWith(void Function(NewMessageEvent) updates) =>
      super.copyWith((message) => updates(message as NewMessageEvent))
          as NewMessageEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NewMessageEvent create() => NewMessageEvent._();
  @$core.override
  NewMessageEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NewMessageEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NewMessageEvent>(create);
  static NewMessageEvent? _defaultInstance;

  @$pb.TagNumber(1)
  Message get message => $_getN(0);
  @$pb.TagNumber(1)
  set message(Message value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => $_clearField(1);
  @$pb.TagNumber(1)
  Message ensureMessage() => $_ensure(0);
}

/// MessageReadEvent 消息已读事件
class MessageReadEvent extends $pb.GeneratedMessage {
  factory MessageReadEvent({
    $core.String? messageId,
    $core.String? conversationId,
    $core.String? readerId,
    $1.Timestamp? readAt,
    $core.Iterable<$core.String>? messageIds,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (conversationId != null) result.conversationId = conversationId;
    if (readerId != null) result.readerId = readerId;
    if (readAt != null) result.readAt = readAt;
    if (messageIds != null) result.messageIds.addAll(messageIds);
    return result;
  }

  MessageReadEvent._();

  factory MessageReadEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MessageReadEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MessageReadEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messageId')
    ..aOS(2, _omitFieldNames ? '' : 'conversationId')
    ..aOS(3, _omitFieldNames ? '' : 'readerId')
    ..aOM<$1.Timestamp>(4, _omitFieldNames ? '' : 'readAt',
        subBuilder: $1.Timestamp.create)
    ..pPS(5, _omitFieldNames ? '' : 'messageIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageReadEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageReadEvent copyWith(void Function(MessageReadEvent) updates) =>
      super.copyWith((message) => updates(message as MessageReadEvent))
          as MessageReadEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageReadEvent create() => MessageReadEvent._();
  @$core.override
  MessageReadEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MessageReadEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MessageReadEvent>(create);
  static MessageReadEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get messageId => $_getSZ(0);
  @$pb.TagNumber(1)
  set messageId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get conversationId => $_getSZ(1);
  @$pb.TagNumber(2)
  set conversationId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConversationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearConversationId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get readerId => $_getSZ(2);
  @$pb.TagNumber(3)
  set readerId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReaderId() => $_has(2);
  @$pb.TagNumber(3)
  void clearReaderId() => $_clearField(3);

  @$pb.TagNumber(4)
  $1.Timestamp get readAt => $_getN(3);
  @$pb.TagNumber(4)
  set readAt($1.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasReadAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearReadAt() => $_clearField(4);
  @$pb.TagNumber(4)
  $1.Timestamp ensureReadAt() => $_ensure(3);

  @$pb.TagNumber(5)
  $pb.PbList<$core.String> get messageIds => $_getList(4);
}

/// ConversationUpdateEvent 会话更新事件
class ConversationUpdateEvent extends $pb.GeneratedMessage {
  factory ConversationUpdateEvent({
    $core.String? conversationId,
    Message? lastMessage,
    $fixnum.Int64? unreadCount,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (lastMessage != null) result.lastMessage = lastMessage;
    if (unreadCount != null) result.unreadCount = unreadCount;
    return result;
  }

  ConversationUpdateEvent._();

  factory ConversationUpdateEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConversationUpdateEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConversationUpdateEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOM<Message>(2, _omitFieldNames ? '' : 'lastMessage',
        subBuilder: Message.create)
    ..aInt64(3, _omitFieldNames ? '' : 'unreadCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationUpdateEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationUpdateEvent copyWith(
          void Function(ConversationUpdateEvent) updates) =>
      super.copyWith((message) => updates(message as ConversationUpdateEvent))
          as ConversationUpdateEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConversationUpdateEvent create() => ConversationUpdateEvent._();
  @$core.override
  ConversationUpdateEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ConversationUpdateEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConversationUpdateEvent>(create);
  static ConversationUpdateEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  @$pb.TagNumber(2)
  Message get lastMessage => $_getN(1);
  @$pb.TagNumber(2)
  set lastMessage(Message value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasLastMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearLastMessage() => $_clearField(2);
  @$pb.TagNumber(2)
  Message ensureLastMessage() => $_ensure(1);

  @$pb.TagNumber(3)
  $fixnum.Int64 get unreadCount => $_getI64(2);
  @$pb.TagNumber(3)
  set unreadCount($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUnreadCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearUnreadCount() => $_clearField(3);
}

/// UnreadCountUpdateEvent 未读数更新事件
class UnreadCountUpdateEvent extends $pb.GeneratedMessage {
  factory UnreadCountUpdateEvent({
    $core.String? conversationId,
    $fixnum.Int64? count,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (count != null) result.count = count;
    return result;
  }

  UnreadCountUpdateEvent._();

  factory UnreadCountUpdateEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UnreadCountUpdateEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UnreadCountUpdateEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aInt64(2, _omitFieldNames ? '' : 'count')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnreadCountUpdateEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnreadCountUpdateEvent copyWith(
          void Function(UnreadCountUpdateEvent) updates) =>
      super.copyWith((message) => updates(message as UnreadCountUpdateEvent))
          as UnreadCountUpdateEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnreadCountUpdateEvent create() => UnreadCountUpdateEvent._();
  @$core.override
  UnreadCountUpdateEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UnreadCountUpdateEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UnreadCountUpdateEvent>(create);
  static UnreadCountUpdateEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get count => $_getI64(1);
  @$pb.TagNumber(2)
  set count($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearCount() => $_clearField(2);
}

/// UserStatusEvent 用户在线状态事件
class UserStatusEvent extends $pb.GeneratedMessage {
  factory UserStatusEvent({
    $core.String? userId,
    $core.bool? isOnline,
    $1.Timestamp? lastSeen,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (isOnline != null) result.isOnline = isOnline;
    if (lastSeen != null) result.lastSeen = lastSeen;
    return result;
  }

  UserStatusEvent._();

  factory UserStatusEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UserStatusEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UserStatusEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOB(2, _omitFieldNames ? '' : 'isOnline')
    ..aOM<$1.Timestamp>(3, _omitFieldNames ? '' : 'lastSeen',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserStatusEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserStatusEvent copyWith(void Function(UserStatusEvent) updates) =>
      super.copyWith((message) => updates(message as UserStatusEvent))
          as UserStatusEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserStatusEvent create() => UserStatusEvent._();
  @$core.override
  UserStatusEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UserStatusEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UserStatusEvent>(create);
  static UserStatusEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get isOnline => $_getBF(1);
  @$pb.TagNumber(2)
  set isOnline($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIsOnline() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsOnline() => $_clearField(2);

  @$pb.TagNumber(3)
  $1.Timestamp get lastSeen => $_getN(2);
  @$pb.TagNumber(3)
  set lastSeen($1.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasLastSeen() => $_has(2);
  @$pb.TagNumber(3)
  void clearLastSeen() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.Timestamp ensureLastSeen() => $_ensure(2);
}

/// TypingIndicatorEvent 正在输入指示器事件
class TypingIndicatorEvent extends $pb.GeneratedMessage {
  factory TypingIndicatorEvent({
    $core.String? conversationId,
    $core.String? userId,
    $core.bool? isTyping,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (userId != null) result.userId = userId;
    if (isTyping != null) result.isTyping = isTyping;
    return result;
  }

  TypingIndicatorEvent._();

  factory TypingIndicatorEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TypingIndicatorEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TypingIndicatorEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOB(3, _omitFieldNames ? '' : 'isTyping')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TypingIndicatorEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TypingIndicatorEvent copyWith(void Function(TypingIndicatorEvent) updates) =>
      super.copyWith((message) => updates(message as TypingIndicatorEvent))
          as TypingIndicatorEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TypingIndicatorEvent create() => TypingIndicatorEvent._();
  @$core.override
  TypingIndicatorEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TypingIndicatorEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TypingIndicatorEvent>(create);
  static TypingIndicatorEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isTyping => $_getBF(2);
  @$pb.TagNumber(3)
  set isTyping($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsTyping() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsTyping() => $_clearField(3);
}

/// SubscribedEvent 订阅成功事件
class SubscribedEvent extends $pb.GeneratedMessage {
  factory SubscribedEvent({
    $core.String? conversationId,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    return result;
  }

  SubscribedEvent._();

  factory SubscribedEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SubscribedEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubscribedEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribedEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribedEvent copyWith(void Function(SubscribedEvent) updates) =>
      super.copyWith((message) => updates(message as SubscribedEvent))
          as SubscribedEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubscribedEvent create() => SubscribedEvent._();
  @$core.override
  SubscribedEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SubscribedEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubscribedEvent>(create);
  static SubscribedEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);
}

/// UnsubscribedEvent 取消订阅成功事件
class UnsubscribedEvent extends $pb.GeneratedMessage {
  factory UnsubscribedEvent({
    $core.String? conversationId,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    return result;
  }

  UnsubscribedEvent._();

  factory UnsubscribedEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UnsubscribedEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UnsubscribedEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnsubscribedEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnsubscribedEvent copyWith(void Function(UnsubscribedEvent) updates) =>
      super.copyWith((message) => updates(message as UnsubscribedEvent))
          as UnsubscribedEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnsubscribedEvent create() => UnsubscribedEvent._();
  @$core.override
  UnsubscribedEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UnsubscribedEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UnsubscribedEvent>(create);
  static UnsubscribedEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);
}

/// PongEvent 心跳响应
class PongEvent extends $pb.GeneratedMessage {
  factory PongEvent() => create();

  PongEvent._();

  factory PongEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PongEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PongEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PongEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PongEvent copyWith(void Function(PongEvent) updates) =>
      super.copyWith((message) => updates(message as PongEvent)) as PongEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PongEvent create() => PongEvent._();
  @$core.override
  PongEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PongEvent getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PongEvent>(create);
  static PongEvent? _defaultInstance;
}

/// ErrorEvent 错误事件
class ErrorEvent extends $pb.GeneratedMessage {
  factory ErrorEvent({
    $core.String? code,
    $core.String? message,
    $core.String? action,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    if (action != null) result.action = action;
    return result;
  }

  ErrorEvent._();

  factory ErrorEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ErrorEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ErrorEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOS(3, _omitFieldNames ? '' : 'action')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ErrorEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ErrorEvent copyWith(void Function(ErrorEvent) updates) =>
      super.copyWith((message) => updates(message as ErrorEvent)) as ErrorEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ErrorEvent create() => ErrorEvent._();
  @$core.override
  ErrorEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ErrorEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ErrorEvent>(create);
  static ErrorEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get code => $_getSZ(0);
  @$pb.TagNumber(1)
  set code($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get action => $_getSZ(2);
  @$pb.TagNumber(3)
  set action($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAction() => $_has(2);
  @$pb.TagNumber(3)
  void clearAction() => $_clearField(3);
}

/// MessageSentEvent 消息发送成功事件
class MessageSentEvent extends $pb.GeneratedMessage {
  factory MessageSentEvent({
    $core.String? clientMessageId,
    Message? message,
  }) {
    final result = create();
    if (clientMessageId != null) result.clientMessageId = clientMessageId;
    if (message != null) result.message = message;
    return result;
  }

  MessageSentEvent._();

  factory MessageSentEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MessageSentEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MessageSentEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'clientMessageId')
    ..aOM<Message>(2, _omitFieldNames ? '' : 'message',
        subBuilder: Message.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageSentEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageSentEvent copyWith(void Function(MessageSentEvent) updates) =>
      super.copyWith((message) => updates(message as MessageSentEvent))
          as MessageSentEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageSentEvent create() => MessageSentEvent._();
  @$core.override
  MessageSentEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MessageSentEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MessageSentEvent>(create);
  static MessageSentEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get clientMessageId => $_getSZ(0);
  @$pb.TagNumber(1)
  set clientMessageId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClientMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClientMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  Message get message => $_getN(1);
  @$pb.TagNumber(2)
  set message(Message value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
  @$pb.TagNumber(2)
  Message ensureMessage() => $_ensure(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
