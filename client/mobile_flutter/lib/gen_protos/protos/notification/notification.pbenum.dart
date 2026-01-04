// This is a generated file - do not edit.
//
// Generated from notification/notification.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// NotificationType 通知类型
class NotificationType extends $pb.ProtobufEnum {
  static const NotificationType NOTIFICATION_TYPE_UNSPECIFIED =
      NotificationType._(
          0, _omitEnumNames ? '' : 'NOTIFICATION_TYPE_UNSPECIFIED');
  static const NotificationType LIKE =
      NotificationType._(1, _omitEnumNames ? '' : 'LIKE');
  static const NotificationType COMMENT =
      NotificationType._(2, _omitEnumNames ? '' : 'COMMENT');
  static const NotificationType REPLY =
      NotificationType._(3, _omitEnumNames ? '' : 'REPLY');
  static const NotificationType BOOKMARK =
      NotificationType._(4, _omitEnumNames ? '' : 'BOOKMARK');
  static const NotificationType MENTION =
      NotificationType._(5, _omitEnumNames ? '' : 'MENTION');
  static const NotificationType FOLLOW =
      NotificationType._(6, _omitEnumNames ? '' : 'FOLLOW');
  static const NotificationType REPOST =
      NotificationType._(7, _omitEnumNames ? '' : 'REPOST');

  static const $core.List<NotificationType> values = <NotificationType>[
    NOTIFICATION_TYPE_UNSPECIFIED,
    LIKE,
    COMMENT,
    REPLY,
    BOOKMARK,
    MENTION,
    FOLLOW,
    REPOST,
  ];

  static final $core.List<NotificationType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 7);
  static NotificationType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const NotificationType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
