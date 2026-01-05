// This is a generated file - do not edit.
//
// Generated from channel/channel.proto.

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

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// Channel 频道实体
class Channel extends $pb.GeneratedMessage {
  factory Channel({
    $core.String? id,
    $core.String? name,
    $core.String? description,
    $core.String? avatarUrl,
    $core.String? ownerId,
    $core.Iterable<$core.String>? adminIds,
    $fixnum.Int64? subscriberCount,
    $fixnum.Int64? postCount,
    $1.Timestamp? createdAt,
    $1.Timestamp? updatedAt,
    $core.bool? isSubscribed,
    $core.bool? isAdmin,
    $core.bool? isOwner,
    ChannelPost? pinnedPost,
    $core.String? username,
    $core.bool? isPublic,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (avatarUrl != null) result.avatarUrl = avatarUrl;
    if (ownerId != null) result.ownerId = ownerId;
    if (adminIds != null) result.adminIds.addAll(adminIds);
    if (subscriberCount != null) result.subscriberCount = subscriberCount;
    if (postCount != null) result.postCount = postCount;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (isSubscribed != null) result.isSubscribed = isSubscribed;
    if (isAdmin != null) result.isAdmin = isAdmin;
    if (isOwner != null) result.isOwner = isOwner;
    if (pinnedPost != null) result.pinnedPost = pinnedPost;
    if (username != null) result.username = username;
    if (isPublic != null) result.isPublic = isPublic;
    return result;
  }

  Channel._();

  factory Channel.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Channel.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Channel',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..aOS(4, _omitFieldNames ? '' : 'avatarUrl')
    ..aOS(5, _omitFieldNames ? '' : 'ownerId')
    ..pPS(6, _omitFieldNames ? '' : 'adminIds')
    ..aInt64(7, _omitFieldNames ? '' : 'subscriberCount')
    ..aInt64(8, _omitFieldNames ? '' : 'postCount')
    ..aOM<$1.Timestamp>(9, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $1.Timestamp.create)
    ..aOM<$1.Timestamp>(10, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $1.Timestamp.create)
    ..aOB(11, _omitFieldNames ? '' : 'isSubscribed')
    ..aOB(12, _omitFieldNames ? '' : 'isAdmin')
    ..aOB(13, _omitFieldNames ? '' : 'isOwner')
    ..aOM<ChannelPost>(14, _omitFieldNames ? '' : 'pinnedPost',
        subBuilder: ChannelPost.create)
    ..aOS(15, _omitFieldNames ? '' : 'username')
    ..aOB(16, _omitFieldNames ? '' : 'isPublic')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Channel clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Channel copyWith(void Function(Channel) updates) =>
      super.copyWith((message) => updates(message as Channel)) as Channel;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Channel create() => Channel._();
  @$core.override
  Channel createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Channel getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Channel>(create);
  static Channel? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get avatarUrl => $_getSZ(3);
  @$pb.TagNumber(4)
  set avatarUrl($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAvatarUrl() => $_has(3);
  @$pb.TagNumber(4)
  void clearAvatarUrl() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get ownerId => $_getSZ(4);
  @$pb.TagNumber(5)
  set ownerId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOwnerId() => $_has(4);
  @$pb.TagNumber(5)
  void clearOwnerId() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<$core.String> get adminIds => $_getList(5);

  @$pb.TagNumber(7)
  $fixnum.Int64 get subscriberCount => $_getI64(6);
  @$pb.TagNumber(7)
  set subscriberCount($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSubscriberCount() => $_has(6);
  @$pb.TagNumber(7)
  void clearSubscriberCount() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get postCount => $_getI64(7);
  @$pb.TagNumber(8)
  set postCount($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPostCount() => $_has(7);
  @$pb.TagNumber(8)
  void clearPostCount() => $_clearField(8);

  @$pb.TagNumber(9)
  $1.Timestamp get createdAt => $_getN(8);
  @$pb.TagNumber(9)
  set createdAt($1.Timestamp value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasCreatedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearCreatedAt() => $_clearField(9);
  @$pb.TagNumber(9)
  $1.Timestamp ensureCreatedAt() => $_ensure(8);

  @$pb.TagNumber(10)
  $1.Timestamp get updatedAt => $_getN(9);
  @$pb.TagNumber(10)
  set updatedAt($1.Timestamp value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasUpdatedAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearUpdatedAt() => $_clearField(10);
  @$pb.TagNumber(10)
  $1.Timestamp ensureUpdatedAt() => $_ensure(9);

  @$pb.TagNumber(11)
  $core.bool get isSubscribed => $_getBF(10);
  @$pb.TagNumber(11)
  set isSubscribed($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasIsSubscribed() => $_has(10);
  @$pb.TagNumber(11)
  void clearIsSubscribed() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.bool get isAdmin => $_getBF(11);
  @$pb.TagNumber(12)
  set isAdmin($core.bool value) => $_setBool(11, value);
  @$pb.TagNumber(12)
  $core.bool hasIsAdmin() => $_has(11);
  @$pb.TagNumber(12)
  void clearIsAdmin() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.bool get isOwner => $_getBF(12);
  @$pb.TagNumber(13)
  set isOwner($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasIsOwner() => $_has(12);
  @$pb.TagNumber(13)
  void clearIsOwner() => $_clearField(13);

  @$pb.TagNumber(14)
  ChannelPost get pinnedPost => $_getN(13);
  @$pb.TagNumber(14)
  set pinnedPost(ChannelPost value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasPinnedPost() => $_has(13);
  @$pb.TagNumber(14)
  void clearPinnedPost() => $_clearField(14);
  @$pb.TagNumber(14)
  ChannelPost ensurePinnedPost() => $_ensure(13);

  @$pb.TagNumber(15)
  $core.String get username => $_getSZ(14);
  @$pb.TagNumber(15)
  set username($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasUsername() => $_has(14);
  @$pb.TagNumber(15)
  void clearUsername() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.bool get isPublic => $_getBF(15);
  @$pb.TagNumber(16)
  set isPublic($core.bool value) => $_setBool(15, value);
  @$pb.TagNumber(16)
  $core.bool hasIsPublic() => $_has(15);
  @$pb.TagNumber(16)
  void clearIsPublic() => $_clearField(16);
}

/// ChannelPost 频道内容
class ChannelPost extends $pb.GeneratedMessage {
  factory ChannelPost({
    $core.String? id,
    $core.String? channelId,
    $core.String? authorId,
    $core.String? content,
    $core.Iterable<$core.String>? mediaUrls,
    $fixnum.Int64? viewCount,
    $1.Timestamp? createdAt,
    $1.Timestamp? updatedAt,
    $core.bool? isPinned,
    $core.bool? isEdited,
    $core.String? authorName,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (channelId != null) result.channelId = channelId;
    if (authorId != null) result.authorId = authorId;
    if (content != null) result.content = content;
    if (mediaUrls != null) result.mediaUrls.addAll(mediaUrls);
    if (viewCount != null) result.viewCount = viewCount;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (isPinned != null) result.isPinned = isPinned;
    if (isEdited != null) result.isEdited = isEdited;
    if (authorName != null) result.authorName = authorName;
    return result;
  }

  ChannelPost._();

  factory ChannelPost.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChannelPost.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChannelPost',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'channelId')
    ..aOS(3, _omitFieldNames ? '' : 'authorId')
    ..aOS(4, _omitFieldNames ? '' : 'content')
    ..pPS(5, _omitFieldNames ? '' : 'mediaUrls')
    ..aInt64(6, _omitFieldNames ? '' : 'viewCount')
    ..aOM<$1.Timestamp>(7, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $1.Timestamp.create)
    ..aOM<$1.Timestamp>(8, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $1.Timestamp.create)
    ..aOB(9, _omitFieldNames ? '' : 'isPinned')
    ..aOB(10, _omitFieldNames ? '' : 'isEdited')
    ..aOS(11, _omitFieldNames ? '' : 'authorName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChannelPost clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChannelPost copyWith(void Function(ChannelPost) updates) =>
      super.copyWith((message) => updates(message as ChannelPost))
          as ChannelPost;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChannelPost create() => ChannelPost._();
  @$core.override
  ChannelPost createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChannelPost getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChannelPost>(create);
  static ChannelPost? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get channelId => $_getSZ(1);
  @$pb.TagNumber(2)
  set channelId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasChannelId() => $_has(1);
  @$pb.TagNumber(2)
  void clearChannelId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get authorId => $_getSZ(2);
  @$pb.TagNumber(3)
  set authorId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAuthorId() => $_has(2);
  @$pb.TagNumber(3)
  void clearAuthorId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get content => $_getSZ(3);
  @$pb.TagNumber(4)
  set content($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasContent() => $_has(3);
  @$pb.TagNumber(4)
  void clearContent() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<$core.String> get mediaUrls => $_getList(4);

  @$pb.TagNumber(6)
  $fixnum.Int64 get viewCount => $_getI64(5);
  @$pb.TagNumber(6)
  set viewCount($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasViewCount() => $_has(5);
  @$pb.TagNumber(6)
  void clearViewCount() => $_clearField(6);

  @$pb.TagNumber(7)
  $1.Timestamp get createdAt => $_getN(6);
  @$pb.TagNumber(7)
  set createdAt($1.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasCreatedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearCreatedAt() => $_clearField(7);
  @$pb.TagNumber(7)
  $1.Timestamp ensureCreatedAt() => $_ensure(6);

  @$pb.TagNumber(8)
  $1.Timestamp get updatedAt => $_getN(7);
  @$pb.TagNumber(8)
  set updatedAt($1.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasUpdatedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearUpdatedAt() => $_clearField(8);
  @$pb.TagNumber(8)
  $1.Timestamp ensureUpdatedAt() => $_ensure(7);

  @$pb.TagNumber(9)
  $core.bool get isPinned => $_getBF(8);
  @$pb.TagNumber(9)
  set isPinned($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasIsPinned() => $_has(8);
  @$pb.TagNumber(9)
  void clearIsPinned() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get isEdited => $_getBF(9);
  @$pb.TagNumber(10)
  set isEdited($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasIsEdited() => $_has(9);
  @$pb.TagNumber(10)
  void clearIsEdited() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get authorName => $_getSZ(10);
  @$pb.TagNumber(11)
  set authorName($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasAuthorName() => $_has(10);
  @$pb.TagNumber(11)
  void clearAuthorName() => $_clearField(11);
}

/// Subscriber 订阅者信息
class Subscriber extends $pb.GeneratedMessage {
  factory Subscriber({
    $core.String? userId,
    $core.String? username,
    $core.String? avatarUrl,
    $1.Timestamp? subscribedAt,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (username != null) result.username = username;
    if (avatarUrl != null) result.avatarUrl = avatarUrl;
    if (subscribedAt != null) result.subscribedAt = subscribedAt;
    return result;
  }

  Subscriber._();

  factory Subscriber.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Subscriber.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Subscriber',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'username')
    ..aOS(3, _omitFieldNames ? '' : 'avatarUrl')
    ..aOM<$1.Timestamp>(4, _omitFieldNames ? '' : 'subscribedAt',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Subscriber clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Subscriber copyWith(void Function(Subscriber) updates) =>
      super.copyWith((message) => updates(message as Subscriber)) as Subscriber;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Subscriber create() => Subscriber._();
  @$core.override
  Subscriber createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Subscriber getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Subscriber>(create);
  static Subscriber? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get username => $_getSZ(1);
  @$pb.TagNumber(2)
  set username($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUsername() => $_has(1);
  @$pb.TagNumber(2)
  void clearUsername() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get avatarUrl => $_getSZ(2);
  @$pb.TagNumber(3)
  set avatarUrl($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAvatarUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearAvatarUrl() => $_clearField(3);

  @$pb.TagNumber(4)
  $1.Timestamp get subscribedAt => $_getN(3);
  @$pb.TagNumber(4)
  set subscribedAt($1.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasSubscribedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearSubscribedAt() => $_clearField(4);
  @$pb.TagNumber(4)
  $1.Timestamp ensureSubscribedAt() => $_ensure(3);
}

/// Admin 管理员信息
class Admin extends $pb.GeneratedMessage {
  factory Admin({
    $core.String? userId,
    $core.String? username,
    $core.String? avatarUrl,
    $core.bool? isOwner,
    $1.Timestamp? addedAt,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (username != null) result.username = username;
    if (avatarUrl != null) result.avatarUrl = avatarUrl;
    if (isOwner != null) result.isOwner = isOwner;
    if (addedAt != null) result.addedAt = addedAt;
    return result;
  }

  Admin._();

  factory Admin.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Admin.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Admin',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'username')
    ..aOS(3, _omitFieldNames ? '' : 'avatarUrl')
    ..aOB(4, _omitFieldNames ? '' : 'isOwner')
    ..aOM<$1.Timestamp>(5, _omitFieldNames ? '' : 'addedAt',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Admin clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Admin copyWith(void Function(Admin) updates) =>
      super.copyWith((message) => updates(message as Admin)) as Admin;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Admin create() => Admin._();
  @$core.override
  Admin createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Admin getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Admin>(create);
  static Admin? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get username => $_getSZ(1);
  @$pb.TagNumber(2)
  set username($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUsername() => $_has(1);
  @$pb.TagNumber(2)
  void clearUsername() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get avatarUrl => $_getSZ(2);
  @$pb.TagNumber(3)
  set avatarUrl($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAvatarUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearAvatarUrl() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isOwner => $_getBF(3);
  @$pb.TagNumber(4)
  set isOwner($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIsOwner() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsOwner() => $_clearField(4);

  @$pb.TagNumber(5)
  $1.Timestamp get addedAt => $_getN(4);
  @$pb.TagNumber(5)
  set addedAt($1.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasAddedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearAddedAt() => $_clearField(5);
  @$pb.TagNumber(5)
  $1.Timestamp ensureAddedAt() => $_ensure(4);
}

/// CreateChannelRequest 创建频道请求
class CreateChannelRequest extends $pb.GeneratedMessage {
  factory CreateChannelRequest({
    $core.String? name,
    $core.String? description,
    $core.String? avatarUrl,
    $core.String? username,
    $core.bool? isPublic,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (avatarUrl != null) result.avatarUrl = avatarUrl;
    if (username != null) result.username = username;
    if (isPublic != null) result.isPublic = isPublic;
    return result;
  }

  CreateChannelRequest._();

  factory CreateChannelRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateChannelRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateChannelRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'description')
    ..aOS(3, _omitFieldNames ? '' : 'avatarUrl')
    ..aOS(4, _omitFieldNames ? '' : 'username')
    ..aOB(5, _omitFieldNames ? '' : 'isPublic')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateChannelRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateChannelRequest copyWith(void Function(CreateChannelRequest) updates) =>
      super.copyWith((message) => updates(message as CreateChannelRequest))
          as CreateChannelRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateChannelRequest create() => CreateChannelRequest._();
  @$core.override
  CreateChannelRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateChannelRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateChannelRequest>(create);
  static CreateChannelRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get description => $_getSZ(1);
  @$pb.TagNumber(2)
  set description($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get avatarUrl => $_getSZ(2);
  @$pb.TagNumber(3)
  set avatarUrl($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAvatarUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearAvatarUrl() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get username => $_getSZ(3);
  @$pb.TagNumber(4)
  set username($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUsername() => $_has(3);
  @$pb.TagNumber(4)
  void clearUsername() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get isPublic => $_getBF(4);
  @$pb.TagNumber(5)
  set isPublic($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIsPublic() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsPublic() => $_clearField(5);
}

/// GetChannelRequest 获取频道请求
class GetChannelRequest extends $pb.GeneratedMessage {
  factory GetChannelRequest({
    $core.String? channelId,
  }) {
    final result = create();
    if (channelId != null) result.channelId = channelId;
    return result;
  }

  GetChannelRequest._();

  factory GetChannelRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetChannelRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetChannelRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'channelId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChannelRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChannelRequest copyWith(void Function(GetChannelRequest) updates) =>
      super.copyWith((message) => updates(message as GetChannelRequest))
          as GetChannelRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetChannelRequest create() => GetChannelRequest._();
  @$core.override
  GetChannelRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetChannelRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetChannelRequest>(create);
  static GetChannelRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get channelId => $_getSZ(0);
  @$pb.TagNumber(1)
  set channelId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChannelId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChannelId() => $_clearField(1);
}

/// UpdateChannelRequest 更新频道请求
class UpdateChannelRequest extends $pb.GeneratedMessage {
  factory UpdateChannelRequest({
    $core.String? channelId,
    $core.String? name,
    $core.String? description,
    $core.String? avatarUrl,
    $core.String? username,
    $core.bool? isPublic,
  }) {
    final result = create();
    if (channelId != null) result.channelId = channelId;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (avatarUrl != null) result.avatarUrl = avatarUrl;
    if (username != null) result.username = username;
    if (isPublic != null) result.isPublic = isPublic;
    return result;
  }

  UpdateChannelRequest._();

  factory UpdateChannelRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateChannelRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateChannelRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'channelId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..aOS(4, _omitFieldNames ? '' : 'avatarUrl')
    ..aOS(5, _omitFieldNames ? '' : 'username')
    ..aOB(6, _omitFieldNames ? '' : 'isPublic')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateChannelRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateChannelRequest copyWith(void Function(UpdateChannelRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateChannelRequest))
          as UpdateChannelRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateChannelRequest create() => UpdateChannelRequest._();
  @$core.override
  UpdateChannelRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateChannelRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateChannelRequest>(create);
  static UpdateChannelRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get channelId => $_getSZ(0);
  @$pb.TagNumber(1)
  set channelId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChannelId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChannelId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get avatarUrl => $_getSZ(3);
  @$pb.TagNumber(4)
  set avatarUrl($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAvatarUrl() => $_has(3);
  @$pb.TagNumber(4)
  void clearAvatarUrl() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get username => $_getSZ(4);
  @$pb.TagNumber(5)
  set username($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUsername() => $_has(4);
  @$pb.TagNumber(5)
  void clearUsername() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get isPublic => $_getBF(5);
  @$pb.TagNumber(6)
  set isPublic($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIsPublic() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsPublic() => $_clearField(6);
}

/// DeleteChannelRequest 删除频道请求
class DeleteChannelRequest extends $pb.GeneratedMessage {
  factory DeleteChannelRequest({
    $core.String? channelId,
  }) {
    final result = create();
    if (channelId != null) result.channelId = channelId;
    return result;
  }

  DeleteChannelRequest._();

  factory DeleteChannelRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteChannelRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteChannelRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'channelId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteChannelRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteChannelRequest copyWith(void Function(DeleteChannelRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteChannelRequest))
          as DeleteChannelRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteChannelRequest create() => DeleteChannelRequest._();
  @$core.override
  DeleteChannelRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteChannelRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteChannelRequest>(create);
  static DeleteChannelRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get channelId => $_getSZ(0);
  @$pb.TagNumber(1)
  set channelId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChannelId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChannelId() => $_clearField(1);
}

/// GetSubscribedChannelsRequest 获取订阅频道列表请求
class GetSubscribedChannelsRequest extends $pb.GeneratedMessage {
  factory GetSubscribedChannelsRequest({
    $core.String? userId,
    $1.Pagination? pagination,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (pagination != null) result.pagination = pagination;
    return result;
  }

  GetSubscribedChannelsRequest._();

  factory GetSubscribedChannelsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSubscribedChannelsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSubscribedChannelsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOM<$1.Pagination>(2, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSubscribedChannelsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSubscribedChannelsRequest copyWith(
          void Function(GetSubscribedChannelsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetSubscribedChannelsRequest))
          as GetSubscribedChannelsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSubscribedChannelsRequest create() =>
      GetSubscribedChannelsRequest._();
  @$core.override
  GetSubscribedChannelsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSubscribedChannelsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSubscribedChannelsRequest>(create);
  static GetSubscribedChannelsRequest? _defaultInstance;

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

/// GetOwnedChannelsRequest 获取管理频道列表请求
class GetOwnedChannelsRequest extends $pb.GeneratedMessage {
  factory GetOwnedChannelsRequest({
    $core.String? userId,
    $1.Pagination? pagination,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (pagination != null) result.pagination = pagination;
    return result;
  }

  GetOwnedChannelsRequest._();

  factory GetOwnedChannelsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetOwnedChannelsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetOwnedChannelsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOM<$1.Pagination>(2, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetOwnedChannelsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetOwnedChannelsRequest copyWith(
          void Function(GetOwnedChannelsRequest) updates) =>
      super.copyWith((message) => updates(message as GetOwnedChannelsRequest))
          as GetOwnedChannelsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetOwnedChannelsRequest create() => GetOwnedChannelsRequest._();
  @$core.override
  GetOwnedChannelsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetOwnedChannelsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetOwnedChannelsRequest>(create);
  static GetOwnedChannelsRequest? _defaultInstance;

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

/// SearchChannelsRequest 搜索频道请求
class SearchChannelsRequest extends $pb.GeneratedMessage {
  factory SearchChannelsRequest({
    $core.String? query,
    $1.Pagination? pagination,
  }) {
    final result = create();
    if (query != null) result.query = query;
    if (pagination != null) result.pagination = pagination;
    return result;
  }

  SearchChannelsRequest._();

  factory SearchChannelsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SearchChannelsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchChannelsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOM<$1.Pagination>(2, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchChannelsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchChannelsRequest copyWith(
          void Function(SearchChannelsRequest) updates) =>
      super.copyWith((message) => updates(message as SearchChannelsRequest))
          as SearchChannelsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SearchChannelsRequest create() => SearchChannelsRequest._();
  @$core.override
  SearchChannelsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SearchChannelsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SearchChannelsRequest>(create);
  static SearchChannelsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => $_clearField(1);

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

/// ChannelsResponse 频道列表响应
class ChannelsResponse extends $pb.GeneratedMessage {
  factory ChannelsResponse({
    $core.Iterable<Channel>? channels,
    $1.Pagination? pagination,
  }) {
    final result = create();
    if (channels != null) result.channels.addAll(channels);
    if (pagination != null) result.pagination = pagination;
    return result;
  }

  ChannelsResponse._();

  factory ChannelsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChannelsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChannelsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..pPM<Channel>(1, _omitFieldNames ? '' : 'channels',
        subBuilder: Channel.create)
    ..aOM<$1.Pagination>(2, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChannelsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChannelsResponse copyWith(void Function(ChannelsResponse) updates) =>
      super.copyWith((message) => updates(message as ChannelsResponse))
          as ChannelsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChannelsResponse create() => ChannelsResponse._();
  @$core.override
  ChannelsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChannelsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChannelsResponse>(create);
  static ChannelsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Channel> get channels => $_getList(0);

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

/// SubscribeRequest 订阅频道请求
class SubscribeRequest extends $pb.GeneratedMessage {
  factory SubscribeRequest({
    $core.String? channelId,
  }) {
    final result = create();
    if (channelId != null) result.channelId = channelId;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'channelId')
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
  $core.String get channelId => $_getSZ(0);
  @$pb.TagNumber(1)
  set channelId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChannelId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChannelId() => $_clearField(1);
}

/// UnsubscribeRequest 取消订阅请求
class UnsubscribeRequest extends $pb.GeneratedMessage {
  factory UnsubscribeRequest({
    $core.String? channelId,
  }) {
    final result = create();
    if (channelId != null) result.channelId = channelId;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'channelId')
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
  $core.String get channelId => $_getSZ(0);
  @$pb.TagNumber(1)
  set channelId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChannelId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChannelId() => $_clearField(1);
}

/// GetSubscribersRequest 获取订阅者列表请求
class GetSubscribersRequest extends $pb.GeneratedMessage {
  factory GetSubscribersRequest({
    $core.String? channelId,
    $1.Pagination? pagination,
  }) {
    final result = create();
    if (channelId != null) result.channelId = channelId;
    if (pagination != null) result.pagination = pagination;
    return result;
  }

  GetSubscribersRequest._();

  factory GetSubscribersRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSubscribersRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSubscribersRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'channelId')
    ..aOM<$1.Pagination>(2, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSubscribersRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSubscribersRequest copyWith(
          void Function(GetSubscribersRequest) updates) =>
      super.copyWith((message) => updates(message as GetSubscribersRequest))
          as GetSubscribersRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSubscribersRequest create() => GetSubscribersRequest._();
  @$core.override
  GetSubscribersRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSubscribersRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSubscribersRequest>(create);
  static GetSubscribersRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get channelId => $_getSZ(0);
  @$pb.TagNumber(1)
  set channelId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChannelId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChannelId() => $_clearField(1);

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

/// SubscribersResponse 订阅者列表响应
class SubscribersResponse extends $pb.GeneratedMessage {
  factory SubscribersResponse({
    $core.Iterable<Subscriber>? subscribers,
    $1.Pagination? pagination,
  }) {
    final result = create();
    if (subscribers != null) result.subscribers.addAll(subscribers);
    if (pagination != null) result.pagination = pagination;
    return result;
  }

  SubscribersResponse._();

  factory SubscribersResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SubscribersResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubscribersResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..pPM<Subscriber>(1, _omitFieldNames ? '' : 'subscribers',
        subBuilder: Subscriber.create)
    ..aOM<$1.Pagination>(2, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribersResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribersResponse copyWith(void Function(SubscribersResponse) updates) =>
      super.copyWith((message) => updates(message as SubscribersResponse))
          as SubscribersResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubscribersResponse create() => SubscribersResponse._();
  @$core.override
  SubscribersResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SubscribersResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubscribersResponse>(create);
  static SubscribersResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Subscriber> get subscribers => $_getList(0);

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

/// CheckSubscriptionRequest 检查订阅状态请求
class CheckSubscriptionRequest extends $pb.GeneratedMessage {
  factory CheckSubscriptionRequest({
    $core.String? channelId,
  }) {
    final result = create();
    if (channelId != null) result.channelId = channelId;
    return result;
  }

  CheckSubscriptionRequest._();

  factory CheckSubscriptionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CheckSubscriptionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CheckSubscriptionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'channelId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckSubscriptionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckSubscriptionRequest copyWith(
          void Function(CheckSubscriptionRequest) updates) =>
      super.copyWith((message) => updates(message as CheckSubscriptionRequest))
          as CheckSubscriptionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CheckSubscriptionRequest create() => CheckSubscriptionRequest._();
  @$core.override
  CheckSubscriptionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CheckSubscriptionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CheckSubscriptionRequest>(create);
  static CheckSubscriptionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get channelId => $_getSZ(0);
  @$pb.TagNumber(1)
  set channelId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChannelId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChannelId() => $_clearField(1);
}

/// CheckSubscriptionResponse 检查订阅状态响应
class CheckSubscriptionResponse extends $pb.GeneratedMessage {
  factory CheckSubscriptionResponse({
    $core.bool? isSubscribed,
  }) {
    final result = create();
    if (isSubscribed != null) result.isSubscribed = isSubscribed;
    return result;
  }

  CheckSubscriptionResponse._();

  factory CheckSubscriptionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CheckSubscriptionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CheckSubscriptionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'isSubscribed')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckSubscriptionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckSubscriptionResponse copyWith(
          void Function(CheckSubscriptionResponse) updates) =>
      super.copyWith((message) => updates(message as CheckSubscriptionResponse))
          as CheckSubscriptionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CheckSubscriptionResponse create() => CheckSubscriptionResponse._();
  @$core.override
  CheckSubscriptionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CheckSubscriptionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CheckSubscriptionResponse>(create);
  static CheckSubscriptionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get isSubscribed => $_getBF(0);
  @$pb.TagNumber(1)
  set isSubscribed($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIsSubscribed() => $_has(0);
  @$pb.TagNumber(1)
  void clearIsSubscribed() => $_clearField(1);
}

/// AddAdminRequest 添加管理员请求
class AddAdminRequest extends $pb.GeneratedMessage {
  factory AddAdminRequest({
    $core.String? channelId,
    $core.String? userId,
  }) {
    final result = create();
    if (channelId != null) result.channelId = channelId;
    if (userId != null) result.userId = userId;
    return result;
  }

  AddAdminRequest._();

  factory AddAdminRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddAdminRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddAdminRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'channelId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddAdminRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddAdminRequest copyWith(void Function(AddAdminRequest) updates) =>
      super.copyWith((message) => updates(message as AddAdminRequest))
          as AddAdminRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddAdminRequest create() => AddAdminRequest._();
  @$core.override
  AddAdminRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddAdminRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddAdminRequest>(create);
  static AddAdminRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get channelId => $_getSZ(0);
  @$pb.TagNumber(1)
  set channelId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChannelId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChannelId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);
}

/// RemoveAdminRequest 移除管理员请求
class RemoveAdminRequest extends $pb.GeneratedMessage {
  factory RemoveAdminRequest({
    $core.String? channelId,
    $core.String? userId,
  }) {
    final result = create();
    if (channelId != null) result.channelId = channelId;
    if (userId != null) result.userId = userId;
    return result;
  }

  RemoveAdminRequest._();

  factory RemoveAdminRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RemoveAdminRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveAdminRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'channelId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveAdminRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveAdminRequest copyWith(void Function(RemoveAdminRequest) updates) =>
      super.copyWith((message) => updates(message as RemoveAdminRequest))
          as RemoveAdminRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveAdminRequest create() => RemoveAdminRequest._();
  @$core.override
  RemoveAdminRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RemoveAdminRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveAdminRequest>(create);
  static RemoveAdminRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get channelId => $_getSZ(0);
  @$pb.TagNumber(1)
  set channelId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChannelId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChannelId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);
}

/// GetAdminsRequest 获取管理员列表请求
class GetAdminsRequest extends $pb.GeneratedMessage {
  factory GetAdminsRequest({
    $core.String? channelId,
  }) {
    final result = create();
    if (channelId != null) result.channelId = channelId;
    return result;
  }

  GetAdminsRequest._();

  factory GetAdminsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetAdminsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetAdminsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'channelId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAdminsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAdminsRequest copyWith(void Function(GetAdminsRequest) updates) =>
      super.copyWith((message) => updates(message as GetAdminsRequest))
          as GetAdminsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAdminsRequest create() => GetAdminsRequest._();
  @$core.override
  GetAdminsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetAdminsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetAdminsRequest>(create);
  static GetAdminsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get channelId => $_getSZ(0);
  @$pb.TagNumber(1)
  set channelId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChannelId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChannelId() => $_clearField(1);
}

/// AdminsResponse 管理员列表响应
class AdminsResponse extends $pb.GeneratedMessage {
  factory AdminsResponse({
    $core.Iterable<Admin>? admins,
  }) {
    final result = create();
    if (admins != null) result.admins.addAll(admins);
    return result;
  }

  AdminsResponse._();

  factory AdminsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AdminsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AdminsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..pPM<Admin>(1, _omitFieldNames ? '' : 'admins', subBuilder: Admin.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AdminsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AdminsResponse copyWith(void Function(AdminsResponse) updates) =>
      super.copyWith((message) => updates(message as AdminsResponse))
          as AdminsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AdminsResponse create() => AdminsResponse._();
  @$core.override
  AdminsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AdminsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AdminsResponse>(create);
  static AdminsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Admin> get admins => $_getList(0);
}

/// PublishPostRequest 发布内容请求
class PublishPostRequest extends $pb.GeneratedMessage {
  factory PublishPostRequest({
    $core.String? channelId,
    $core.String? content,
    $core.Iterable<$core.String>? mediaUrls,
  }) {
    final result = create();
    if (channelId != null) result.channelId = channelId;
    if (content != null) result.content = content;
    if (mediaUrls != null) result.mediaUrls.addAll(mediaUrls);
    return result;
  }

  PublishPostRequest._();

  factory PublishPostRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PublishPostRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PublishPostRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'channelId')
    ..aOS(2, _omitFieldNames ? '' : 'content')
    ..pPS(3, _omitFieldNames ? '' : 'mediaUrls')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PublishPostRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PublishPostRequest copyWith(void Function(PublishPostRequest) updates) =>
      super.copyWith((message) => updates(message as PublishPostRequest))
          as PublishPostRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PublishPostRequest create() => PublishPostRequest._();
  @$core.override
  PublishPostRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PublishPostRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PublishPostRequest>(create);
  static PublishPostRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get channelId => $_getSZ(0);
  @$pb.TagNumber(1)
  set channelId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChannelId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChannelId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get content => $_getSZ(1);
  @$pb.TagNumber(2)
  set content($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasContent() => $_has(1);
  @$pb.TagNumber(2)
  void clearContent() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get mediaUrls => $_getList(2);
}

/// GetPostsRequest 获取内容列表请求
class GetPostsRequest extends $pb.GeneratedMessage {
  factory GetPostsRequest({
    $core.String? channelId,
    $1.Pagination? pagination,
  }) {
    final result = create();
    if (channelId != null) result.channelId = channelId;
    if (pagination != null) result.pagination = pagination;
    return result;
  }

  GetPostsRequest._();

  factory GetPostsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetPostsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetPostsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'channelId')
    ..aOM<$1.Pagination>(2, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPostsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPostsRequest copyWith(void Function(GetPostsRequest) updates) =>
      super.copyWith((message) => updates(message as GetPostsRequest))
          as GetPostsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPostsRequest create() => GetPostsRequest._();
  @$core.override
  GetPostsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetPostsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetPostsRequest>(create);
  static GetPostsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get channelId => $_getSZ(0);
  @$pb.TagNumber(1)
  set channelId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChannelId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChannelId() => $_clearField(1);

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

/// GetPostRequest 获取单个内容请求
class GetPostRequest extends $pb.GeneratedMessage {
  factory GetPostRequest({
    $core.String? postId,
  }) {
    final result = create();
    if (postId != null) result.postId = postId;
    return result;
  }

  GetPostRequest._();

  factory GetPostRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetPostRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetPostRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'postId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPostRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPostRequest copyWith(void Function(GetPostRequest) updates) =>
      super.copyWith((message) => updates(message as GetPostRequest))
          as GetPostRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPostRequest create() => GetPostRequest._();
  @$core.override
  GetPostRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetPostRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetPostRequest>(create);
  static GetPostRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get postId => $_getSZ(0);
  @$pb.TagNumber(1)
  set postId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPostId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPostId() => $_clearField(1);
}

/// EditPostRequest 编辑内容请求
class EditPostRequest extends $pb.GeneratedMessage {
  factory EditPostRequest({
    $core.String? postId,
    $core.String? content,
    $core.Iterable<$core.String>? mediaUrls,
  }) {
    final result = create();
    if (postId != null) result.postId = postId;
    if (content != null) result.content = content;
    if (mediaUrls != null) result.mediaUrls.addAll(mediaUrls);
    return result;
  }

  EditPostRequest._();

  factory EditPostRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EditPostRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EditPostRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'postId')
    ..aOS(2, _omitFieldNames ? '' : 'content')
    ..pPS(3, _omitFieldNames ? '' : 'mediaUrls')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EditPostRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EditPostRequest copyWith(void Function(EditPostRequest) updates) =>
      super.copyWith((message) => updates(message as EditPostRequest))
          as EditPostRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EditPostRequest create() => EditPostRequest._();
  @$core.override
  EditPostRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EditPostRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EditPostRequest>(create);
  static EditPostRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get postId => $_getSZ(0);
  @$pb.TagNumber(1)
  set postId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPostId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPostId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get content => $_getSZ(1);
  @$pb.TagNumber(2)
  set content($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasContent() => $_has(1);
  @$pb.TagNumber(2)
  void clearContent() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get mediaUrls => $_getList(2);
}

/// DeletePostRequest 删除内容请求
class DeletePostRequest extends $pb.GeneratedMessage {
  factory DeletePostRequest({
    $core.String? postId,
  }) {
    final result = create();
    if (postId != null) result.postId = postId;
    return result;
  }

  DeletePostRequest._();

  factory DeletePostRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeletePostRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeletePostRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'postId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeletePostRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeletePostRequest copyWith(void Function(DeletePostRequest) updates) =>
      super.copyWith((message) => updates(message as DeletePostRequest))
          as DeletePostRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeletePostRequest create() => DeletePostRequest._();
  @$core.override
  DeletePostRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeletePostRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeletePostRequest>(create);
  static DeletePostRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get postId => $_getSZ(0);
  @$pb.TagNumber(1)
  set postId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPostId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPostId() => $_clearField(1);
}

/// PinPostRequest 置顶内容请求
class PinPostRequest extends $pb.GeneratedMessage {
  factory PinPostRequest({
    $core.String? postId,
  }) {
    final result = create();
    if (postId != null) result.postId = postId;
    return result;
  }

  PinPostRequest._();

  factory PinPostRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PinPostRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PinPostRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'postId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PinPostRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PinPostRequest copyWith(void Function(PinPostRequest) updates) =>
      super.copyWith((message) => updates(message as PinPostRequest))
          as PinPostRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PinPostRequest create() => PinPostRequest._();
  @$core.override
  PinPostRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PinPostRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PinPostRequest>(create);
  static PinPostRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get postId => $_getSZ(0);
  @$pb.TagNumber(1)
  set postId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPostId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPostId() => $_clearField(1);
}

/// UnpinPostRequest 取消置顶请求
class UnpinPostRequest extends $pb.GeneratedMessage {
  factory UnpinPostRequest({
    $core.String? postId,
  }) {
    final result = create();
    if (postId != null) result.postId = postId;
    return result;
  }

  UnpinPostRequest._();

  factory UnpinPostRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UnpinPostRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UnpinPostRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'postId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnpinPostRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnpinPostRequest copyWith(void Function(UnpinPostRequest) updates) =>
      super.copyWith((message) => updates(message as UnpinPostRequest))
          as UnpinPostRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnpinPostRequest create() => UnpinPostRequest._();
  @$core.override
  UnpinPostRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UnpinPostRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UnpinPostRequest>(create);
  static UnpinPostRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get postId => $_getSZ(0);
  @$pb.TagNumber(1)
  set postId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPostId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPostId() => $_clearField(1);
}

/// PostsResponse 内容列表响应
class PostsResponse extends $pb.GeneratedMessage {
  factory PostsResponse({
    $core.Iterable<ChannelPost>? posts,
    $1.Pagination? pagination,
  }) {
    final result = create();
    if (posts != null) result.posts.addAll(posts);
    if (pagination != null) result.pagination = pagination;
    return result;
  }

  PostsResponse._();

  factory PostsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PostsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PostsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..pPM<ChannelPost>(1, _omitFieldNames ? '' : 'posts',
        subBuilder: ChannelPost.create)
    ..aOM<$1.Pagination>(2, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PostsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PostsResponse copyWith(void Function(PostsResponse) updates) =>
      super.copyWith((message) => updates(message as PostsResponse))
          as PostsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PostsResponse create() => PostsResponse._();
  @$core.override
  PostsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PostsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PostsResponse>(create);
  static PostsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ChannelPost> get posts => $_getList(0);

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

enum ChannelClientEvent_Event { subscribe, unsubscribe, ping, notSet }

/// ChannelClientEvent 客户端发送的事件
class ChannelClientEvent extends $pb.GeneratedMessage {
  factory ChannelClientEvent({
    ChannelSubscribeEvent? subscribe,
    ChannelUnsubscribeEvent? unsubscribe,
    ChannelPingEvent? ping,
  }) {
    final result = create();
    if (subscribe != null) result.subscribe = subscribe;
    if (unsubscribe != null) result.unsubscribe = unsubscribe;
    if (ping != null) result.ping = ping;
    return result;
  }

  ChannelClientEvent._();

  factory ChannelClientEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChannelClientEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, ChannelClientEvent_Event>
      _ChannelClientEvent_EventByTag = {
    1: ChannelClientEvent_Event.subscribe,
    2: ChannelClientEvent_Event.unsubscribe,
    3: ChannelClientEvent_Event.ping,
    0: ChannelClientEvent_Event.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChannelClientEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..oo(0, [1, 2, 3])
    ..aOM<ChannelSubscribeEvent>(1, _omitFieldNames ? '' : 'subscribe',
        subBuilder: ChannelSubscribeEvent.create)
    ..aOM<ChannelUnsubscribeEvent>(2, _omitFieldNames ? '' : 'unsubscribe',
        subBuilder: ChannelUnsubscribeEvent.create)
    ..aOM<ChannelPingEvent>(3, _omitFieldNames ? '' : 'ping',
        subBuilder: ChannelPingEvent.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChannelClientEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChannelClientEvent copyWith(void Function(ChannelClientEvent) updates) =>
      super.copyWith((message) => updates(message as ChannelClientEvent))
          as ChannelClientEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChannelClientEvent create() => ChannelClientEvent._();
  @$core.override
  ChannelClientEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChannelClientEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChannelClientEvent>(create);
  static ChannelClientEvent? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  ChannelClientEvent_Event whichEvent() =>
      _ChannelClientEvent_EventByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  void clearEvent() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  ChannelSubscribeEvent get subscribe => $_getN(0);
  @$pb.TagNumber(1)
  set subscribe(ChannelSubscribeEvent value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSubscribe() => $_has(0);
  @$pb.TagNumber(1)
  void clearSubscribe() => $_clearField(1);
  @$pb.TagNumber(1)
  ChannelSubscribeEvent ensureSubscribe() => $_ensure(0);

  @$pb.TagNumber(2)
  ChannelUnsubscribeEvent get unsubscribe => $_getN(1);
  @$pb.TagNumber(2)
  set unsubscribe(ChannelUnsubscribeEvent value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasUnsubscribe() => $_has(1);
  @$pb.TagNumber(2)
  void clearUnsubscribe() => $_clearField(2);
  @$pb.TagNumber(2)
  ChannelUnsubscribeEvent ensureUnsubscribe() => $_ensure(1);

  @$pb.TagNumber(3)
  ChannelPingEvent get ping => $_getN(2);
  @$pb.TagNumber(3)
  set ping(ChannelPingEvent value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasPing() => $_has(2);
  @$pb.TagNumber(3)
  void clearPing() => $_clearField(3);
  @$pb.TagNumber(3)
  ChannelPingEvent ensurePing() => $_ensure(2);
}

/// ChannelSubscribeEvent 订阅频道更新事件
class ChannelSubscribeEvent extends $pb.GeneratedMessage {
  factory ChannelSubscribeEvent({
    $core.String? channelId,
  }) {
    final result = create();
    if (channelId != null) result.channelId = channelId;
    return result;
  }

  ChannelSubscribeEvent._();

  factory ChannelSubscribeEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChannelSubscribeEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChannelSubscribeEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'channelId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChannelSubscribeEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChannelSubscribeEvent copyWith(
          void Function(ChannelSubscribeEvent) updates) =>
      super.copyWith((message) => updates(message as ChannelSubscribeEvent))
          as ChannelSubscribeEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChannelSubscribeEvent create() => ChannelSubscribeEvent._();
  @$core.override
  ChannelSubscribeEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChannelSubscribeEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChannelSubscribeEvent>(create);
  static ChannelSubscribeEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get channelId => $_getSZ(0);
  @$pb.TagNumber(1)
  set channelId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChannelId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChannelId() => $_clearField(1);
}

/// ChannelUnsubscribeEvent 取消订阅更新事件
class ChannelUnsubscribeEvent extends $pb.GeneratedMessage {
  factory ChannelUnsubscribeEvent({
    $core.String? channelId,
  }) {
    final result = create();
    if (channelId != null) result.channelId = channelId;
    return result;
  }

  ChannelUnsubscribeEvent._();

  factory ChannelUnsubscribeEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChannelUnsubscribeEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChannelUnsubscribeEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'channelId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChannelUnsubscribeEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChannelUnsubscribeEvent copyWith(
          void Function(ChannelUnsubscribeEvent) updates) =>
      super.copyWith((message) => updates(message as ChannelUnsubscribeEvent))
          as ChannelUnsubscribeEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChannelUnsubscribeEvent create() => ChannelUnsubscribeEvent._();
  @$core.override
  ChannelUnsubscribeEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChannelUnsubscribeEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChannelUnsubscribeEvent>(create);
  static ChannelUnsubscribeEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get channelId => $_getSZ(0);
  @$pb.TagNumber(1)
  set channelId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChannelId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChannelId() => $_clearField(1);
}

/// ChannelPingEvent 心跳事件
class ChannelPingEvent extends $pb.GeneratedMessage {
  factory ChannelPingEvent() => create();

  ChannelPingEvent._();

  factory ChannelPingEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChannelPingEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChannelPingEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChannelPingEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChannelPingEvent copyWith(void Function(ChannelPingEvent) updates) =>
      super.copyWith((message) => updates(message as ChannelPingEvent))
          as ChannelPingEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChannelPingEvent create() => ChannelPingEvent._();
  @$core.override
  ChannelPingEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChannelPingEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChannelPingEvent>(create);
  static ChannelPingEvent? _defaultInstance;
}

enum ChannelServerEvent_Event {
  newPost,
  postEdited,
  postDeleted,
  postPinned,
  postUnpinned,
  channelUpdated,
  channelDeleted,
  subscribed,
  unsubscribed,
  pong,
  error,
  notSet
}

/// ChannelServerEvent 服务端推送的事件
class ChannelServerEvent extends $pb.GeneratedMessage {
  factory ChannelServerEvent({
    NewPostEvent? newPost,
    PostEditedEvent? postEdited,
    PostDeletedEvent? postDeleted,
    PostPinnedEvent? postPinned,
    PostUnpinnedEvent? postUnpinned,
    ChannelUpdatedEvent? channelUpdated,
    ChannelDeletedEvent? channelDeleted,
    ChannelSubscribedEvent? subscribed,
    ChannelUnsubscribedEvent? unsubscribed,
    ChannelPongEvent? pong,
    ChannelErrorEvent? error,
  }) {
    final result = create();
    if (newPost != null) result.newPost = newPost;
    if (postEdited != null) result.postEdited = postEdited;
    if (postDeleted != null) result.postDeleted = postDeleted;
    if (postPinned != null) result.postPinned = postPinned;
    if (postUnpinned != null) result.postUnpinned = postUnpinned;
    if (channelUpdated != null) result.channelUpdated = channelUpdated;
    if (channelDeleted != null) result.channelDeleted = channelDeleted;
    if (subscribed != null) result.subscribed = subscribed;
    if (unsubscribed != null) result.unsubscribed = unsubscribed;
    if (pong != null) result.pong = pong;
    if (error != null) result.error = error;
    return result;
  }

  ChannelServerEvent._();

  factory ChannelServerEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChannelServerEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, ChannelServerEvent_Event>
      _ChannelServerEvent_EventByTag = {
    1: ChannelServerEvent_Event.newPost,
    2: ChannelServerEvent_Event.postEdited,
    3: ChannelServerEvent_Event.postDeleted,
    4: ChannelServerEvent_Event.postPinned,
    5: ChannelServerEvent_Event.postUnpinned,
    6: ChannelServerEvent_Event.channelUpdated,
    7: ChannelServerEvent_Event.channelDeleted,
    8: ChannelServerEvent_Event.subscribed,
    9: ChannelServerEvent_Event.unsubscribed,
    10: ChannelServerEvent_Event.pong,
    11: ChannelServerEvent_Event.error,
    0: ChannelServerEvent_Event.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChannelServerEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11])
    ..aOM<NewPostEvent>(1, _omitFieldNames ? '' : 'newPost',
        subBuilder: NewPostEvent.create)
    ..aOM<PostEditedEvent>(2, _omitFieldNames ? '' : 'postEdited',
        subBuilder: PostEditedEvent.create)
    ..aOM<PostDeletedEvent>(3, _omitFieldNames ? '' : 'postDeleted',
        subBuilder: PostDeletedEvent.create)
    ..aOM<PostPinnedEvent>(4, _omitFieldNames ? '' : 'postPinned',
        subBuilder: PostPinnedEvent.create)
    ..aOM<PostUnpinnedEvent>(5, _omitFieldNames ? '' : 'postUnpinned',
        subBuilder: PostUnpinnedEvent.create)
    ..aOM<ChannelUpdatedEvent>(6, _omitFieldNames ? '' : 'channelUpdated',
        subBuilder: ChannelUpdatedEvent.create)
    ..aOM<ChannelDeletedEvent>(7, _omitFieldNames ? '' : 'channelDeleted',
        subBuilder: ChannelDeletedEvent.create)
    ..aOM<ChannelSubscribedEvent>(8, _omitFieldNames ? '' : 'subscribed',
        subBuilder: ChannelSubscribedEvent.create)
    ..aOM<ChannelUnsubscribedEvent>(9, _omitFieldNames ? '' : 'unsubscribed',
        subBuilder: ChannelUnsubscribedEvent.create)
    ..aOM<ChannelPongEvent>(10, _omitFieldNames ? '' : 'pong',
        subBuilder: ChannelPongEvent.create)
    ..aOM<ChannelErrorEvent>(11, _omitFieldNames ? '' : 'error',
        subBuilder: ChannelErrorEvent.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChannelServerEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChannelServerEvent copyWith(void Function(ChannelServerEvent) updates) =>
      super.copyWith((message) => updates(message as ChannelServerEvent))
          as ChannelServerEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChannelServerEvent create() => ChannelServerEvent._();
  @$core.override
  ChannelServerEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChannelServerEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChannelServerEvent>(create);
  static ChannelServerEvent? _defaultInstance;

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
  ChannelServerEvent_Event whichEvent() =>
      _ChannelServerEvent_EventByTag[$_whichOneof(0)]!;
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
  NewPostEvent get newPost => $_getN(0);
  @$pb.TagNumber(1)
  set newPost(NewPostEvent value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasNewPost() => $_has(0);
  @$pb.TagNumber(1)
  void clearNewPost() => $_clearField(1);
  @$pb.TagNumber(1)
  NewPostEvent ensureNewPost() => $_ensure(0);

  @$pb.TagNumber(2)
  PostEditedEvent get postEdited => $_getN(1);
  @$pb.TagNumber(2)
  set postEdited(PostEditedEvent value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPostEdited() => $_has(1);
  @$pb.TagNumber(2)
  void clearPostEdited() => $_clearField(2);
  @$pb.TagNumber(2)
  PostEditedEvent ensurePostEdited() => $_ensure(1);

  @$pb.TagNumber(3)
  PostDeletedEvent get postDeleted => $_getN(2);
  @$pb.TagNumber(3)
  set postDeleted(PostDeletedEvent value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasPostDeleted() => $_has(2);
  @$pb.TagNumber(3)
  void clearPostDeleted() => $_clearField(3);
  @$pb.TagNumber(3)
  PostDeletedEvent ensurePostDeleted() => $_ensure(2);

  @$pb.TagNumber(4)
  PostPinnedEvent get postPinned => $_getN(3);
  @$pb.TagNumber(4)
  set postPinned(PostPinnedEvent value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasPostPinned() => $_has(3);
  @$pb.TagNumber(4)
  void clearPostPinned() => $_clearField(4);
  @$pb.TagNumber(4)
  PostPinnedEvent ensurePostPinned() => $_ensure(3);

  @$pb.TagNumber(5)
  PostUnpinnedEvent get postUnpinned => $_getN(4);
  @$pb.TagNumber(5)
  set postUnpinned(PostUnpinnedEvent value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasPostUnpinned() => $_has(4);
  @$pb.TagNumber(5)
  void clearPostUnpinned() => $_clearField(5);
  @$pb.TagNumber(5)
  PostUnpinnedEvent ensurePostUnpinned() => $_ensure(4);

  @$pb.TagNumber(6)
  ChannelUpdatedEvent get channelUpdated => $_getN(5);
  @$pb.TagNumber(6)
  set channelUpdated(ChannelUpdatedEvent value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasChannelUpdated() => $_has(5);
  @$pb.TagNumber(6)
  void clearChannelUpdated() => $_clearField(6);
  @$pb.TagNumber(6)
  ChannelUpdatedEvent ensureChannelUpdated() => $_ensure(5);

  @$pb.TagNumber(7)
  ChannelDeletedEvent get channelDeleted => $_getN(6);
  @$pb.TagNumber(7)
  set channelDeleted(ChannelDeletedEvent value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasChannelDeleted() => $_has(6);
  @$pb.TagNumber(7)
  void clearChannelDeleted() => $_clearField(7);
  @$pb.TagNumber(7)
  ChannelDeletedEvent ensureChannelDeleted() => $_ensure(6);

  @$pb.TagNumber(8)
  ChannelSubscribedEvent get subscribed => $_getN(7);
  @$pb.TagNumber(8)
  set subscribed(ChannelSubscribedEvent value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasSubscribed() => $_has(7);
  @$pb.TagNumber(8)
  void clearSubscribed() => $_clearField(8);
  @$pb.TagNumber(8)
  ChannelSubscribedEvent ensureSubscribed() => $_ensure(7);

  @$pb.TagNumber(9)
  ChannelUnsubscribedEvent get unsubscribed => $_getN(8);
  @$pb.TagNumber(9)
  set unsubscribed(ChannelUnsubscribedEvent value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasUnsubscribed() => $_has(8);
  @$pb.TagNumber(9)
  void clearUnsubscribed() => $_clearField(9);
  @$pb.TagNumber(9)
  ChannelUnsubscribedEvent ensureUnsubscribed() => $_ensure(8);

  @$pb.TagNumber(10)
  ChannelPongEvent get pong => $_getN(9);
  @$pb.TagNumber(10)
  set pong(ChannelPongEvent value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasPong() => $_has(9);
  @$pb.TagNumber(10)
  void clearPong() => $_clearField(10);
  @$pb.TagNumber(10)
  ChannelPongEvent ensurePong() => $_ensure(9);

  @$pb.TagNumber(11)
  ChannelErrorEvent get error => $_getN(10);
  @$pb.TagNumber(11)
  set error(ChannelErrorEvent value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasError() => $_has(10);
  @$pb.TagNumber(11)
  void clearError() => $_clearField(11);
  @$pb.TagNumber(11)
  ChannelErrorEvent ensureError() => $_ensure(10);
}

/// NewPostEvent 新内容发布事件
class NewPostEvent extends $pb.GeneratedMessage {
  factory NewPostEvent({
    ChannelPost? post,
  }) {
    final result = create();
    if (post != null) result.post = post;
    return result;
  }

  NewPostEvent._();

  factory NewPostEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NewPostEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NewPostEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOM<ChannelPost>(1, _omitFieldNames ? '' : 'post',
        subBuilder: ChannelPost.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NewPostEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NewPostEvent copyWith(void Function(NewPostEvent) updates) =>
      super.copyWith((message) => updates(message as NewPostEvent))
          as NewPostEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NewPostEvent create() => NewPostEvent._();
  @$core.override
  NewPostEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NewPostEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NewPostEvent>(create);
  static NewPostEvent? _defaultInstance;

  @$pb.TagNumber(1)
  ChannelPost get post => $_getN(0);
  @$pb.TagNumber(1)
  set post(ChannelPost value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPost() => $_has(0);
  @$pb.TagNumber(1)
  void clearPost() => $_clearField(1);
  @$pb.TagNumber(1)
  ChannelPost ensurePost() => $_ensure(0);
}

/// PostEditedEvent 内容已编辑事件
class PostEditedEvent extends $pb.GeneratedMessage {
  factory PostEditedEvent({
    ChannelPost? post,
  }) {
    final result = create();
    if (post != null) result.post = post;
    return result;
  }

  PostEditedEvent._();

  factory PostEditedEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PostEditedEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PostEditedEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOM<ChannelPost>(1, _omitFieldNames ? '' : 'post',
        subBuilder: ChannelPost.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PostEditedEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PostEditedEvent copyWith(void Function(PostEditedEvent) updates) =>
      super.copyWith((message) => updates(message as PostEditedEvent))
          as PostEditedEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PostEditedEvent create() => PostEditedEvent._();
  @$core.override
  PostEditedEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PostEditedEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PostEditedEvent>(create);
  static PostEditedEvent? _defaultInstance;

  @$pb.TagNumber(1)
  ChannelPost get post => $_getN(0);
  @$pb.TagNumber(1)
  set post(ChannelPost value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPost() => $_has(0);
  @$pb.TagNumber(1)
  void clearPost() => $_clearField(1);
  @$pb.TagNumber(1)
  ChannelPost ensurePost() => $_ensure(0);
}

/// PostDeletedEvent 内容已删除事件
class PostDeletedEvent extends $pb.GeneratedMessage {
  factory PostDeletedEvent({
    $core.String? postId,
    $core.String? channelId,
  }) {
    final result = create();
    if (postId != null) result.postId = postId;
    if (channelId != null) result.channelId = channelId;
    return result;
  }

  PostDeletedEvent._();

  factory PostDeletedEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PostDeletedEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PostDeletedEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'postId')
    ..aOS(2, _omitFieldNames ? '' : 'channelId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PostDeletedEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PostDeletedEvent copyWith(void Function(PostDeletedEvent) updates) =>
      super.copyWith((message) => updates(message as PostDeletedEvent))
          as PostDeletedEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PostDeletedEvent create() => PostDeletedEvent._();
  @$core.override
  PostDeletedEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PostDeletedEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PostDeletedEvent>(create);
  static PostDeletedEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get postId => $_getSZ(0);
  @$pb.TagNumber(1)
  set postId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPostId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPostId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get channelId => $_getSZ(1);
  @$pb.TagNumber(2)
  set channelId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasChannelId() => $_has(1);
  @$pb.TagNumber(2)
  void clearChannelId() => $_clearField(2);
}

/// PostPinnedEvent 内容已置顶事件
class PostPinnedEvent extends $pb.GeneratedMessage {
  factory PostPinnedEvent({
    ChannelPost? post,
  }) {
    final result = create();
    if (post != null) result.post = post;
    return result;
  }

  PostPinnedEvent._();

  factory PostPinnedEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PostPinnedEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PostPinnedEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOM<ChannelPost>(1, _omitFieldNames ? '' : 'post',
        subBuilder: ChannelPost.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PostPinnedEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PostPinnedEvent copyWith(void Function(PostPinnedEvent) updates) =>
      super.copyWith((message) => updates(message as PostPinnedEvent))
          as PostPinnedEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PostPinnedEvent create() => PostPinnedEvent._();
  @$core.override
  PostPinnedEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PostPinnedEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PostPinnedEvent>(create);
  static PostPinnedEvent? _defaultInstance;

  @$pb.TagNumber(1)
  ChannelPost get post => $_getN(0);
  @$pb.TagNumber(1)
  set post(ChannelPost value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPost() => $_has(0);
  @$pb.TagNumber(1)
  void clearPost() => $_clearField(1);
  @$pb.TagNumber(1)
  ChannelPost ensurePost() => $_ensure(0);
}

/// PostUnpinnedEvent 内容已取消置顶事件
class PostUnpinnedEvent extends $pb.GeneratedMessage {
  factory PostUnpinnedEvent({
    $core.String? postId,
    $core.String? channelId,
  }) {
    final result = create();
    if (postId != null) result.postId = postId;
    if (channelId != null) result.channelId = channelId;
    return result;
  }

  PostUnpinnedEvent._();

  factory PostUnpinnedEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PostUnpinnedEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PostUnpinnedEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'postId')
    ..aOS(2, _omitFieldNames ? '' : 'channelId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PostUnpinnedEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PostUnpinnedEvent copyWith(void Function(PostUnpinnedEvent) updates) =>
      super.copyWith((message) => updates(message as PostUnpinnedEvent))
          as PostUnpinnedEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PostUnpinnedEvent create() => PostUnpinnedEvent._();
  @$core.override
  PostUnpinnedEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PostUnpinnedEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PostUnpinnedEvent>(create);
  static PostUnpinnedEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get postId => $_getSZ(0);
  @$pb.TagNumber(1)
  set postId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPostId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPostId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get channelId => $_getSZ(1);
  @$pb.TagNumber(2)
  set channelId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasChannelId() => $_has(1);
  @$pb.TagNumber(2)
  void clearChannelId() => $_clearField(2);
}

/// ChannelUpdatedEvent 频道信息更新事件
class ChannelUpdatedEvent extends $pb.GeneratedMessage {
  factory ChannelUpdatedEvent({
    Channel? channel,
  }) {
    final result = create();
    if (channel != null) result.channel = channel;
    return result;
  }

  ChannelUpdatedEvent._();

  factory ChannelUpdatedEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChannelUpdatedEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChannelUpdatedEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOM<Channel>(1, _omitFieldNames ? '' : 'channel',
        subBuilder: Channel.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChannelUpdatedEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChannelUpdatedEvent copyWith(void Function(ChannelUpdatedEvent) updates) =>
      super.copyWith((message) => updates(message as ChannelUpdatedEvent))
          as ChannelUpdatedEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChannelUpdatedEvent create() => ChannelUpdatedEvent._();
  @$core.override
  ChannelUpdatedEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChannelUpdatedEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChannelUpdatedEvent>(create);
  static ChannelUpdatedEvent? _defaultInstance;

  @$pb.TagNumber(1)
  Channel get channel => $_getN(0);
  @$pb.TagNumber(1)
  set channel(Channel value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasChannel() => $_has(0);
  @$pb.TagNumber(1)
  void clearChannel() => $_clearField(1);
  @$pb.TagNumber(1)
  Channel ensureChannel() => $_ensure(0);
}

/// ChannelDeletedEvent 频道已删除事件
class ChannelDeletedEvent extends $pb.GeneratedMessage {
  factory ChannelDeletedEvent({
    $core.String? channelId,
  }) {
    final result = create();
    if (channelId != null) result.channelId = channelId;
    return result;
  }

  ChannelDeletedEvent._();

  factory ChannelDeletedEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChannelDeletedEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChannelDeletedEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'channelId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChannelDeletedEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChannelDeletedEvent copyWith(void Function(ChannelDeletedEvent) updates) =>
      super.copyWith((message) => updates(message as ChannelDeletedEvent))
          as ChannelDeletedEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChannelDeletedEvent create() => ChannelDeletedEvent._();
  @$core.override
  ChannelDeletedEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChannelDeletedEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChannelDeletedEvent>(create);
  static ChannelDeletedEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get channelId => $_getSZ(0);
  @$pb.TagNumber(1)
  set channelId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChannelId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChannelId() => $_clearField(1);
}

/// ChannelSubscribedEvent 订阅成功事件
class ChannelSubscribedEvent extends $pb.GeneratedMessage {
  factory ChannelSubscribedEvent({
    $core.String? channelId,
  }) {
    final result = create();
    if (channelId != null) result.channelId = channelId;
    return result;
  }

  ChannelSubscribedEvent._();

  factory ChannelSubscribedEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChannelSubscribedEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChannelSubscribedEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'channelId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChannelSubscribedEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChannelSubscribedEvent copyWith(
          void Function(ChannelSubscribedEvent) updates) =>
      super.copyWith((message) => updates(message as ChannelSubscribedEvent))
          as ChannelSubscribedEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChannelSubscribedEvent create() => ChannelSubscribedEvent._();
  @$core.override
  ChannelSubscribedEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChannelSubscribedEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChannelSubscribedEvent>(create);
  static ChannelSubscribedEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get channelId => $_getSZ(0);
  @$pb.TagNumber(1)
  set channelId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChannelId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChannelId() => $_clearField(1);
}

/// ChannelUnsubscribedEvent 取消订阅成功事件
class ChannelUnsubscribedEvent extends $pb.GeneratedMessage {
  factory ChannelUnsubscribedEvent({
    $core.String? channelId,
  }) {
    final result = create();
    if (channelId != null) result.channelId = channelId;
    return result;
  }

  ChannelUnsubscribedEvent._();

  factory ChannelUnsubscribedEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChannelUnsubscribedEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChannelUnsubscribedEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'channelId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChannelUnsubscribedEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChannelUnsubscribedEvent copyWith(
          void Function(ChannelUnsubscribedEvent) updates) =>
      super.copyWith((message) => updates(message as ChannelUnsubscribedEvent))
          as ChannelUnsubscribedEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChannelUnsubscribedEvent create() => ChannelUnsubscribedEvent._();
  @$core.override
  ChannelUnsubscribedEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChannelUnsubscribedEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChannelUnsubscribedEvent>(create);
  static ChannelUnsubscribedEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get channelId => $_getSZ(0);
  @$pb.TagNumber(1)
  set channelId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChannelId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChannelId() => $_clearField(1);
}

/// ChannelPongEvent 心跳响应
class ChannelPongEvent extends $pb.GeneratedMessage {
  factory ChannelPongEvent() => create();

  ChannelPongEvent._();

  factory ChannelPongEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChannelPongEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChannelPongEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChannelPongEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChannelPongEvent copyWith(void Function(ChannelPongEvent) updates) =>
      super.copyWith((message) => updates(message as ChannelPongEvent))
          as ChannelPongEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChannelPongEvent create() => ChannelPongEvent._();
  @$core.override
  ChannelPongEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChannelPongEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChannelPongEvent>(create);
  static ChannelPongEvent? _defaultInstance;
}

/// ChannelErrorEvent 错误事件
class ChannelErrorEvent extends $pb.GeneratedMessage {
  factory ChannelErrorEvent({
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

  ChannelErrorEvent._();

  factory ChannelErrorEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChannelErrorEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChannelErrorEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'channel'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOS(3, _omitFieldNames ? '' : 'action')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChannelErrorEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChannelErrorEvent copyWith(void Function(ChannelErrorEvent) updates) =>
      super.copyWith((message) => updates(message as ChannelErrorEvent))
          as ChannelErrorEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChannelErrorEvent create() => ChannelErrorEvent._();
  @$core.override
  ChannelErrorEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChannelErrorEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChannelErrorEvent>(create);
  static ChannelErrorEvent? _defaultInstance;

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

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
