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

/// ContentType 内容类型
class ContentType extends $pb.ProtobufEnum {
  static const ContentType CONTENT_TYPE_UNSPECIFIED =
      ContentType._(0, _omitEnumNames ? '' : 'CONTENT_TYPE_UNSPECIFIED');
  static const ContentType STORY =
      ContentType._(1, _omitEnumNames ? '' : 'STORY');
  static const ContentType SHORT =
      ContentType._(2, _omitEnumNames ? '' : 'SHORT');
  static const ContentType ARTICLE =
      ContentType._(3, _omitEnumNames ? '' : 'ARTICLE');

  static const $core.List<ContentType> values = <ContentType>[
    CONTENT_TYPE_UNSPECIFIED,
    STORY,
    SHORT,
    ARTICLE,
  ];

  static final $core.List<ContentType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static ContentType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ContentType._(super.value, super.name);
}

/// ContentStatus 内容状态
class ContentStatus extends $pb.ProtobufEnum {
  static const ContentStatus CONTENT_STATUS_UNSPECIFIED =
      ContentStatus._(0, _omitEnumNames ? '' : 'CONTENT_STATUS_UNSPECIFIED');
  static const ContentStatus DRAFT =
      ContentStatus._(1, _omitEnumNames ? '' : 'DRAFT');
  static const ContentStatus PUBLISHED =
      ContentStatus._(2, _omitEnumNames ? '' : 'PUBLISHED');
  static const ContentStatus ARCHIVED =
      ContentStatus._(3, _omitEnumNames ? '' : 'ARCHIVED');
  static const ContentStatus DELETED =
      ContentStatus._(4, _omitEnumNames ? '' : 'DELETED');

  static const $core.List<ContentStatus> values = <ContentStatus>[
    CONTENT_STATUS_UNSPECIFIED,
    DRAFT,
    PUBLISHED,
    ARCHIVED,
    DELETED,
  ];

  static final $core.List<ContentStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static ContentStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ContentStatus._(super.value, super.name);
}

/// MediaType 媒体类型
class MediaType extends $pb.ProtobufEnum {
  static const MediaType MEDIA_TYPE_UNSPECIFIED =
      MediaType._(0, _omitEnumNames ? '' : 'MEDIA_TYPE_UNSPECIFIED');
  static const MediaType IMAGE = MediaType._(1, _omitEnumNames ? '' : 'IMAGE');
  static const MediaType VIDEO = MediaType._(2, _omitEnumNames ? '' : 'VIDEO');
  static const MediaType AUDIO = MediaType._(3, _omitEnumNames ? '' : 'AUDIO');
  static const MediaType GIF = MediaType._(4, _omitEnumNames ? '' : 'GIF');

  static const $core.List<MediaType> values = <MediaType>[
    MEDIA_TYPE_UNSPECIFIED,
    IMAGE,
    VIDEO,
    AUDIO,
    GIF,
  ];

  static final $core.List<MediaType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static MediaType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MediaType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
