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

import 'package:protobuf/protobuf.dart' as $pb;

/// ConversationType 会话类型
/// 注意：CHANNEL 类型已迁移到独立的 Channel 服务 (protos/channel/channel.proto)
class ConversationType extends $pb.ProtobufEnum {
  static const ConversationType PRIVATE =
      ConversationType._(0, _omitEnumNames ? '' : 'PRIVATE');
  static const ConversationType GROUP =
      ConversationType._(1, _omitEnumNames ? '' : 'GROUP');

  static const $core.List<ConversationType> values = <ConversationType>[
    PRIVATE,
    GROUP,
  ];

  static final $core.List<ConversationType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static ConversationType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ConversationType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
