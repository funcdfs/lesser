// This is a generated file - do not edit.
//
// Generated from content/content.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import '../common/common.pb.dart' as $1;
import 'content.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'content.pbenum.dart';

/// Media 媒体附件
class Media extends $pb.GeneratedMessage {
  factory Media({
    $core.String? id,
    MediaType? type,
    $core.String? url,
    $core.String? thumbnailUrl,
    $core.int? width,
    $core.int? height,
    $core.int? duration,
    $core.String? altText,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (type != null) result.type = type;
    if (url != null) result.url = url;
    if (thumbnailUrl != null) result.thumbnailUrl = thumbnailUrl;
    if (width != null) result.width = width;
    if (height != null) result.height = height;
    if (duration != null) result.duration = duration;
    if (altText != null) result.altText = altText;
    return result;
  }

  Media._();

  factory Media.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Media.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Media',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'content'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aE<MediaType>(2, _omitFieldNames ? '' : 'type',
        enumValues: MediaType.values)
    ..aOS(3, _omitFieldNames ? '' : 'url')
    ..aOS(4, _omitFieldNames ? '' : 'thumbnailUrl')
    ..aI(5, _omitFieldNames ? '' : 'width')
    ..aI(6, _omitFieldNames ? '' : 'height')
    ..aI(7, _omitFieldNames ? '' : 'duration')
    ..aOS(8, _omitFieldNames ? '' : 'altText')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Media clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Media copyWith(void Function(Media) updates) =>
      super.copyWith((message) => updates(message as Media)) as Media;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Media create() => Media._();
  @$core.override
  Media createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Media getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Media>(create);
  static Media? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  MediaType get type => $_getN(1);
  @$pb.TagNumber(2)
  set type(MediaType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get url => $_getSZ(2);
  @$pb.TagNumber(3)
  set url($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearUrl() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get thumbnailUrl => $_getSZ(3);
  @$pb.TagNumber(4)
  set thumbnailUrl($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasThumbnailUrl() => $_has(3);
  @$pb.TagNumber(4)
  void clearThumbnailUrl() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get width => $_getIZ(4);
  @$pb.TagNumber(5)
  set width($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasWidth() => $_has(4);
  @$pb.TagNumber(5)
  void clearWidth() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get height => $_getIZ(5);
  @$pb.TagNumber(6)
  set height($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasHeight() => $_has(5);
  @$pb.TagNumber(6)
  void clearHeight() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get duration => $_getIZ(6);
  @$pb.TagNumber(7)
  set duration($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDuration() => $_has(6);
  @$pb.TagNumber(7)
  void clearDuration() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get altText => $_getSZ(7);
  @$pb.TagNumber(8)
  set altText($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasAltText() => $_has(7);
  @$pb.TagNumber(8)
  void clearAltText() => $_clearField(8);
}

/// Content 内容实体
class Content extends $pb.GeneratedMessage {
  factory Content({
    $core.String? id,
    $core.String? authorId,
    ContentType? type,
    ContentStatus? status,
    $core.String? title,
    $core.String? text,
    $core.String? summary,
    $core.Iterable<Media>? media,
    $core.Iterable<$core.String>? tags,
    $core.String? replyToId,
    $core.String? quoteId,
    $core.int? likeCount,
    $core.int? commentCount,
    $core.int? repostCount,
    $core.int? bookmarkCount,
    $core.int? viewCount,
    $1.Timestamp? createdAt,
    $1.Timestamp? updatedAt,
    $1.Timestamp? publishedAt,
    $1.Timestamp? expiresAt,
    $core.bool? isPinned,
    $core.bool? commentsDisabled,
    $core.String? language,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (authorId != null) result.authorId = authorId;
    if (type != null) result.type = type;
    if (status != null) result.status = status;
    if (title != null) result.title = title;
    if (text != null) result.text = text;
    if (summary != null) result.summary = summary;
    if (media != null) result.media.addAll(media);
    if (tags != null) result.tags.addAll(tags);
    if (replyToId != null) result.replyToId = replyToId;
    if (quoteId != null) result.quoteId = quoteId;
    if (likeCount != null) result.likeCount = likeCount;
    if (commentCount != null) result.commentCount = commentCount;
    if (repostCount != null) result.repostCount = repostCount;
    if (bookmarkCount != null) result.bookmarkCount = bookmarkCount;
    if (viewCount != null) result.viewCount = viewCount;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (publishedAt != null) result.publishedAt = publishedAt;
    if (expiresAt != null) result.expiresAt = expiresAt;
    if (isPinned != null) result.isPinned = isPinned;
    if (commentsDisabled != null) result.commentsDisabled = commentsDisabled;
    if (language != null) result.language = language;
    return result;
  }

  Content._();

  factory Content.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Content.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Content',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'content'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'authorId')
    ..aE<ContentType>(3, _omitFieldNames ? '' : 'type',
        enumValues: ContentType.values)
    ..aE<ContentStatus>(4, _omitFieldNames ? '' : 'status',
        enumValues: ContentStatus.values)
    ..aOS(5, _omitFieldNames ? '' : 'title')
    ..aOS(6, _omitFieldNames ? '' : 'text')
    ..aOS(7, _omitFieldNames ? '' : 'summary')
    ..pPM<Media>(8, _omitFieldNames ? '' : 'media', subBuilder: Media.create)
    ..pPS(9, _omitFieldNames ? '' : 'tags')
    ..aOS(10, _omitFieldNames ? '' : 'replyToId')
    ..aOS(11, _omitFieldNames ? '' : 'quoteId')
    ..aI(20, _omitFieldNames ? '' : 'likeCount')
    ..aI(21, _omitFieldNames ? '' : 'commentCount')
    ..aI(22, _omitFieldNames ? '' : 'repostCount')
    ..aI(23, _omitFieldNames ? '' : 'bookmarkCount')
    ..aI(24, _omitFieldNames ? '' : 'viewCount')
    ..aOM<$1.Timestamp>(30, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $1.Timestamp.create)
    ..aOM<$1.Timestamp>(31, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $1.Timestamp.create)
    ..aOM<$1.Timestamp>(32, _omitFieldNames ? '' : 'publishedAt',
        subBuilder: $1.Timestamp.create)
    ..aOM<$1.Timestamp>(33, _omitFieldNames ? '' : 'expiresAt',
        subBuilder: $1.Timestamp.create)
    ..aOB(40, _omitFieldNames ? '' : 'isPinned')
    ..aOB(41, _omitFieldNames ? '' : 'commentsDisabled')
    ..aOS(42, _omitFieldNames ? '' : 'language')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Content clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Content copyWith(void Function(Content) updates) =>
      super.copyWith((message) => updates(message as Content)) as Content;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Content create() => Content._();
  @$core.override
  Content createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Content getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Content>(create);
  static Content? _defaultInstance;

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
  ContentType get type => $_getN(2);
  @$pb.TagNumber(3)
  set type(ContentType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasType() => $_has(2);
  @$pb.TagNumber(3)
  void clearType() => $_clearField(3);

  @$pb.TagNumber(4)
  ContentStatus get status => $_getN(3);
  @$pb.TagNumber(4)
  set status(ContentStatus value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);

  /// 内容字段
  @$pb.TagNumber(5)
  $core.String get title => $_getSZ(4);
  @$pb.TagNumber(5)
  set title($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTitle() => $_has(4);
  @$pb.TagNumber(5)
  void clearTitle() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get text => $_getSZ(5);
  @$pb.TagNumber(6)
  set text($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasText() => $_has(5);
  @$pb.TagNumber(6)
  void clearText() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get summary => $_getSZ(6);
  @$pb.TagNumber(7)
  set summary($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSummary() => $_has(6);
  @$pb.TagNumber(7)
  void clearSummary() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<Media> get media => $_getList(7);

  @$pb.TagNumber(9)
  $pb.PbList<$core.String> get tags => $_getList(8);

  /// 引用关系
  @$pb.TagNumber(10)
  $core.String get replyToId => $_getSZ(9);
  @$pb.TagNumber(10)
  set replyToId($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasReplyToId() => $_has(9);
  @$pb.TagNumber(10)
  void clearReplyToId() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get quoteId => $_getSZ(10);
  @$pb.TagNumber(11)
  set quoteId($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasQuoteId() => $_has(10);
  @$pb.TagNumber(11)
  void clearQuoteId() => $_clearField(11);

  /// 统计数据
  @$pb.TagNumber(20)
  $core.int get likeCount => $_getIZ(11);
  @$pb.TagNumber(20)
  set likeCount($core.int value) => $_setSignedInt32(11, value);
  @$pb.TagNumber(20)
  $core.bool hasLikeCount() => $_has(11);
  @$pb.TagNumber(20)
  void clearLikeCount() => $_clearField(20);

  @$pb.TagNumber(21)
  $core.int get commentCount => $_getIZ(12);
  @$pb.TagNumber(21)
  set commentCount($core.int value) => $_setSignedInt32(12, value);
  @$pb.TagNumber(21)
  $core.bool hasCommentCount() => $_has(12);
  @$pb.TagNumber(21)
  void clearCommentCount() => $_clearField(21);

  @$pb.TagNumber(22)
  $core.int get repostCount => $_getIZ(13);
  @$pb.TagNumber(22)
  set repostCount($core.int value) => $_setSignedInt32(13, value);
  @$pb.TagNumber(22)
  $core.bool hasRepostCount() => $_has(13);
  @$pb.TagNumber(22)
  void clearRepostCount() => $_clearField(22);

  @$pb.TagNumber(23)
  $core.int get bookmarkCount => $_getIZ(14);
  @$pb.TagNumber(23)
  set bookmarkCount($core.int value) => $_setSignedInt32(14, value);
  @$pb.TagNumber(23)
  $core.bool hasBookmarkCount() => $_has(14);
  @$pb.TagNumber(23)
  void clearBookmarkCount() => $_clearField(23);

  @$pb.TagNumber(24)
  $core.int get viewCount => $_getIZ(15);
  @$pb.TagNumber(24)
  set viewCount($core.int value) => $_setSignedInt32(15, value);
  @$pb.TagNumber(24)
  $core.bool hasViewCount() => $_has(15);
  @$pb.TagNumber(24)
  void clearViewCount() => $_clearField(24);

  /// 时间戳
  @$pb.TagNumber(30)
  $1.Timestamp get createdAt => $_getN(16);
  @$pb.TagNumber(30)
  set createdAt($1.Timestamp value) => $_setField(30, value);
  @$pb.TagNumber(30)
  $core.bool hasCreatedAt() => $_has(16);
  @$pb.TagNumber(30)
  void clearCreatedAt() => $_clearField(30);
  @$pb.TagNumber(30)
  $1.Timestamp ensureCreatedAt() => $_ensure(16);

  @$pb.TagNumber(31)
  $1.Timestamp get updatedAt => $_getN(17);
  @$pb.TagNumber(31)
  set updatedAt($1.Timestamp value) => $_setField(31, value);
  @$pb.TagNumber(31)
  $core.bool hasUpdatedAt() => $_has(17);
  @$pb.TagNumber(31)
  void clearUpdatedAt() => $_clearField(31);
  @$pb.TagNumber(31)
  $1.Timestamp ensureUpdatedAt() => $_ensure(17);

  @$pb.TagNumber(32)
  $1.Timestamp get publishedAt => $_getN(18);
  @$pb.TagNumber(32)
  set publishedAt($1.Timestamp value) => $_setField(32, value);
  @$pb.TagNumber(32)
  $core.bool hasPublishedAt() => $_has(18);
  @$pb.TagNumber(32)
  void clearPublishedAt() => $_clearField(32);
  @$pb.TagNumber(32)
  $1.Timestamp ensurePublishedAt() => $_ensure(18);

  @$pb.TagNumber(33)
  $1.Timestamp get expiresAt => $_getN(19);
  @$pb.TagNumber(33)
  set expiresAt($1.Timestamp value) => $_setField(33, value);
  @$pb.TagNumber(33)
  $core.bool hasExpiresAt() => $_has(19);
  @$pb.TagNumber(33)
  void clearExpiresAt() => $_clearField(33);
  @$pb.TagNumber(33)
  $1.Timestamp ensureExpiresAt() => $_ensure(19);

  /// 元数据
  @$pb.TagNumber(40)
  $core.bool get isPinned => $_getBF(20);
  @$pb.TagNumber(40)
  set isPinned($core.bool value) => $_setBool(20, value);
  @$pb.TagNumber(40)
  $core.bool hasIsPinned() => $_has(20);
  @$pb.TagNumber(40)
  void clearIsPinned() => $_clearField(40);

  @$pb.TagNumber(41)
  $core.bool get commentsDisabled => $_getBF(21);
  @$pb.TagNumber(41)
  set commentsDisabled($core.bool value) => $_setBool(21, value);
  @$pb.TagNumber(41)
  $core.bool hasCommentsDisabled() => $_has(21);
  @$pb.TagNumber(41)
  void clearCommentsDisabled() => $_clearField(41);

  @$pb.TagNumber(42)
  $core.String get language => $_getSZ(22);
  @$pb.TagNumber(42)
  set language($core.String value) => $_setString(22, value);
  @$pb.TagNumber(42)
  $core.bool hasLanguage() => $_has(22);
  @$pb.TagNumber(42)
  void clearLanguage() => $_clearField(42);
}

/// CreateContentRequest 创建内容请求
class CreateContentRequest extends $pb.GeneratedMessage {
  factory CreateContentRequest({
    $core.String? authorId,
    ContentType? type,
    $core.String? title,
    $core.String? text,
    $core.String? summary,
    $core.Iterable<Media>? media,
    $core.Iterable<$core.String>? tags,
    $core.String? replyToId,
    $core.String? quoteId,
    $core.bool? isDraft,
    $core.bool? commentsDisabled,
  }) {
    final result = create();
    if (authorId != null) result.authorId = authorId;
    if (type != null) result.type = type;
    if (title != null) result.title = title;
    if (text != null) result.text = text;
    if (summary != null) result.summary = summary;
    if (media != null) result.media.addAll(media);
    if (tags != null) result.tags.addAll(tags);
    if (replyToId != null) result.replyToId = replyToId;
    if (quoteId != null) result.quoteId = quoteId;
    if (isDraft != null) result.isDraft = isDraft;
    if (commentsDisabled != null) result.commentsDisabled = commentsDisabled;
    return result;
  }

  CreateContentRequest._();

  factory CreateContentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateContentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateContentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'content'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'authorId')
    ..aE<ContentType>(2, _omitFieldNames ? '' : 'type',
        enumValues: ContentType.values)
    ..aOS(3, _omitFieldNames ? '' : 'title')
    ..aOS(4, _omitFieldNames ? '' : 'text')
    ..aOS(5, _omitFieldNames ? '' : 'summary')
    ..pPM<Media>(6, _omitFieldNames ? '' : 'media', subBuilder: Media.create)
    ..pPS(7, _omitFieldNames ? '' : 'tags')
    ..aOS(8, _omitFieldNames ? '' : 'replyToId')
    ..aOS(9, _omitFieldNames ? '' : 'quoteId')
    ..aOB(10, _omitFieldNames ? '' : 'isDraft')
    ..aOB(11, _omitFieldNames ? '' : 'commentsDisabled')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateContentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateContentRequest copyWith(void Function(CreateContentRequest) updates) =>
      super.copyWith((message) => updates(message as CreateContentRequest))
          as CreateContentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateContentRequest create() => CreateContentRequest._();
  @$core.override
  CreateContentRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateContentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateContentRequest>(create);
  static CreateContentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get authorId => $_getSZ(0);
  @$pb.TagNumber(1)
  set authorId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAuthorId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAuthorId() => $_clearField(1);

  @$pb.TagNumber(2)
  ContentType get type => $_getN(1);
  @$pb.TagNumber(2)
  set type(ContentType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get title => $_getSZ(2);
  @$pb.TagNumber(3)
  set title($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTitle() => $_has(2);
  @$pb.TagNumber(3)
  void clearTitle() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get text => $_getSZ(3);
  @$pb.TagNumber(4)
  set text($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasText() => $_has(3);
  @$pb.TagNumber(4)
  void clearText() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get summary => $_getSZ(4);
  @$pb.TagNumber(5)
  set summary($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSummary() => $_has(4);
  @$pb.TagNumber(5)
  void clearSummary() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<Media> get media => $_getList(5);

  @$pb.TagNumber(7)
  $pb.PbList<$core.String> get tags => $_getList(6);

  @$pb.TagNumber(8)
  $core.String get replyToId => $_getSZ(7);
  @$pb.TagNumber(8)
  set replyToId($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasReplyToId() => $_has(7);
  @$pb.TagNumber(8)
  void clearReplyToId() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get quoteId => $_getSZ(8);
  @$pb.TagNumber(9)
  set quoteId($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasQuoteId() => $_has(8);
  @$pb.TagNumber(9)
  void clearQuoteId() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get isDraft => $_getBF(9);
  @$pb.TagNumber(10)
  set isDraft($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasIsDraft() => $_has(9);
  @$pb.TagNumber(10)
  void clearIsDraft() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.bool get commentsDisabled => $_getBF(10);
  @$pb.TagNumber(11)
  set commentsDisabled($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasCommentsDisabled() => $_has(10);
  @$pb.TagNumber(11)
  void clearCommentsDisabled() => $_clearField(11);
}

/// CreateContentResponse 创建内容响应
class CreateContentResponse extends $pb.GeneratedMessage {
  factory CreateContentResponse({
    Content? content,
  }) {
    final result = create();
    if (content != null) result.content = content;
    return result;
  }

  CreateContentResponse._();

  factory CreateContentResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateContentResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateContentResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'content'),
      createEmptyInstance: create)
    ..aOM<Content>(1, _omitFieldNames ? '' : 'content',
        subBuilder: Content.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateContentResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateContentResponse copyWith(
          void Function(CreateContentResponse) updates) =>
      super.copyWith((message) => updates(message as CreateContentResponse))
          as CreateContentResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateContentResponse create() => CreateContentResponse._();
  @$core.override
  CreateContentResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateContentResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateContentResponse>(create);
  static CreateContentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Content get content => $_getN(0);
  @$pb.TagNumber(1)
  set content(Content value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearContent() => $_clearField(1);
  @$pb.TagNumber(1)
  Content ensureContent() => $_ensure(0);
}

/// GetContentRequest 获取内容请求
class GetContentRequest extends $pb.GeneratedMessage {
  factory GetContentRequest({
    $core.String? contentId,
    $core.String? viewerId,
  }) {
    final result = create();
    if (contentId != null) result.contentId = contentId;
    if (viewerId != null) result.viewerId = viewerId;
    return result;
  }

  GetContentRequest._();

  factory GetContentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetContentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetContentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'content'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'contentId')
    ..aOS(2, _omitFieldNames ? '' : 'viewerId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetContentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetContentRequest copyWith(void Function(GetContentRequest) updates) =>
      super.copyWith((message) => updates(message as GetContentRequest))
          as GetContentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetContentRequest create() => GetContentRequest._();
  @$core.override
  GetContentRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetContentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetContentRequest>(create);
  static GetContentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get contentId => $_getSZ(0);
  @$pb.TagNumber(1)
  set contentId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasContentId() => $_has(0);
  @$pb.TagNumber(1)
  void clearContentId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get viewerId => $_getSZ(1);
  @$pb.TagNumber(2)
  set viewerId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasViewerId() => $_has(1);
  @$pb.TagNumber(2)
  void clearViewerId() => $_clearField(2);
}

/// GetContentResponse 获取内容响应
class GetContentResponse extends $pb.GeneratedMessage {
  factory GetContentResponse({
    Content? content,
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

  GetContentResponse._();

  factory GetContentResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetContentResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetContentResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'content'),
      createEmptyInstance: create)
    ..aOM<Content>(1, _omitFieldNames ? '' : 'content',
        subBuilder: Content.create)
    ..aOB(2, _omitFieldNames ? '' : 'isLiked')
    ..aOB(3, _omitFieldNames ? '' : 'isBookmarked')
    ..aOB(4, _omitFieldNames ? '' : 'isReposted')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetContentResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetContentResponse copyWith(void Function(GetContentResponse) updates) =>
      super.copyWith((message) => updates(message as GetContentResponse))
          as GetContentResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetContentResponse create() => GetContentResponse._();
  @$core.override
  GetContentResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetContentResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetContentResponse>(create);
  static GetContentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Content get content => $_getN(0);
  @$pb.TagNumber(1)
  set content(Content value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearContent() => $_clearField(1);
  @$pb.TagNumber(1)
  Content ensureContent() => $_ensure(0);

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

/// UpdateContentRequest 更新内容请求
class UpdateContentRequest extends $pb.GeneratedMessage {
  factory UpdateContentRequest({
    $core.String? contentId,
    $core.String? userId,
    $core.String? title,
    $core.String? text,
    $core.String? summary,
    $core.Iterable<Media>? media,
    $core.Iterable<$core.String>? tags,
    $core.bool? commentsDisabled,
  }) {
    final result = create();
    if (contentId != null) result.contentId = contentId;
    if (userId != null) result.userId = userId;
    if (title != null) result.title = title;
    if (text != null) result.text = text;
    if (summary != null) result.summary = summary;
    if (media != null) result.media.addAll(media);
    if (tags != null) result.tags.addAll(tags);
    if (commentsDisabled != null) result.commentsDisabled = commentsDisabled;
    return result;
  }

  UpdateContentRequest._();

  factory UpdateContentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateContentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateContentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'content'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'contentId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'title')
    ..aOS(4, _omitFieldNames ? '' : 'text')
    ..aOS(5, _omitFieldNames ? '' : 'summary')
    ..pPM<Media>(6, _omitFieldNames ? '' : 'media', subBuilder: Media.create)
    ..pPS(7, _omitFieldNames ? '' : 'tags')
    ..aOB(8, _omitFieldNames ? '' : 'commentsDisabled')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateContentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateContentRequest copyWith(void Function(UpdateContentRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateContentRequest))
          as UpdateContentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateContentRequest create() => UpdateContentRequest._();
  @$core.override
  UpdateContentRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateContentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateContentRequest>(create);
  static UpdateContentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get contentId => $_getSZ(0);
  @$pb.TagNumber(1)
  set contentId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasContentId() => $_has(0);
  @$pb.TagNumber(1)
  void clearContentId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get title => $_getSZ(2);
  @$pb.TagNumber(3)
  set title($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTitle() => $_has(2);
  @$pb.TagNumber(3)
  void clearTitle() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get text => $_getSZ(3);
  @$pb.TagNumber(4)
  set text($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasText() => $_has(3);
  @$pb.TagNumber(4)
  void clearText() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get summary => $_getSZ(4);
  @$pb.TagNumber(5)
  set summary($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSummary() => $_has(4);
  @$pb.TagNumber(5)
  void clearSummary() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<Media> get media => $_getList(5);

  @$pb.TagNumber(7)
  $pb.PbList<$core.String> get tags => $_getList(6);

  @$pb.TagNumber(8)
  $core.bool get commentsDisabled => $_getBF(7);
  @$pb.TagNumber(8)
  set commentsDisabled($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCommentsDisabled() => $_has(7);
  @$pb.TagNumber(8)
  void clearCommentsDisabled() => $_clearField(8);
}

/// UpdateContentResponse 更新内容响应
class UpdateContentResponse extends $pb.GeneratedMessage {
  factory UpdateContentResponse({
    Content? content,
  }) {
    final result = create();
    if (content != null) result.content = content;
    return result;
  }

  UpdateContentResponse._();

  factory UpdateContentResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateContentResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateContentResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'content'),
      createEmptyInstance: create)
    ..aOM<Content>(1, _omitFieldNames ? '' : 'content',
        subBuilder: Content.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateContentResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateContentResponse copyWith(
          void Function(UpdateContentResponse) updates) =>
      super.copyWith((message) => updates(message as UpdateContentResponse))
          as UpdateContentResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateContentResponse create() => UpdateContentResponse._();
  @$core.override
  UpdateContentResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateContentResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateContentResponse>(create);
  static UpdateContentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Content get content => $_getN(0);
  @$pb.TagNumber(1)
  set content(Content value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearContent() => $_clearField(1);
  @$pb.TagNumber(1)
  Content ensureContent() => $_ensure(0);
}

/// DeleteContentRequest 删除内容请求
class DeleteContentRequest extends $pb.GeneratedMessage {
  factory DeleteContentRequest({
    $core.String? contentId,
    $core.String? userId,
  }) {
    final result = create();
    if (contentId != null) result.contentId = contentId;
    if (userId != null) result.userId = userId;
    return result;
  }

  DeleteContentRequest._();

  factory DeleteContentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteContentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteContentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'content'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'contentId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteContentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteContentRequest copyWith(void Function(DeleteContentRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteContentRequest))
          as DeleteContentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteContentRequest create() => DeleteContentRequest._();
  @$core.override
  DeleteContentRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteContentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteContentRequest>(create);
  static DeleteContentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get contentId => $_getSZ(0);
  @$pb.TagNumber(1)
  set contentId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasContentId() => $_has(0);
  @$pb.TagNumber(1)
  void clearContentId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);
}

/// DeleteContentResponse 删除内容响应
class DeleteContentResponse extends $pb.GeneratedMessage {
  factory DeleteContentResponse({
    $core.bool? success,
  }) {
    final result = create();
    if (success != null) result.success = success;
    return result;
  }

  DeleteContentResponse._();

  factory DeleteContentResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteContentResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteContentResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'content'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteContentResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteContentResponse copyWith(
          void Function(DeleteContentResponse) updates) =>
      super.copyWith((message) => updates(message as DeleteContentResponse))
          as DeleteContentResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteContentResponse create() => DeleteContentResponse._();
  @$core.override
  DeleteContentResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteContentResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteContentResponse>(create);
  static DeleteContentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
}

/// PublishDraftRequest 发布草稿请求
class PublishDraftRequest extends $pb.GeneratedMessage {
  factory PublishDraftRequest({
    $core.String? contentId,
    $core.String? userId,
  }) {
    final result = create();
    if (contentId != null) result.contentId = contentId;
    if (userId != null) result.userId = userId;
    return result;
  }

  PublishDraftRequest._();

  factory PublishDraftRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PublishDraftRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PublishDraftRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'content'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'contentId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PublishDraftRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PublishDraftRequest copyWith(void Function(PublishDraftRequest) updates) =>
      super.copyWith((message) => updates(message as PublishDraftRequest))
          as PublishDraftRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PublishDraftRequest create() => PublishDraftRequest._();
  @$core.override
  PublishDraftRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PublishDraftRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PublishDraftRequest>(create);
  static PublishDraftRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get contentId => $_getSZ(0);
  @$pb.TagNumber(1)
  set contentId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasContentId() => $_has(0);
  @$pb.TagNumber(1)
  void clearContentId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);
}

/// PublishDraftResponse 发布草稿响应
class PublishDraftResponse extends $pb.GeneratedMessage {
  factory PublishDraftResponse({
    Content? content,
  }) {
    final result = create();
    if (content != null) result.content = content;
    return result;
  }

  PublishDraftResponse._();

  factory PublishDraftResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PublishDraftResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PublishDraftResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'content'),
      createEmptyInstance: create)
    ..aOM<Content>(1, _omitFieldNames ? '' : 'content',
        subBuilder: Content.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PublishDraftResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PublishDraftResponse copyWith(void Function(PublishDraftResponse) updates) =>
      super.copyWith((message) => updates(message as PublishDraftResponse))
          as PublishDraftResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PublishDraftResponse create() => PublishDraftResponse._();
  @$core.override
  PublishDraftResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PublishDraftResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PublishDraftResponse>(create);
  static PublishDraftResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Content get content => $_getN(0);
  @$pb.TagNumber(1)
  set content(Content value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearContent() => $_clearField(1);
  @$pb.TagNumber(1)
  Content ensureContent() => $_ensure(0);
}

/// ListContentsRequest 获取内容列表请求
class ListContentsRequest extends $pb.GeneratedMessage {
  factory ListContentsRequest({
    $core.String? authorId,
    ContentType? type,
    ContentStatus? status,
    $core.Iterable<$core.String>? tags,
    $1.Pagination? pagination,
    $core.String? orderBy,
    $core.bool? descending,
  }) {
    final result = create();
    if (authorId != null) result.authorId = authorId;
    if (type != null) result.type = type;
    if (status != null) result.status = status;
    if (tags != null) result.tags.addAll(tags);
    if (pagination != null) result.pagination = pagination;
    if (orderBy != null) result.orderBy = orderBy;
    if (descending != null) result.descending = descending;
    return result;
  }

  ListContentsRequest._();

  factory ListContentsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListContentsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListContentsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'content'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'authorId')
    ..aE<ContentType>(2, _omitFieldNames ? '' : 'type',
        enumValues: ContentType.values)
    ..aE<ContentStatus>(3, _omitFieldNames ? '' : 'status',
        enumValues: ContentStatus.values)
    ..pPS(4, _omitFieldNames ? '' : 'tags')
    ..aOM<$1.Pagination>(10, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..aOS(11, _omitFieldNames ? '' : 'orderBy')
    ..aOB(12, _omitFieldNames ? '' : 'descending')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListContentsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListContentsRequest copyWith(void Function(ListContentsRequest) updates) =>
      super.copyWith((message) => updates(message as ListContentsRequest))
          as ListContentsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListContentsRequest create() => ListContentsRequest._();
  @$core.override
  ListContentsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListContentsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListContentsRequest>(create);
  static ListContentsRequest? _defaultInstance;

  /// 筛选条件
  @$pb.TagNumber(1)
  $core.String get authorId => $_getSZ(0);
  @$pb.TagNumber(1)
  set authorId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAuthorId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAuthorId() => $_clearField(1);

  @$pb.TagNumber(2)
  ContentType get type => $_getN(1);
  @$pb.TagNumber(2)
  set type(ContentType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);

  @$pb.TagNumber(3)
  ContentStatus get status => $_getN(2);
  @$pb.TagNumber(3)
  set status(ContentStatus value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get tags => $_getList(3);

  /// 分页
  @$pb.TagNumber(10)
  $1.Pagination get pagination => $_getN(4);
  @$pb.TagNumber(10)
  set pagination($1.Pagination value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasPagination() => $_has(4);
  @$pb.TagNumber(10)
  void clearPagination() => $_clearField(10);
  @$pb.TagNumber(10)
  $1.Pagination ensurePagination() => $_ensure(4);

  /// 排序
  @$pb.TagNumber(11)
  $core.String get orderBy => $_getSZ(5);
  @$pb.TagNumber(11)
  set orderBy($core.String value) => $_setString(5, value);
  @$pb.TagNumber(11)
  $core.bool hasOrderBy() => $_has(5);
  @$pb.TagNumber(11)
  void clearOrderBy() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.bool get descending => $_getBF(6);
  @$pb.TagNumber(12)
  set descending($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(12)
  $core.bool hasDescending() => $_has(6);
  @$pb.TagNumber(12)
  void clearDescending() => $_clearField(12);
}

/// ListContentsResponse 内容列表响应
class ListContentsResponse extends $pb.GeneratedMessage {
  factory ListContentsResponse({
    $core.Iterable<Content>? contents,
    $1.Pagination? pagination,
  }) {
    final result = create();
    if (contents != null) result.contents.addAll(contents);
    if (pagination != null) result.pagination = pagination;
    return result;
  }

  ListContentsResponse._();

  factory ListContentsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListContentsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListContentsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'content'),
      createEmptyInstance: create)
    ..pPM<Content>(1, _omitFieldNames ? '' : 'contents',
        subBuilder: Content.create)
    ..aOM<$1.Pagination>(2, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListContentsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListContentsResponse copyWith(void Function(ListContentsResponse) updates) =>
      super.copyWith((message) => updates(message as ListContentsResponse))
          as ListContentsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListContentsResponse create() => ListContentsResponse._();
  @$core.override
  ListContentsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListContentsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListContentsResponse>(create);
  static ListContentsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Content> get contents => $_getList(0);

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

/// GetUserDraftsRequest 获取用户草稿列表请求
class GetUserDraftsRequest extends $pb.GeneratedMessage {
  factory GetUserDraftsRequest({
    $core.String? userId,
    $1.Pagination? pagination,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (pagination != null) result.pagination = pagination;
    return result;
  }

  GetUserDraftsRequest._();

  factory GetUserDraftsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetUserDraftsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetUserDraftsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'content'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOM<$1.Pagination>(2, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUserDraftsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUserDraftsRequest copyWith(void Function(GetUserDraftsRequest) updates) =>
      super.copyWith((message) => updates(message as GetUserDraftsRequest))
          as GetUserDraftsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetUserDraftsRequest create() => GetUserDraftsRequest._();
  @$core.override
  GetUserDraftsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetUserDraftsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetUserDraftsRequest>(create);
  static GetUserDraftsRequest? _defaultInstance;

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

/// GetUserDraftsResponse 用户草稿列表响应
class GetUserDraftsResponse extends $pb.GeneratedMessage {
  factory GetUserDraftsResponse({
    $core.Iterable<Content>? drafts,
    $1.Pagination? pagination,
  }) {
    final result = create();
    if (drafts != null) result.drafts.addAll(drafts);
    if (pagination != null) result.pagination = pagination;
    return result;
  }

  GetUserDraftsResponse._();

  factory GetUserDraftsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetUserDraftsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetUserDraftsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'content'),
      createEmptyInstance: create)
    ..pPM<Content>(1, _omitFieldNames ? '' : 'drafts',
        subBuilder: Content.create)
    ..aOM<$1.Pagination>(2, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUserDraftsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUserDraftsResponse copyWith(
          void Function(GetUserDraftsResponse) updates) =>
      super.copyWith((message) => updates(message as GetUserDraftsResponse))
          as GetUserDraftsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetUserDraftsResponse create() => GetUserDraftsResponse._();
  @$core.override
  GetUserDraftsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetUserDraftsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetUserDraftsResponse>(create);
  static GetUserDraftsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Content> get drafts => $_getList(0);

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

/// GetRepliesRequest 获取回复列表请求
class GetRepliesRequest extends $pb.GeneratedMessage {
  factory GetRepliesRequest({
    $core.String? contentId,
    $1.Pagination? pagination,
  }) {
    final result = create();
    if (contentId != null) result.contentId = contentId;
    if (pagination != null) result.pagination = pagination;
    return result;
  }

  GetRepliesRequest._();

  factory GetRepliesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetRepliesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetRepliesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'content'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'contentId')
    ..aOM<$1.Pagination>(2, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRepliesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRepliesRequest copyWith(void Function(GetRepliesRequest) updates) =>
      super.copyWith((message) => updates(message as GetRepliesRequest))
          as GetRepliesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRepliesRequest create() => GetRepliesRequest._();
  @$core.override
  GetRepliesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetRepliesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetRepliesRequest>(create);
  static GetRepliesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get contentId => $_getSZ(0);
  @$pb.TagNumber(1)
  set contentId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasContentId() => $_has(0);
  @$pb.TagNumber(1)
  void clearContentId() => $_clearField(1);

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

/// GetRepliesResponse 回复列表响应
class GetRepliesResponse extends $pb.GeneratedMessage {
  factory GetRepliesResponse({
    $core.Iterable<Content>? replies,
    $1.Pagination? pagination,
  }) {
    final result = create();
    if (replies != null) result.replies.addAll(replies);
    if (pagination != null) result.pagination = pagination;
    return result;
  }

  GetRepliesResponse._();

  factory GetRepliesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetRepliesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetRepliesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'content'),
      createEmptyInstance: create)
    ..pPM<Content>(1, _omitFieldNames ? '' : 'replies',
        subBuilder: Content.create)
    ..aOM<$1.Pagination>(2, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.Pagination.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRepliesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRepliesResponse copyWith(void Function(GetRepliesResponse) updates) =>
      super.copyWith((message) => updates(message as GetRepliesResponse))
          as GetRepliesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRepliesResponse create() => GetRepliesResponse._();
  @$core.override
  GetRepliesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetRepliesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetRepliesResponse>(create);
  static GetRepliesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Content> get replies => $_getList(0);

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

/// GetUserStoriesRequest 获取用户 Story 列表请求
class GetUserStoriesRequest extends $pb.GeneratedMessage {
  factory GetUserStoriesRequest({
    $core.String? userId,
    $core.String? viewerId,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (viewerId != null) result.viewerId = viewerId;
    return result;
  }

  GetUserStoriesRequest._();

  factory GetUserStoriesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetUserStoriesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetUserStoriesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'content'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'viewerId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUserStoriesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUserStoriesRequest copyWith(
          void Function(GetUserStoriesRequest) updates) =>
      super.copyWith((message) => updates(message as GetUserStoriesRequest))
          as GetUserStoriesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetUserStoriesRequest create() => GetUserStoriesRequest._();
  @$core.override
  GetUserStoriesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetUserStoriesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetUserStoriesRequest>(create);
  static GetUserStoriesRequest? _defaultInstance;

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

/// GetUserStoriesResponse 用户 Story 列表响应
class GetUserStoriesResponse extends $pb.GeneratedMessage {
  factory GetUserStoriesResponse({
    $core.Iterable<Content>? stories,
    $core.bool? hasUnseen,
  }) {
    final result = create();
    if (stories != null) result.stories.addAll(stories);
    if (hasUnseen != null) result.hasUnseen = hasUnseen;
    return result;
  }

  GetUserStoriesResponse._();

  factory GetUserStoriesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetUserStoriesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetUserStoriesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'content'),
      createEmptyInstance: create)
    ..pPM<Content>(1, _omitFieldNames ? '' : 'stories',
        subBuilder: Content.create)
    ..aOB(2, _omitFieldNames ? '' : 'hasUnseen')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUserStoriesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUserStoriesResponse copyWith(
          void Function(GetUserStoriesResponse) updates) =>
      super.copyWith((message) => updates(message as GetUserStoriesResponse))
          as GetUserStoriesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetUserStoriesResponse create() => GetUserStoriesResponse._();
  @$core.override
  GetUserStoriesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetUserStoriesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetUserStoriesResponse>(create);
  static GetUserStoriesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Content> get stories => $_getList(0);

  @$pb.TagNumber(2)
  $core.bool get hasUnseen => $_getBF(1);
  @$pb.TagNumber(2)
  set hasUnseen($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHasUnseen() => $_has(1);
  @$pb.TagNumber(2)
  void clearHasUnseen() => $_clearField(2);
}

/// BatchGetContentsRequest 批量获取内容请求
class BatchGetContentsRequest extends $pb.GeneratedMessage {
  factory BatchGetContentsRequest({
    $core.Iterable<$core.String>? contentIds,
    $core.String? viewerId,
  }) {
    final result = create();
    if (contentIds != null) result.contentIds.addAll(contentIds);
    if (viewerId != null) result.viewerId = viewerId;
    return result;
  }

  BatchGetContentsRequest._();

  factory BatchGetContentsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BatchGetContentsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BatchGetContentsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'content'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'contentIds')
    ..aOS(2, _omitFieldNames ? '' : 'viewerId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BatchGetContentsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BatchGetContentsRequest copyWith(
          void Function(BatchGetContentsRequest) updates) =>
      super.copyWith((message) => updates(message as BatchGetContentsRequest))
          as BatchGetContentsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BatchGetContentsRequest create() => BatchGetContentsRequest._();
  @$core.override
  BatchGetContentsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BatchGetContentsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BatchGetContentsRequest>(create);
  static BatchGetContentsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get contentIds => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get viewerId => $_getSZ(1);
  @$pb.TagNumber(2)
  set viewerId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasViewerId() => $_has(1);
  @$pb.TagNumber(2)
  void clearViewerId() => $_clearField(2);
}

/// BatchGetContentsResponse 批量获取内容响应
class BatchGetContentsResponse extends $pb.GeneratedMessage {
  factory BatchGetContentsResponse({
    $core.Iterable<Content>? contents,
  }) {
    final result = create();
    if (contents != null) result.contents.addAll(contents);
    return result;
  }

  BatchGetContentsResponse._();

  factory BatchGetContentsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BatchGetContentsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BatchGetContentsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'content'),
      createEmptyInstance: create)
    ..pPM<Content>(1, _omitFieldNames ? '' : 'contents',
        subBuilder: Content.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BatchGetContentsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BatchGetContentsResponse copyWith(
          void Function(BatchGetContentsResponse) updates) =>
      super.copyWith((message) => updates(message as BatchGetContentsResponse))
          as BatchGetContentsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BatchGetContentsResponse create() => BatchGetContentsResponse._();
  @$core.override
  BatchGetContentsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BatchGetContentsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BatchGetContentsResponse>(create);
  static BatchGetContentsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Content> get contents => $_getList(0);
}

/// PinContentRequest 置顶内容请求
class PinContentRequest extends $pb.GeneratedMessage {
  factory PinContentRequest({
    $core.String? contentId,
    $core.String? userId,
    $core.bool? pin,
  }) {
    final result = create();
    if (contentId != null) result.contentId = contentId;
    if (userId != null) result.userId = userId;
    if (pin != null) result.pin = pin;
    return result;
  }

  PinContentRequest._();

  factory PinContentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PinContentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PinContentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'content'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'contentId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOB(3, _omitFieldNames ? '' : 'pin')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PinContentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PinContentRequest copyWith(void Function(PinContentRequest) updates) =>
      super.copyWith((message) => updates(message as PinContentRequest))
          as PinContentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PinContentRequest create() => PinContentRequest._();
  @$core.override
  PinContentRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PinContentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PinContentRequest>(create);
  static PinContentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get contentId => $_getSZ(0);
  @$pb.TagNumber(1)
  set contentId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasContentId() => $_has(0);
  @$pb.TagNumber(1)
  void clearContentId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get pin => $_getBF(2);
  @$pb.TagNumber(3)
  set pin($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPin() => $_has(2);
  @$pb.TagNumber(3)
  void clearPin() => $_clearField(3);
}

/// PinContentResponse 置顶内容响应
class PinContentResponse extends $pb.GeneratedMessage {
  factory PinContentResponse({
    $core.bool? success,
  }) {
    final result = create();
    if (success != null) result.success = success;
    return result;
  }

  PinContentResponse._();

  factory PinContentResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PinContentResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PinContentResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'content'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PinContentResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PinContentResponse copyWith(void Function(PinContentResponse) updates) =>
      super.copyWith((message) => updates(message as PinContentResponse))
          as PinContentResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PinContentResponse create() => PinContentResponse._();
  @$core.override
  PinContentResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PinContentResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PinContentResponse>(create);
  static PinContentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
