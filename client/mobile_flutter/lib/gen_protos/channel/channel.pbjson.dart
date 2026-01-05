// This is a generated file - do not edit.
//
// Generated from channel/channel.proto.

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

@$core.Deprecated('Use channelDescriptor instead')
const Channel$json = {
  '1': 'Channel',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {'1': 'avatar_url', '3': 4, '4': 1, '5': 9, '10': 'avatarUrl'},
    {'1': 'owner_id', '3': 5, '4': 1, '5': 9, '10': 'ownerId'},
    {'1': 'admin_ids', '3': 6, '4': 3, '5': 9, '10': 'adminIds'},
    {'1': 'subscriber_count', '3': 7, '4': 1, '5': 3, '10': 'subscriberCount'},
    {'1': 'post_count', '3': 8, '4': 1, '5': 3, '10': 'postCount'},
    {
      '1': 'created_at',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.common.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.common.Timestamp',
      '10': 'updatedAt'
    },
    {'1': 'is_subscribed', '3': 11, '4': 1, '5': 8, '10': 'isSubscribed'},
    {'1': 'is_admin', '3': 12, '4': 1, '5': 8, '10': 'isAdmin'},
    {'1': 'is_owner', '3': 13, '4': 1, '5': 8, '10': 'isOwner'},
    {
      '1': 'pinned_post',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.channel.ChannelPost',
      '10': 'pinnedPost'
    },
    {'1': 'username', '3': 15, '4': 1, '5': 9, '10': 'username'},
    {'1': 'is_public', '3': 16, '4': 1, '5': 8, '10': 'isPublic'},
  ],
};

/// Descriptor for `Channel`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List channelDescriptor = $convert.base64Decode(
    'CgdDaGFubmVsEg4KAmlkGAEgASgJUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEiAKC2Rlc2NyaX'
    'B0aW9uGAMgASgJUgtkZXNjcmlwdGlvbhIdCgphdmF0YXJfdXJsGAQgASgJUglhdmF0YXJVcmwS'
    'GQoIb3duZXJfaWQYBSABKAlSB293bmVySWQSGwoJYWRtaW5faWRzGAYgAygJUghhZG1pbklkcx'
    'IpChBzdWJzY3JpYmVyX2NvdW50GAcgASgDUg9zdWJzY3JpYmVyQ291bnQSHQoKcG9zdF9jb3Vu'
    'dBgIIAEoA1IJcG9zdENvdW50EjAKCmNyZWF0ZWRfYXQYCSABKAsyES5jb21tb24uVGltZXN0YW'
    '1wUgljcmVhdGVkQXQSMAoKdXBkYXRlZF9hdBgKIAEoCzIRLmNvbW1vbi5UaW1lc3RhbXBSCXVw'
    'ZGF0ZWRBdBIjCg1pc19zdWJzY3JpYmVkGAsgASgIUgxpc1N1YnNjcmliZWQSGQoIaXNfYWRtaW'
    '4YDCABKAhSB2lzQWRtaW4SGQoIaXNfb3duZXIYDSABKAhSB2lzT3duZXISNQoLcGlubmVkX3Bv'
    'c3QYDiABKAsyFC5jaGFubmVsLkNoYW5uZWxQb3N0UgpwaW5uZWRQb3N0EhoKCHVzZXJuYW1lGA'
    '8gASgJUgh1c2VybmFtZRIbCglpc19wdWJsaWMYECABKAhSCGlzUHVibGlj');

@$core.Deprecated('Use channelPostDescriptor instead')
const ChannelPost$json = {
  '1': 'ChannelPost',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'channel_id', '3': 2, '4': 1, '5': 9, '10': 'channelId'},
    {'1': 'author_id', '3': 3, '4': 1, '5': 9, '10': 'authorId'},
    {'1': 'content', '3': 4, '4': 1, '5': 9, '10': 'content'},
    {'1': 'media_urls', '3': 5, '4': 3, '5': 9, '10': 'mediaUrls'},
    {'1': 'view_count', '3': 6, '4': 1, '5': 3, '10': 'viewCount'},
    {
      '1': 'created_at',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.common.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.common.Timestamp',
      '10': 'updatedAt'
    },
    {'1': 'is_pinned', '3': 9, '4': 1, '5': 8, '10': 'isPinned'},
    {'1': 'is_edited', '3': 10, '4': 1, '5': 8, '10': 'isEdited'},
    {'1': 'author_name', '3': 11, '4': 1, '5': 9, '10': 'authorName'},
  ],
};

/// Descriptor for `ChannelPost`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List channelPostDescriptor = $convert.base64Decode(
    'CgtDaGFubmVsUG9zdBIOCgJpZBgBIAEoCVICaWQSHQoKY2hhbm5lbF9pZBgCIAEoCVIJY2hhbm'
    '5lbElkEhsKCWF1dGhvcl9pZBgDIAEoCVIIYXV0aG9ySWQSGAoHY29udGVudBgEIAEoCVIHY29u'
    'dGVudBIdCgptZWRpYV91cmxzGAUgAygJUgltZWRpYVVybHMSHQoKdmlld19jb3VudBgGIAEoA1'
    'IJdmlld0NvdW50EjAKCmNyZWF0ZWRfYXQYByABKAsyES5jb21tb24uVGltZXN0YW1wUgljcmVh'
    'dGVkQXQSMAoKdXBkYXRlZF9hdBgIIAEoCzIRLmNvbW1vbi5UaW1lc3RhbXBSCXVwZGF0ZWRBdB'
    'IbCglpc19waW5uZWQYCSABKAhSCGlzUGlubmVkEhsKCWlzX2VkaXRlZBgKIAEoCFIIaXNFZGl0'
    'ZWQSHwoLYXV0aG9yX25hbWUYCyABKAlSCmF1dGhvck5hbWU=');

@$core.Deprecated('Use subscriberDescriptor instead')
const Subscriber$json = {
  '1': 'Subscriber',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'username', '3': 2, '4': 1, '5': 9, '10': 'username'},
    {'1': 'avatar_url', '3': 3, '4': 1, '5': 9, '10': 'avatarUrl'},
    {
      '1': 'subscribed_at',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.common.Timestamp',
      '10': 'subscribedAt'
    },
  ],
};

/// Descriptor for `Subscriber`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subscriberDescriptor = $convert.base64Decode(
    'CgpTdWJzY3JpYmVyEhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBIaCgh1c2VybmFtZRgCIAEoCV'
    'IIdXNlcm5hbWUSHQoKYXZhdGFyX3VybBgDIAEoCVIJYXZhdGFyVXJsEjYKDXN1YnNjcmliZWRf'
    'YXQYBCABKAsyES5jb21tb24uVGltZXN0YW1wUgxzdWJzY3JpYmVkQXQ=');

@$core.Deprecated('Use adminDescriptor instead')
const Admin$json = {
  '1': 'Admin',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'username', '3': 2, '4': 1, '5': 9, '10': 'username'},
    {'1': 'avatar_url', '3': 3, '4': 1, '5': 9, '10': 'avatarUrl'},
    {'1': 'is_owner', '3': 4, '4': 1, '5': 8, '10': 'isOwner'},
    {
      '1': 'added_at',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.common.Timestamp',
      '10': 'addedAt'
    },
  ],
};

/// Descriptor for `Admin`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List adminDescriptor = $convert.base64Decode(
    'CgVBZG1pbhIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSGgoIdXNlcm5hbWUYAiABKAlSCHVzZX'
    'JuYW1lEh0KCmF2YXRhcl91cmwYAyABKAlSCWF2YXRhclVybBIZCghpc19vd25lchgEIAEoCFIH'
    'aXNPd25lchIsCghhZGRlZF9hdBgFIAEoCzIRLmNvbW1vbi5UaW1lc3RhbXBSB2FkZGVkQXQ=');

@$core.Deprecated('Use createChannelRequestDescriptor instead')
const CreateChannelRequest$json = {
  '1': 'CreateChannelRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 2, '4': 1, '5': 9, '10': 'description'},
    {'1': 'avatar_url', '3': 3, '4': 1, '5': 9, '10': 'avatarUrl'},
    {'1': 'username', '3': 4, '4': 1, '5': 9, '10': 'username'},
    {'1': 'is_public', '3': 5, '4': 1, '5': 8, '10': 'isPublic'},
  ],
};

/// Descriptor for `CreateChannelRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createChannelRequestDescriptor = $convert.base64Decode(
    'ChRDcmVhdGVDaGFubmVsUmVxdWVzdBISCgRuYW1lGAEgASgJUgRuYW1lEiAKC2Rlc2NyaXB0aW'
    '9uGAIgASgJUgtkZXNjcmlwdGlvbhIdCgphdmF0YXJfdXJsGAMgASgJUglhdmF0YXJVcmwSGgoI'
    'dXNlcm5hbWUYBCABKAlSCHVzZXJuYW1lEhsKCWlzX3B1YmxpYxgFIAEoCFIIaXNQdWJsaWM=');

@$core.Deprecated('Use getChannelRequestDescriptor instead')
const GetChannelRequest$json = {
  '1': 'GetChannelRequest',
  '2': [
    {'1': 'channel_id', '3': 1, '4': 1, '5': 9, '10': 'channelId'},
  ],
};

/// Descriptor for `GetChannelRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getChannelRequestDescriptor = $convert.base64Decode(
    'ChFHZXRDaGFubmVsUmVxdWVzdBIdCgpjaGFubmVsX2lkGAEgASgJUgljaGFubmVsSWQ=');

@$core.Deprecated('Use updateChannelRequestDescriptor instead')
const UpdateChannelRequest$json = {
  '1': 'UpdateChannelRequest',
  '2': [
    {'1': 'channel_id', '3': 1, '4': 1, '5': 9, '10': 'channelId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {'1': 'avatar_url', '3': 4, '4': 1, '5': 9, '10': 'avatarUrl'},
    {'1': 'username', '3': 5, '4': 1, '5': 9, '10': 'username'},
    {'1': 'is_public', '3': 6, '4': 1, '5': 8, '10': 'isPublic'},
  ],
};

/// Descriptor for `UpdateChannelRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateChannelRequestDescriptor = $convert.base64Decode(
    'ChRVcGRhdGVDaGFubmVsUmVxdWVzdBIdCgpjaGFubmVsX2lkGAEgASgJUgljaGFubmVsSWQSEg'
    'oEbmFtZRgCIAEoCVIEbmFtZRIgCgtkZXNjcmlwdGlvbhgDIAEoCVILZGVzY3JpcHRpb24SHQoK'
    'YXZhdGFyX3VybBgEIAEoCVIJYXZhdGFyVXJsEhoKCHVzZXJuYW1lGAUgASgJUgh1c2VybmFtZR'
    'IbCglpc19wdWJsaWMYBiABKAhSCGlzUHVibGlj');

@$core.Deprecated('Use deleteChannelRequestDescriptor instead')
const DeleteChannelRequest$json = {
  '1': 'DeleteChannelRequest',
  '2': [
    {'1': 'channel_id', '3': 1, '4': 1, '5': 9, '10': 'channelId'},
  ],
};

/// Descriptor for `DeleteChannelRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteChannelRequestDescriptor = $convert.base64Decode(
    'ChREZWxldGVDaGFubmVsUmVxdWVzdBIdCgpjaGFubmVsX2lkGAEgASgJUgljaGFubmVsSWQ=');

@$core.Deprecated('Use getSubscribedChannelsRequestDescriptor instead')
const GetSubscribedChannelsRequest$json = {
  '1': 'GetSubscribedChannelsRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
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

/// Descriptor for `GetSubscribedChannelsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSubscribedChannelsRequestDescriptor =
    $convert.base64Decode(
        'ChxHZXRTdWJzY3JpYmVkQ2hhbm5lbHNSZXF1ZXN0EhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZB'
        'IyCgpwYWdpbmF0aW9uGAIgASgLMhIuY29tbW9uLlBhZ2luYXRpb25SCnBhZ2luYXRpb24=');

@$core.Deprecated('Use getOwnedChannelsRequestDescriptor instead')
const GetOwnedChannelsRequest$json = {
  '1': 'GetOwnedChannelsRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
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

/// Descriptor for `GetOwnedChannelsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getOwnedChannelsRequestDescriptor =
    $convert.base64Decode(
        'ChdHZXRPd25lZENoYW5uZWxzUmVxdWVzdBIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSMgoKcG'
        'FnaW5hdGlvbhgCIAEoCzISLmNvbW1vbi5QYWdpbmF0aW9uUgpwYWdpbmF0aW9u');

@$core.Deprecated('Use searchChannelsRequestDescriptor instead')
const SearchChannelsRequest$json = {
  '1': 'SearchChannelsRequest',
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

/// Descriptor for `SearchChannelsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchChannelsRequestDescriptor = $convert.base64Decode(
    'ChVTZWFyY2hDaGFubmVsc1JlcXVlc3QSFAoFcXVlcnkYASABKAlSBXF1ZXJ5EjIKCnBhZ2luYX'
    'Rpb24YAiABKAsyEi5jb21tb24uUGFnaW5hdGlvblIKcGFnaW5hdGlvbg==');

@$core.Deprecated('Use channelsResponseDescriptor instead')
const ChannelsResponse$json = {
  '1': 'ChannelsResponse',
  '2': [
    {
      '1': 'channels',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.channel.Channel',
      '10': 'channels'
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

/// Descriptor for `ChannelsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List channelsResponseDescriptor = $convert.base64Decode(
    'ChBDaGFubmVsc1Jlc3BvbnNlEiwKCGNoYW5uZWxzGAEgAygLMhAuY2hhbm5lbC5DaGFubmVsUg'
    'hjaGFubmVscxIyCgpwYWdpbmF0aW9uGAIgASgLMhIuY29tbW9uLlBhZ2luYXRpb25SCnBhZ2lu'
    'YXRpb24=');

@$core.Deprecated('Use subscribeRequestDescriptor instead')
const SubscribeRequest$json = {
  '1': 'SubscribeRequest',
  '2': [
    {'1': 'channel_id', '3': 1, '4': 1, '5': 9, '10': 'channelId'},
  ],
};

/// Descriptor for `SubscribeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subscribeRequestDescriptor = $convert.base64Decode(
    'ChBTdWJzY3JpYmVSZXF1ZXN0Eh0KCmNoYW5uZWxfaWQYASABKAlSCWNoYW5uZWxJZA==');

@$core.Deprecated('Use unsubscribeRequestDescriptor instead')
const UnsubscribeRequest$json = {
  '1': 'UnsubscribeRequest',
  '2': [
    {'1': 'channel_id', '3': 1, '4': 1, '5': 9, '10': 'channelId'},
  ],
};

/// Descriptor for `UnsubscribeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unsubscribeRequestDescriptor =
    $convert.base64Decode(
        'ChJVbnN1YnNjcmliZVJlcXVlc3QSHQoKY2hhbm5lbF9pZBgBIAEoCVIJY2hhbm5lbElk');

@$core.Deprecated('Use getSubscribersRequestDescriptor instead')
const GetSubscribersRequest$json = {
  '1': 'GetSubscribersRequest',
  '2': [
    {'1': 'channel_id', '3': 1, '4': 1, '5': 9, '10': 'channelId'},
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

/// Descriptor for `GetSubscribersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSubscribersRequestDescriptor = $convert.base64Decode(
    'ChVHZXRTdWJzY3JpYmVyc1JlcXVlc3QSHQoKY2hhbm5lbF9pZBgBIAEoCVIJY2hhbm5lbElkEj'
    'IKCnBhZ2luYXRpb24YAiABKAsyEi5jb21tb24uUGFnaW5hdGlvblIKcGFnaW5hdGlvbg==');

@$core.Deprecated('Use subscribersResponseDescriptor instead')
const SubscribersResponse$json = {
  '1': 'SubscribersResponse',
  '2': [
    {
      '1': 'subscribers',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.channel.Subscriber',
      '10': 'subscribers'
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

/// Descriptor for `SubscribersResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subscribersResponseDescriptor = $convert.base64Decode(
    'ChNTdWJzY3JpYmVyc1Jlc3BvbnNlEjUKC3N1YnNjcmliZXJzGAEgAygLMhMuY2hhbm5lbC5TdW'
    'JzY3JpYmVyUgtzdWJzY3JpYmVycxIyCgpwYWdpbmF0aW9uGAIgASgLMhIuY29tbW9uLlBhZ2lu'
    'YXRpb25SCnBhZ2luYXRpb24=');

@$core.Deprecated('Use checkSubscriptionRequestDescriptor instead')
const CheckSubscriptionRequest$json = {
  '1': 'CheckSubscriptionRequest',
  '2': [
    {'1': 'channel_id', '3': 1, '4': 1, '5': 9, '10': 'channelId'},
  ],
};

/// Descriptor for `CheckSubscriptionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkSubscriptionRequestDescriptor =
    $convert.base64Decode(
        'ChhDaGVja1N1YnNjcmlwdGlvblJlcXVlc3QSHQoKY2hhbm5lbF9pZBgBIAEoCVIJY2hhbm5lbE'
        'lk');

@$core.Deprecated('Use checkSubscriptionResponseDescriptor instead')
const CheckSubscriptionResponse$json = {
  '1': 'CheckSubscriptionResponse',
  '2': [
    {'1': 'is_subscribed', '3': 1, '4': 1, '5': 8, '10': 'isSubscribed'},
  ],
};

/// Descriptor for `CheckSubscriptionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkSubscriptionResponseDescriptor =
    $convert.base64Decode(
        'ChlDaGVja1N1YnNjcmlwdGlvblJlc3BvbnNlEiMKDWlzX3N1YnNjcmliZWQYASABKAhSDGlzU3'
        'Vic2NyaWJlZA==');

@$core.Deprecated('Use addAdminRequestDescriptor instead')
const AddAdminRequest$json = {
  '1': 'AddAdminRequest',
  '2': [
    {'1': 'channel_id', '3': 1, '4': 1, '5': 9, '10': 'channelId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `AddAdminRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addAdminRequestDescriptor = $convert.base64Decode(
    'Cg9BZGRBZG1pblJlcXVlc3QSHQoKY2hhbm5lbF9pZBgBIAEoCVIJY2hhbm5lbElkEhcKB3VzZX'
    'JfaWQYAiABKAlSBnVzZXJJZA==');

@$core.Deprecated('Use removeAdminRequestDescriptor instead')
const RemoveAdminRequest$json = {
  '1': 'RemoveAdminRequest',
  '2': [
    {'1': 'channel_id', '3': 1, '4': 1, '5': 9, '10': 'channelId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `RemoveAdminRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeAdminRequestDescriptor = $convert.base64Decode(
    'ChJSZW1vdmVBZG1pblJlcXVlc3QSHQoKY2hhbm5lbF9pZBgBIAEoCVIJY2hhbm5lbElkEhcKB3'
    'VzZXJfaWQYAiABKAlSBnVzZXJJZA==');

@$core.Deprecated('Use getAdminsRequestDescriptor instead')
const GetAdminsRequest$json = {
  '1': 'GetAdminsRequest',
  '2': [
    {'1': 'channel_id', '3': 1, '4': 1, '5': 9, '10': 'channelId'},
  ],
};

/// Descriptor for `GetAdminsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAdminsRequestDescriptor = $convert.base64Decode(
    'ChBHZXRBZG1pbnNSZXF1ZXN0Eh0KCmNoYW5uZWxfaWQYASABKAlSCWNoYW5uZWxJZA==');

@$core.Deprecated('Use adminsResponseDescriptor instead')
const AdminsResponse$json = {
  '1': 'AdminsResponse',
  '2': [
    {
      '1': 'admins',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.channel.Admin',
      '10': 'admins'
    },
  ],
};

/// Descriptor for `AdminsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List adminsResponseDescriptor = $convert.base64Decode(
    'Cg5BZG1pbnNSZXNwb25zZRImCgZhZG1pbnMYASADKAsyDi5jaGFubmVsLkFkbWluUgZhZG1pbn'
    'M=');

@$core.Deprecated('Use publishPostRequestDescriptor instead')
const PublishPostRequest$json = {
  '1': 'PublishPostRequest',
  '2': [
    {'1': 'channel_id', '3': 1, '4': 1, '5': 9, '10': 'channelId'},
    {'1': 'content', '3': 2, '4': 1, '5': 9, '10': 'content'},
    {'1': 'media_urls', '3': 3, '4': 3, '5': 9, '10': 'mediaUrls'},
  ],
};

/// Descriptor for `PublishPostRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List publishPostRequestDescriptor = $convert.base64Decode(
    'ChJQdWJsaXNoUG9zdFJlcXVlc3QSHQoKY2hhbm5lbF9pZBgBIAEoCVIJY2hhbm5lbElkEhgKB2'
    'NvbnRlbnQYAiABKAlSB2NvbnRlbnQSHQoKbWVkaWFfdXJscxgDIAMoCVIJbWVkaWFVcmxz');

@$core.Deprecated('Use getPostsRequestDescriptor instead')
const GetPostsRequest$json = {
  '1': 'GetPostsRequest',
  '2': [
    {'1': 'channel_id', '3': 1, '4': 1, '5': 9, '10': 'channelId'},
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

/// Descriptor for `GetPostsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPostsRequestDescriptor = $convert.base64Decode(
    'Cg9HZXRQb3N0c1JlcXVlc3QSHQoKY2hhbm5lbF9pZBgBIAEoCVIJY2hhbm5lbElkEjIKCnBhZ2'
    'luYXRpb24YAiABKAsyEi5jb21tb24uUGFnaW5hdGlvblIKcGFnaW5hdGlvbg==');

@$core.Deprecated('Use getPostRequestDescriptor instead')
const GetPostRequest$json = {
  '1': 'GetPostRequest',
  '2': [
    {'1': 'post_id', '3': 1, '4': 1, '5': 9, '10': 'postId'},
  ],
};

/// Descriptor for `GetPostRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPostRequestDescriptor = $convert
    .base64Decode('Cg5HZXRQb3N0UmVxdWVzdBIXCgdwb3N0X2lkGAEgASgJUgZwb3N0SWQ=');

@$core.Deprecated('Use editPostRequestDescriptor instead')
const EditPostRequest$json = {
  '1': 'EditPostRequest',
  '2': [
    {'1': 'post_id', '3': 1, '4': 1, '5': 9, '10': 'postId'},
    {'1': 'content', '3': 2, '4': 1, '5': 9, '10': 'content'},
    {'1': 'media_urls', '3': 3, '4': 3, '5': 9, '10': 'mediaUrls'},
  ],
};

/// Descriptor for `EditPostRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List editPostRequestDescriptor = $convert.base64Decode(
    'Cg9FZGl0UG9zdFJlcXVlc3QSFwoHcG9zdF9pZBgBIAEoCVIGcG9zdElkEhgKB2NvbnRlbnQYAi'
    'ABKAlSB2NvbnRlbnQSHQoKbWVkaWFfdXJscxgDIAMoCVIJbWVkaWFVcmxz');

@$core.Deprecated('Use deletePostRequestDescriptor instead')
const DeletePostRequest$json = {
  '1': 'DeletePostRequest',
  '2': [
    {'1': 'post_id', '3': 1, '4': 1, '5': 9, '10': 'postId'},
  ],
};

/// Descriptor for `DeletePostRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deletePostRequestDescriptor = $convert.base64Decode(
    'ChFEZWxldGVQb3N0UmVxdWVzdBIXCgdwb3N0X2lkGAEgASgJUgZwb3N0SWQ=');

@$core.Deprecated('Use pinPostRequestDescriptor instead')
const PinPostRequest$json = {
  '1': 'PinPostRequest',
  '2': [
    {'1': 'post_id', '3': 1, '4': 1, '5': 9, '10': 'postId'},
  ],
};

/// Descriptor for `PinPostRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pinPostRequestDescriptor = $convert
    .base64Decode('Cg5QaW5Qb3N0UmVxdWVzdBIXCgdwb3N0X2lkGAEgASgJUgZwb3N0SWQ=');

@$core.Deprecated('Use unpinPostRequestDescriptor instead')
const UnpinPostRequest$json = {
  '1': 'UnpinPostRequest',
  '2': [
    {'1': 'post_id', '3': 1, '4': 1, '5': 9, '10': 'postId'},
  ],
};

/// Descriptor for `UnpinPostRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unpinPostRequestDescriptor = $convert.base64Decode(
    'ChBVbnBpblBvc3RSZXF1ZXN0EhcKB3Bvc3RfaWQYASABKAlSBnBvc3RJZA==');

@$core.Deprecated('Use postsResponseDescriptor instead')
const PostsResponse$json = {
  '1': 'PostsResponse',
  '2': [
    {
      '1': 'posts',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.channel.ChannelPost',
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

/// Descriptor for `PostsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List postsResponseDescriptor = $convert.base64Decode(
    'Cg1Qb3N0c1Jlc3BvbnNlEioKBXBvc3RzGAEgAygLMhQuY2hhbm5lbC5DaGFubmVsUG9zdFIFcG'
    '9zdHMSMgoKcGFnaW5hdGlvbhgCIAEoCzISLmNvbW1vbi5QYWdpbmF0aW9uUgpwYWdpbmF0aW9u');

@$core.Deprecated('Use channelClientEventDescriptor instead')
const ChannelClientEvent$json = {
  '1': 'ChannelClientEvent',
  '2': [
    {
      '1': 'subscribe',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.channel.ChannelSubscribeEvent',
      '9': 0,
      '10': 'subscribe'
    },
    {
      '1': 'unsubscribe',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.channel.ChannelUnsubscribeEvent',
      '9': 0,
      '10': 'unsubscribe'
    },
    {
      '1': 'ping',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.channel.ChannelPingEvent',
      '9': 0,
      '10': 'ping'
    },
  ],
  '8': [
    {'1': 'event'},
  ],
};

/// Descriptor for `ChannelClientEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List channelClientEventDescriptor = $convert.base64Decode(
    'ChJDaGFubmVsQ2xpZW50RXZlbnQSPgoJc3Vic2NyaWJlGAEgASgLMh4uY2hhbm5lbC5DaGFubm'
    'VsU3Vic2NyaWJlRXZlbnRIAFIJc3Vic2NyaWJlEkQKC3Vuc3Vic2NyaWJlGAIgASgLMiAuY2hh'
    'bm5lbC5DaGFubmVsVW5zdWJzY3JpYmVFdmVudEgAUgt1bnN1YnNjcmliZRIvCgRwaW5nGAMgAS'
    'gLMhkuY2hhbm5lbC5DaGFubmVsUGluZ0V2ZW50SABSBHBpbmdCBwoFZXZlbnQ=');

@$core.Deprecated('Use channelSubscribeEventDescriptor instead')
const ChannelSubscribeEvent$json = {
  '1': 'ChannelSubscribeEvent',
  '2': [
    {'1': 'channel_id', '3': 1, '4': 1, '5': 9, '10': 'channelId'},
  ],
};

/// Descriptor for `ChannelSubscribeEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List channelSubscribeEventDescriptor = $convert.base64Decode(
    'ChVDaGFubmVsU3Vic2NyaWJlRXZlbnQSHQoKY2hhbm5lbF9pZBgBIAEoCVIJY2hhbm5lbElk');

@$core.Deprecated('Use channelUnsubscribeEventDescriptor instead')
const ChannelUnsubscribeEvent$json = {
  '1': 'ChannelUnsubscribeEvent',
  '2': [
    {'1': 'channel_id', '3': 1, '4': 1, '5': 9, '10': 'channelId'},
  ],
};

/// Descriptor for `ChannelUnsubscribeEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List channelUnsubscribeEventDescriptor =
    $convert.base64Decode(
        'ChdDaGFubmVsVW5zdWJzY3JpYmVFdmVudBIdCgpjaGFubmVsX2lkGAEgASgJUgljaGFubmVsSW'
        'Q=');

@$core.Deprecated('Use channelPingEventDescriptor instead')
const ChannelPingEvent$json = {
  '1': 'ChannelPingEvent',
};

/// Descriptor for `ChannelPingEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List channelPingEventDescriptor =
    $convert.base64Decode('ChBDaGFubmVsUGluZ0V2ZW50');

@$core.Deprecated('Use channelServerEventDescriptor instead')
const ChannelServerEvent$json = {
  '1': 'ChannelServerEvent',
  '2': [
    {
      '1': 'new_post',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.channel.NewPostEvent',
      '9': 0,
      '10': 'newPost'
    },
    {
      '1': 'post_edited',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.channel.PostEditedEvent',
      '9': 0,
      '10': 'postEdited'
    },
    {
      '1': 'post_deleted',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.channel.PostDeletedEvent',
      '9': 0,
      '10': 'postDeleted'
    },
    {
      '1': 'post_pinned',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.channel.PostPinnedEvent',
      '9': 0,
      '10': 'postPinned'
    },
    {
      '1': 'post_unpinned',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.channel.PostUnpinnedEvent',
      '9': 0,
      '10': 'postUnpinned'
    },
    {
      '1': 'channel_updated',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.channel.ChannelUpdatedEvent',
      '9': 0,
      '10': 'channelUpdated'
    },
    {
      '1': 'channel_deleted',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.channel.ChannelDeletedEvent',
      '9': 0,
      '10': 'channelDeleted'
    },
    {
      '1': 'subscribed',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.channel.ChannelSubscribedEvent',
      '9': 0,
      '10': 'subscribed'
    },
    {
      '1': 'unsubscribed',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.channel.ChannelUnsubscribedEvent',
      '9': 0,
      '10': 'unsubscribed'
    },
    {
      '1': 'pong',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.channel.ChannelPongEvent',
      '9': 0,
      '10': 'pong'
    },
    {
      '1': 'error',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.channel.ChannelErrorEvent',
      '9': 0,
      '10': 'error'
    },
  ],
  '8': [
    {'1': 'event'},
  ],
};

/// Descriptor for `ChannelServerEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List channelServerEventDescriptor = $convert.base64Decode(
    'ChJDaGFubmVsU2VydmVyRXZlbnQSMgoIbmV3X3Bvc3QYASABKAsyFS5jaGFubmVsLk5ld1Bvc3'
    'RFdmVudEgAUgduZXdQb3N0EjsKC3Bvc3RfZWRpdGVkGAIgASgLMhguY2hhbm5lbC5Qb3N0RWRp'
    'dGVkRXZlbnRIAFIKcG9zdEVkaXRlZBI+Cgxwb3N0X2RlbGV0ZWQYAyABKAsyGS5jaGFubmVsLl'
    'Bvc3REZWxldGVkRXZlbnRIAFILcG9zdERlbGV0ZWQSOwoLcG9zdF9waW5uZWQYBCABKAsyGC5j'
    'aGFubmVsLlBvc3RQaW5uZWRFdmVudEgAUgpwb3N0UGlubmVkEkEKDXBvc3RfdW5waW5uZWQYBS'
    'ABKAsyGi5jaGFubmVsLlBvc3RVbnBpbm5lZEV2ZW50SABSDHBvc3RVbnBpbm5lZBJHCg9jaGFu'
    'bmVsX3VwZGF0ZWQYBiABKAsyHC5jaGFubmVsLkNoYW5uZWxVcGRhdGVkRXZlbnRIAFIOY2hhbm'
    '5lbFVwZGF0ZWQSRwoPY2hhbm5lbF9kZWxldGVkGAcgASgLMhwuY2hhbm5lbC5DaGFubmVsRGVs'
    'ZXRlZEV2ZW50SABSDmNoYW5uZWxEZWxldGVkEkEKCnN1YnNjcmliZWQYCCABKAsyHy5jaGFubm'
    'VsLkNoYW5uZWxTdWJzY3JpYmVkRXZlbnRIAFIKc3Vic2NyaWJlZBJHCgx1bnN1YnNjcmliZWQY'
    'CSABKAsyIS5jaGFubmVsLkNoYW5uZWxVbnN1YnNjcmliZWRFdmVudEgAUgx1bnN1YnNjcmliZW'
    'QSLwoEcG9uZxgKIAEoCzIZLmNoYW5uZWwuQ2hhbm5lbFBvbmdFdmVudEgAUgRwb25nEjIKBWVy'
    'cm9yGAsgASgLMhouY2hhbm5lbC5DaGFubmVsRXJyb3JFdmVudEgAUgVlcnJvckIHCgVldmVudA'
    '==');

@$core.Deprecated('Use newPostEventDescriptor instead')
const NewPostEvent$json = {
  '1': 'NewPostEvent',
  '2': [
    {
      '1': 'post',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.channel.ChannelPost',
      '10': 'post'
    },
  ],
};

/// Descriptor for `NewPostEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List newPostEventDescriptor = $convert.base64Decode(
    'CgxOZXdQb3N0RXZlbnQSKAoEcG9zdBgBIAEoCzIULmNoYW5uZWwuQ2hhbm5lbFBvc3RSBHBvc3'
    'Q=');

@$core.Deprecated('Use postEditedEventDescriptor instead')
const PostEditedEvent$json = {
  '1': 'PostEditedEvent',
  '2': [
    {
      '1': 'post',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.channel.ChannelPost',
      '10': 'post'
    },
  ],
};

/// Descriptor for `PostEditedEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List postEditedEventDescriptor = $convert.base64Decode(
    'Cg9Qb3N0RWRpdGVkRXZlbnQSKAoEcG9zdBgBIAEoCzIULmNoYW5uZWwuQ2hhbm5lbFBvc3RSBH'
    'Bvc3Q=');

@$core.Deprecated('Use postDeletedEventDescriptor instead')
const PostDeletedEvent$json = {
  '1': 'PostDeletedEvent',
  '2': [
    {'1': 'post_id', '3': 1, '4': 1, '5': 9, '10': 'postId'},
    {'1': 'channel_id', '3': 2, '4': 1, '5': 9, '10': 'channelId'},
  ],
};

/// Descriptor for `PostDeletedEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List postDeletedEventDescriptor = $convert.base64Decode(
    'ChBQb3N0RGVsZXRlZEV2ZW50EhcKB3Bvc3RfaWQYASABKAlSBnBvc3RJZBIdCgpjaGFubmVsX2'
    'lkGAIgASgJUgljaGFubmVsSWQ=');

@$core.Deprecated('Use postPinnedEventDescriptor instead')
const PostPinnedEvent$json = {
  '1': 'PostPinnedEvent',
  '2': [
    {
      '1': 'post',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.channel.ChannelPost',
      '10': 'post'
    },
  ],
};

/// Descriptor for `PostPinnedEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List postPinnedEventDescriptor = $convert.base64Decode(
    'Cg9Qb3N0UGlubmVkRXZlbnQSKAoEcG9zdBgBIAEoCzIULmNoYW5uZWwuQ2hhbm5lbFBvc3RSBH'
    'Bvc3Q=');

@$core.Deprecated('Use postUnpinnedEventDescriptor instead')
const PostUnpinnedEvent$json = {
  '1': 'PostUnpinnedEvent',
  '2': [
    {'1': 'post_id', '3': 1, '4': 1, '5': 9, '10': 'postId'},
    {'1': 'channel_id', '3': 2, '4': 1, '5': 9, '10': 'channelId'},
  ],
};

/// Descriptor for `PostUnpinnedEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List postUnpinnedEventDescriptor = $convert.base64Decode(
    'ChFQb3N0VW5waW5uZWRFdmVudBIXCgdwb3N0X2lkGAEgASgJUgZwb3N0SWQSHQoKY2hhbm5lbF'
    '9pZBgCIAEoCVIJY2hhbm5lbElk');

@$core.Deprecated('Use channelUpdatedEventDescriptor instead')
const ChannelUpdatedEvent$json = {
  '1': 'ChannelUpdatedEvent',
  '2': [
    {
      '1': 'channel',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.channel.Channel',
      '10': 'channel'
    },
  ],
};

/// Descriptor for `ChannelUpdatedEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List channelUpdatedEventDescriptor = $convert.base64Decode(
    'ChNDaGFubmVsVXBkYXRlZEV2ZW50EioKB2NoYW5uZWwYASABKAsyEC5jaGFubmVsLkNoYW5uZW'
    'xSB2NoYW5uZWw=');

@$core.Deprecated('Use channelDeletedEventDescriptor instead')
const ChannelDeletedEvent$json = {
  '1': 'ChannelDeletedEvent',
  '2': [
    {'1': 'channel_id', '3': 1, '4': 1, '5': 9, '10': 'channelId'},
  ],
};

/// Descriptor for `ChannelDeletedEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List channelDeletedEventDescriptor = $convert.base64Decode(
    'ChNDaGFubmVsRGVsZXRlZEV2ZW50Eh0KCmNoYW5uZWxfaWQYASABKAlSCWNoYW5uZWxJZA==');

@$core.Deprecated('Use channelSubscribedEventDescriptor instead')
const ChannelSubscribedEvent$json = {
  '1': 'ChannelSubscribedEvent',
  '2': [
    {'1': 'channel_id', '3': 1, '4': 1, '5': 9, '10': 'channelId'},
  ],
};

/// Descriptor for `ChannelSubscribedEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List channelSubscribedEventDescriptor =
    $convert.base64Decode(
        'ChZDaGFubmVsU3Vic2NyaWJlZEV2ZW50Eh0KCmNoYW5uZWxfaWQYASABKAlSCWNoYW5uZWxJZA'
        '==');

@$core.Deprecated('Use channelUnsubscribedEventDescriptor instead')
const ChannelUnsubscribedEvent$json = {
  '1': 'ChannelUnsubscribedEvent',
  '2': [
    {'1': 'channel_id', '3': 1, '4': 1, '5': 9, '10': 'channelId'},
  ],
};

/// Descriptor for `ChannelUnsubscribedEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List channelUnsubscribedEventDescriptor =
    $convert.base64Decode(
        'ChhDaGFubmVsVW5zdWJzY3JpYmVkRXZlbnQSHQoKY2hhbm5lbF9pZBgBIAEoCVIJY2hhbm5lbE'
        'lk');

@$core.Deprecated('Use channelPongEventDescriptor instead')
const ChannelPongEvent$json = {
  '1': 'ChannelPongEvent',
};

/// Descriptor for `ChannelPongEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List channelPongEventDescriptor =
    $convert.base64Decode('ChBDaGFubmVsUG9uZ0V2ZW50');

@$core.Deprecated('Use channelErrorEventDescriptor instead')
const ChannelErrorEvent$json = {
  '1': 'ChannelErrorEvent',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 9, '10': 'code'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'action', '3': 3, '4': 1, '5': 9, '10': 'action'},
  ],
};

/// Descriptor for `ChannelErrorEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List channelErrorEventDescriptor = $convert.base64Decode(
    'ChFDaGFubmVsRXJyb3JFdmVudBISCgRjb2RlGAEgASgJUgRjb2RlEhgKB21lc3NhZ2UYAiABKA'
    'lSB21lc3NhZ2USFgoGYWN0aW9uGAMgASgJUgZhY3Rpb24=');
