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

/// BlockType 屏蔽类型
class BlockType extends $pb.ProtobufEnum {
  static const BlockType BLOCK_TYPE_UNSPECIFIED =
      BlockType._(0, _omitEnumNames ? '' : 'BLOCK_TYPE_UNSPECIFIED');
  static const BlockType BLOCK_TYPE_HIDE_POSTS =
      BlockType._(1, _omitEnumNames ? '' : 'BLOCK_TYPE_HIDE_POSTS');
  static const BlockType BLOCK_TYPE_HIDE_ME =
      BlockType._(2, _omitEnumNames ? '' : 'BLOCK_TYPE_HIDE_ME');
  static const BlockType BLOCK_TYPE_BLOCK =
      BlockType._(3, _omitEnumNames ? '' : 'BLOCK_TYPE_BLOCK');

  static const $core.List<BlockType> values = <BlockType>[
    BLOCK_TYPE_UNSPECIFIED,
    BLOCK_TYPE_HIDE_POSTS,
    BLOCK_TYPE_HIDE_ME,
    BLOCK_TYPE_BLOCK,
  ];

  static final $core.List<BlockType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static BlockType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const BlockType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
