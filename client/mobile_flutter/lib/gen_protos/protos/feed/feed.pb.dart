// This is a generated file - do not edit.
//
// Generated from feed/feed.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import '../common/common.pb.dart' as $1;
import '../content/content.pb.dart' as $2;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// FeedItem Feed 流中的单个条目
class FeedItem extends $pb.GeneratedMessage {
  factory FeedItem({
    $2.Content? content,
    $core.bool? isLiked,
    $core.bool? isBookmarked,
    $core.bool? isReposted,
  }) {
    final result = create();
    if (content != null) result.content = content;
    if (isLiked != null) result.isLiked = isLiked;
    if (isBookmarked != null) result.isBookmarked = isBookmarked;
    if (isReposted != null) result.isReposted = isReposted;
    return result;
  }

  FeedItem._();

  factory FeedItem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FeedItem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FeedItem',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..aOM<$2.Content>(1, _omitFieldNames ? '' : 'content',
        subBuilder: $2.Content.create)
    ..aOB(2, _omitFieldNames ? '' : 'isLiked')
    ..aOB(3, _omitFieldNames ? '' : 'isBookmarked')
    ..aOB(4, _omitFieldNames ? '' : 'isReposted')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FeedItem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FeedItem copyWith(void Function(FeedItem) updates) =>
      super.copyWith((message) => updates(message as FeedItem)) as FeedItem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FeedItem create() => FeedItem._();
  @$core.override
  FeedItem createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FeedItem getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FeedItem>(create);
  static FeedItem? _defaultInstance;

  @$pb.TagNumber(1)
  $2.Content get content => $_getN(0);
  @$pb.TagNumber(1)
  set content($2.Content value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearContent() => $_clearField(1);
  @$pb.TagNumber(1)
  $2.Content ensureContent() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.bool get isLiked => $_getBF(1);
  @$pb.TagNumber(2)
  set isLiked($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIsLiked() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsLiked() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isBookmarked => $_getBF(2);
  @$pb.TagNumber(3)
  set isBookmarked($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsBookmarked() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsBookmarked() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isReposted => $_getBF(3);
  @$pb.TagNumber(4)
  set isReposted($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIsReposted() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsReposted() => $_clearField(4);
}

/// GetFollowingFeedRequest 获取关注用户 Feed 流请求
class GetFollowingFeedRequest extends $pb.GeneratedMessage {
  factory GetFollowingFeedRequest({
    $core.String? userId,
    $1.Pagination? pagination,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (pagination != null) result.pagination = pagination;
    return result;
  }

  GetFollowingFeedRequest._();

  factory GetFollowingFeedRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFollowingFeedRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFollowingFeedRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOM<$1.Pagination>(2, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFollowingFeedRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFollowingFeedRequest copyWith(
          void Function(GetFollowingFeedRequest) updates) =>
      super.copyWith((message) => updates(message as GetFollowingFeedRequest))
          as GetFollowingFeedRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFollowingFeedRequest create() => GetFollowingFeedRequest._();
  @$core.override
  GetFollowingFeedRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFollowingFeedRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFollowingFeedRequest>(create);
  static GetFollowingFeedRequest? _defaultInstance;

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

/// GetFollowingFeedResponse 获取关注用户 Feed 流响应
class GetFollowingFeedResponse extends $pb.GeneratedMessage {
  factory GetFollowingFeedResponse({
    $core.Iterable<FeedItem>? items,
    $1.Pagination? pagination,
  }) {
    final result = create();
    if (items != null) result.items.addAll(items);
    if (pagination != null) result.pagination = pagination;
    return result;
  }

  GetFollowingFeedResponse._();

  factory GetFollowingFeedResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFollowingFeedResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFollowingFeedResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..pPM<FeedItem>(1, _omitFieldNames ? '' : 'items',
        subBuilder: FeedItem.create)
    ..aOM<$1.Pagination>(2, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFollowingFeedResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFollowingFeedResponse copyWith(
          void Function(GetFollowingFeedResponse) updates) =>
      super.copyWith((message) => updates(message as GetFollowingFeedResponse))
          as GetFollowingFeedResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFollowingFeedResponse create() => GetFollowingFeedResponse._();
  @$core.override
  GetFollowingFeedResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFollowingFeedResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFollowingFeedResponse>(create);
  static GetFollowingFeedResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<FeedItem> get items => $_getList(0);

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

/// GetRecommendFeedRequest 获取推荐 Feed 流请求（预留）
class GetRecommendFeedRequest extends $pb.GeneratedMessage {
  factory GetRecommendFeedRequest({
    $core.String? userId,
    $1.Pagination? pagination,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (pagination != null) result.pagination = pagination;
    return result;
  }

  GetRecommendFeedRequest._();

  factory GetRecommendFeedRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetRecommendFeedRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetRecommendFeedRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOM<$1.Pagination>(2, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRecommendFeedRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRecommendFeedRequest copyWith(
          void Function(GetRecommendFeedRequest) updates) =>
      super.copyWith((message) => updates(message as GetRecommendFeedRequest))
          as GetRecommendFeedRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRecommendFeedRequest create() => GetRecommendFeedRequest._();
  @$core.override
  GetRecommendFeedRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetRecommendFeedRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetRecommendFeedRequest>(create);
  static GetRecommendFeedRequest? _defaultInstance;

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

/// GetRecommendFeedResponse 获取推荐 Feed 流响应（预留）
class GetRecommendFeedResponse extends $pb.GeneratedMessage {
  factory GetRecommendFeedResponse({
    $core.Iterable<FeedItem>? items,
    $1.Pagination? pagination,
  }) {
    final result = create();
    if (items != null) result.items.addAll(items);
    if (pagination != null) result.pagination = pagination;
    return result;
  }

  GetRecommendFeedResponse._();

  factory GetRecommendFeedResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetRecommendFeedResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetRecommendFeedResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..pPM<FeedItem>(1, _omitFieldNames ? '' : 'items',
        subBuilder: FeedItem.create)
    ..aOM<$1.Pagination>(2, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRecommendFeedResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRecommendFeedResponse copyWith(
          void Function(GetRecommendFeedResponse) updates) =>
      super.copyWith((message) => updates(message as GetRecommendFeedResponse))
          as GetRecommendFeedResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRecommendFeedResponse create() => GetRecommendFeedResponse._();
  @$core.override
  GetRecommendFeedResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetRecommendFeedResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetRecommendFeedResponse>(create);
  static GetRecommendFeedResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<FeedItem> get items => $_getList(0);

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

/// GetUserFeedRequest 获取指定用户的 Feed（用户主页）
class GetUserFeedRequest extends $pb.GeneratedMessage {
  factory GetUserFeedRequest({
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

  GetUserFeedRequest._();

  factory GetUserFeedRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetUserFeedRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetUserFeedRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'viewerId')
    ..aOM<$1.Pagination>(3, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUserFeedRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUserFeedRequest copyWith(void Function(GetUserFeedRequest) updates) =>
      super.copyWith((message) => updates(message as GetUserFeedRequest))
          as GetUserFeedRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetUserFeedRequest create() => GetUserFeedRequest._();
  @$core.override
  GetUserFeedRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetUserFeedRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetUserFeedRequest>(create);
  static GetUserFeedRequest? _defaultInstance;

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

/// GetUserFeedResponse 获取指定用户的 Feed 响应
class GetUserFeedResponse extends $pb.GeneratedMessage {
  factory GetUserFeedResponse({
    $core.Iterable<FeedItem>? items,
    $1.Pagination? pagination,
  }) {
    final result = create();
    if (items != null) result.items.addAll(items);
    if (pagination != null) result.pagination = pagination;
    return result;
  }

  GetUserFeedResponse._();

  factory GetUserFeedResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetUserFeedResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetUserFeedResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..pPM<FeedItem>(1, _omitFieldNames ? '' : 'items',
        subBuilder: FeedItem.create)
    ..aOM<$1.Pagination>(2, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUserFeedResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUserFeedResponse copyWith(void Function(GetUserFeedResponse) updates) =>
      super.copyWith((message) => updates(message as GetUserFeedResponse))
          as GetUserFeedResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetUserFeedResponse create() => GetUserFeedResponse._();
  @$core.override
  GetUserFeedResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetUserFeedResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetUserFeedResponse>(create);
  static GetUserFeedResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<FeedItem> get items => $_getList(0);

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

/// Comment 评论实体
class Comment extends $pb.GeneratedMessage {
  factory Comment({
    $core.String? id,
    $core.String? authorId,
    $core.String? postId,
    $core.String? parentId,
    $core.String? content,
    $core.bool? isDeleted,
    $1.Timestamp? createdAt,
    $1.Timestamp? updatedAt,
    $core.int? replyCount,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (authorId != null) result.authorId = authorId;
    if (postId != null) result.postId = postId;
    if (parentId != null) result.parentId = parentId;
    if (content != null) result.content = content;
    if (isDeleted != null) result.isDeleted = isDeleted;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (replyCount != null) result.replyCount = replyCount;
    return result;
  }

  Comment._();

  factory Comment.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Comment.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Comment',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'authorId')
    ..aOS(3, _omitFieldNames ? '' : 'postId')
    ..aOS(4, _omitFieldNames ? '' : 'parentId')
    ..aOS(5, _omitFieldNames ? '' : 'content')
    ..aOB(6, _omitFieldNames ? '' : 'isDeleted')
    ..aOM<$1.Timestamp>(7, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $1.Timestamp.create)
    ..aOM<$1.Timestamp>(8, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $1.Timestamp.create)
    ..aI(9, _omitFieldNames ? '' : 'replyCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Comment clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Comment copyWith(void Function(Comment) updates) =>
      super.copyWith((message) => updates(message as Comment)) as Comment;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Comment create() => Comment._();
  @$core.override
  Comment createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Comment getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Comment>(create);
  static Comment? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get authorId => $_getSZ(1);
  @$pb.TagNumber(2)
  set authorId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAuthorId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAuthorId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get postId => $_getSZ(2);
  @$pb.TagNumber(3)
  set postId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPostId() => $_has(2);
  @$pb.TagNumber(3)
  void clearPostId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get parentId => $_getSZ(3);
  @$pb.TagNumber(4)
  set parentId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasParentId() => $_has(3);
  @$pb.TagNumber(4)
  void clearParentId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get content => $_getSZ(4);
  @$pb.TagNumber(5)
  set content($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasContent() => $_has(4);
  @$pb.TagNumber(5)
  void clearContent() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get isDeleted => $_getBF(5);
  @$pb.TagNumber(6)
  set isDeleted($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIsDeleted() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsDeleted() => $_clearField(6);

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
  $core.int get replyCount => $_getIZ(8);
  @$pb.TagNumber(9)
  set replyCount($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasReplyCount() => $_has(8);
  @$pb.TagNumber(9)
  void clearReplyCount() => $_clearField(9);
}

/// Repost 转发实体
class Repost extends $pb.GeneratedMessage {
  factory Repost({
    $core.String? id,
    $core.String? userId,
    $core.String? postId,
    $core.String? quote,
    $1.Timestamp? createdAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (userId != null) result.userId = userId;
    if (postId != null) result.postId = postId;
    if (quote != null) result.quote = quote;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  Repost._();

  factory Repost.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Repost.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Repost',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'postId')
    ..aOS(4, _omitFieldNames ? '' : 'quote')
    ..aOM<$1.Timestamp>(5, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Repost clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Repost copyWith(void Function(Repost) updates) =>
      super.copyWith((message) => updates(message as Repost)) as Repost;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Repost create() => Repost._();
  @$core.override
  Repost createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Repost getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Repost>(create);
  static Repost? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get postId => $_getSZ(2);
  @$pb.TagNumber(3)
  set postId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPostId() => $_has(2);
  @$pb.TagNumber(3)
  void clearPostId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get quote => $_getSZ(3);
  @$pb.TagNumber(4)
  set quote($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasQuote() => $_has(3);
  @$pb.TagNumber(4)
  void clearQuote() => $_clearField(4);

  @$pb.TagNumber(5)
  $1.Timestamp get createdAt => $_getN(4);
  @$pb.TagNumber(5)
  set createdAt($1.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasCreatedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearCreatedAt() => $_clearField(5);
  @$pb.TagNumber(5)
  $1.Timestamp ensureCreatedAt() => $_ensure(4);
}

/// Bookmark 收藏实体
class Bookmark extends $pb.GeneratedMessage {
  factory Bookmark({
    $core.String? id,
    $core.String? userId,
    $core.String? postId,
    $1.Timestamp? createdAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (userId != null) result.userId = userId;
    if (postId != null) result.postId = postId;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  Bookmark._();

  factory Bookmark.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Bookmark.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Bookmark',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'postId')
    ..aOM<$1.Timestamp>(4, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Bookmark clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Bookmark copyWith(void Function(Bookmark) updates) =>
      super.copyWith((message) => updates(message as Bookmark)) as Bookmark;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Bookmark create() => Bookmark._();
  @$core.override
  Bookmark createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Bookmark getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Bookmark>(create);
  static Bookmark? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get postId => $_getSZ(2);
  @$pb.TagNumber(3)
  set postId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPostId() => $_has(2);
  @$pb.TagNumber(3)
  void clearPostId() => $_clearField(3);

  @$pb.TagNumber(4)
  $1.Timestamp get createdAt => $_getN(3);
  @$pb.TagNumber(4)
  set createdAt($1.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCreatedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearCreatedAt() => $_clearField(4);
  @$pb.TagNumber(4)
  $1.Timestamp ensureCreatedAt() => $_ensure(3);
}

/// LikeRequest 点赞请求
class LikeRequest extends $pb.GeneratedMessage {
  factory LikeRequest({
    $core.String? userId,
    $core.String? postId,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (postId != null) result.postId = postId;
    return result;
  }

  LikeRequest._();

  factory LikeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LikeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LikeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'postId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LikeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LikeRequest copyWith(void Function(LikeRequest) updates) =>
      super.copyWith((message) => updates(message as LikeRequest))
          as LikeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LikeRequest create() => LikeRequest._();
  @$core.override
  LikeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LikeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LikeRequest>(create);
  static LikeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get postId => $_getSZ(1);
  @$pb.TagNumber(2)
  set postId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPostId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPostId() => $_clearField(2);
}

/// UnlikeRequest 取消点赞请求
class UnlikeRequest extends $pb.GeneratedMessage {
  factory UnlikeRequest({
    $core.String? userId,
    $core.String? postId,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (postId != null) result.postId = postId;
    return result;
  }

  UnlikeRequest._();

  factory UnlikeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UnlikeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UnlikeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'postId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnlikeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnlikeRequest copyWith(void Function(UnlikeRequest) updates) =>
      super.copyWith((message) => updates(message as UnlikeRequest))
          as UnlikeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnlikeRequest create() => UnlikeRequest._();
  @$core.override
  UnlikeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UnlikeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UnlikeRequest>(create);
  static UnlikeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get postId => $_getSZ(1);
  @$pb.TagNumber(2)
  set postId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPostId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPostId() => $_clearField(2);
}

/// CreateCommentRequest 创建评论请求
class CreateCommentRequest extends $pb.GeneratedMessage {
  factory CreateCommentRequest({
    $core.String? authorId,
    $core.String? postId,
    $core.String? parentId,
    $core.String? content,
  }) {
    final result = create();
    if (authorId != null) result.authorId = authorId;
    if (postId != null) result.postId = postId;
    if (parentId != null) result.parentId = parentId;
    if (content != null) result.content = content;
    return result;
  }

  CreateCommentRequest._();

  factory CreateCommentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateCommentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateCommentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'authorId')
    ..aOS(2, _omitFieldNames ? '' : 'postId')
    ..aOS(3, _omitFieldNames ? '' : 'parentId')
    ..aOS(4, _omitFieldNames ? '' : 'content')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateCommentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateCommentRequest copyWith(void Function(CreateCommentRequest) updates) =>
      super.copyWith((message) => updates(message as CreateCommentRequest))
          as CreateCommentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateCommentRequest create() => CreateCommentRequest._();
  @$core.override
  CreateCommentRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateCommentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateCommentRequest>(create);
  static CreateCommentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get authorId => $_getSZ(0);
  @$pb.TagNumber(1)
  set authorId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAuthorId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAuthorId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get postId => $_getSZ(1);
  @$pb.TagNumber(2)
  set postId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPostId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPostId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get parentId => $_getSZ(2);
  @$pb.TagNumber(3)
  set parentId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasParentId() => $_has(2);
  @$pb.TagNumber(3)
  void clearParentId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get content => $_getSZ(3);
  @$pb.TagNumber(4)
  set content($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasContent() => $_has(3);
  @$pb.TagNumber(4)
  void clearContent() => $_clearField(4);
}

/// DeleteCommentRequest 删除评论请求
class DeleteCommentRequest extends $pb.GeneratedMessage {
  factory DeleteCommentRequest({
    $core.String? commentId,
    $core.String? userId,
  }) {
    final result = create();
    if (commentId != null) result.commentId = commentId;
    if (userId != null) result.userId = userId;
    return result;
  }

  DeleteCommentRequest._();

  factory DeleteCommentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteCommentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteCommentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'commentId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteCommentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteCommentRequest copyWith(void Function(DeleteCommentRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteCommentRequest))
          as DeleteCommentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteCommentRequest create() => DeleteCommentRequest._();
  @$core.override
  DeleteCommentRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteCommentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteCommentRequest>(create);
  static DeleteCommentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get commentId => $_getSZ(0);
  @$pb.TagNumber(1)
  set commentId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCommentId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCommentId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);
}

/// ListCommentsRequest 获取评论列表请求
class ListCommentsRequest extends $pb.GeneratedMessage {
  factory ListCommentsRequest({
    $core.String? postId,
    $core.String? parentId,
    $1.Pagination? pagination,
  }) {
    final result = create();
    if (postId != null) result.postId = postId;
    if (parentId != null) result.parentId = parentId;
    if (pagination != null) result.pagination = pagination;
    return result;
  }

  ListCommentsRequest._();

  factory ListCommentsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListCommentsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListCommentsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'postId')
    ..aOS(2, _omitFieldNames ? '' : 'parentId')
    ..aOM<$1.Pagination>(3, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListCommentsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListCommentsRequest copyWith(void Function(ListCommentsRequest) updates) =>
      super.copyWith((message) => updates(message as ListCommentsRequest))
          as ListCommentsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListCommentsRequest create() => ListCommentsRequest._();
  @$core.override
  ListCommentsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListCommentsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListCommentsRequest>(create);
  static ListCommentsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get postId => $_getSZ(0);
  @$pb.TagNumber(1)
  set postId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPostId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPostId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get parentId => $_getSZ(1);
  @$pb.TagNumber(2)
  set parentId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasParentId() => $_has(1);
  @$pb.TagNumber(2)
  void clearParentId() => $_clearField(2);

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

/// ListCommentsResponse 评论列表响应
class ListCommentsResponse extends $pb.GeneratedMessage {
  factory ListCommentsResponse({
    $core.Iterable<Comment>? comments,
    $1.Pagination? pagination,
  }) {
    final result = create();
    if (comments != null) result.comments.addAll(comments);
    if (pagination != null) result.pagination = pagination;
    return result;
  }

  ListCommentsResponse._();

  factory ListCommentsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListCommentsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListCommentsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..pPM<Comment>(1, _omitFieldNames ? '' : 'comments',
        subBuilder: Comment.create)
    ..aOM<$1.Pagination>(2, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListCommentsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListCommentsResponse copyWith(void Function(ListCommentsResponse) updates) =>
      super.copyWith((message) => updates(message as ListCommentsResponse))
          as ListCommentsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListCommentsResponse create() => ListCommentsResponse._();
  @$core.override
  ListCommentsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListCommentsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListCommentsResponse>(create);
  static ListCommentsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Comment> get comments => $_getList(0);

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

/// RepostRequest 转发请求
class RepostRequest extends $pb.GeneratedMessage {
  factory RepostRequest({
    $core.String? userId,
    $core.String? postId,
    $core.String? quote,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (postId != null) result.postId = postId;
    if (quote != null) result.quote = quote;
    return result;
  }

  RepostRequest._();

  factory RepostRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RepostRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RepostRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'postId')
    ..aOS(3, _omitFieldNames ? '' : 'quote')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RepostRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RepostRequest copyWith(void Function(RepostRequest) updates) =>
      super.copyWith((message) => updates(message as RepostRequest))
          as RepostRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RepostRequest create() => RepostRequest._();
  @$core.override
  RepostRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RepostRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RepostRequest>(create);
  static RepostRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get postId => $_getSZ(1);
  @$pb.TagNumber(2)
  set postId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPostId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPostId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get quote => $_getSZ(2);
  @$pb.TagNumber(3)
  set quote($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasQuote() => $_has(2);
  @$pb.TagNumber(3)
  void clearQuote() => $_clearField(3);
}

/// BookmarkRequest 收藏请求
class BookmarkRequest extends $pb.GeneratedMessage {
  factory BookmarkRequest({
    $core.String? userId,
    $core.String? postId,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (postId != null) result.postId = postId;
    return result;
  }

  BookmarkRequest._();

  factory BookmarkRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BookmarkRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BookmarkRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'postId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BookmarkRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BookmarkRequest copyWith(void Function(BookmarkRequest) updates) =>
      super.copyWith((message) => updates(message as BookmarkRequest))
          as BookmarkRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BookmarkRequest create() => BookmarkRequest._();
  @$core.override
  BookmarkRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BookmarkRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BookmarkRequest>(create);
  static BookmarkRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get postId => $_getSZ(1);
  @$pb.TagNumber(2)
  set postId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPostId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPostId() => $_clearField(2);
}

/// UnbookmarkRequest 取消收藏请求
class UnbookmarkRequest extends $pb.GeneratedMessage {
  factory UnbookmarkRequest({
    $core.String? userId,
    $core.String? postId,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (postId != null) result.postId = postId;
    return result;
  }

  UnbookmarkRequest._();

  factory UnbookmarkRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UnbookmarkRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UnbookmarkRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'postId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnbookmarkRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnbookmarkRequest copyWith(void Function(UnbookmarkRequest) updates) =>
      super.copyWith((message) => updates(message as UnbookmarkRequest))
          as UnbookmarkRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnbookmarkRequest create() => UnbookmarkRequest._();
  @$core.override
  UnbookmarkRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UnbookmarkRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UnbookmarkRequest>(create);
  static UnbookmarkRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get postId => $_getSZ(1);
  @$pb.TagNumber(2)
  set postId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPostId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPostId() => $_clearField(2);
}

/// ListBookmarksRequest 获取收藏列表请求
class ListBookmarksRequest extends $pb.GeneratedMessage {
  factory ListBookmarksRequest({
    $core.String? userId,
    $1.Pagination? pagination,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (pagination != null) result.pagination = pagination;
    return result;
  }

  ListBookmarksRequest._();

  factory ListBookmarksRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListBookmarksRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListBookmarksRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOM<$1.Pagination>(2, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBookmarksRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBookmarksRequest copyWith(void Function(ListBookmarksRequest) updates) =>
      super.copyWith((message) => updates(message as ListBookmarksRequest))
          as ListBookmarksRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListBookmarksRequest create() => ListBookmarksRequest._();
  @$core.override
  ListBookmarksRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListBookmarksRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListBookmarksRequest>(create);
  static ListBookmarksRequest? _defaultInstance;

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

/// ListBookmarksResponse 收藏列表响应
class ListBookmarksResponse extends $pb.GeneratedMessage {
  factory ListBookmarksResponse({
    $core.Iterable<Bookmark>? bookmarks,
    $1.Pagination? pagination,
  }) {
    final result = create();
    if (bookmarks != null) result.bookmarks.addAll(bookmarks);
    if (pagination != null) result.pagination = pagination;
    return result;
  }

  ListBookmarksResponse._();

  factory ListBookmarksResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListBookmarksResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListBookmarksResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'feed'),
      createEmptyInstance: create)
    ..pPM<Bookmark>(1, _omitFieldNames ? '' : 'bookmarks',
        subBuilder: Bookmark.create)
    ..aOM<$1.Pagination>(2, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBookmarksResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBookmarksResponse copyWith(
          void Function(ListBookmarksResponse) updates) =>
      super.copyWith((message) => updates(message as ListBookmarksResponse))
          as ListBookmarksResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListBookmarksResponse create() => ListBookmarksResponse._();
  @$core.override
  ListBookmarksResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListBookmarksResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListBookmarksResponse>(create);
  static ListBookmarksResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Bookmark> get bookmarks => $_getList(0);

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
