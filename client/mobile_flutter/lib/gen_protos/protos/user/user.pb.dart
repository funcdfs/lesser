// This is a generated file - do not edit.
//
// Generated from user/user.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import '../common/common.pb.dart' as $1;
import 'user.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'user.pbenum.dart';

/// Profile 用户资料
class Profile extends $pb.GeneratedMessage {
  factory Profile({
    $core.String? id,
    $core.String? username,
    $core.String? email,
    $core.String? displayName,
    $core.String? avatarUrl,
    $core.String? bio,
    $core.String? location,
    $core.String? website,
    $core.String? birthday,
    $core.bool? isVerified,
    $core.bool? isPrivate,
    $core.int? followersCount,
    $core.int? followingCount,
    $core.int? postsCount,
    $1.Timestamp? createdAt,
    $1.Timestamp? updatedAt,
    RelationshipStatus? relationship,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (username != null) result.username = username;
    if (email != null) result.email = email;
    if (displayName != null) result.displayName = displayName;
    if (avatarUrl != null) result.avatarUrl = avatarUrl;
    if (bio != null) result.bio = bio;
    if (location != null) result.location = location;
    if (website != null) result.website = website;
    if (birthday != null) result.birthday = birthday;
    if (isVerified != null) result.isVerified = isVerified;
    if (isPrivate != null) result.isPrivate = isPrivate;
    if (followersCount != null) result.followersCount = followersCount;
    if (followingCount != null) result.followingCount = followingCount;
    if (postsCount != null) result.postsCount = postsCount;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (relationship != null) result.relationship = relationship;
    return result;
  }

  Profile._();

  factory Profile.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Profile.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Profile',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'user'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'username')
    ..aOS(3, _omitFieldNames ? '' : 'email')
    ..aOS(4, _omitFieldNames ? '' : 'displayName')
    ..aOS(5, _omitFieldNames ? '' : 'avatarUrl')
    ..aOS(6, _omitFieldNames ? '' : 'bio')
    ..aOS(7, _omitFieldNames ? '' : 'location')
    ..aOS(8, _omitFieldNames ? '' : 'website')
    ..aOS(9, _omitFieldNames ? '' : 'birthday')
    ..aOB(10, _omitFieldNames ? '' : 'isVerified')
    ..aOB(11, _omitFieldNames ? '' : 'isPrivate')
    ..aI(12, _omitFieldNames ? '' : 'followersCount')
    ..aI(13, _omitFieldNames ? '' : 'followingCount')
    ..aI(14, _omitFieldNames ? '' : 'postsCount')
    ..aOM<$1.Timestamp>(15, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $1.Timestamp.create)
    ..aOM<$1.Timestamp>(16, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $1.Timestamp.create)
    ..aOM<RelationshipStatus>(17, _omitFieldNames ? '' : 'relationship',
        subBuilder: RelationshipStatus.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Profile clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Profile copyWith(void Function(Profile) updates) =>
      super.copyWith((message) => updates(message as Profile)) as Profile;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Profile create() => Profile._();
  @$core.override
  Profile createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Profile getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Profile>(create);
  static Profile? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get username => $_getSZ(1);
  @$pb.TagNumber(2)
  set username($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUsername() => $_has(1);
  @$pb.TagNumber(2)
  void clearUsername() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get email => $_getSZ(2);
  @$pb.TagNumber(3)
  set email($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEmail() => $_has(2);
  @$pb.TagNumber(3)
  void clearEmail() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get displayName => $_getSZ(3);
  @$pb.TagNumber(4)
  set displayName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDisplayName() => $_has(3);
  @$pb.TagNumber(4)
  void clearDisplayName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get avatarUrl => $_getSZ(4);
  @$pb.TagNumber(5)
  set avatarUrl($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAvatarUrl() => $_has(4);
  @$pb.TagNumber(5)
  void clearAvatarUrl() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get bio => $_getSZ(5);
  @$pb.TagNumber(6)
  set bio($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBio() => $_has(5);
  @$pb.TagNumber(6)
  void clearBio() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get location => $_getSZ(6);
  @$pb.TagNumber(7)
  set location($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasLocation() => $_has(6);
  @$pb.TagNumber(7)
  void clearLocation() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get website => $_getSZ(7);
  @$pb.TagNumber(8)
  set website($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasWebsite() => $_has(7);
  @$pb.TagNumber(8)
  void clearWebsite() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get birthday => $_getSZ(8);
  @$pb.TagNumber(9)
  set birthday($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasBirthday() => $_has(8);
  @$pb.TagNumber(9)
  void clearBirthday() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get isVerified => $_getBF(9);
  @$pb.TagNumber(10)
  set isVerified($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasIsVerified() => $_has(9);
  @$pb.TagNumber(10)
  void clearIsVerified() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.bool get isPrivate => $_getBF(10);
  @$pb.TagNumber(11)
  set isPrivate($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasIsPrivate() => $_has(10);
  @$pb.TagNumber(11)
  void clearIsPrivate() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.int get followersCount => $_getIZ(11);
  @$pb.TagNumber(12)
  set followersCount($core.int value) => $_setSignedInt32(11, value);
  @$pb.TagNumber(12)
  $core.bool hasFollowersCount() => $_has(11);
  @$pb.TagNumber(12)
  void clearFollowersCount() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.int get followingCount => $_getIZ(12);
  @$pb.TagNumber(13)
  set followingCount($core.int value) => $_setSignedInt32(12, value);
  @$pb.TagNumber(13)
  $core.bool hasFollowingCount() => $_has(12);
  @$pb.TagNumber(13)
  void clearFollowingCount() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.int get postsCount => $_getIZ(13);
  @$pb.TagNumber(14)
  set postsCount($core.int value) => $_setSignedInt32(13, value);
  @$pb.TagNumber(14)
  $core.bool hasPostsCount() => $_has(13);
  @$pb.TagNumber(14)
  void clearPostsCount() => $_clearField(14);

  @$pb.TagNumber(15)
  $1.Timestamp get createdAt => $_getN(14);
  @$pb.TagNumber(15)
  set createdAt($1.Timestamp value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasCreatedAt() => $_has(14);
  @$pb.TagNumber(15)
  void clearCreatedAt() => $_clearField(15);
  @$pb.TagNumber(15)
  $1.Timestamp ensureCreatedAt() => $_ensure(14);

  @$pb.TagNumber(16)
  $1.Timestamp get updatedAt => $_getN(15);
  @$pb.TagNumber(16)
  set updatedAt($1.Timestamp value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasUpdatedAt() => $_has(15);
  @$pb.TagNumber(16)
  void clearUpdatedAt() => $_clearField(16);
  @$pb.TagNumber(16)
  $1.Timestamp ensureUpdatedAt() => $_ensure(15);

  /// 查看者视角的关系状态（可选，仅在需要时填充）
  @$pb.TagNumber(17)
  RelationshipStatus get relationship => $_getN(16);
  @$pb.TagNumber(17)
  set relationship(RelationshipStatus value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasRelationship() => $_has(16);
  @$pb.TagNumber(17)
  void clearRelationship() => $_clearField(17);
  @$pb.TagNumber(17)
  RelationshipStatus ensureRelationship() => $_ensure(16);
}

/// RelationshipStatus 关系状态（从查看者视角）
class RelationshipStatus extends $pb.GeneratedMessage {
  factory RelationshipStatus({
    $core.bool? isFollowing,
    $core.bool? isFollowedBy,
    $core.bool? isMutual,
    $core.bool? isBlocking,
    $core.bool? isBlockedBy,
    $core.bool? isMuting,
    $core.bool? isHidingFrom,
  }) {
    final result = create();
    if (isFollowing != null) result.isFollowing = isFollowing;
    if (isFollowedBy != null) result.isFollowedBy = isFollowedBy;
    if (isMutual != null) result.isMutual = isMutual;
    if (isBlocking != null) result.isBlocking = isBlocking;
    if (isBlockedBy != null) result.isBlockedBy = isBlockedBy;
    if (isMuting != null) result.isMuting = isMuting;
    if (isHidingFrom != null) result.isHidingFrom = isHidingFrom;
    return result;
  }

  RelationshipStatus._();

  factory RelationshipStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RelationshipStatus.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RelationshipStatus',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'user'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'isFollowing')
    ..aOB(2, _omitFieldNames ? '' : 'isFollowedBy')
    ..aOB(3, _omitFieldNames ? '' : 'isMutual')
    ..aOB(4, _omitFieldNames ? '' : 'isBlocking')
    ..aOB(5, _omitFieldNames ? '' : 'isBlockedBy')
    ..aOB(6, _omitFieldNames ? '' : 'isMuting')
    ..aOB(7, _omitFieldNames ? '' : 'isHidingFrom')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RelationshipStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RelationshipStatus copyWith(void Function(RelationshipStatus) updates) =>
      super.copyWith((message) => updates(message as RelationshipStatus))
          as RelationshipStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RelationshipStatus create() => RelationshipStatus._();
  @$core.override
  RelationshipStatus createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RelationshipStatus getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RelationshipStatus>(create);
  static RelationshipStatus? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get isFollowing => $_getBF(0);
  @$pb.TagNumber(1)
  set isFollowing($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIsFollowing() => $_has(0);
  @$pb.TagNumber(1)
  void clearIsFollowing() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get isFollowedBy => $_getBF(1);
  @$pb.TagNumber(2)
  set isFollowedBy($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIsFollowedBy() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsFollowedBy() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isMutual => $_getBF(2);
  @$pb.TagNumber(3)
  set isMutual($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsMutual() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsMutual() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isBlocking => $_getBF(3);
  @$pb.TagNumber(4)
  set isBlocking($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIsBlocking() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsBlocking() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get isBlockedBy => $_getBF(4);
  @$pb.TagNumber(5)
  set isBlockedBy($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIsBlockedBy() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsBlockedBy() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get isMuting => $_getBF(5);
  @$pb.TagNumber(6)
  set isMuting($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIsMuting() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsMuting() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get isHidingFrom => $_getBF(6);
  @$pb.TagNumber(7)
  set isHidingFrom($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasIsHidingFrom() => $_has(6);
  @$pb.TagNumber(7)
  void clearIsHidingFrom() => $_clearField(7);
}

/// GetProfileRequest 获取用户资料请求
class GetProfileRequest extends $pb.GeneratedMessage {
  factory GetProfileRequest({
    $core.String? userId,
    $core.String? viewerId,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (viewerId != null) result.viewerId = viewerId;
    return result;
  }

  GetProfileRequest._();

  factory GetProfileRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetProfileRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetProfileRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'user'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'viewerId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetProfileRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetProfileRequest copyWith(void Function(GetProfileRequest) updates) =>
      super.copyWith((message) => updates(message as GetProfileRequest))
          as GetProfileRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetProfileRequest create() => GetProfileRequest._();
  @$core.override
  GetProfileRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetProfileRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetProfileRequest>(create);
  static GetProfileRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get viewerId => $_getSZ(1);
  @$pb.TagNumber(2)
  set viewerId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasViewerId() => $_has(1);
  @$pb.TagNumber(2)
  void clearViewerId() => $_clearField(2);
}

/// GetProfileByUsernameRequest 通过用户名获取资料
class GetProfileByUsernameRequest extends $pb.GeneratedMessage {
  factory GetProfileByUsernameRequest({
    $core.String? username,
    $core.String? viewerId,
  }) {
    final result = create();
    if (username != null) result.username = username;
    if (viewerId != null) result.viewerId = viewerId;
    return result;
  }

  GetProfileByUsernameRequest._();

  factory GetProfileByUsernameRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetProfileByUsernameRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetProfileByUsernameRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'user'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'username')
    ..aOS(2, _omitFieldNames ? '' : 'viewerId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetProfileByUsernameRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetProfileByUsernameRequest copyWith(
          void Function(GetProfileByUsernameRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetProfileByUsernameRequest))
          as GetProfileByUsernameRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetProfileByUsernameRequest create() =>
      GetProfileByUsernameRequest._();
  @$core.override
  GetProfileByUsernameRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetProfileByUsernameRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetProfileByUsernameRequest>(create);
  static GetProfileByUsernameRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get username => $_getSZ(0);
  @$pb.TagNumber(1)
  set username($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUsername() => $_has(0);
  @$pb.TagNumber(1)
  void clearUsername() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get viewerId => $_getSZ(1);
  @$pb.TagNumber(2)
  set viewerId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasViewerId() => $_has(1);
  @$pb.TagNumber(2)
  void clearViewerId() => $_clearField(2);
}

/// UpdateProfileRequest 更新用户资料请求
class UpdateProfileRequest extends $pb.GeneratedMessage {
  factory UpdateProfileRequest({
    $core.String? userId,
    $core.String? displayName,
    $core.String? avatarUrl,
    $core.String? bio,
    $core.String? location,
    $core.String? website,
    $core.String? birthday,
    $core.bool? isPrivate,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (displayName != null) result.displayName = displayName;
    if (avatarUrl != null) result.avatarUrl = avatarUrl;
    if (bio != null) result.bio = bio;
    if (location != null) result.location = location;
    if (website != null) result.website = website;
    if (birthday != null) result.birthday = birthday;
    if (isPrivate != null) result.isPrivate = isPrivate;
    return result;
  }

  UpdateProfileRequest._();

  factory UpdateProfileRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateProfileRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateProfileRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'user'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'displayName')
    ..aOS(3, _omitFieldNames ? '' : 'avatarUrl')
    ..aOS(4, _omitFieldNames ? '' : 'bio')
    ..aOS(5, _omitFieldNames ? '' : 'location')
    ..aOS(6, _omitFieldNames ? '' : 'website')
    ..aOS(7, _omitFieldNames ? '' : 'birthday')
    ..aOB(8, _omitFieldNames ? '' : 'isPrivate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateProfileRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateProfileRequest copyWith(void Function(UpdateProfileRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateProfileRequest))
          as UpdateProfileRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateProfileRequest create() => UpdateProfileRequest._();
  @$core.override
  UpdateProfileRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateProfileRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateProfileRequest>(create);
  static UpdateProfileRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get displayName => $_getSZ(1);
  @$pb.TagNumber(2)
  set displayName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDisplayName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisplayName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get avatarUrl => $_getSZ(2);
  @$pb.TagNumber(3)
  set avatarUrl($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAvatarUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearAvatarUrl() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get bio => $_getSZ(3);
  @$pb.TagNumber(4)
  set bio($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBio() => $_has(3);
  @$pb.TagNumber(4)
  void clearBio() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get location => $_getSZ(4);
  @$pb.TagNumber(5)
  set location($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLocation() => $_has(4);
  @$pb.TagNumber(5)
  void clearLocation() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get website => $_getSZ(5);
  @$pb.TagNumber(6)
  set website($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasWebsite() => $_has(5);
  @$pb.TagNumber(6)
  void clearWebsite() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get birthday => $_getSZ(6);
  @$pb.TagNumber(7)
  set birthday($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasBirthday() => $_has(6);
  @$pb.TagNumber(7)
  void clearBirthday() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get isPrivate => $_getBF(7);
  @$pb.TagNumber(8)
  set isPrivate($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasIsPrivate() => $_has(7);
  @$pb.TagNumber(8)
  void clearIsPrivate() => $_clearField(8);
}

/// BatchGetProfilesRequest 批量获取用户资料
class BatchGetProfilesRequest extends $pb.GeneratedMessage {
  factory BatchGetProfilesRequest({
    $core.Iterable<$core.String>? userIds,
    $core.String? viewerId,
  }) {
    final result = create();
    if (userIds != null) result.userIds.addAll(userIds);
    if (viewerId != null) result.viewerId = viewerId;
    return result;
  }

  BatchGetProfilesRequest._();

  factory BatchGetProfilesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BatchGetProfilesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BatchGetProfilesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'user'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'userIds')
    ..aOS(2, _omitFieldNames ? '' : 'viewerId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BatchGetProfilesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BatchGetProfilesRequest copyWith(
          void Function(BatchGetProfilesRequest) updates) =>
      super.copyWith((message) => updates(message as BatchGetProfilesRequest))
          as BatchGetProfilesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BatchGetProfilesRequest create() => BatchGetProfilesRequest._();
  @$core.override
  BatchGetProfilesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BatchGetProfilesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BatchGetProfilesRequest>(create);
  static BatchGetProfilesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get userIds => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get viewerId => $_getSZ(1);
  @$pb.TagNumber(2)
  set viewerId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasViewerId() => $_has(1);
  @$pb.TagNumber(2)
  void clearViewerId() => $_clearField(2);
}

/// BatchGetProfilesResponse 批量获取用户资料响应
class BatchGetProfilesResponse extends $pb.GeneratedMessage {
  factory BatchGetProfilesResponse({
    $core.Iterable<$core.MapEntry<$core.String, Profile>>? profiles,
  }) {
    final result = create();
    if (profiles != null) result.profiles.addEntries(profiles);
    return result;
  }

  BatchGetProfilesResponse._();

  factory BatchGetProfilesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BatchGetProfilesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BatchGetProfilesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'user'),
      createEmptyInstance: create)
    ..m<$core.String, Profile>(1, _omitFieldNames ? '' : 'profiles',
        entryClassName: 'BatchGetProfilesResponse.ProfilesEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: Profile.create,
        valueDefaultOrMaker: Profile.getDefault,
        packageName: const $pb.PackageName('user'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BatchGetProfilesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BatchGetProfilesResponse copyWith(
          void Function(BatchGetProfilesResponse) updates) =>
      super.copyWith((message) => updates(message as BatchGetProfilesResponse))
          as BatchGetProfilesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BatchGetProfilesResponse create() => BatchGetProfilesResponse._();
  @$core.override
  BatchGetProfilesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BatchGetProfilesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BatchGetProfilesResponse>(create);
  static BatchGetProfilesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbMap<$core.String, Profile> get profiles => $_getMap(0);
}

/// FollowRequest 关注请求
class FollowRequest extends $pb.GeneratedMessage {
  factory FollowRequest({
    $core.String? followerId,
    $core.String? followingId,
  }) {
    final result = create();
    if (followerId != null) result.followerId = followerId;
    if (followingId != null) result.followingId = followingId;
    return result;
  }

  FollowRequest._();

  factory FollowRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FollowRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FollowRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'user'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'followerId')
    ..aOS(2, _omitFieldNames ? '' : 'followingId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FollowRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FollowRequest copyWith(void Function(FollowRequest) updates) =>
      super.copyWith((message) => updates(message as FollowRequest))
          as FollowRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FollowRequest create() => FollowRequest._();
  @$core.override
  FollowRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FollowRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FollowRequest>(create);
  static FollowRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get followerId => $_getSZ(0);
  @$pb.TagNumber(1)
  set followerId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFollowerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFollowerId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get followingId => $_getSZ(1);
  @$pb.TagNumber(2)
  set followingId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFollowingId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFollowingId() => $_clearField(2);
}

/// UnfollowRequest 取消关注请求
class UnfollowRequest extends $pb.GeneratedMessage {
  factory UnfollowRequest({
    $core.String? followerId,
    $core.String? followingId,
  }) {
    final result = create();
    if (followerId != null) result.followerId = followerId;
    if (followingId != null) result.followingId = followingId;
    return result;
  }

  UnfollowRequest._();

  factory UnfollowRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UnfollowRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UnfollowRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'user'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'followerId')
    ..aOS(2, _omitFieldNames ? '' : 'followingId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnfollowRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnfollowRequest copyWith(void Function(UnfollowRequest) updates) =>
      super.copyWith((message) => updates(message as UnfollowRequest))
          as UnfollowRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnfollowRequest create() => UnfollowRequest._();
  @$core.override
  UnfollowRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UnfollowRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UnfollowRequest>(create);
  static UnfollowRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get followerId => $_getSZ(0);
  @$pb.TagNumber(1)
  set followerId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFollowerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFollowerId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get followingId => $_getSZ(1);
  @$pb.TagNumber(2)
  set followingId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFollowingId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFollowingId() => $_clearField(2);
}

/// GetFollowersRequest 获取粉丝列表请求
class GetFollowersRequest extends $pb.GeneratedMessage {
  factory GetFollowersRequest({
    $core.String? userId,
    $core.String? viewerId,
    $1.Pagination? pagination,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (viewerId != null) result.viewerId = viewerId;
    if (pagination != null) result.pagination = pagination;
    return result;
  }

  GetFollowersRequest._();

  factory GetFollowersRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFollowersRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFollowersRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'user'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'viewerId')
    ..aOM<$1.Pagination>(3, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFollowersRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFollowersRequest copyWith(void Function(GetFollowersRequest) updates) =>
      super.copyWith((message) => updates(message as GetFollowersRequest))
          as GetFollowersRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFollowersRequest create() => GetFollowersRequest._();
  @$core.override
  GetFollowersRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFollowersRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFollowersRequest>(create);
  static GetFollowersRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get viewerId => $_getSZ(1);
  @$pb.TagNumber(2)
  set viewerId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasViewerId() => $_has(1);
  @$pb.TagNumber(2)
  void clearViewerId() => $_clearField(2);

  @$pb.TagNumber(3)
  $1.Pagination get pagination => $_getN(2);
  @$pb.TagNumber(3)
  set pagination($1.Pagination value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasPagination() => $_has(2);
  @$pb.TagNumber(3)
  void clearPagination() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.Pagination ensurePagination() => $_ensure(2);
}

/// GetFollowingRequest 获取关注列表请求
class GetFollowingRequest extends $pb.GeneratedMessage {
  factory GetFollowingRequest({
    $core.String? userId,
    $core.String? viewerId,
    $1.Pagination? pagination,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (viewerId != null) result.viewerId = viewerId;
    if (pagination != null) result.pagination = pagination;
    return result;
  }

  GetFollowingRequest._();

  factory GetFollowingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFollowingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFollowingRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'user'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'viewerId')
    ..aOM<$1.Pagination>(3, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFollowingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFollowingRequest copyWith(void Function(GetFollowingRequest) updates) =>
      super.copyWith((message) => updates(message as GetFollowingRequest))
          as GetFollowingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFollowingRequest create() => GetFollowingRequest._();
  @$core.override
  GetFollowingRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFollowingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFollowingRequest>(create);
  static GetFollowingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get viewerId => $_getSZ(1);
  @$pb.TagNumber(2)
  set viewerId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasViewerId() => $_has(1);
  @$pb.TagNumber(2)
  void clearViewerId() => $_clearField(2);

  @$pb.TagNumber(3)
  $1.Pagination get pagination => $_getN(2);
  @$pb.TagNumber(3)
  set pagination($1.Pagination value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasPagination() => $_has(2);
  @$pb.TagNumber(3)
  void clearPagination() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.Pagination ensurePagination() => $_ensure(2);
}

/// FollowListResponse 关注/粉丝列表响应
class FollowListResponse extends $pb.GeneratedMessage {
  factory FollowListResponse({
    $core.Iterable<Profile>? users,
    $1.Pagination? pagination,
  }) {
    final result = create();
    if (users != null) result.users.addAll(users);
    if (pagination != null) result.pagination = pagination;
    return result;
  }

  FollowListResponse._();

  factory FollowListResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FollowListResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FollowListResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'user'),
      createEmptyInstance: create)
    ..pPM<Profile>(1, _omitFieldNames ? '' : 'users',
        subBuilder: Profile.create)
    ..aOM<$1.Pagination>(2, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FollowListResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FollowListResponse copyWith(void Function(FollowListResponse) updates) =>
      super.copyWith((message) => updates(message as FollowListResponse))
          as FollowListResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FollowListResponse create() => FollowListResponse._();
  @$core.override
  FollowListResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FollowListResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FollowListResponse>(create);
  static FollowListResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Profile> get users => $_getList(0);

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

/// CheckFollowingRequest 检查是否关注请求
class CheckFollowingRequest extends $pb.GeneratedMessage {
  factory CheckFollowingRequest({
    $core.String? followerId,
    $core.String? followingId,
  }) {
    final result = create();
    if (followerId != null) result.followerId = followerId;
    if (followingId != null) result.followingId = followingId;
    return result;
  }

  CheckFollowingRequest._();

  factory CheckFollowingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CheckFollowingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CheckFollowingRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'user'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'followerId')
    ..aOS(2, _omitFieldNames ? '' : 'followingId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckFollowingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckFollowingRequest copyWith(
          void Function(CheckFollowingRequest) updates) =>
      super.copyWith((message) => updates(message as CheckFollowingRequest))
          as CheckFollowingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CheckFollowingRequest create() => CheckFollowingRequest._();
  @$core.override
  CheckFollowingRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CheckFollowingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CheckFollowingRequest>(create);
  static CheckFollowingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get followerId => $_getSZ(0);
  @$pb.TagNumber(1)
  set followerId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFollowerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFollowerId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get followingId => $_getSZ(1);
  @$pb.TagNumber(2)
  set followingId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFollowingId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFollowingId() => $_clearField(2);
}

/// CheckFollowingResponse 检查是否关注响应
class CheckFollowingResponse extends $pb.GeneratedMessage {
  factory CheckFollowingResponse({
    $core.bool? isFollowing,
  }) {
    final result = create();
    if (isFollowing != null) result.isFollowing = isFollowing;
    return result;
  }

  CheckFollowingResponse._();

  factory CheckFollowingResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CheckFollowingResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CheckFollowingResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'user'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'isFollowing')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckFollowingResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckFollowingResponse copyWith(
          void Function(CheckFollowingResponse) updates) =>
      super.copyWith((message) => updates(message as CheckFollowingResponse))
          as CheckFollowingResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CheckFollowingResponse create() => CheckFollowingResponse._();
  @$core.override
  CheckFollowingResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CheckFollowingResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CheckFollowingResponse>(create);
  static CheckFollowingResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get isFollowing => $_getBF(0);
  @$pb.TagNumber(1)
  set isFollowing($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIsFollowing() => $_has(0);
  @$pb.TagNumber(1)
  void clearIsFollowing() => $_clearField(1);
}

/// GetRelationshipRequest 获取两用户间关系
class GetRelationshipRequest extends $pb.GeneratedMessage {
  factory GetRelationshipRequest({
    $core.String? userId,
    $core.String? targetId,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (targetId != null) result.targetId = targetId;
    return result;
  }

  GetRelationshipRequest._();

  factory GetRelationshipRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetRelationshipRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetRelationshipRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'user'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'targetId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRelationshipRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRelationshipRequest copyWith(
          void Function(GetRelationshipRequest) updates) =>
      super.copyWith((message) => updates(message as GetRelationshipRequest))
          as GetRelationshipRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRelationshipRequest create() => GetRelationshipRequest._();
  @$core.override
  GetRelationshipRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetRelationshipRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetRelationshipRequest>(create);
  static GetRelationshipRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get targetId => $_getSZ(1);
  @$pb.TagNumber(2)
  set targetId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTargetId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTargetId() => $_clearField(2);
}

/// GetRelationshipResponse 关系响应
class GetRelationshipResponse extends $pb.GeneratedMessage {
  factory GetRelationshipResponse({
    RelationshipStatus? relationship,
  }) {
    final result = create();
    if (relationship != null) result.relationship = relationship;
    return result;
  }

  GetRelationshipResponse._();

  factory GetRelationshipResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetRelationshipResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetRelationshipResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'user'),
      createEmptyInstance: create)
    ..aOM<RelationshipStatus>(1, _omitFieldNames ? '' : 'relationship',
        subBuilder: RelationshipStatus.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRelationshipResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRelationshipResponse copyWith(
          void Function(GetRelationshipResponse) updates) =>
      super.copyWith((message) => updates(message as GetRelationshipResponse))
          as GetRelationshipResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRelationshipResponse create() => GetRelationshipResponse._();
  @$core.override
  GetRelationshipResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetRelationshipResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetRelationshipResponse>(create);
  static GetRelationshipResponse? _defaultInstance;

  @$pb.TagNumber(1)
  RelationshipStatus get relationship => $_getN(0);
  @$pb.TagNumber(1)
  set relationship(RelationshipStatus value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasRelationship() => $_has(0);
  @$pb.TagNumber(1)
  void clearRelationship() => $_clearField(1);
  @$pb.TagNumber(1)
  RelationshipStatus ensureRelationship() => $_ensure(0);
}

/// GetMutualFollowersRequest 获取共同关注
class GetMutualFollowersRequest extends $pb.GeneratedMessage {
  factory GetMutualFollowersRequest({
    $core.String? userId,
    $core.String? targetId,
    $1.Pagination? pagination,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (targetId != null) result.targetId = targetId;
    if (pagination != null) result.pagination = pagination;
    return result;
  }

  GetMutualFollowersRequest._();

  factory GetMutualFollowersRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMutualFollowersRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMutualFollowersRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'user'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'targetId')
    ..aOM<$1.Pagination>(3, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMutualFollowersRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMutualFollowersRequest copyWith(
          void Function(GetMutualFollowersRequest) updates) =>
      super.copyWith((message) => updates(message as GetMutualFollowersRequest))
          as GetMutualFollowersRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMutualFollowersRequest create() => GetMutualFollowersRequest._();
  @$core.override
  GetMutualFollowersRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetMutualFollowersRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMutualFollowersRequest>(create);
  static GetMutualFollowersRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get targetId => $_getSZ(1);
  @$pb.TagNumber(2)
  set targetId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTargetId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTargetId() => $_clearField(2);

  @$pb.TagNumber(3)
  $1.Pagination get pagination => $_getN(2);
  @$pb.TagNumber(3)
  set pagination($1.Pagination value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasPagination() => $_has(2);
  @$pb.TagNumber(3)
  void clearPagination() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.Pagination ensurePagination() => $_ensure(2);
}

/// BlockRequest 屏蔽请求
class BlockRequest extends $pb.GeneratedMessage {
  factory BlockRequest({
    $core.String? blockerId,
    $core.String? blockedId,
    BlockType? blockType,
  }) {
    final result = create();
    if (blockerId != null) result.blockerId = blockerId;
    if (blockedId != null) result.blockedId = blockedId;
    if (blockType != null) result.blockType = blockType;
    return result;
  }

  BlockRequest._();

  factory BlockRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BlockRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BlockRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'user'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'blockerId')
    ..aOS(2, _omitFieldNames ? '' : 'blockedId')
    ..aE<BlockType>(3, _omitFieldNames ? '' : 'blockType',
        enumValues: BlockType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockRequest copyWith(void Function(BlockRequest) updates) =>
      super.copyWith((message) => updates(message as BlockRequest))
          as BlockRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BlockRequest create() => BlockRequest._();
  @$core.override
  BlockRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BlockRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BlockRequest>(create);
  static BlockRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get blockerId => $_getSZ(0);
  @$pb.TagNumber(1)
  set blockerId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBlockerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockerId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get blockedId => $_getSZ(1);
  @$pb.TagNumber(2)
  set blockedId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBlockedId() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlockedId() => $_clearField(2);

  @$pb.TagNumber(3)
  BlockType get blockType => $_getN(2);
  @$pb.TagNumber(3)
  set blockType(BlockType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasBlockType() => $_has(2);
  @$pb.TagNumber(3)
  void clearBlockType() => $_clearField(3);
}

/// UnblockRequest 取消屏蔽请求
class UnblockRequest extends $pb.GeneratedMessage {
  factory UnblockRequest({
    $core.String? blockerId,
    $core.String? blockedId,
    BlockType? blockType,
  }) {
    final result = create();
    if (blockerId != null) result.blockerId = blockerId;
    if (blockedId != null) result.blockedId = blockedId;
    if (blockType != null) result.blockType = blockType;
    return result;
  }

  UnblockRequest._();

  factory UnblockRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UnblockRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UnblockRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'user'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'blockerId')
    ..aOS(2, _omitFieldNames ? '' : 'blockedId')
    ..aE<BlockType>(3, _omitFieldNames ? '' : 'blockType',
        enumValues: BlockType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnblockRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnblockRequest copyWith(void Function(UnblockRequest) updates) =>
      super.copyWith((message) => updates(message as UnblockRequest))
          as UnblockRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnblockRequest create() => UnblockRequest._();
  @$core.override
  UnblockRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UnblockRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UnblockRequest>(create);
  static UnblockRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get blockerId => $_getSZ(0);
  @$pb.TagNumber(1)
  set blockerId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBlockerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockerId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get blockedId => $_getSZ(1);
  @$pb.TagNumber(2)
  set blockedId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBlockedId() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlockedId() => $_clearField(2);

  @$pb.TagNumber(3)
  BlockType get blockType => $_getN(2);
  @$pb.TagNumber(3)
  set blockType(BlockType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasBlockType() => $_has(2);
  @$pb.TagNumber(3)
  void clearBlockType() => $_clearField(3);
}

/// GetBlockListRequest 获取屏蔽列表
class GetBlockListRequest extends $pb.GeneratedMessage {
  factory GetBlockListRequest({
    $core.String? userId,
    BlockType? blockType,
    $1.Pagination? pagination,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (blockType != null) result.blockType = blockType;
    if (pagination != null) result.pagination = pagination;
    return result;
  }

  GetBlockListRequest._();

  factory GetBlockListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetBlockListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetBlockListRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'user'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aE<BlockType>(2, _omitFieldNames ? '' : 'blockType',
        enumValues: BlockType.values)
    ..aOM<$1.Pagination>(3, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockListRequest copyWith(void Function(GetBlockListRequest) updates) =>
      super.copyWith((message) => updates(message as GetBlockListRequest))
          as GetBlockListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBlockListRequest create() => GetBlockListRequest._();
  @$core.override
  GetBlockListRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetBlockListRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBlockListRequest>(create);
  static GetBlockListRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  BlockType get blockType => $_getN(1);
  @$pb.TagNumber(2)
  set blockType(BlockType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasBlockType() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlockType() => $_clearField(2);

  @$pb.TagNumber(3)
  $1.Pagination get pagination => $_getN(2);
  @$pb.TagNumber(3)
  set pagination($1.Pagination value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasPagination() => $_has(2);
  @$pb.TagNumber(3)
  void clearPagination() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.Pagination ensurePagination() => $_ensure(2);
}

/// BlockListResponse 屏蔽列表响应
class BlockListResponse extends $pb.GeneratedMessage {
  factory BlockListResponse({
    $core.Iterable<BlockedUser>? users,
    $1.Pagination? pagination,
  }) {
    final result = create();
    if (users != null) result.users.addAll(users);
    if (pagination != null) result.pagination = pagination;
    return result;
  }

  BlockListResponse._();

  factory BlockListResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BlockListResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BlockListResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'user'),
      createEmptyInstance: create)
    ..pPM<BlockedUser>(1, _omitFieldNames ? '' : 'users',
        subBuilder: BlockedUser.create)
    ..aOM<$1.Pagination>(2, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockListResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockListResponse copyWith(void Function(BlockListResponse) updates) =>
      super.copyWith((message) => updates(message as BlockListResponse))
          as BlockListResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BlockListResponse create() => BlockListResponse._();
  @$core.override
  BlockListResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BlockListResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BlockListResponse>(create);
  static BlockListResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<BlockedUser> get users => $_getList(0);

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

/// BlockedUser 被屏蔽的用户
class BlockedUser extends $pb.GeneratedMessage {
  factory BlockedUser({
    Profile? profile,
    BlockType? blockType,
    $1.Timestamp? blockedAt,
  }) {
    final result = create();
    if (profile != null) result.profile = profile;
    if (blockType != null) result.blockType = blockType;
    if (blockedAt != null) result.blockedAt = blockedAt;
    return result;
  }

  BlockedUser._();

  factory BlockedUser.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BlockedUser.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BlockedUser',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'user'),
      createEmptyInstance: create)
    ..aOM<Profile>(1, _omitFieldNames ? '' : 'profile',
        subBuilder: Profile.create)
    ..aE<BlockType>(2, _omitFieldNames ? '' : 'blockType',
        enumValues: BlockType.values)
    ..aOM<$1.Timestamp>(3, _omitFieldNames ? '' : 'blockedAt',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockedUser clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockedUser copyWith(void Function(BlockedUser) updates) =>
      super.copyWith((message) => updates(message as BlockedUser))
          as BlockedUser;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BlockedUser create() => BlockedUser._();
  @$core.override
  BlockedUser createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BlockedUser getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BlockedUser>(create);
  static BlockedUser? _defaultInstance;

  @$pb.TagNumber(1)
  Profile get profile => $_getN(0);
  @$pb.TagNumber(1)
  set profile(Profile value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasProfile() => $_has(0);
  @$pb.TagNumber(1)
  void clearProfile() => $_clearField(1);
  @$pb.TagNumber(1)
  Profile ensureProfile() => $_ensure(0);

  @$pb.TagNumber(2)
  BlockType get blockType => $_getN(1);
  @$pb.TagNumber(2)
  set blockType(BlockType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasBlockType() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlockType() => $_clearField(2);

  @$pb.TagNumber(3)
  $1.Timestamp get blockedAt => $_getN(2);
  @$pb.TagNumber(3)
  set blockedAt($1.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasBlockedAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearBlockedAt() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.Timestamp ensureBlockedAt() => $_ensure(2);
}

/// CheckBlockedRequest 检查屏蔽状态
class CheckBlockedRequest extends $pb.GeneratedMessage {
  factory CheckBlockedRequest({
    $core.String? userId,
    $core.String? targetId,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (targetId != null) result.targetId = targetId;
    return result;
  }

  CheckBlockedRequest._();

  factory CheckBlockedRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CheckBlockedRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CheckBlockedRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'user'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'targetId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckBlockedRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckBlockedRequest copyWith(void Function(CheckBlockedRequest) updates) =>
      super.copyWith((message) => updates(message as CheckBlockedRequest))
          as CheckBlockedRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CheckBlockedRequest create() => CheckBlockedRequest._();
  @$core.override
  CheckBlockedRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CheckBlockedRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CheckBlockedRequest>(create);
  static CheckBlockedRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get targetId => $_getSZ(1);
  @$pb.TagNumber(2)
  set targetId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTargetId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTargetId() => $_clearField(2);
}

/// CheckBlockedResponse 屏蔽状态响应
class CheckBlockedResponse extends $pb.GeneratedMessage {
  factory CheckBlockedResponse({
    $core.bool? isBlocking,
    $core.bool? isBlockedBy,
    BlockType? myBlockType,
    BlockType? theirBlockType,
    $core.bool? canViewProfile,
    $core.bool? canBeViewed,
  }) {
    final result = create();
    if (isBlocking != null) result.isBlocking = isBlocking;
    if (isBlockedBy != null) result.isBlockedBy = isBlockedBy;
    if (myBlockType != null) result.myBlockType = myBlockType;
    if (theirBlockType != null) result.theirBlockType = theirBlockType;
    if (canViewProfile != null) result.canViewProfile = canViewProfile;
    if (canBeViewed != null) result.canBeViewed = canBeViewed;
    return result;
  }

  CheckBlockedResponse._();

  factory CheckBlockedResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CheckBlockedResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CheckBlockedResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'user'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'isBlocking')
    ..aOB(2, _omitFieldNames ? '' : 'isBlockedBy')
    ..aE<BlockType>(3, _omitFieldNames ? '' : 'myBlockType',
        enumValues: BlockType.values)
    ..aE<BlockType>(4, _omitFieldNames ? '' : 'theirBlockType',
        enumValues: BlockType.values)
    ..aOB(5, _omitFieldNames ? '' : 'canViewProfile')
    ..aOB(6, _omitFieldNames ? '' : 'canBeViewed')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckBlockedResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckBlockedResponse copyWith(void Function(CheckBlockedResponse) updates) =>
      super.copyWith((message) => updates(message as CheckBlockedResponse))
          as CheckBlockedResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CheckBlockedResponse create() => CheckBlockedResponse._();
  @$core.override
  CheckBlockedResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CheckBlockedResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CheckBlockedResponse>(create);
  static CheckBlockedResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get isBlocking => $_getBF(0);
  @$pb.TagNumber(1)
  set isBlocking($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIsBlocking() => $_has(0);
  @$pb.TagNumber(1)
  void clearIsBlocking() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get isBlockedBy => $_getBF(1);
  @$pb.TagNumber(2)
  set isBlockedBy($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIsBlockedBy() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsBlockedBy() => $_clearField(2);

  @$pb.TagNumber(3)
  BlockType get myBlockType => $_getN(2);
  @$pb.TagNumber(3)
  set myBlockType(BlockType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasMyBlockType() => $_has(2);
  @$pb.TagNumber(3)
  void clearMyBlockType() => $_clearField(3);

  @$pb.TagNumber(4)
  BlockType get theirBlockType => $_getN(3);
  @$pb.TagNumber(4)
  set theirBlockType(BlockType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasTheirBlockType() => $_has(3);
  @$pb.TagNumber(4)
  void clearTheirBlockType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get canViewProfile => $_getBF(4);
  @$pb.TagNumber(5)
  set canViewProfile($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCanViewProfile() => $_has(4);
  @$pb.TagNumber(5)
  void clearCanViewProfile() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get canBeViewed => $_getBF(5);
  @$pb.TagNumber(6)
  set canBeViewed($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCanBeViewed() => $_has(5);
  @$pb.TagNumber(6)
  void clearCanBeViewed() => $_clearField(6);
}

/// UserSettings 用户设置
class UserSettings extends $pb.GeneratedMessage {
  factory UserSettings({
    $core.String? userId,
    PrivacySettings? privacy,
    NotificationSettings? notification,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (privacy != null) result.privacy = privacy;
    if (notification != null) result.notification = notification;
    return result;
  }

  UserSettings._();

  factory UserSettings.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UserSettings.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UserSettings',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'user'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOM<PrivacySettings>(2, _omitFieldNames ? '' : 'privacy',
        subBuilder: PrivacySettings.create)
    ..aOM<NotificationSettings>(3, _omitFieldNames ? '' : 'notification',
        subBuilder: NotificationSettings.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserSettings clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserSettings copyWith(void Function(UserSettings) updates) =>
      super.copyWith((message) => updates(message as UserSettings))
          as UserSettings;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserSettings create() => UserSettings._();
  @$core.override
  UserSettings createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UserSettings getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UserSettings>(create);
  static UserSettings? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  PrivacySettings get privacy => $_getN(1);
  @$pb.TagNumber(2)
  set privacy(PrivacySettings value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPrivacy() => $_has(1);
  @$pb.TagNumber(2)
  void clearPrivacy() => $_clearField(2);
  @$pb.TagNumber(2)
  PrivacySettings ensurePrivacy() => $_ensure(1);

  @$pb.TagNumber(3)
  NotificationSettings get notification => $_getN(2);
  @$pb.TagNumber(3)
  set notification(NotificationSettings value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasNotification() => $_has(2);
  @$pb.TagNumber(3)
  void clearNotification() => $_clearField(3);
  @$pb.TagNumber(3)
  NotificationSettings ensureNotification() => $_ensure(2);
}

/// PrivacySettings 隐私设置
class PrivacySettings extends $pb.GeneratedMessage {
  factory PrivacySettings({
    $core.bool? isPrivateAccount,
    $core.bool? allowMessageFromAnyone,
    $core.bool? showOnlineStatus,
    $core.bool? showLastSeen,
    $core.bool? allowTagging,
    $core.bool? showActivityStatus,
  }) {
    final result = create();
    if (isPrivateAccount != null) result.isPrivateAccount = isPrivateAccount;
    if (allowMessageFromAnyone != null)
      result.allowMessageFromAnyone = allowMessageFromAnyone;
    if (showOnlineStatus != null) result.showOnlineStatus = showOnlineStatus;
    if (showLastSeen != null) result.showLastSeen = showLastSeen;
    if (allowTagging != null) result.allowTagging = allowTagging;
    if (showActivityStatus != null)
      result.showActivityStatus = showActivityStatus;
    return result;
  }

  PrivacySettings._();

  factory PrivacySettings.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PrivacySettings.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PrivacySettings',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'user'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'isPrivateAccount')
    ..aOB(2, _omitFieldNames ? '' : 'allowMessageFromAnyone')
    ..aOB(3, _omitFieldNames ? '' : 'showOnlineStatus')
    ..aOB(4, _omitFieldNames ? '' : 'showLastSeen')
    ..aOB(5, _omitFieldNames ? '' : 'allowTagging')
    ..aOB(6, _omitFieldNames ? '' : 'showActivityStatus')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrivacySettings clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrivacySettings copyWith(void Function(PrivacySettings) updates) =>
      super.copyWith((message) => updates(message as PrivacySettings))
          as PrivacySettings;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PrivacySettings create() => PrivacySettings._();
  @$core.override
  PrivacySettings createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PrivacySettings getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PrivacySettings>(create);
  static PrivacySettings? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get isPrivateAccount => $_getBF(0);
  @$pb.TagNumber(1)
  set isPrivateAccount($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIsPrivateAccount() => $_has(0);
  @$pb.TagNumber(1)
  void clearIsPrivateAccount() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get allowMessageFromAnyone => $_getBF(1);
  @$pb.TagNumber(2)
  set allowMessageFromAnyone($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAllowMessageFromAnyone() => $_has(1);
  @$pb.TagNumber(2)
  void clearAllowMessageFromAnyone() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get showOnlineStatus => $_getBF(2);
  @$pb.TagNumber(3)
  set showOnlineStatus($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasShowOnlineStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearShowOnlineStatus() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get showLastSeen => $_getBF(3);
  @$pb.TagNumber(4)
  set showLastSeen($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasShowLastSeen() => $_has(3);
  @$pb.TagNumber(4)
  void clearShowLastSeen() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get allowTagging => $_getBF(4);
  @$pb.TagNumber(5)
  set allowTagging($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAllowTagging() => $_has(4);
  @$pb.TagNumber(5)
  void clearAllowTagging() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get showActivityStatus => $_getBF(5);
  @$pb.TagNumber(6)
  set showActivityStatus($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasShowActivityStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearShowActivityStatus() => $_clearField(6);
}

/// NotificationSettings 通知设置
class NotificationSettings extends $pb.GeneratedMessage {
  factory NotificationSettings({
    $core.bool? pushEnabled,
    $core.bool? emailEnabled,
    $core.bool? notifyNewFollower,
    $core.bool? notifyLike,
    $core.bool? notifyComment,
    $core.bool? notifyMention,
    $core.bool? notifyRepost,
    $core.bool? notifyMessage,
  }) {
    final result = create();
    if (pushEnabled != null) result.pushEnabled = pushEnabled;
    if (emailEnabled != null) result.emailEnabled = emailEnabled;
    if (notifyNewFollower != null) result.notifyNewFollower = notifyNewFollower;
    if (notifyLike != null) result.notifyLike = notifyLike;
    if (notifyComment != null) result.notifyComment = notifyComment;
    if (notifyMention != null) result.notifyMention = notifyMention;
    if (notifyRepost != null) result.notifyRepost = notifyRepost;
    if (notifyMessage != null) result.notifyMessage = notifyMessage;
    return result;
  }

  NotificationSettings._();

  factory NotificationSettings.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NotificationSettings.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NotificationSettings',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'user'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'pushEnabled')
    ..aOB(2, _omitFieldNames ? '' : 'emailEnabled')
    ..aOB(3, _omitFieldNames ? '' : 'notifyNewFollower')
    ..aOB(4, _omitFieldNames ? '' : 'notifyLike')
    ..aOB(5, _omitFieldNames ? '' : 'notifyComment')
    ..aOB(6, _omitFieldNames ? '' : 'notifyMention')
    ..aOB(7, _omitFieldNames ? '' : 'notifyRepost')
    ..aOB(8, _omitFieldNames ? '' : 'notifyMessage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationSettings clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationSettings copyWith(void Function(NotificationSettings) updates) =>
      super.copyWith((message) => updates(message as NotificationSettings))
          as NotificationSettings;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NotificationSettings create() => NotificationSettings._();
  @$core.override
  NotificationSettings createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NotificationSettings getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NotificationSettings>(create);
  static NotificationSettings? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get pushEnabled => $_getBF(0);
  @$pb.TagNumber(1)
  set pushEnabled($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPushEnabled() => $_has(0);
  @$pb.TagNumber(1)
  void clearPushEnabled() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get emailEnabled => $_getBF(1);
  @$pb.TagNumber(2)
  set emailEnabled($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEmailEnabled() => $_has(1);
  @$pb.TagNumber(2)
  void clearEmailEnabled() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get notifyNewFollower => $_getBF(2);
  @$pb.TagNumber(3)
  set notifyNewFollower($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNotifyNewFollower() => $_has(2);
  @$pb.TagNumber(3)
  void clearNotifyNewFollower() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get notifyLike => $_getBF(3);
  @$pb.TagNumber(4)
  set notifyLike($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNotifyLike() => $_has(3);
  @$pb.TagNumber(4)
  void clearNotifyLike() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get notifyComment => $_getBF(4);
  @$pb.TagNumber(5)
  set notifyComment($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasNotifyComment() => $_has(4);
  @$pb.TagNumber(5)
  void clearNotifyComment() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get notifyMention => $_getBF(5);
  @$pb.TagNumber(6)
  set notifyMention($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasNotifyMention() => $_has(5);
  @$pb.TagNumber(6)
  void clearNotifyMention() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get notifyRepost => $_getBF(6);
  @$pb.TagNumber(7)
  set notifyRepost($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasNotifyRepost() => $_has(6);
  @$pb.TagNumber(7)
  void clearNotifyRepost() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get notifyMessage => $_getBF(7);
  @$pb.TagNumber(8)
  set notifyMessage($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasNotifyMessage() => $_has(7);
  @$pb.TagNumber(8)
  void clearNotifyMessage() => $_clearField(8);
}

/// GetUserSettingsRequest 获取用户设置
class GetUserSettingsRequest extends $pb.GeneratedMessage {
  factory GetUserSettingsRequest({
    $core.String? userId,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    return result;
  }

  GetUserSettingsRequest._();

  factory GetUserSettingsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetUserSettingsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetUserSettingsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'user'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUserSettingsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUserSettingsRequest copyWith(
          void Function(GetUserSettingsRequest) updates) =>
      super.copyWith((message) => updates(message as GetUserSettingsRequest))
          as GetUserSettingsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetUserSettingsRequest create() => GetUserSettingsRequest._();
  @$core.override
  GetUserSettingsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetUserSettingsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetUserSettingsRequest>(create);
  static GetUserSettingsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);
}

/// UpdateUserSettingsRequest 更新用户设置
class UpdateUserSettingsRequest extends $pb.GeneratedMessage {
  factory UpdateUserSettingsRequest({
    $core.String? userId,
    PrivacySettings? privacy,
    NotificationSettings? notification,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (privacy != null) result.privacy = privacy;
    if (notification != null) result.notification = notification;
    return result;
  }

  UpdateUserSettingsRequest._();

  factory UpdateUserSettingsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateUserSettingsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateUserSettingsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'user'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOM<PrivacySettings>(2, _omitFieldNames ? '' : 'privacy',
        subBuilder: PrivacySettings.create)
    ..aOM<NotificationSettings>(3, _omitFieldNames ? '' : 'notification',
        subBuilder: NotificationSettings.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateUserSettingsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateUserSettingsRequest copyWith(
          void Function(UpdateUserSettingsRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateUserSettingsRequest))
          as UpdateUserSettingsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateUserSettingsRequest create() => UpdateUserSettingsRequest._();
  @$core.override
  UpdateUserSettingsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateUserSettingsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateUserSettingsRequest>(create);
  static UpdateUserSettingsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  PrivacySettings get privacy => $_getN(1);
  @$pb.TagNumber(2)
  set privacy(PrivacySettings value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPrivacy() => $_has(1);
  @$pb.TagNumber(2)
  void clearPrivacy() => $_clearField(2);
  @$pb.TagNumber(2)
  PrivacySettings ensurePrivacy() => $_ensure(1);

  @$pb.TagNumber(3)
  NotificationSettings get notification => $_getN(2);
  @$pb.TagNumber(3)
  set notification(NotificationSettings value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasNotification() => $_has(2);
  @$pb.TagNumber(3)
  void clearNotification() => $_clearField(3);
  @$pb.TagNumber(3)
  NotificationSettings ensureNotification() => $_ensure(2);
}

/// SearchUsersRequest 搜索用户请求
class SearchUsersRequest extends $pb.GeneratedMessage {
  factory SearchUsersRequest({
    $core.String? query,
    $core.String? viewerId,
    $1.Pagination? pagination,
  }) {
    final result = create();
    if (query != null) result.query = query;
    if (viewerId != null) result.viewerId = viewerId;
    if (pagination != null) result.pagination = pagination;
    return result;
  }

  SearchUsersRequest._();

  factory SearchUsersRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SearchUsersRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchUsersRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'user'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'viewerId')
    ..aOM<$1.Pagination>(3, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchUsersRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchUsersRequest copyWith(void Function(SearchUsersRequest) updates) =>
      super.copyWith((message) => updates(message as SearchUsersRequest))
          as SearchUsersRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SearchUsersRequest create() => SearchUsersRequest._();
  @$core.override
  SearchUsersRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SearchUsersRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SearchUsersRequest>(create);
  static SearchUsersRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get viewerId => $_getSZ(1);
  @$pb.TagNumber(2)
  set viewerId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasViewerId() => $_has(1);
  @$pb.TagNumber(2)
  void clearViewerId() => $_clearField(2);

  @$pb.TagNumber(3)
  $1.Pagination get pagination => $_getN(2);
  @$pb.TagNumber(3)
  set pagination($1.Pagination value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasPagination() => $_has(2);
  @$pb.TagNumber(3)
  void clearPagination() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.Pagination ensurePagination() => $_ensure(2);
}

/// SearchUsersResponse 搜索用户响应
class SearchUsersResponse extends $pb.GeneratedMessage {
  factory SearchUsersResponse({
    $core.Iterable<Profile>? users,
    $1.Pagination? pagination,
  }) {
    final result = create();
    if (users != null) result.users.addAll(users);
    if (pagination != null) result.pagination = pagination;
    return result;
  }

  SearchUsersResponse._();

  factory SearchUsersResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SearchUsersResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchUsersResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'user'),
      createEmptyInstance: create)
    ..pPM<Profile>(1, _omitFieldNames ? '' : 'users',
        subBuilder: Profile.create)
    ..aOM<$1.Pagination>(2, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchUsersResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchUsersResponse copyWith(void Function(SearchUsersResponse) updates) =>
      super.copyWith((message) => updates(message as SearchUsersResponse))
          as SearchUsersResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SearchUsersResponse create() => SearchUsersResponse._();
  @$core.override
  SearchUsersResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SearchUsersResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SearchUsersResponse>(create);
  static SearchUsersResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Profile> get users => $_getList(0);

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

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
