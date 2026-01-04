// This is a generated file - do not edit.
//
// Generated from search/search.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use searchPostsRequestDescriptor instead')
const SearchPostsRequest$json = {
  '1': 'SearchPostsRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
    {
      '1': 'pagination',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.common.Pagination',
      '10': 'pagination'
    },
  ],
};

/// Descriptor for `SearchPostsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchPostsRequestDescriptor = $convert.base64Decode(
    'ChJTZWFyY2hQb3N0c1JlcXVlc3QSFAoFcXVlcnkYASABKAlSBXF1ZXJ5EjIKCnBhZ2luYXRpb2'
    '4YAiABKAsyEi5jb21tb24uUGFnaW5hdGlvblIKcGFnaW5hdGlvbg==');

@$core.Deprecated('Use postResultDescriptor instead')
const PostResult$json = {
  '1': 'PostResult',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'author_id', '3': 2, '4': 1, '5': 9, '10': 'authorId'},
    {'1': 'title', '3': 3, '4': 1, '5': 9, '10': 'title'},
    {'1': 'content', '3': 4, '4': 1, '5': 9, '10': 'content'},
    {'1': 'media_urls', '3': 5, '4': 3, '5': 9, '10': 'mediaUrls'},
    {
      '1': 'created_at',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.common.Timestamp',
      '10': 'createdAt'
    },
  ],
};

/// Descriptor for `PostResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List postResultDescriptor = $convert.base64Decode(
    'CgpQb3N0UmVzdWx0Eg4KAmlkGAEgASgJUgJpZBIbCglhdXRob3JfaWQYAiABKAlSCGF1dGhvck'
    'lkEhQKBXRpdGxlGAMgASgJUgV0aXRsZRIYCgdjb250ZW50GAQgASgJUgdjb250ZW50Eh0KCm1l'
    'ZGlhX3VybHMYBSADKAlSCW1lZGlhVXJscxIwCgpjcmVhdGVkX2F0GAYgASgLMhEuY29tbW9uLl'
    'RpbWVzdGFtcFIJY3JlYXRlZEF0');

@$core.Deprecated('Use searchPostsResponseDescriptor instead')
const SearchPostsResponse$json = {
  '1': 'SearchPostsResponse',
  '2': [
    {
      '1': 'posts',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.search.PostResult',
      '10': 'posts'
    },
    {
      '1': 'pagination',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.common.Pagination',
      '10': 'pagination'
    },
  ],
};

/// Descriptor for `SearchPostsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchPostsResponseDescriptor = $convert.base64Decode(
    'ChNTZWFyY2hQb3N0c1Jlc3BvbnNlEigKBXBvc3RzGAEgAygLMhIuc2VhcmNoLlBvc3RSZXN1bH'
    'RSBXBvc3RzEjIKCnBhZ2luYXRpb24YAiABKAsyEi5jb21tb24uUGFnaW5hdGlvblIKcGFnaW5h'
    'dGlvbg==');

@$core.Deprecated('Use searchUsersRequestDescriptor instead')
const SearchUsersRequest$json = {
  '1': 'SearchUsersRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
    {
      '1': 'pagination',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.common.Pagination',
      '10': 'pagination'
    },
  ],
};

/// Descriptor for `SearchUsersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchUsersRequestDescriptor = $convert.base64Decode(
    'ChJTZWFyY2hVc2Vyc1JlcXVlc3QSFAoFcXVlcnkYASABKAlSBXF1ZXJ5EjIKCnBhZ2luYXRpb2'
    '4YAiABKAsyEi5jb21tb24uUGFnaW5hdGlvblIKcGFnaW5hdGlvbg==');

@$core.Deprecated('Use userResultDescriptor instead')
const UserResult$json = {
  '1': 'UserResult',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'username', '3': 2, '4': 1, '5': 9, '10': 'username'},
    {'1': 'display_name', '3': 3, '4': 1, '5': 9, '10': 'displayName'},
    {'1': 'avatar_url', '3': 4, '4': 1, '5': 9, '10': 'avatarUrl'},
    {'1': 'bio', '3': 5, '4': 1, '5': 9, '10': 'bio'},
  ],
};

/// Descriptor for `UserResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userResultDescriptor = $convert.base64Decode(
    'CgpVc2VyUmVzdWx0Eg4KAmlkGAEgASgJUgJpZBIaCgh1c2VybmFtZRgCIAEoCVIIdXNlcm5hbW'
    'USIQoMZGlzcGxheV9uYW1lGAMgASgJUgtkaXNwbGF5TmFtZRIdCgphdmF0YXJfdXJsGAQgASgJ'
    'UglhdmF0YXJVcmwSEAoDYmlvGAUgASgJUgNiaW8=');

@$core.Deprecated('Use searchUsersResponseDescriptor instead')
const SearchUsersResponse$json = {
  '1': 'SearchUsersResponse',
  '2': [
    {
      '1': 'users',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.search.UserResult',
      '10': 'users'
    },
    {
      '1': 'pagination',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.common.Pagination',
      '10': 'pagination'
    },
  ],
};

/// Descriptor for `SearchUsersResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchUsersResponseDescriptor = $convert.base64Decode(
    'ChNTZWFyY2hVc2Vyc1Jlc3BvbnNlEigKBXVzZXJzGAEgAygLMhIuc2VhcmNoLlVzZXJSZXN1bH'
    'RSBXVzZXJzEjIKCnBhZ2luYXRpb24YAiABKAsyEi5jb21tb24uUGFnaW5hdGlvblIKcGFnaW5h'
    'dGlvbg==');
