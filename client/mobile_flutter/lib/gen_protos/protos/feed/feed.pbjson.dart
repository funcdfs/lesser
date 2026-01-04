// This is a generated file - do not edit.
//
// Generated from feed/feed.proto.

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

@$core.Deprecated('Use feedItemDescriptor instead')
const FeedItem$json = {
  '1': 'FeedItem',
  '2': [
    {
      '1': 'content',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.content.Content',
      '10': 'content'
    },
    {'1': 'is_liked', '3': 2, '4': 1, '5': 8, '10': 'isLiked'},
    {'1': 'is_bookmarked', '3': 3, '4': 1, '5': 8, '10': 'isBookmarked'},
    {'1': 'is_reposted', '3': 4, '4': 1, '5': 8, '10': 'isReposted'},
  ],
};

/// Descriptor for `FeedItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List feedItemDescriptor = $convert.base64Decode(
    'CghGZWVkSXRlbRIqCgdjb250ZW50GAEgASgLMhAuY29udGVudC5Db250ZW50Ugdjb250ZW50Eh'
    'kKCGlzX2xpa2VkGAIgASgIUgdpc0xpa2VkEiMKDWlzX2Jvb2ttYXJrZWQYAyABKAhSDGlzQm9v'
    'a21hcmtlZBIfCgtpc19yZXBvc3RlZBgEIAEoCFIKaXNSZXBvc3RlZA==');

@$core.Deprecated('Use getFollowingFeedRequestDescriptor instead')
const GetFollowingFeedRequest$json = {
  '1': 'GetFollowingFeedRequest',
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

/// Descriptor for `GetFollowingFeedRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFollowingFeedRequestDescriptor =
    $convert.base64Decode(
        'ChdHZXRGb2xsb3dpbmdGZWVkUmVxdWVzdBIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSMgoKcG'
        'FnaW5hdGlvbhgCIAEoCzISLmNvbW1vbi5QYWdpbmF0aW9uUgpwYWdpbmF0aW9u');

@$core.Deprecated('Use getFollowingFeedResponseDescriptor instead')
const GetFollowingFeedResponse$json = {
  '1': 'GetFollowingFeedResponse',
  '2': [
    {
      '1': 'items',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.feed.FeedItem',
      '10': 'items'
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

/// Descriptor for `GetFollowingFeedResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFollowingFeedResponseDescriptor = $convert.base64Decode(
    'ChhHZXRGb2xsb3dpbmdGZWVkUmVzcG9uc2USJAoFaXRlbXMYASADKAsyDi5mZWVkLkZlZWRJdG'
    'VtUgVpdGVtcxIyCgpwYWdpbmF0aW9uGAIgASgLMhIuY29tbW9uLlBhZ2luYXRpb25SCnBhZ2lu'
    'YXRpb24=');

@$core.Deprecated('Use getRecommendFeedRequestDescriptor instead')
const GetRecommendFeedRequest$json = {
  '1': 'GetRecommendFeedRequest',
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

/// Descriptor for `GetRecommendFeedRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRecommendFeedRequestDescriptor =
    $convert.base64Decode(
        'ChdHZXRSZWNvbW1lbmRGZWVkUmVxdWVzdBIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSMgoKcG'
        'FnaW5hdGlvbhgCIAEoCzISLmNvbW1vbi5QYWdpbmF0aW9uUgpwYWdpbmF0aW9u');

@$core.Deprecated('Use getRecommendFeedResponseDescriptor instead')
const GetRecommendFeedResponse$json = {
  '1': 'GetRecommendFeedResponse',
  '2': [
    {
      '1': 'items',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.feed.FeedItem',
      '10': 'items'
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

/// Descriptor for `GetRecommendFeedResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRecommendFeedResponseDescriptor = $convert.base64Decode(
    'ChhHZXRSZWNvbW1lbmRGZWVkUmVzcG9uc2USJAoFaXRlbXMYASADKAsyDi5mZWVkLkZlZWRJdG'
    'VtUgVpdGVtcxIyCgpwYWdpbmF0aW9uGAIgASgLMhIuY29tbW9uLlBhZ2luYXRpb25SCnBhZ2lu'
    'YXRpb24=');

@$core.Deprecated('Use getUserFeedRequestDescriptor instead')
const GetUserFeedRequest$json = {
  '1': 'GetUserFeedRequest',
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

/// Descriptor for `GetUserFeedRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getUserFeedRequestDescriptor = $convert.base64Decode(
    'ChJHZXRVc2VyRmVlZFJlcXVlc3QSFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklkEhsKCXZpZXdlcl'
    '9pZBgCIAEoCVIIdmlld2VySWQSMgoKcGFnaW5hdGlvbhgDIAEoCzISLmNvbW1vbi5QYWdpbmF0'
    'aW9uUgpwYWdpbmF0aW9u');

@$core.Deprecated('Use getUserFeedResponseDescriptor instead')
const GetUserFeedResponse$json = {
  '1': 'GetUserFeedResponse',
  '2': [
    {
      '1': 'items',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.feed.FeedItem',
      '10': 'items'
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

/// Descriptor for `GetUserFeedResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getUserFeedResponseDescriptor = $convert.base64Decode(
    'ChNHZXRVc2VyRmVlZFJlc3BvbnNlEiQKBWl0ZW1zGAEgAygLMg4uZmVlZC5GZWVkSXRlbVIFaX'
    'RlbXMSMgoKcGFnaW5hdGlvbhgCIAEoCzISLmNvbW1vbi5QYWdpbmF0aW9uUgpwYWdpbmF0aW9u');

@$core.Deprecated('Use commentDescriptor instead')
const Comment$json = {
  '1': 'Comment',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'author_id', '3': 2, '4': 1, '5': 9, '10': 'authorId'},
    {'1': 'post_id', '3': 3, '4': 1, '5': 9, '10': 'postId'},
    {'1': 'parent_id', '3': 4, '4': 1, '5': 9, '10': 'parentId'},
    {'1': 'content', '3': 5, '4': 1, '5': 9, '10': 'content'},
    {'1': 'is_deleted', '3': 6, '4': 1, '5': 8, '10': 'isDeleted'},
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
    {'1': 'reply_count', '3': 9, '4': 1, '5': 5, '10': 'replyCount'},
  ],
};

/// Descriptor for `Comment`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commentDescriptor = $convert.base64Decode(
    'CgdDb21tZW50Eg4KAmlkGAEgASgJUgJpZBIbCglhdXRob3JfaWQYAiABKAlSCGF1dGhvcklkEh'
    'cKB3Bvc3RfaWQYAyABKAlSBnBvc3RJZBIbCglwYXJlbnRfaWQYBCABKAlSCHBhcmVudElkEhgK'
    'B2NvbnRlbnQYBSABKAlSB2NvbnRlbnQSHQoKaXNfZGVsZXRlZBgGIAEoCFIJaXNEZWxldGVkEj'
    'AKCmNyZWF0ZWRfYXQYByABKAsyES5jb21tb24uVGltZXN0YW1wUgljcmVhdGVkQXQSMAoKdXBk'
    'YXRlZF9hdBgIIAEoCzIRLmNvbW1vbi5UaW1lc3RhbXBSCXVwZGF0ZWRBdBIfCgtyZXBseV9jb3'
    'VudBgJIAEoBVIKcmVwbHlDb3VudA==');

@$core.Deprecated('Use repostDescriptor instead')
const Repost$json = {
  '1': 'Repost',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'post_id', '3': 3, '4': 1, '5': 9, '10': 'postId'},
    {'1': 'quote', '3': 4, '4': 1, '5': 9, '10': 'quote'},
    {
      '1': 'created_at',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.common.Timestamp',
      '10': 'createdAt'
    },
  ],
};

/// Descriptor for `Repost`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List repostDescriptor = $convert.base64Decode(
    'CgZSZXBvc3QSDgoCaWQYASABKAlSAmlkEhcKB3VzZXJfaWQYAiABKAlSBnVzZXJJZBIXCgdwb3'
    'N0X2lkGAMgASgJUgZwb3N0SWQSFAoFcXVvdGUYBCABKAlSBXF1b3RlEjAKCmNyZWF0ZWRfYXQY'
    'BSABKAsyES5jb21tb24uVGltZXN0YW1wUgljcmVhdGVkQXQ=');

@$core.Deprecated('Use bookmarkDescriptor instead')
const Bookmark$json = {
  '1': 'Bookmark',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'post_id', '3': 3, '4': 1, '5': 9, '10': 'postId'},
    {
      '1': 'created_at',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.common.Timestamp',
      '10': 'createdAt'
    },
  ],
};

/// Descriptor for `Bookmark`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bookmarkDescriptor = $convert.base64Decode(
    'CghCb29rbWFyaxIOCgJpZBgBIAEoCVICaWQSFwoHdXNlcl9pZBgCIAEoCVIGdXNlcklkEhcKB3'
    'Bvc3RfaWQYAyABKAlSBnBvc3RJZBIwCgpjcmVhdGVkX2F0GAQgASgLMhEuY29tbW9uLlRpbWVz'
    'dGFtcFIJY3JlYXRlZEF0');

@$core.Deprecated('Use likeRequestDescriptor instead')
const LikeRequest$json = {
  '1': 'LikeRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'post_id', '3': 2, '4': 1, '5': 9, '10': 'postId'},
  ],
};

/// Descriptor for `LikeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List likeRequestDescriptor = $convert.base64Decode(
    'CgtMaWtlUmVxdWVzdBIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSFwoHcG9zdF9pZBgCIAEoCV'
    'IGcG9zdElk');

@$core.Deprecated('Use unlikeRequestDescriptor instead')
const UnlikeRequest$json = {
  '1': 'UnlikeRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'post_id', '3': 2, '4': 1, '5': 9, '10': 'postId'},
  ],
};

/// Descriptor for `UnlikeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unlikeRequestDescriptor = $convert.base64Decode(
    'Cg1Vbmxpa2VSZXF1ZXN0EhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBIXCgdwb3N0X2lkGAIgAS'
    'gJUgZwb3N0SWQ=');

@$core.Deprecated('Use createCommentRequestDescriptor instead')
const CreateCommentRequest$json = {
  '1': 'CreateCommentRequest',
  '2': [
    {'1': 'author_id', '3': 1, '4': 1, '5': 9, '10': 'authorId'},
    {'1': 'post_id', '3': 2, '4': 1, '5': 9, '10': 'postId'},
    {'1': 'parent_id', '3': 3, '4': 1, '5': 9, '10': 'parentId'},
    {'1': 'content', '3': 4, '4': 1, '5': 9, '10': 'content'},
  ],
};

/// Descriptor for `CreateCommentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createCommentRequestDescriptor = $convert.base64Decode(
    'ChRDcmVhdGVDb21tZW50UmVxdWVzdBIbCglhdXRob3JfaWQYASABKAlSCGF1dGhvcklkEhcKB3'
    'Bvc3RfaWQYAiABKAlSBnBvc3RJZBIbCglwYXJlbnRfaWQYAyABKAlSCHBhcmVudElkEhgKB2Nv'
    'bnRlbnQYBCABKAlSB2NvbnRlbnQ=');

@$core.Deprecated('Use deleteCommentRequestDescriptor instead')
const DeleteCommentRequest$json = {
  '1': 'DeleteCommentRequest',
  '2': [
    {'1': 'comment_id', '3': 1, '4': 1, '5': 9, '10': 'commentId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `DeleteCommentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteCommentRequestDescriptor = $convert.base64Decode(
    'ChREZWxldGVDb21tZW50UmVxdWVzdBIdCgpjb21tZW50X2lkGAEgASgJUgljb21tZW50SWQSFw'
    'oHdXNlcl9pZBgCIAEoCVIGdXNlcklk');

@$core.Deprecated('Use listCommentsRequestDescriptor instead')
const ListCommentsRequest$json = {
  '1': 'ListCommentsRequest',
  '2': [
    {'1': 'post_id', '3': 1, '4': 1, '5': 9, '10': 'postId'},
    {'1': 'parent_id', '3': 2, '4': 1, '5': 9, '10': 'parentId'},
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

/// Descriptor for `ListCommentsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listCommentsRequestDescriptor = $convert.base64Decode(
    'ChNMaXN0Q29tbWVudHNSZXF1ZXN0EhcKB3Bvc3RfaWQYASABKAlSBnBvc3RJZBIbCglwYXJlbn'
    'RfaWQYAiABKAlSCHBhcmVudElkEjIKCnBhZ2luYXRpb24YAyABKAsyEi5jb21tb24uUGFnaW5h'
    'dGlvblIKcGFnaW5hdGlvbg==');

@$core.Deprecated('Use listCommentsResponseDescriptor instead')
const ListCommentsResponse$json = {
  '1': 'ListCommentsResponse',
  '2': [
    {
      '1': 'comments',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.feed.Comment',
      '10': 'comments'
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

/// Descriptor for `ListCommentsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listCommentsResponseDescriptor = $convert.base64Decode(
    'ChRMaXN0Q29tbWVudHNSZXNwb25zZRIpCghjb21tZW50cxgBIAMoCzINLmZlZWQuQ29tbWVudF'
    'IIY29tbWVudHMSMgoKcGFnaW5hdGlvbhgCIAEoCzISLmNvbW1vbi5QYWdpbmF0aW9uUgpwYWdp'
    'bmF0aW9u');

@$core.Deprecated('Use repostRequestDescriptor instead')
const RepostRequest$json = {
  '1': 'RepostRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'post_id', '3': 2, '4': 1, '5': 9, '10': 'postId'},
    {'1': 'quote', '3': 3, '4': 1, '5': 9, '10': 'quote'},
  ],
};

/// Descriptor for `RepostRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List repostRequestDescriptor = $convert.base64Decode(
    'Cg1SZXBvc3RSZXF1ZXN0EhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBIXCgdwb3N0X2lkGAIgAS'
    'gJUgZwb3N0SWQSFAoFcXVvdGUYAyABKAlSBXF1b3Rl');

@$core.Deprecated('Use bookmarkRequestDescriptor instead')
const BookmarkRequest$json = {
  '1': 'BookmarkRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'post_id', '3': 2, '4': 1, '5': 9, '10': 'postId'},
  ],
};

/// Descriptor for `BookmarkRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bookmarkRequestDescriptor = $convert.base64Decode(
    'Cg9Cb29rbWFya1JlcXVlc3QSFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklkEhcKB3Bvc3RfaWQYAi'
    'ABKAlSBnBvc3RJZA==');

@$core.Deprecated('Use unbookmarkRequestDescriptor instead')
const UnbookmarkRequest$json = {
  '1': 'UnbookmarkRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'post_id', '3': 2, '4': 1, '5': 9, '10': 'postId'},
  ],
};

/// Descriptor for `UnbookmarkRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unbookmarkRequestDescriptor = $convert.base64Decode(
    'ChFVbmJvb2ttYXJrUmVxdWVzdBIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSFwoHcG9zdF9pZB'
    'gCIAEoCVIGcG9zdElk');

@$core.Deprecated('Use listBookmarksRequestDescriptor instead')
const ListBookmarksRequest$json = {
  '1': 'ListBookmarksRequest',
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

/// Descriptor for `ListBookmarksRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listBookmarksRequestDescriptor = $convert.base64Decode(
    'ChRMaXN0Qm9va21hcmtzUmVxdWVzdBIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSMgoKcGFnaW'
    '5hdGlvbhgCIAEoCzISLmNvbW1vbi5QYWdpbmF0aW9uUgpwYWdpbmF0aW9u');

@$core.Deprecated('Use listBookmarksResponseDescriptor instead')
const ListBookmarksResponse$json = {
  '1': 'ListBookmarksResponse',
  '2': [
    {
      '1': 'bookmarks',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.feed.Bookmark',
      '10': 'bookmarks'
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

/// Descriptor for `ListBookmarksResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listBookmarksResponseDescriptor = $convert.base64Decode(
    'ChVMaXN0Qm9va21hcmtzUmVzcG9uc2USLAoJYm9va21hcmtzGAEgAygLMg4uZmVlZC5Cb29rbW'
    'Fya1IJYm9va21hcmtzEjIKCnBhZ2luYXRpb24YAiABKAsyEi5jb21tb24uUGFnaW5hdGlvblIK'
    'cGFnaW5hdGlvbg==');
