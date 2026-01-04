// This is a generated file - do not edit.
//
// Generated from content/content.proto.

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

@$core.Deprecated('Use contentTypeDescriptor instead')
const ContentType$json = {
  '1': 'ContentType',
  '2': [
    {'1': 'CONTENT_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'STORY', '2': 1},
    {'1': 'SHORT', '2': 2},
    {'1': 'ARTICLE', '2': 3},
  ],
};

/// Descriptor for `ContentType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List contentTypeDescriptor = $convert.base64Decode(
    'CgtDb250ZW50VHlwZRIcChhDT05URU5UX1RZUEVfVU5TUEVDSUZJRUQQABIJCgVTVE9SWRABEg'
    'kKBVNIT1JUEAISCwoHQVJUSUNMRRAD');

@$core.Deprecated('Use contentStatusDescriptor instead')
const ContentStatus$json = {
  '1': 'ContentStatus',
  '2': [
    {'1': 'CONTENT_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'DRAFT', '2': 1},
    {'1': 'PUBLISHED', '2': 2},
    {'1': 'ARCHIVED', '2': 3},
    {'1': 'DELETED', '2': 4},
  ],
};

/// Descriptor for `ContentStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List contentStatusDescriptor = $convert.base64Decode(
    'Cg1Db250ZW50U3RhdHVzEh4KGkNPTlRFTlRfU1RBVFVTX1VOU1BFQ0lGSUVEEAASCQoFRFJBRl'
    'QQARINCglQVUJMSVNIRUQQAhIMCghBUkNISVZFRBADEgsKB0RFTEVURUQQBA==');

@$core.Deprecated('Use mediaTypeDescriptor instead')
const MediaType$json = {
  '1': 'MediaType',
  '2': [
    {'1': 'MEDIA_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'IMAGE', '2': 1},
    {'1': 'VIDEO', '2': 2},
    {'1': 'AUDIO', '2': 3},
    {'1': 'GIF', '2': 4},
  ],
};

/// Descriptor for `MediaType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List mediaTypeDescriptor = $convert.base64Decode(
    'CglNZWRpYVR5cGUSGgoWTUVESUFfVFlQRV9VTlNQRUNJRklFRBAAEgkKBUlNQUdFEAESCQoFVk'
    'lERU8QAhIJCgVBVURJTxADEgcKA0dJRhAE');

@$core.Deprecated('Use mediaDescriptor instead')
const Media$json = {
  '1': 'Media',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.content.MediaType',
      '10': 'type'
    },
    {'1': 'url', '3': 3, '4': 1, '5': 9, '10': 'url'},
    {'1': 'thumbnail_url', '3': 4, '4': 1, '5': 9, '10': 'thumbnailUrl'},
    {'1': 'width', '3': 5, '4': 1, '5': 5, '10': 'width'},
    {'1': 'height', '3': 6, '4': 1, '5': 5, '10': 'height'},
    {'1': 'duration', '3': 7, '4': 1, '5': 5, '10': 'duration'},
    {'1': 'alt_text', '3': 8, '4': 1, '5': 9, '10': 'altText'},
  ],
};

/// Descriptor for `Media`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mediaDescriptor = $convert.base64Decode(
    'CgVNZWRpYRIOCgJpZBgBIAEoCVICaWQSJgoEdHlwZRgCIAEoDjISLmNvbnRlbnQuTWVkaWFUeX'
    'BlUgR0eXBlEhAKA3VybBgDIAEoCVIDdXJsEiMKDXRodW1ibmFpbF91cmwYBCABKAlSDHRodW1i'
    'bmFpbFVybBIUCgV3aWR0aBgFIAEoBVIFd2lkdGgSFgoGaGVpZ2h0GAYgASgFUgZoZWlnaHQSGg'
    'oIZHVyYXRpb24YByABKAVSCGR1cmF0aW9uEhkKCGFsdF90ZXh0GAggASgJUgdhbHRUZXh0');

@$core.Deprecated('Use contentDescriptor instead')
const Content$json = {
  '1': 'Content',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'author_id', '3': 2, '4': 1, '5': 9, '10': 'authorId'},
    {
      '1': 'type',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.content.ContentType',
      '10': 'type'
    },
    {
      '1': 'status',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.content.ContentStatus',
      '10': 'status'
    },
    {'1': 'title', '3': 5, '4': 1, '5': 9, '10': 'title'},
    {'1': 'text', '3': 6, '4': 1, '5': 9, '10': 'text'},
    {'1': 'summary', '3': 7, '4': 1, '5': 9, '10': 'summary'},
    {
      '1': 'media',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.content.Media',
      '10': 'media'
    },
    {'1': 'tags', '3': 9, '4': 3, '5': 9, '10': 'tags'},
    {'1': 'reply_to_id', '3': 10, '4': 1, '5': 9, '10': 'replyToId'},
    {'1': 'quote_id', '3': 11, '4': 1, '5': 9, '10': 'quoteId'},
    {'1': 'like_count', '3': 20, '4': 1, '5': 5, '10': 'likeCount'},
    {'1': 'comment_count', '3': 21, '4': 1, '5': 5, '10': 'commentCount'},
    {'1': 'repost_count', '3': 22, '4': 1, '5': 5, '10': 'repostCount'},
    {'1': 'bookmark_count', '3': 23, '4': 1, '5': 5, '10': 'bookmarkCount'},
    {'1': 'view_count', '3': 24, '4': 1, '5': 5, '10': 'viewCount'},
    {
      '1': 'created_at',
      '3': 30,
      '4': 1,
      '5': 11,
      '6': '.common.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 31,
      '4': 1,
      '5': 11,
      '6': '.common.Timestamp',
      '10': 'updatedAt'
    },
    {
      '1': 'published_at',
      '3': 32,
      '4': 1,
      '5': 11,
      '6': '.common.Timestamp',
      '10': 'publishedAt'
    },
    {
      '1': 'expires_at',
      '3': 33,
      '4': 1,
      '5': 11,
      '6': '.common.Timestamp',
      '10': 'expiresAt'
    },
    {'1': 'is_pinned', '3': 40, '4': 1, '5': 8, '10': 'isPinned'},
    {
      '1': 'comments_disabled',
      '3': 41,
      '4': 1,
      '5': 8,
      '10': 'commentsDisabled'
    },
    {'1': 'language', '3': 42, '4': 1, '5': 9, '10': 'language'},
  ],
};

/// Descriptor for `Content`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contentDescriptor = $convert.base64Decode(
    'CgdDb250ZW50Eg4KAmlkGAEgASgJUgJpZBIbCglhdXRob3JfaWQYAiABKAlSCGF1dGhvcklkEi'
    'gKBHR5cGUYAyABKA4yFC5jb250ZW50LkNvbnRlbnRUeXBlUgR0eXBlEi4KBnN0YXR1cxgEIAEo'
    'DjIWLmNvbnRlbnQuQ29udGVudFN0YXR1c1IGc3RhdHVzEhQKBXRpdGxlGAUgASgJUgV0aXRsZR'
    'ISCgR0ZXh0GAYgASgJUgR0ZXh0EhgKB3N1bW1hcnkYByABKAlSB3N1bW1hcnkSJAoFbWVkaWEY'
    'CCADKAsyDi5jb250ZW50Lk1lZGlhUgVtZWRpYRISCgR0YWdzGAkgAygJUgR0YWdzEh4KC3JlcG'
    'x5X3RvX2lkGAogASgJUglyZXBseVRvSWQSGQoIcXVvdGVfaWQYCyABKAlSB3F1b3RlSWQSHQoK'
    'bGlrZV9jb3VudBgUIAEoBVIJbGlrZUNvdW50EiMKDWNvbW1lbnRfY291bnQYFSABKAVSDGNvbW'
    '1lbnRDb3VudBIhCgxyZXBvc3RfY291bnQYFiABKAVSC3JlcG9zdENvdW50EiUKDmJvb2ttYXJr'
    'X2NvdW50GBcgASgFUg1ib29rbWFya0NvdW50Eh0KCnZpZXdfY291bnQYGCABKAVSCXZpZXdDb3'
    'VudBIwCgpjcmVhdGVkX2F0GB4gASgLMhEuY29tbW9uLlRpbWVzdGFtcFIJY3JlYXRlZEF0EjAK'
    'CnVwZGF0ZWRfYXQYHyABKAsyES5jb21tb24uVGltZXN0YW1wUgl1cGRhdGVkQXQSNAoMcHVibG'
    'lzaGVkX2F0GCAgASgLMhEuY29tbW9uLlRpbWVzdGFtcFILcHVibGlzaGVkQXQSMAoKZXhwaXJl'
    'c19hdBghIAEoCzIRLmNvbW1vbi5UaW1lc3RhbXBSCWV4cGlyZXNBdBIbCglpc19waW5uZWQYKC'
    'ABKAhSCGlzUGlubmVkEisKEWNvbW1lbnRzX2Rpc2FibGVkGCkgASgIUhBjb21tZW50c0Rpc2Fi'
    'bGVkEhoKCGxhbmd1YWdlGCogASgJUghsYW5ndWFnZQ==');

@$core.Deprecated('Use createContentRequestDescriptor instead')
const CreateContentRequest$json = {
  '1': 'CreateContentRequest',
  '2': [
    {'1': 'author_id', '3': 1, '4': 1, '5': 9, '10': 'authorId'},
    {
      '1': 'type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.content.ContentType',
      '10': 'type'
    },
    {'1': 'title', '3': 3, '4': 1, '5': 9, '10': 'title'},
    {'1': 'text', '3': 4, '4': 1, '5': 9, '10': 'text'},
    {'1': 'summary', '3': 5, '4': 1, '5': 9, '10': 'summary'},
    {
      '1': 'media',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.content.Media',
      '10': 'media'
    },
    {'1': 'tags', '3': 7, '4': 3, '5': 9, '10': 'tags'},
    {'1': 'reply_to_id', '3': 8, '4': 1, '5': 9, '10': 'replyToId'},
    {'1': 'quote_id', '3': 9, '4': 1, '5': 9, '10': 'quoteId'},
    {'1': 'is_draft', '3': 10, '4': 1, '5': 8, '10': 'isDraft'},
    {
      '1': 'comments_disabled',
      '3': 11,
      '4': 1,
      '5': 8,
      '10': 'commentsDisabled'
    },
  ],
};

/// Descriptor for `CreateContentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createContentRequestDescriptor = $convert.base64Decode(
    'ChRDcmVhdGVDb250ZW50UmVxdWVzdBIbCglhdXRob3JfaWQYASABKAlSCGF1dGhvcklkEigKBH'
    'R5cGUYAiABKA4yFC5jb250ZW50LkNvbnRlbnRUeXBlUgR0eXBlEhQKBXRpdGxlGAMgASgJUgV0'
    'aXRsZRISCgR0ZXh0GAQgASgJUgR0ZXh0EhgKB3N1bW1hcnkYBSABKAlSB3N1bW1hcnkSJAoFbW'
    'VkaWEYBiADKAsyDi5jb250ZW50Lk1lZGlhUgVtZWRpYRISCgR0YWdzGAcgAygJUgR0YWdzEh4K'
    'C3JlcGx5X3RvX2lkGAggASgJUglyZXBseVRvSWQSGQoIcXVvdGVfaWQYCSABKAlSB3F1b3RlSW'
    'QSGQoIaXNfZHJhZnQYCiABKAhSB2lzRHJhZnQSKwoRY29tbWVudHNfZGlzYWJsZWQYCyABKAhS'
    'EGNvbW1lbnRzRGlzYWJsZWQ=');

@$core.Deprecated('Use createContentResponseDescriptor instead')
const CreateContentResponse$json = {
  '1': 'CreateContentResponse',
  '2': [
    {
      '1': 'content',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.content.Content',
      '10': 'content'
    },
  ],
};

/// Descriptor for `CreateContentResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createContentResponseDescriptor = $convert.base64Decode(
    'ChVDcmVhdGVDb250ZW50UmVzcG9uc2USKgoHY29udGVudBgBIAEoCzIQLmNvbnRlbnQuQ29udG'
    'VudFIHY29udGVudA==');

@$core.Deprecated('Use getContentRequestDescriptor instead')
const GetContentRequest$json = {
  '1': 'GetContentRequest',
  '2': [
    {'1': 'content_id', '3': 1, '4': 1, '5': 9, '10': 'contentId'},
    {'1': 'viewer_id', '3': 2, '4': 1, '5': 9, '10': 'viewerId'},
  ],
};

/// Descriptor for `GetContentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getContentRequestDescriptor = $convert.base64Decode(
    'ChFHZXRDb250ZW50UmVxdWVzdBIdCgpjb250ZW50X2lkGAEgASgJUgljb250ZW50SWQSGwoJdm'
    'lld2VyX2lkGAIgASgJUgh2aWV3ZXJJZA==');

@$core.Deprecated('Use getContentResponseDescriptor instead')
const GetContentResponse$json = {
  '1': 'GetContentResponse',
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

/// Descriptor for `GetContentResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getContentResponseDescriptor = $convert.base64Decode(
    'ChJHZXRDb250ZW50UmVzcG9uc2USKgoHY29udGVudBgBIAEoCzIQLmNvbnRlbnQuQ29udGVudF'
    'IHY29udGVudBIZCghpc19saWtlZBgCIAEoCFIHaXNMaWtlZBIjCg1pc19ib29rbWFya2VkGAMg'
    'ASgIUgxpc0Jvb2ttYXJrZWQSHwoLaXNfcmVwb3N0ZWQYBCABKAhSCmlzUmVwb3N0ZWQ=');

@$core.Deprecated('Use updateContentRequestDescriptor instead')
const UpdateContentRequest$json = {
  '1': 'UpdateContentRequest',
  '2': [
    {'1': 'content_id', '3': 1, '4': 1, '5': 9, '10': 'contentId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'title', '3': 3, '4': 1, '5': 9, '10': 'title'},
    {'1': 'text', '3': 4, '4': 1, '5': 9, '10': 'text'},
    {'1': 'summary', '3': 5, '4': 1, '5': 9, '10': 'summary'},
    {
      '1': 'media',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.content.Media',
      '10': 'media'
    },
    {'1': 'tags', '3': 7, '4': 3, '5': 9, '10': 'tags'},
    {
      '1': 'comments_disabled',
      '3': 8,
      '4': 1,
      '5': 8,
      '10': 'commentsDisabled'
    },
  ],
};

/// Descriptor for `UpdateContentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateContentRequestDescriptor = $convert.base64Decode(
    'ChRVcGRhdGVDb250ZW50UmVxdWVzdBIdCgpjb250ZW50X2lkGAEgASgJUgljb250ZW50SWQSFw'
    'oHdXNlcl9pZBgCIAEoCVIGdXNlcklkEhQKBXRpdGxlGAMgASgJUgV0aXRsZRISCgR0ZXh0GAQg'
    'ASgJUgR0ZXh0EhgKB3N1bW1hcnkYBSABKAlSB3N1bW1hcnkSJAoFbWVkaWEYBiADKAsyDi5jb2'
    '50ZW50Lk1lZGlhUgVtZWRpYRISCgR0YWdzGAcgAygJUgR0YWdzEisKEWNvbW1lbnRzX2Rpc2Fi'
    'bGVkGAggASgIUhBjb21tZW50c0Rpc2FibGVk');

@$core.Deprecated('Use updateContentResponseDescriptor instead')
const UpdateContentResponse$json = {
  '1': 'UpdateContentResponse',
  '2': [
    {
      '1': 'content',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.content.Content',
      '10': 'content'
    },
  ],
};

/// Descriptor for `UpdateContentResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateContentResponseDescriptor = $convert.base64Decode(
    'ChVVcGRhdGVDb250ZW50UmVzcG9uc2USKgoHY29udGVudBgBIAEoCzIQLmNvbnRlbnQuQ29udG'
    'VudFIHY29udGVudA==');

@$core.Deprecated('Use deleteContentRequestDescriptor instead')
const DeleteContentRequest$json = {
  '1': 'DeleteContentRequest',
  '2': [
    {'1': 'content_id', '3': 1, '4': 1, '5': 9, '10': 'contentId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `DeleteContentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteContentRequestDescriptor = $convert.base64Decode(
    'ChREZWxldGVDb250ZW50UmVxdWVzdBIdCgpjb250ZW50X2lkGAEgASgJUgljb250ZW50SWQSFw'
    'oHdXNlcl9pZBgCIAEoCVIGdXNlcklk');

@$core.Deprecated('Use deleteContentResponseDescriptor instead')
const DeleteContentResponse$json = {
  '1': 'DeleteContentResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
  ],
};

/// Descriptor for `DeleteContentResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteContentResponseDescriptor =
    $convert.base64Decode(
        'ChVEZWxldGVDb250ZW50UmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2Vzcw==');

@$core.Deprecated('Use publishDraftRequestDescriptor instead')
const PublishDraftRequest$json = {
  '1': 'PublishDraftRequest',
  '2': [
    {'1': 'content_id', '3': 1, '4': 1, '5': 9, '10': 'contentId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `PublishDraftRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List publishDraftRequestDescriptor = $convert.base64Decode(
    'ChNQdWJsaXNoRHJhZnRSZXF1ZXN0Eh0KCmNvbnRlbnRfaWQYASABKAlSCWNvbnRlbnRJZBIXCg'
    'd1c2VyX2lkGAIgASgJUgZ1c2VySWQ=');

@$core.Deprecated('Use publishDraftResponseDescriptor instead')
const PublishDraftResponse$json = {
  '1': 'PublishDraftResponse',
  '2': [
    {
      '1': 'content',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.content.Content',
      '10': 'content'
    },
  ],
};

/// Descriptor for `PublishDraftResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List publishDraftResponseDescriptor = $convert.base64Decode(
    'ChRQdWJsaXNoRHJhZnRSZXNwb25zZRIqCgdjb250ZW50GAEgASgLMhAuY29udGVudC5Db250ZW'
    '50Ugdjb250ZW50');

@$core.Deprecated('Use listContentsRequestDescriptor instead')
const ListContentsRequest$json = {
  '1': 'ListContentsRequest',
  '2': [
    {'1': 'author_id', '3': 1, '4': 1, '5': 9, '10': 'authorId'},
    {
      '1': 'type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.content.ContentType',
      '10': 'type'
    },
    {
      '1': 'status',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.content.ContentStatus',
      '10': 'status'
    },
    {'1': 'tags', '3': 4, '4': 3, '5': 9, '10': 'tags'},
    {
      '1': 'pagination',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.common.Pagination',
      '10': 'pagination'
    },
    {'1': 'order_by', '3': 11, '4': 1, '5': 9, '10': 'orderBy'},
    {'1': 'descending', '3': 12, '4': 1, '5': 8, '10': 'descending'},
  ],
};

/// Descriptor for `ListContentsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listContentsRequestDescriptor = $convert.base64Decode(
    'ChNMaXN0Q29udGVudHNSZXF1ZXN0EhsKCWF1dGhvcl9pZBgBIAEoCVIIYXV0aG9ySWQSKAoEdH'
    'lwZRgCIAEoDjIULmNvbnRlbnQuQ29udGVudFR5cGVSBHR5cGUSLgoGc3RhdHVzGAMgASgOMhYu'
    'Y29udGVudC5Db250ZW50U3RhdHVzUgZzdGF0dXMSEgoEdGFncxgEIAMoCVIEdGFncxIyCgpwYW'
    'dpbmF0aW9uGAogASgLMhIuY29tbW9uLlBhZ2luYXRpb25SCnBhZ2luYXRpb24SGQoIb3JkZXJf'
    'YnkYCyABKAlSB29yZGVyQnkSHgoKZGVzY2VuZGluZxgMIAEoCFIKZGVzY2VuZGluZw==');

@$core.Deprecated('Use listContentsResponseDescriptor instead')
const ListContentsResponse$json = {
  '1': 'ListContentsResponse',
  '2': [
    {
      '1': 'contents',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.content.Content',
      '10': 'contents'
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

/// Descriptor for `ListContentsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listContentsResponseDescriptor = $convert.base64Decode(
    'ChRMaXN0Q29udGVudHNSZXNwb25zZRIsCghjb250ZW50cxgBIAMoCzIQLmNvbnRlbnQuQ29udG'
    'VudFIIY29udGVudHMSMgoKcGFnaW5hdGlvbhgCIAEoCzISLmNvbW1vbi5QYWdpbmF0aW9uUgpw'
    'YWdpbmF0aW9u');

@$core.Deprecated('Use getUserDraftsRequestDescriptor instead')
const GetUserDraftsRequest$json = {
  '1': 'GetUserDraftsRequest',
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

/// Descriptor for `GetUserDraftsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getUserDraftsRequestDescriptor = $convert.base64Decode(
    'ChRHZXRVc2VyRHJhZnRzUmVxdWVzdBIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSMgoKcGFnaW'
    '5hdGlvbhgCIAEoCzISLmNvbW1vbi5QYWdpbmF0aW9uUgpwYWdpbmF0aW9u');

@$core.Deprecated('Use getUserDraftsResponseDescriptor instead')
const GetUserDraftsResponse$json = {
  '1': 'GetUserDraftsResponse',
  '2': [
    {
      '1': 'drafts',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.content.Content',
      '10': 'drafts'
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

/// Descriptor for `GetUserDraftsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getUserDraftsResponseDescriptor = $convert.base64Decode(
    'ChVHZXRVc2VyRHJhZnRzUmVzcG9uc2USKAoGZHJhZnRzGAEgAygLMhAuY29udGVudC5Db250ZW'
    '50UgZkcmFmdHMSMgoKcGFnaW5hdGlvbhgCIAEoCzISLmNvbW1vbi5QYWdpbmF0aW9uUgpwYWdp'
    'bmF0aW9u');

@$core.Deprecated('Use getRepliesRequestDescriptor instead')
const GetRepliesRequest$json = {
  '1': 'GetRepliesRequest',
  '2': [
    {'1': 'content_id', '3': 1, '4': 1, '5': 9, '10': 'contentId'},
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

/// Descriptor for `GetRepliesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRepliesRequestDescriptor = $convert.base64Decode(
    'ChFHZXRSZXBsaWVzUmVxdWVzdBIdCgpjb250ZW50X2lkGAEgASgJUgljb250ZW50SWQSMgoKcG'
    'FnaW5hdGlvbhgCIAEoCzISLmNvbW1vbi5QYWdpbmF0aW9uUgpwYWdpbmF0aW9u');

@$core.Deprecated('Use getRepliesResponseDescriptor instead')
const GetRepliesResponse$json = {
  '1': 'GetRepliesResponse',
  '2': [
    {
      '1': 'replies',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.content.Content',
      '10': 'replies'
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

/// Descriptor for `GetRepliesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRepliesResponseDescriptor = $convert.base64Decode(
    'ChJHZXRSZXBsaWVzUmVzcG9uc2USKgoHcmVwbGllcxgBIAMoCzIQLmNvbnRlbnQuQ29udGVudF'
    'IHcmVwbGllcxIyCgpwYWdpbmF0aW9uGAIgASgLMhIuY29tbW9uLlBhZ2luYXRpb25SCnBhZ2lu'
    'YXRpb24=');

@$core.Deprecated('Use getUserStoriesRequestDescriptor instead')
const GetUserStoriesRequest$json = {
  '1': 'GetUserStoriesRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'viewer_id', '3': 2, '4': 1, '5': 9, '10': 'viewerId'},
  ],
};

/// Descriptor for `GetUserStoriesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getUserStoriesRequestDescriptor = $convert.base64Decode(
    'ChVHZXRVc2VyU3Rvcmllc1JlcXVlc3QSFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklkEhsKCXZpZX'
    'dlcl9pZBgCIAEoCVIIdmlld2VySWQ=');

@$core.Deprecated('Use getUserStoriesResponseDescriptor instead')
const GetUserStoriesResponse$json = {
  '1': 'GetUserStoriesResponse',
  '2': [
    {
      '1': 'stories',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.content.Content',
      '10': 'stories'
    },
    {'1': 'has_unseen', '3': 2, '4': 1, '5': 8, '10': 'hasUnseen'},
  ],
};

/// Descriptor for `GetUserStoriesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getUserStoriesResponseDescriptor =
    $convert.base64Decode(
        'ChZHZXRVc2VyU3Rvcmllc1Jlc3BvbnNlEioKB3N0b3JpZXMYASADKAsyEC5jb250ZW50LkNvbn'
        'RlbnRSB3N0b3JpZXMSHQoKaGFzX3Vuc2VlbhgCIAEoCFIJaGFzVW5zZWVu');

@$core.Deprecated('Use batchGetContentsRequestDescriptor instead')
const BatchGetContentsRequest$json = {
  '1': 'BatchGetContentsRequest',
  '2': [
    {'1': 'content_ids', '3': 1, '4': 3, '5': 9, '10': 'contentIds'},
    {'1': 'viewer_id', '3': 2, '4': 1, '5': 9, '10': 'viewerId'},
  ],
};

/// Descriptor for `BatchGetContentsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List batchGetContentsRequestDescriptor =
    $convert.base64Decode(
        'ChdCYXRjaEdldENvbnRlbnRzUmVxdWVzdBIfCgtjb250ZW50X2lkcxgBIAMoCVIKY29udGVudE'
        'lkcxIbCgl2aWV3ZXJfaWQYAiABKAlSCHZpZXdlcklk');

@$core.Deprecated('Use batchGetContentsResponseDescriptor instead')
const BatchGetContentsResponse$json = {
  '1': 'BatchGetContentsResponse',
  '2': [
    {
      '1': 'contents',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.content.Content',
      '10': 'contents'
    },
  ],
};

/// Descriptor for `BatchGetContentsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List batchGetContentsResponseDescriptor =
    $convert.base64Decode(
        'ChhCYXRjaEdldENvbnRlbnRzUmVzcG9uc2USLAoIY29udGVudHMYASADKAsyEC5jb250ZW50Lk'
        'NvbnRlbnRSCGNvbnRlbnRz');

@$core.Deprecated('Use pinContentRequestDescriptor instead')
const PinContentRequest$json = {
  '1': 'PinContentRequest',
  '2': [
    {'1': 'content_id', '3': 1, '4': 1, '5': 9, '10': 'contentId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'pin', '3': 3, '4': 1, '5': 8, '10': 'pin'},
  ],
};

/// Descriptor for `PinContentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pinContentRequestDescriptor = $convert.base64Decode(
    'ChFQaW5Db250ZW50UmVxdWVzdBIdCgpjb250ZW50X2lkGAEgASgJUgljb250ZW50SWQSFwoHdX'
    'Nlcl9pZBgCIAEoCVIGdXNlcklkEhAKA3BpbhgDIAEoCFIDcGlu');

@$core.Deprecated('Use pinContentResponseDescriptor instead')
const PinContentResponse$json = {
  '1': 'PinContentResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
  ],
};

/// Descriptor for `PinContentResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pinContentResponseDescriptor =
    $convert.base64Decode(
        'ChJQaW5Db250ZW50UmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2Vzcw==');
