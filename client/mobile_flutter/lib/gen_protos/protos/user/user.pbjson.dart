// This is a generated file - do not edit.
//
// Generated from user/user.proto.

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

@$core.Deprecated('Use blockTypeDescriptor instead')
const BlockType$json = {
  '1': 'BlockType',
  '2': [
    {'1': 'BLOCK_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'BLOCK_TYPE_HIDE_POSTS', '2': 1},
    {'1': 'BLOCK_TYPE_HIDE_ME', '2': 2},
    {'1': 'BLOCK_TYPE_BLOCK', '2': 3},
  ],
};

/// Descriptor for `BlockType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List blockTypeDescriptor = $convert.base64Decode(
    'CglCbG9ja1R5cGUSGgoWQkxPQ0tfVFlQRV9VTlNQRUNJRklFRBAAEhkKFUJMT0NLX1RZUEVfSE'
    'lERV9QT1NUUxABEhYKEkJMT0NLX1RZUEVfSElERV9NRRACEhQKEEJMT0NLX1RZUEVfQkxPQ0sQ'
    'Aw==');

@$core.Deprecated('Use profileDescriptor instead')
const Profile$json = {
  '1': 'Profile',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'username', '3': 2, '4': 1, '5': 9, '10': 'username'},
    {'1': 'email', '3': 3, '4': 1, '5': 9, '10': 'email'},
    {'1': 'display_name', '3': 4, '4': 1, '5': 9, '10': 'displayName'},
    {'1': 'avatar_url', '3': 5, '4': 1, '5': 9, '10': 'avatarUrl'},
    {'1': 'bio', '3': 6, '4': 1, '5': 9, '10': 'bio'},
    {'1': 'location', '3': 7, '4': 1, '5': 9, '10': 'location'},
    {'1': 'website', '3': 8, '4': 1, '5': 9, '10': 'website'},
    {'1': 'birthday', '3': 9, '4': 1, '5': 9, '10': 'birthday'},
    {'1': 'is_verified', '3': 10, '4': 1, '5': 8, '10': 'isVerified'},
    {'1': 'is_private', '3': 11, '4': 1, '5': 8, '10': 'isPrivate'},
    {'1': 'followers_count', '3': 12, '4': 1, '5': 5, '10': 'followersCount'},
    {'1': 'following_count', '3': 13, '4': 1, '5': 5, '10': 'followingCount'},
    {'1': 'posts_count', '3': 14, '4': 1, '5': 5, '10': 'postsCount'},
    {
      '1': 'created_at',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.common.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.common.Timestamp',
      '10': 'updatedAt'
    },
    {
      '1': 'relationship',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.user.RelationshipStatus',
      '10': 'relationship'
    },
  ],
};

/// Descriptor for `Profile`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List profileDescriptor = $convert.base64Decode(
    'CgdQcm9maWxlEg4KAmlkGAEgASgJUgJpZBIaCgh1c2VybmFtZRgCIAEoCVIIdXNlcm5hbWUSFA'
    'oFZW1haWwYAyABKAlSBWVtYWlsEiEKDGRpc3BsYXlfbmFtZRgEIAEoCVILZGlzcGxheU5hbWUS'
    'HQoKYXZhdGFyX3VybBgFIAEoCVIJYXZhdGFyVXJsEhAKA2JpbxgGIAEoCVIDYmlvEhoKCGxvY2'
    'F0aW9uGAcgASgJUghsb2NhdGlvbhIYCgd3ZWJzaXRlGAggASgJUgd3ZWJzaXRlEhoKCGJpcnRo'
    'ZGF5GAkgASgJUghiaXJ0aGRheRIfCgtpc192ZXJpZmllZBgKIAEoCFIKaXNWZXJpZmllZBIdCg'
    'ppc19wcml2YXRlGAsgASgIUglpc1ByaXZhdGUSJwoPZm9sbG93ZXJzX2NvdW50GAwgASgFUg5m'
    'b2xsb3dlcnNDb3VudBInCg9mb2xsb3dpbmdfY291bnQYDSABKAVSDmZvbGxvd2luZ0NvdW50Eh'
    '8KC3Bvc3RzX2NvdW50GA4gASgFUgpwb3N0c0NvdW50EjAKCmNyZWF0ZWRfYXQYDyABKAsyES5j'
    'b21tb24uVGltZXN0YW1wUgljcmVhdGVkQXQSMAoKdXBkYXRlZF9hdBgQIAEoCzIRLmNvbW1vbi'
    '5UaW1lc3RhbXBSCXVwZGF0ZWRBdBI8CgxyZWxhdGlvbnNoaXAYESABKAsyGC51c2VyLlJlbGF0'
    'aW9uc2hpcFN0YXR1c1IMcmVsYXRpb25zaGlw');

@$core.Deprecated('Use relationshipStatusDescriptor instead')
const RelationshipStatus$json = {
  '1': 'RelationshipStatus',
  '2': [
    {'1': 'is_following', '3': 1, '4': 1, '5': 8, '10': 'isFollowing'},
    {'1': 'is_followed_by', '3': 2, '4': 1, '5': 8, '10': 'isFollowedBy'},
    {'1': 'is_mutual', '3': 3, '4': 1, '5': 8, '10': 'isMutual'},
    {'1': 'is_blocking', '3': 4, '4': 1, '5': 8, '10': 'isBlocking'},
    {'1': 'is_blocked_by', '3': 5, '4': 1, '5': 8, '10': 'isBlockedBy'},
    {'1': 'is_muting', '3': 6, '4': 1, '5': 8, '10': 'isMuting'},
    {'1': 'is_hiding_from', '3': 7, '4': 1, '5': 8, '10': 'isHidingFrom'},
  ],
};

/// Descriptor for `RelationshipStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List relationshipStatusDescriptor = $convert.base64Decode(
    'ChJSZWxhdGlvbnNoaXBTdGF0dXMSIQoMaXNfZm9sbG93aW5nGAEgASgIUgtpc0ZvbGxvd2luZx'
    'IkCg5pc19mb2xsb3dlZF9ieRgCIAEoCFIMaXNGb2xsb3dlZEJ5EhsKCWlzX211dHVhbBgDIAEo'
    'CFIIaXNNdXR1YWwSHwoLaXNfYmxvY2tpbmcYBCABKAhSCmlzQmxvY2tpbmcSIgoNaXNfYmxvY2'
    'tlZF9ieRgFIAEoCFILaXNCbG9ja2VkQnkSGwoJaXNfbXV0aW5nGAYgASgIUghpc011dGluZxIk'
    'Cg5pc19oaWRpbmdfZnJvbRgHIAEoCFIMaXNIaWRpbmdGcm9t');

@$core.Deprecated('Use getProfileRequestDescriptor instead')
const GetProfileRequest$json = {
  '1': 'GetProfileRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'viewer_id', '3': 2, '4': 1, '5': 9, '10': 'viewerId'},
  ],
};

/// Descriptor for `GetProfileRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getProfileRequestDescriptor = $convert.base64Decode(
    'ChFHZXRQcm9maWxlUmVxdWVzdBIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSGwoJdmlld2VyX2'
    'lkGAIgASgJUgh2aWV3ZXJJZA==');

@$core.Deprecated('Use getProfileByUsernameRequestDescriptor instead')
const GetProfileByUsernameRequest$json = {
  '1': 'GetProfileByUsernameRequest',
  '2': [
    {'1': 'username', '3': 1, '4': 1, '5': 9, '10': 'username'},
    {'1': 'viewer_id', '3': 2, '4': 1, '5': 9, '10': 'viewerId'},
  ],
};

/// Descriptor for `GetProfileByUsernameRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getProfileByUsernameRequestDescriptor =
    $convert.base64Decode(
        'ChtHZXRQcm9maWxlQnlVc2VybmFtZVJlcXVlc3QSGgoIdXNlcm5hbWUYASABKAlSCHVzZXJuYW'
        '1lEhsKCXZpZXdlcl9pZBgCIAEoCVIIdmlld2VySWQ=');

@$core.Deprecated('Use updateProfileRequestDescriptor instead')
const UpdateProfileRequest$json = {
  '1': 'UpdateProfileRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {
      '1': 'display_name',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'displayName',
      '17': true
    },
    {
      '1': 'avatar_url',
      '3': 3,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'avatarUrl',
      '17': true
    },
    {'1': 'bio', '3': 4, '4': 1, '5': 9, '9': 2, '10': 'bio', '17': true},
    {
      '1': 'location',
      '3': 5,
      '4': 1,
      '5': 9,
      '9': 3,
      '10': 'location',
      '17': true
    },
    {
      '1': 'website',
      '3': 6,
      '4': 1,
      '5': 9,
      '9': 4,
      '10': 'website',
      '17': true
    },
    {
      '1': 'birthday',
      '3': 7,
      '4': 1,
      '5': 9,
      '9': 5,
      '10': 'birthday',
      '17': true
    },
    {
      '1': 'is_private',
      '3': 8,
      '4': 1,
      '5': 8,
      '9': 6,
      '10': 'isPrivate',
      '17': true
    },
  ],
  '8': [
    {'1': '_display_name'},
    {'1': '_avatar_url'},
    {'1': '_bio'},
    {'1': '_location'},
    {'1': '_website'},
    {'1': '_birthday'},
    {'1': '_is_private'},
  ],
};

/// Descriptor for `UpdateProfileRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateProfileRequestDescriptor = $convert.base64Decode(
    'ChRVcGRhdGVQcm9maWxlUmVxdWVzdBIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSJgoMZGlzcG'
    'xheV9uYW1lGAIgASgJSABSC2Rpc3BsYXlOYW1liAEBEiIKCmF2YXRhcl91cmwYAyABKAlIAVIJ'
    'YXZhdGFyVXJsiAEBEhUKA2JpbxgEIAEoCUgCUgNiaW+IAQESHwoIbG9jYXRpb24YBSABKAlIA1'
    'IIbG9jYXRpb26IAQESHQoHd2Vic2l0ZRgGIAEoCUgEUgd3ZWJzaXRliAEBEh8KCGJpcnRoZGF5'
    'GAcgASgJSAVSCGJpcnRoZGF5iAEBEiIKCmlzX3ByaXZhdGUYCCABKAhIBlIJaXNQcml2YXRliA'
    'EBQg8KDV9kaXNwbGF5X25hbWVCDQoLX2F2YXRhcl91cmxCBgoEX2Jpb0ILCglfbG9jYXRpb25C'
    'CgoIX3dlYnNpdGVCCwoJX2JpcnRoZGF5Qg0KC19pc19wcml2YXRl');

@$core.Deprecated('Use batchGetProfilesRequestDescriptor instead')
const BatchGetProfilesRequest$json = {
  '1': 'BatchGetProfilesRequest',
  '2': [
    {'1': 'user_ids', '3': 1, '4': 3, '5': 9, '10': 'userIds'},
    {'1': 'viewer_id', '3': 2, '4': 1, '5': 9, '10': 'viewerId'},
  ],
};

/// Descriptor for `BatchGetProfilesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List batchGetProfilesRequestDescriptor =
    $convert.base64Decode(
        'ChdCYXRjaEdldFByb2ZpbGVzUmVxdWVzdBIZCgh1c2VyX2lkcxgBIAMoCVIHdXNlcklkcxIbCg'
        'l2aWV3ZXJfaWQYAiABKAlSCHZpZXdlcklk');

@$core.Deprecated('Use batchGetProfilesResponseDescriptor instead')
const BatchGetProfilesResponse$json = {
  '1': 'BatchGetProfilesResponse',
  '2': [
    {
      '1': 'profiles',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.user.BatchGetProfilesResponse.ProfilesEntry',
      '10': 'profiles'
    },
  ],
  '3': [BatchGetProfilesResponse_ProfilesEntry$json],
};

@$core.Deprecated('Use batchGetProfilesResponseDescriptor instead')
const BatchGetProfilesResponse_ProfilesEntry$json = {
  '1': 'ProfilesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.user.Profile',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

/// Descriptor for `BatchGetProfilesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List batchGetProfilesResponseDescriptor = $convert.base64Decode(
    'ChhCYXRjaEdldFByb2ZpbGVzUmVzcG9uc2USSAoIcHJvZmlsZXMYASADKAsyLC51c2VyLkJhdG'
    'NoR2V0UHJvZmlsZXNSZXNwb25zZS5Qcm9maWxlc0VudHJ5Ughwcm9maWxlcxpKCg1Qcm9maWxl'
    'c0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5EiMKBXZhbHVlGAIgASgLMg0udXNlci5Qcm9maWxlUg'
    'V2YWx1ZToCOAE=');

@$core.Deprecated('Use followRequestDescriptor instead')
const FollowRequest$json = {
  '1': 'FollowRequest',
  '2': [
    {'1': 'follower_id', '3': 1, '4': 1, '5': 9, '10': 'followerId'},
    {'1': 'following_id', '3': 2, '4': 1, '5': 9, '10': 'followingId'},
  ],
};

/// Descriptor for `FollowRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List followRequestDescriptor = $convert.base64Decode(
    'Cg1Gb2xsb3dSZXF1ZXN0Eh8KC2ZvbGxvd2VyX2lkGAEgASgJUgpmb2xsb3dlcklkEiEKDGZvbG'
    'xvd2luZ19pZBgCIAEoCVILZm9sbG93aW5nSWQ=');

@$core.Deprecated('Use unfollowRequestDescriptor instead')
const UnfollowRequest$json = {
  '1': 'UnfollowRequest',
  '2': [
    {'1': 'follower_id', '3': 1, '4': 1, '5': 9, '10': 'followerId'},
    {'1': 'following_id', '3': 2, '4': 1, '5': 9, '10': 'followingId'},
  ],
};

/// Descriptor for `UnfollowRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unfollowRequestDescriptor = $convert.base64Decode(
    'Cg9VbmZvbGxvd1JlcXVlc3QSHwoLZm9sbG93ZXJfaWQYASABKAlSCmZvbGxvd2VySWQSIQoMZm'
    '9sbG93aW5nX2lkGAIgASgJUgtmb2xsb3dpbmdJZA==');

@$core.Deprecated('Use getFollowersRequestDescriptor instead')
const GetFollowersRequest$json = {
  '1': 'GetFollowersRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'viewer_id', '3': 2, '4': 1, '5': 9, '10': 'viewerId'},
    {
      '1': 'pagination',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.common.Pagination',
      '10': 'pagination'
    },
  ],
};

/// Descriptor for `GetFollowersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFollowersRequestDescriptor = $convert.base64Decode(
    'ChNHZXRGb2xsb3dlcnNSZXF1ZXN0EhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBIbCgl2aWV3ZX'
    'JfaWQYAiABKAlSCHZpZXdlcklkEjIKCnBhZ2luYXRpb24YAyABKAsyEi5jb21tb24uUGFnaW5h'
    'dGlvblIKcGFnaW5hdGlvbg==');

@$core.Deprecated('Use getFollowingRequestDescriptor instead')
const GetFollowingRequest$json = {
  '1': 'GetFollowingRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'viewer_id', '3': 2, '4': 1, '5': 9, '10': 'viewerId'},
    {
      '1': 'pagination',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.common.Pagination',
      '10': 'pagination'
    },
  ],
};

/// Descriptor for `GetFollowingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFollowingRequestDescriptor = $convert.base64Decode(
    'ChNHZXRGb2xsb3dpbmdSZXF1ZXN0EhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBIbCgl2aWV3ZX'
    'JfaWQYAiABKAlSCHZpZXdlcklkEjIKCnBhZ2luYXRpb24YAyABKAsyEi5jb21tb24uUGFnaW5h'
    'dGlvblIKcGFnaW5hdGlvbg==');

@$core.Deprecated('Use followListResponseDescriptor instead')
const FollowListResponse$json = {
  '1': 'FollowListResponse',
  '2': [
    {
      '1': 'users',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.user.Profile',
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

/// Descriptor for `FollowListResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List followListResponseDescriptor = $convert.base64Decode(
    'ChJGb2xsb3dMaXN0UmVzcG9uc2USIwoFdXNlcnMYASADKAsyDS51c2VyLlByb2ZpbGVSBXVzZX'
    'JzEjIKCnBhZ2luYXRpb24YAiABKAsyEi5jb21tb24uUGFnaW5hdGlvblIKcGFnaW5hdGlvbg==');

@$core.Deprecated('Use checkFollowingRequestDescriptor instead')
const CheckFollowingRequest$json = {
  '1': 'CheckFollowingRequest',
  '2': [
    {'1': 'follower_id', '3': 1, '4': 1, '5': 9, '10': 'followerId'},
    {'1': 'following_id', '3': 2, '4': 1, '5': 9, '10': 'followingId'},
  ],
};

/// Descriptor for `CheckFollowingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkFollowingRequestDescriptor = $convert.base64Decode(
    'ChVDaGVja0ZvbGxvd2luZ1JlcXVlc3QSHwoLZm9sbG93ZXJfaWQYASABKAlSCmZvbGxvd2VySW'
    'QSIQoMZm9sbG93aW5nX2lkGAIgASgJUgtmb2xsb3dpbmdJZA==');

@$core.Deprecated('Use checkFollowingResponseDescriptor instead')
const CheckFollowingResponse$json = {
  '1': 'CheckFollowingResponse',
  '2': [
    {'1': 'is_following', '3': 1, '4': 1, '5': 8, '10': 'isFollowing'},
  ],
};

/// Descriptor for `CheckFollowingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkFollowingResponseDescriptor =
    $convert.base64Decode(
        'ChZDaGVja0ZvbGxvd2luZ1Jlc3BvbnNlEiEKDGlzX2ZvbGxvd2luZxgBIAEoCFILaXNGb2xsb3'
        'dpbmc=');

@$core.Deprecated('Use getRelationshipRequestDescriptor instead')
const GetRelationshipRequest$json = {
  '1': 'GetRelationshipRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'target_id', '3': 2, '4': 1, '5': 9, '10': 'targetId'},
  ],
};

/// Descriptor for `GetRelationshipRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRelationshipRequestDescriptor =
    $convert.base64Decode(
        'ChZHZXRSZWxhdGlvbnNoaXBSZXF1ZXN0EhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBIbCgl0YX'
        'JnZXRfaWQYAiABKAlSCHRhcmdldElk');

@$core.Deprecated('Use getRelationshipResponseDescriptor instead')
const GetRelationshipResponse$json = {
  '1': 'GetRelationshipResponse',
  '2': [
    {
      '1': 'relationship',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.user.RelationshipStatus',
      '10': 'relationship'
    },
  ],
};

/// Descriptor for `GetRelationshipResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRelationshipResponseDescriptor =
    $convert.base64Decode(
        'ChdHZXRSZWxhdGlvbnNoaXBSZXNwb25zZRI8CgxyZWxhdGlvbnNoaXAYASABKAsyGC51c2VyLl'
        'JlbGF0aW9uc2hpcFN0YXR1c1IMcmVsYXRpb25zaGlw');

@$core.Deprecated('Use getMutualFollowersRequestDescriptor instead')
const GetMutualFollowersRequest$json = {
  '1': 'GetMutualFollowersRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'target_id', '3': 2, '4': 1, '5': 9, '10': 'targetId'},
    {
      '1': 'pagination',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.common.Pagination',
      '10': 'pagination'
    },
  ],
};

/// Descriptor for `GetMutualFollowersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMutualFollowersRequestDescriptor = $convert.base64Decode(
    'ChlHZXRNdXR1YWxGb2xsb3dlcnNSZXF1ZXN0EhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBIbCg'
    'l0YXJnZXRfaWQYAiABKAlSCHRhcmdldElkEjIKCnBhZ2luYXRpb24YAyABKAsyEi5jb21tb24u'
    'UGFnaW5hdGlvblIKcGFnaW5hdGlvbg==');

@$core.Deprecated('Use blockRequestDescriptor instead')
const BlockRequest$json = {
  '1': 'BlockRequest',
  '2': [
    {'1': 'blocker_id', '3': 1, '4': 1, '5': 9, '10': 'blockerId'},
    {'1': 'blocked_id', '3': 2, '4': 1, '5': 9, '10': 'blockedId'},
    {
      '1': 'block_type',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.user.BlockType',
      '10': 'blockType'
    },
  ],
};

/// Descriptor for `BlockRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockRequestDescriptor = $convert.base64Decode(
    'CgxCbG9ja1JlcXVlc3QSHQoKYmxvY2tlcl9pZBgBIAEoCVIJYmxvY2tlcklkEh0KCmJsb2NrZW'
    'RfaWQYAiABKAlSCWJsb2NrZWRJZBIuCgpibG9ja190eXBlGAMgASgOMg8udXNlci5CbG9ja1R5'
    'cGVSCWJsb2NrVHlwZQ==');

@$core.Deprecated('Use unblockRequestDescriptor instead')
const UnblockRequest$json = {
  '1': 'UnblockRequest',
  '2': [
    {'1': 'blocker_id', '3': 1, '4': 1, '5': 9, '10': 'blockerId'},
    {'1': 'blocked_id', '3': 2, '4': 1, '5': 9, '10': 'blockedId'},
    {
      '1': 'block_type',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.user.BlockType',
      '10': 'blockType'
    },
  ],
};

/// Descriptor for `UnblockRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unblockRequestDescriptor = $convert.base64Decode(
    'Cg5VbmJsb2NrUmVxdWVzdBIdCgpibG9ja2VyX2lkGAEgASgJUglibG9ja2VySWQSHQoKYmxvY2'
    'tlZF9pZBgCIAEoCVIJYmxvY2tlZElkEi4KCmJsb2NrX3R5cGUYAyABKA4yDy51c2VyLkJsb2Nr'
    'VHlwZVIJYmxvY2tUeXBl');

@$core.Deprecated('Use getBlockListRequestDescriptor instead')
const GetBlockListRequest$json = {
  '1': 'GetBlockListRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {
      '1': 'block_type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.user.BlockType',
      '10': 'blockType'
    },
    {
      '1': 'pagination',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.common.Pagination',
      '10': 'pagination'
    },
  ],
};

/// Descriptor for `GetBlockListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockListRequestDescriptor = $convert.base64Decode(
    'ChNHZXRCbG9ja0xpc3RSZXF1ZXN0EhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBIuCgpibG9ja1'
    '90eXBlGAIgASgOMg8udXNlci5CbG9ja1R5cGVSCWJsb2NrVHlwZRIyCgpwYWdpbmF0aW9uGAMg'
    'ASgLMhIuY29tbW9uLlBhZ2luYXRpb25SCnBhZ2luYXRpb24=');

@$core.Deprecated('Use blockListResponseDescriptor instead')
const BlockListResponse$json = {
  '1': 'BlockListResponse',
  '2': [
    {
      '1': 'users',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.user.BlockedUser',
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

/// Descriptor for `BlockListResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockListResponseDescriptor = $convert.base64Decode(
    'ChFCbG9ja0xpc3RSZXNwb25zZRInCgV1c2VycxgBIAMoCzIRLnVzZXIuQmxvY2tlZFVzZXJSBX'
    'VzZXJzEjIKCnBhZ2luYXRpb24YAiABKAsyEi5jb21tb24uUGFnaW5hdGlvblIKcGFnaW5hdGlv'
    'bg==');

@$core.Deprecated('Use blockedUserDescriptor instead')
const BlockedUser$json = {
  '1': 'BlockedUser',
  '2': [
    {
      '1': 'profile',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.user.Profile',
      '10': 'profile'
    },
    {
      '1': 'block_type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.user.BlockType',
      '10': 'blockType'
    },
    {
      '1': 'blocked_at',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.common.Timestamp',
      '10': 'blockedAt'
    },
  ],
};

/// Descriptor for `BlockedUser`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockedUserDescriptor = $convert.base64Decode(
    'CgtCbG9ja2VkVXNlchInCgdwcm9maWxlGAEgASgLMg0udXNlci5Qcm9maWxlUgdwcm9maWxlEi'
    '4KCmJsb2NrX3R5cGUYAiABKA4yDy51c2VyLkJsb2NrVHlwZVIJYmxvY2tUeXBlEjAKCmJsb2Nr'
    'ZWRfYXQYAyABKAsyES5jb21tb24uVGltZXN0YW1wUglibG9ja2VkQXQ=');

@$core.Deprecated('Use checkBlockedRequestDescriptor instead')
const CheckBlockedRequest$json = {
  '1': 'CheckBlockedRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'target_id', '3': 2, '4': 1, '5': 9, '10': 'targetId'},
  ],
};

/// Descriptor for `CheckBlockedRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkBlockedRequestDescriptor = $convert.base64Decode(
    'ChNDaGVja0Jsb2NrZWRSZXF1ZXN0EhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBIbCgl0YXJnZX'
    'RfaWQYAiABKAlSCHRhcmdldElk');

@$core.Deprecated('Use checkBlockedResponseDescriptor instead')
const CheckBlockedResponse$json = {
  '1': 'CheckBlockedResponse',
  '2': [
    {'1': 'is_blocking', '3': 1, '4': 1, '5': 8, '10': 'isBlocking'},
    {'1': 'is_blocked_by', '3': 2, '4': 1, '5': 8, '10': 'isBlockedBy'},
    {
      '1': 'my_block_type',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.user.BlockType',
      '10': 'myBlockType'
    },
    {
      '1': 'their_block_type',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.user.BlockType',
      '10': 'theirBlockType'
    },
    {'1': 'can_view_profile', '3': 5, '4': 1, '5': 8, '10': 'canViewProfile'},
    {'1': 'can_be_viewed', '3': 6, '4': 1, '5': 8, '10': 'canBeViewed'},
  ],
};

/// Descriptor for `CheckBlockedResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkBlockedResponseDescriptor = $convert.base64Decode(
    'ChRDaGVja0Jsb2NrZWRSZXNwb25zZRIfCgtpc19ibG9ja2luZxgBIAEoCFIKaXNCbG9ja2luZx'
    'IiCg1pc19ibG9ja2VkX2J5GAIgASgIUgtpc0Jsb2NrZWRCeRIzCg1teV9ibG9ja190eXBlGAMg'
    'ASgOMg8udXNlci5CbG9ja1R5cGVSC215QmxvY2tUeXBlEjkKEHRoZWlyX2Jsb2NrX3R5cGUYBC'
    'ABKA4yDy51c2VyLkJsb2NrVHlwZVIOdGhlaXJCbG9ja1R5cGUSKAoQY2FuX3ZpZXdfcHJvZmls'
    'ZRgFIAEoCFIOY2FuVmlld1Byb2ZpbGUSIgoNY2FuX2JlX3ZpZXdlZBgGIAEoCFILY2FuQmVWaW'
    'V3ZWQ=');

@$core.Deprecated('Use userSettingsDescriptor instead')
const UserSettings$json = {
  '1': 'UserSettings',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {
      '1': 'privacy',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.user.PrivacySettings',
      '10': 'privacy'
    },
    {
      '1': 'notification',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.user.NotificationSettings',
      '10': 'notification'
    },
  ],
};

/// Descriptor for `UserSettings`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userSettingsDescriptor = $convert.base64Decode(
    'CgxVc2VyU2V0dGluZ3MSFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklkEi8KB3ByaXZhY3kYAiABKA'
    'syFS51c2VyLlByaXZhY3lTZXR0aW5nc1IHcHJpdmFjeRI+Cgxub3RpZmljYXRpb24YAyABKAsy'
    'Gi51c2VyLk5vdGlmaWNhdGlvblNldHRpbmdzUgxub3RpZmljYXRpb24=');

@$core.Deprecated('Use privacySettingsDescriptor instead')
const PrivacySettings$json = {
  '1': 'PrivacySettings',
  '2': [
    {
      '1': 'is_private_account',
      '3': 1,
      '4': 1,
      '5': 8,
      '10': 'isPrivateAccount'
    },
    {
      '1': 'allow_message_from_anyone',
      '3': 2,
      '4': 1,
      '5': 8,
      '10': 'allowMessageFromAnyone'
    },
    {
      '1': 'show_online_status',
      '3': 3,
      '4': 1,
      '5': 8,
      '10': 'showOnlineStatus'
    },
    {'1': 'show_last_seen', '3': 4, '4': 1, '5': 8, '10': 'showLastSeen'},
    {'1': 'allow_tagging', '3': 5, '4': 1, '5': 8, '10': 'allowTagging'},
    {
      '1': 'show_activity_status',
      '3': 6,
      '4': 1,
      '5': 8,
      '10': 'showActivityStatus'
    },
  ],
};

/// Descriptor for `PrivacySettings`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List privacySettingsDescriptor = $convert.base64Decode(
    'Cg9Qcml2YWN5U2V0dGluZ3MSLAoSaXNfcHJpdmF0ZV9hY2NvdW50GAEgASgIUhBpc1ByaXZhdG'
    'VBY2NvdW50EjkKGWFsbG93X21lc3NhZ2VfZnJvbV9hbnlvbmUYAiABKAhSFmFsbG93TWVzc2Fn'
    'ZUZyb21BbnlvbmUSLAoSc2hvd19vbmxpbmVfc3RhdHVzGAMgASgIUhBzaG93T25saW5lU3RhdH'
    'VzEiQKDnNob3dfbGFzdF9zZWVuGAQgASgIUgxzaG93TGFzdFNlZW4SIwoNYWxsb3dfdGFnZ2lu'
    'ZxgFIAEoCFIMYWxsb3dUYWdnaW5nEjAKFHNob3dfYWN0aXZpdHlfc3RhdHVzGAYgASgIUhJzaG'
    '93QWN0aXZpdHlTdGF0dXM=');

@$core.Deprecated('Use notificationSettingsDescriptor instead')
const NotificationSettings$json = {
  '1': 'NotificationSettings',
  '2': [
    {'1': 'push_enabled', '3': 1, '4': 1, '5': 8, '10': 'pushEnabled'},
    {'1': 'email_enabled', '3': 2, '4': 1, '5': 8, '10': 'emailEnabled'},
    {
      '1': 'notify_new_follower',
      '3': 3,
      '4': 1,
      '5': 8,
      '10': 'notifyNewFollower'
    },
    {'1': 'notify_like', '3': 4, '4': 1, '5': 8, '10': 'notifyLike'},
    {'1': 'notify_comment', '3': 5, '4': 1, '5': 8, '10': 'notifyComment'},
    {'1': 'notify_mention', '3': 6, '4': 1, '5': 8, '10': 'notifyMention'},
    {'1': 'notify_repost', '3': 7, '4': 1, '5': 8, '10': 'notifyRepost'},
    {'1': 'notify_message', '3': 8, '4': 1, '5': 8, '10': 'notifyMessage'},
  ],
};

/// Descriptor for `NotificationSettings`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationSettingsDescriptor = $convert.base64Decode(
    'ChROb3RpZmljYXRpb25TZXR0aW5ncxIhCgxwdXNoX2VuYWJsZWQYASABKAhSC3B1c2hFbmFibG'
    'VkEiMKDWVtYWlsX2VuYWJsZWQYAiABKAhSDGVtYWlsRW5hYmxlZBIuChNub3RpZnlfbmV3X2Zv'
    'bGxvd2VyGAMgASgIUhFub3RpZnlOZXdGb2xsb3dlchIfCgtub3RpZnlfbGlrZRgEIAEoCFIKbm'
    '90aWZ5TGlrZRIlCg5ub3RpZnlfY29tbWVudBgFIAEoCFINbm90aWZ5Q29tbWVudBIlCg5ub3Rp'
    'ZnlfbWVudGlvbhgGIAEoCFINbm90aWZ5TWVudGlvbhIjCg1ub3RpZnlfcmVwb3N0GAcgASgIUg'
    'xub3RpZnlSZXBvc3QSJQoObm90aWZ5X21lc3NhZ2UYCCABKAhSDW5vdGlmeU1lc3NhZ2U=');

@$core.Deprecated('Use getUserSettingsRequestDescriptor instead')
const GetUserSettingsRequest$json = {
  '1': 'GetUserSettingsRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `GetUserSettingsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getUserSettingsRequestDescriptor =
    $convert.base64Decode(
        'ChZHZXRVc2VyU2V0dGluZ3NSZXF1ZXN0EhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZA==');

@$core.Deprecated('Use updateUserSettingsRequestDescriptor instead')
const UpdateUserSettingsRequest$json = {
  '1': 'UpdateUserSettingsRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {
      '1': 'privacy',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.user.PrivacySettings',
      '9': 0,
      '10': 'privacy',
      '17': true
    },
    {
      '1': 'notification',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.user.NotificationSettings',
      '9': 1,
      '10': 'notification',
      '17': true
    },
  ],
  '8': [
    {'1': '_privacy'},
    {'1': '_notification'},
  ],
};

/// Descriptor for `UpdateUserSettingsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateUserSettingsRequestDescriptor = $convert.base64Decode(
    'ChlVcGRhdGVVc2VyU2V0dGluZ3NSZXF1ZXN0EhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBI0Cg'
    'dwcml2YWN5GAIgASgLMhUudXNlci5Qcml2YWN5U2V0dGluZ3NIAFIHcHJpdmFjeYgBARJDCgxu'
    'b3RpZmljYXRpb24YAyABKAsyGi51c2VyLk5vdGlmaWNhdGlvblNldHRpbmdzSAFSDG5vdGlmaW'
    'NhdGlvbogBAUIKCghfcHJpdmFjeUIPCg1fbm90aWZpY2F0aW9u');

@$core.Deprecated('Use searchUsersRequestDescriptor instead')
const SearchUsersRequest$json = {
  '1': 'SearchUsersRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
    {'1': 'viewer_id', '3': 2, '4': 1, '5': 9, '10': 'viewerId'},
    {
      '1': 'pagination',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.common.Pagination',
      '10': 'pagination'
    },
  ],
};

/// Descriptor for `SearchUsersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchUsersRequestDescriptor = $convert.base64Decode(
    'ChJTZWFyY2hVc2Vyc1JlcXVlc3QSFAoFcXVlcnkYASABKAlSBXF1ZXJ5EhsKCXZpZXdlcl9pZB'
    'gCIAEoCVIIdmlld2VySWQSMgoKcGFnaW5hdGlvbhgDIAEoCzISLmNvbW1vbi5QYWdpbmF0aW9u'
    'UgpwYWdpbmF0aW9u');

@$core.Deprecated('Use searchUsersResponseDescriptor instead')
const SearchUsersResponse$json = {
  '1': 'SearchUsersResponse',
  '2': [
    {
      '1': 'users',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.user.Profile',
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
    'ChNTZWFyY2hVc2Vyc1Jlc3BvbnNlEiMKBXVzZXJzGAEgAygLMg0udXNlci5Qcm9maWxlUgV1c2'
    'VycxIyCgpwYWdpbmF0aW9uGAIgASgLMhIuY29tbW9uLlBhZ2luYXRpb25SCnBhZ2luYXRpb24=');
