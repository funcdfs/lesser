// This is a generated file - do not edit.
//
// Generated from chat/chat.proto.

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

@$core.Deprecated('Use conversationTypeDescriptor instead')
const ConversationType$json = {
  '1': 'ConversationType',
  '2': [
    {'1': 'PRIVATE', '2': 0},
    {'1': 'GROUP', '2': 1},
  ],
};

/// Descriptor for `ConversationType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List conversationTypeDescriptor = $convert
    .base64Decode('ChBDb252ZXJzYXRpb25UeXBlEgsKB1BSSVZBVEUQABIJCgVHUk9VUBAB');

@$core.Deprecated('Use conversationDescriptor instead')
const Conversation$json = {
  '1': 'Conversation',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.chat.ConversationType',
      '10': 'type'
    },
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'member_ids', '3': 4, '4': 3, '5': 9, '10': 'memberIds'},
    {'1': 'creator_id', '3': 5, '4': 1, '5': 9, '10': 'creatorId'},
    {
      '1': 'created_at',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.common.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'last_message',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.chat.Message',
      '10': 'lastMessage'
    },
    {'1': 'unread_count', '3': 8, '4': 1, '5': 3, '10': 'unreadCount'},
  ],
};

/// Descriptor for `Conversation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationDescriptor = $convert.base64Decode(
    'CgxDb252ZXJzYXRpb24SDgoCaWQYASABKAlSAmlkEioKBHR5cGUYAiABKA4yFi5jaGF0LkNvbn'
    'ZlcnNhdGlvblR5cGVSBHR5cGUSEgoEbmFtZRgDIAEoCVIEbmFtZRIdCgptZW1iZXJfaWRzGAQg'
    'AygJUgltZW1iZXJJZHMSHQoKY3JlYXRvcl9pZBgFIAEoCVIJY3JlYXRvcklkEjAKCmNyZWF0ZW'
    'RfYXQYBiABKAsyES5jb21tb24uVGltZXN0YW1wUgljcmVhdGVkQXQSMAoMbGFzdF9tZXNzYWdl'
    'GAcgASgLMg0uY2hhdC5NZXNzYWdlUgtsYXN0TWVzc2FnZRIhCgx1bnJlYWRfY291bnQYCCABKA'
    'NSC3VucmVhZENvdW50');

@$core.Deprecated('Use messageDescriptor instead')
const Message$json = {
  '1': 'Message',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'conversation_id', '3': 2, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'sender_id', '3': 3, '4': 1, '5': 9, '10': 'senderId'},
    {'1': 'content', '3': 4, '4': 1, '5': 9, '10': 'content'},
    {'1': 'message_type', '3': 5, '4': 1, '5': 9, '10': 'messageType'},
    {
      '1': 'created_at',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.common.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'read_at',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.common.Timestamp',
      '10': 'readAt'
    },
  ],
};

/// Descriptor for `Message`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageDescriptor = $convert.base64Decode(
    'CgdNZXNzYWdlEg4KAmlkGAEgASgJUgJpZBInCg9jb252ZXJzYXRpb25faWQYAiABKAlSDmNvbn'
    'ZlcnNhdGlvbklkEhsKCXNlbmRlcl9pZBgDIAEoCVIIc2VuZGVySWQSGAoHY29udGVudBgEIAEo'
    'CVIHY29udGVudBIhCgxtZXNzYWdlX3R5cGUYBSABKAlSC21lc3NhZ2VUeXBlEjAKCmNyZWF0ZW'
    'RfYXQYBiABKAsyES5jb21tb24uVGltZXN0YW1wUgljcmVhdGVkQXQSKgoHcmVhZF9hdBgHIAEo'
    'CzIRLmNvbW1vbi5UaW1lc3RhbXBSBnJlYWRBdA==');

@$core.Deprecated('Use readReceiptDescriptor instead')
const ReadReceipt$json = {
  '1': 'ReadReceipt',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'conversation_id', '3': 2, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'reader_id', '3': 3, '4': 1, '5': 9, '10': 'readerId'},
    {
      '1': 'read_at',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.common.Timestamp',
      '10': 'readAt'
    },
  ],
};

/// Descriptor for `ReadReceipt`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List readReceiptDescriptor = $convert.base64Decode(
    'CgtSZWFkUmVjZWlwdBIdCgptZXNzYWdlX2lkGAEgASgJUgltZXNzYWdlSWQSJwoPY29udmVyc2'
    'F0aW9uX2lkGAIgASgJUg5jb252ZXJzYXRpb25JZBIbCglyZWFkZXJfaWQYAyABKAlSCHJlYWRl'
    'cklkEioKB3JlYWRfYXQYBCABKAsyES5jb21tb24uVGltZXN0YW1wUgZyZWFkQXQ=');

@$core.Deprecated('Use batchReadReceiptDescriptor instead')
const BatchReadReceipt$json = {
  '1': 'BatchReadReceipt',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'reader_id', '3': 2, '4': 1, '5': 9, '10': 'readerId'},
    {'1': 'message_ids', '3': 3, '4': 3, '5': 9, '10': 'messageIds'},
    {
      '1': 'read_at',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.common.Timestamp',
      '10': 'readAt'
    },
  ],
};

/// Descriptor for `BatchReadReceipt`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List batchReadReceiptDescriptor = $convert.base64Decode(
    'ChBCYXRjaFJlYWRSZWNlaXB0EicKD2NvbnZlcnNhdGlvbl9pZBgBIAEoCVIOY29udmVyc2F0aW'
    '9uSWQSGwoJcmVhZGVyX2lkGAIgASgJUghyZWFkZXJJZBIfCgttZXNzYWdlX2lkcxgDIAMoCVIK'
    'bWVzc2FnZUlkcxIqCgdyZWFkX2F0GAQgASgLMhEuY29tbW9uLlRpbWVzdGFtcFIGcmVhZEF0');

@$core.Deprecated('Use getConversationsRequestDescriptor instead')
const GetConversationsRequest$json = {
  '1': 'GetConversationsRequest',
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

/// Descriptor for `GetConversationsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getConversationsRequestDescriptor =
    $convert.base64Decode(
        'ChdHZXRDb252ZXJzYXRpb25zUmVxdWVzdBIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSMgoKcG'
        'FnaW5hdGlvbhgCIAEoCzISLmNvbW1vbi5QYWdpbmF0aW9uUgpwYWdpbmF0aW9u');

@$core.Deprecated('Use conversationsResponseDescriptor instead')
const ConversationsResponse$json = {
  '1': 'ConversationsResponse',
  '2': [
    {
      '1': 'conversations',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.chat.Conversation',
      '10': 'conversations'
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

/// Descriptor for `ConversationsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationsResponseDescriptor = $convert.base64Decode(
    'ChVDb252ZXJzYXRpb25zUmVzcG9uc2USOAoNY29udmVyc2F0aW9ucxgBIAMoCzISLmNoYXQuQ2'
    '9udmVyc2F0aW9uUg1jb252ZXJzYXRpb25zEjIKCnBhZ2luYXRpb24YAiABKAsyEi5jb21tb24u'
    'UGFnaW5hdGlvblIKcGFnaW5hdGlvbg==');

@$core.Deprecated('Use getConversationRequestDescriptor instead')
const GetConversationRequest$json = {
  '1': 'GetConversationRequest',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
  ],
};

/// Descriptor for `GetConversationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getConversationRequestDescriptor =
    $convert.base64Decode(
        'ChZHZXRDb252ZXJzYXRpb25SZXF1ZXN0EicKD2NvbnZlcnNhdGlvbl9pZBgBIAEoCVIOY29udm'
        'Vyc2F0aW9uSWQ=');

@$core.Deprecated('Use createConversationRequestDescriptor instead')
const CreateConversationRequest$json = {
  '1': 'CreateConversationRequest',
  '2': [
    {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.chat.ConversationType',
      '10': 'type'
    },
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'member_ids', '3': 3, '4': 3, '5': 9, '10': 'memberIds'},
    {'1': 'creator_id', '3': 4, '4': 1, '5': 9, '10': 'creatorId'},
  ],
};

/// Descriptor for `CreateConversationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createConversationRequestDescriptor = $convert.base64Decode(
    'ChlDcmVhdGVDb252ZXJzYXRpb25SZXF1ZXN0EioKBHR5cGUYASABKA4yFi5jaGF0LkNvbnZlcn'
    'NhdGlvblR5cGVSBHR5cGUSEgoEbmFtZRgCIAEoCVIEbmFtZRIdCgptZW1iZXJfaWRzGAMgAygJ'
    'UgltZW1iZXJJZHMSHQoKY3JlYXRvcl9pZBgEIAEoCVIJY3JlYXRvcklk');

@$core.Deprecated('Use getMessagesRequestDescriptor instead')
const GetMessagesRequest$json = {
  '1': 'GetMessagesRequest',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
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

/// Descriptor for `GetMessagesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMessagesRequestDescriptor = $convert.base64Decode(
    'ChJHZXRNZXNzYWdlc1JlcXVlc3QSJwoPY29udmVyc2F0aW9uX2lkGAEgASgJUg5jb252ZXJzYX'
    'Rpb25JZBIyCgpwYWdpbmF0aW9uGAIgASgLMhIuY29tbW9uLlBhZ2luYXRpb25SCnBhZ2luYXRp'
    'b24=');

@$core.Deprecated('Use messagesResponseDescriptor instead')
const MessagesResponse$json = {
  '1': 'MessagesResponse',
  '2': [
    {
      '1': 'messages',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.chat.Message',
      '10': 'messages'
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

/// Descriptor for `MessagesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messagesResponseDescriptor = $convert.base64Decode(
    'ChBNZXNzYWdlc1Jlc3BvbnNlEikKCG1lc3NhZ2VzGAEgAygLMg0uY2hhdC5NZXNzYWdlUghtZX'
    'NzYWdlcxIyCgpwYWdpbmF0aW9uGAIgASgLMhIuY29tbW9uLlBhZ2luYXRpb25SCnBhZ2luYXRp'
    'b24=');

@$core.Deprecated('Use sendMessageRequestDescriptor instead')
const SendMessageRequest$json = {
  '1': 'SendMessageRequest',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'sender_id', '3': 2, '4': 1, '5': 9, '10': 'senderId'},
    {'1': 'content', '3': 3, '4': 1, '5': 9, '10': 'content'},
    {'1': 'message_type', '3': 4, '4': 1, '5': 9, '10': 'messageType'},
  ],
};

/// Descriptor for `SendMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendMessageRequestDescriptor = $convert.base64Decode(
    'ChJTZW5kTWVzc2FnZVJlcXVlc3QSJwoPY29udmVyc2F0aW9uX2lkGAEgASgJUg5jb252ZXJzYX'
    'Rpb25JZBIbCglzZW5kZXJfaWQYAiABKAlSCHNlbmRlcklkEhgKB2NvbnRlbnQYAyABKAlSB2Nv'
    'bnRlbnQSIQoMbWVzc2FnZV90eXBlGAQgASgJUgttZXNzYWdlVHlwZQ==');

@$core.Deprecated('Use markAsReadRequestDescriptor instead')
const MarkAsReadRequest$json = {
  '1': 'MarkAsReadRequest',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `MarkAsReadRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List markAsReadRequestDescriptor = $convert.base64Decode(
    'ChFNYXJrQXNSZWFkUmVxdWVzdBIdCgptZXNzYWdlX2lkGAEgASgJUgltZXNzYWdlSWQSFwoHdX'
    'Nlcl9pZBgCIAEoCVIGdXNlcklk');

@$core.Deprecated('Use markConversationAsReadRequestDescriptor instead')
const MarkConversationAsReadRequest$json = {
  '1': 'MarkConversationAsReadRequest',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `MarkConversationAsReadRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List markConversationAsReadRequestDescriptor =
    $convert.base64Decode(
        'Ch1NYXJrQ29udmVyc2F0aW9uQXNSZWFkUmVxdWVzdBInCg9jb252ZXJzYXRpb25faWQYASABKA'
        'lSDmNvbnZlcnNhdGlvbklkEhcKB3VzZXJfaWQYAiABKAlSBnVzZXJJZA==');

@$core.Deprecated('Use getUnreadCountsRequestDescriptor instead')
const GetUnreadCountsRequest$json = {
  '1': 'GetUnreadCountsRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'conversation_ids', '3': 2, '4': 3, '5': 9, '10': 'conversationIds'},
  ],
};

/// Descriptor for `GetUnreadCountsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getUnreadCountsRequestDescriptor =
    $convert.base64Decode(
        'ChZHZXRVbnJlYWRDb3VudHNSZXF1ZXN0EhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBIpChBjb2'
        '52ZXJzYXRpb25faWRzGAIgAygJUg9jb252ZXJzYXRpb25JZHM=');

@$core.Deprecated('Use unreadCountDescriptor instead')
const UnreadCount$json = {
  '1': 'UnreadCount',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'count', '3': 2, '4': 1, '5': 3, '10': 'count'},
  ],
};

/// Descriptor for `UnreadCount`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unreadCountDescriptor = $convert.base64Decode(
    'CgtVbnJlYWRDb3VudBInCg9jb252ZXJzYXRpb25faWQYASABKAlSDmNvbnZlcnNhdGlvbklkEh'
    'QKBWNvdW50GAIgASgDUgVjb3VudA==');

@$core.Deprecated('Use getUnreadCountsResponseDescriptor instead')
const GetUnreadCountsResponse$json = {
  '1': 'GetUnreadCountsResponse',
  '2': [
    {
      '1': 'unread_counts',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.chat.UnreadCount',
      '10': 'unreadCounts'
    },
  ],
};

/// Descriptor for `GetUnreadCountsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getUnreadCountsResponseDescriptor =
    $convert.base64Decode(
        'ChdHZXRVbnJlYWRDb3VudHNSZXNwb25zZRI2Cg11bnJlYWRfY291bnRzGAEgAygLMhEuY2hhdC'
        '5VbnJlYWRDb3VudFIMdW5yZWFkQ291bnRz');

@$core.Deprecated('Use clientEventDescriptor instead')
const ClientEvent$json = {
  '1': 'ClientEvent',
  '2': [
    {
      '1': 'subscribe',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.chat.SubscribeRequest',
      '9': 0,
      '10': 'subscribe'
    },
    {
      '1': 'unsubscribe',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.chat.UnsubscribeRequest',
      '9': 0,
      '10': 'unsubscribe'
    },
    {
      '1': 'send_message',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.chat.SendMessageEvent',
      '9': 0,
      '10': 'sendMessage'
    },
    {
      '1': 'ping',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.chat.PingEvent',
      '9': 0,
      '10': 'ping'
    },
    {
      '1': 'typing',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.chat.TypingEvent',
      '9': 0,
      '10': 'typing'
    },
  ],
  '8': [
    {'1': 'event'},
  ],
};

/// Descriptor for `ClientEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientEventDescriptor = $convert.base64Decode(
    'CgtDbGllbnRFdmVudBI2CglzdWJzY3JpYmUYASABKAsyFi5jaGF0LlN1YnNjcmliZVJlcXVlc3'
    'RIAFIJc3Vic2NyaWJlEjwKC3Vuc3Vic2NyaWJlGAIgASgLMhguY2hhdC5VbnN1YnNjcmliZVJl'
    'cXVlc3RIAFILdW5zdWJzY3JpYmUSOwoMc2VuZF9tZXNzYWdlGAMgASgLMhYuY2hhdC5TZW5kTW'
    'Vzc2FnZUV2ZW50SABSC3NlbmRNZXNzYWdlEiUKBHBpbmcYBCABKAsyDy5jaGF0LlBpbmdFdmVu'
    'dEgAUgRwaW5nEisKBnR5cGluZxgFIAEoCzIRLmNoYXQuVHlwaW5nRXZlbnRIAFIGdHlwaW5nQg'
    'cKBWV2ZW50');

@$core.Deprecated('Use subscribeRequestDescriptor instead')
const SubscribeRequest$json = {
  '1': 'SubscribeRequest',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
  ],
};

/// Descriptor for `SubscribeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subscribeRequestDescriptor = $convert.base64Decode(
    'ChBTdWJzY3JpYmVSZXF1ZXN0EicKD2NvbnZlcnNhdGlvbl9pZBgBIAEoCVIOY29udmVyc2F0aW'
    '9uSWQ=');

@$core.Deprecated('Use unsubscribeRequestDescriptor instead')
const UnsubscribeRequest$json = {
  '1': 'UnsubscribeRequest',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
  ],
};

/// Descriptor for `UnsubscribeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unsubscribeRequestDescriptor = $convert.base64Decode(
    'ChJVbnN1YnNjcmliZVJlcXVlc3QSJwoPY29udmVyc2F0aW9uX2lkGAEgASgJUg5jb252ZXJzYX'
    'Rpb25JZA==');

@$core.Deprecated('Use sendMessageEventDescriptor instead')
const SendMessageEvent$json = {
  '1': 'SendMessageEvent',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'content', '3': 2, '4': 1, '5': 9, '10': 'content'},
    {'1': 'message_type', '3': 3, '4': 1, '5': 9, '10': 'messageType'},
    {'1': 'client_message_id', '3': 4, '4': 1, '5': 9, '10': 'clientMessageId'},
  ],
};

/// Descriptor for `SendMessageEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendMessageEventDescriptor = $convert.base64Decode(
    'ChBTZW5kTWVzc2FnZUV2ZW50EicKD2NvbnZlcnNhdGlvbl9pZBgBIAEoCVIOY29udmVyc2F0aW'
    '9uSWQSGAoHY29udGVudBgCIAEoCVIHY29udGVudBIhCgxtZXNzYWdlX3R5cGUYAyABKAlSC21l'
    'c3NhZ2VUeXBlEioKEWNsaWVudF9tZXNzYWdlX2lkGAQgASgJUg9jbGllbnRNZXNzYWdlSWQ=');

@$core.Deprecated('Use pingEventDescriptor instead')
const PingEvent$json = {
  '1': 'PingEvent',
};

/// Descriptor for `PingEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pingEventDescriptor =
    $convert.base64Decode('CglQaW5nRXZlbnQ=');

@$core.Deprecated('Use typingEventDescriptor instead')
const TypingEvent$json = {
  '1': 'TypingEvent',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'is_typing', '3': 2, '4': 1, '5': 8, '10': 'isTyping'},
  ],
};

/// Descriptor for `TypingEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List typingEventDescriptor = $convert.base64Decode(
    'CgtUeXBpbmdFdmVudBInCg9jb252ZXJzYXRpb25faWQYASABKAlSDmNvbnZlcnNhdGlvbklkEh'
    'sKCWlzX3R5cGluZxgCIAEoCFIIaXNUeXBpbmc=');

@$core.Deprecated('Use serverEventDescriptor instead')
const ServerEvent$json = {
  '1': 'ServerEvent',
  '2': [
    {
      '1': 'new_message',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.chat.NewMessageEvent',
      '9': 0,
      '10': 'newMessage'
    },
    {
      '1': 'message_read',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.chat.MessageReadEvent',
      '9': 0,
      '10': 'messageRead'
    },
    {
      '1': 'conversation_update',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.chat.ConversationUpdateEvent',
      '9': 0,
      '10': 'conversationUpdate'
    },
    {
      '1': 'unread_update',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.chat.UnreadCountUpdateEvent',
      '9': 0,
      '10': 'unreadUpdate'
    },
    {
      '1': 'user_status',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.chat.UserStatusEvent',
      '9': 0,
      '10': 'userStatus'
    },
    {
      '1': 'typing_indicator',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.chat.TypingIndicatorEvent',
      '9': 0,
      '10': 'typingIndicator'
    },
    {
      '1': 'subscribed',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.chat.SubscribedEvent',
      '9': 0,
      '10': 'subscribed'
    },
    {
      '1': 'unsubscribed',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.chat.UnsubscribedEvent',
      '9': 0,
      '10': 'unsubscribed'
    },
    {
      '1': 'pong',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.chat.PongEvent',
      '9': 0,
      '10': 'pong'
    },
    {
      '1': 'error',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.chat.ErrorEvent',
      '9': 0,
      '10': 'error'
    },
    {
      '1': 'message_sent',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.chat.MessageSentEvent',
      '9': 0,
      '10': 'messageSent'
    },
  ],
  '8': [
    {'1': 'event'},
  ],
};

/// Descriptor for `ServerEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List serverEventDescriptor = $convert.base64Decode(
    'CgtTZXJ2ZXJFdmVudBI4CgtuZXdfbWVzc2FnZRgBIAEoCzIVLmNoYXQuTmV3TWVzc2FnZUV2ZW'
    '50SABSCm5ld01lc3NhZ2USOwoMbWVzc2FnZV9yZWFkGAIgASgLMhYuY2hhdC5NZXNzYWdlUmVh'
    'ZEV2ZW50SABSC21lc3NhZ2VSZWFkElAKE2NvbnZlcnNhdGlvbl91cGRhdGUYAyABKAsyHS5jaG'
    'F0LkNvbnZlcnNhdGlvblVwZGF0ZUV2ZW50SABSEmNvbnZlcnNhdGlvblVwZGF0ZRJDCg11bnJl'
    'YWRfdXBkYXRlGAQgASgLMhwuY2hhdC5VbnJlYWRDb3VudFVwZGF0ZUV2ZW50SABSDHVucmVhZF'
    'VwZGF0ZRI4Cgt1c2VyX3N0YXR1cxgFIAEoCzIVLmNoYXQuVXNlclN0YXR1c0V2ZW50SABSCnVz'
    'ZXJTdGF0dXMSRwoQdHlwaW5nX2luZGljYXRvchgGIAEoCzIaLmNoYXQuVHlwaW5nSW5kaWNhdG'
    '9yRXZlbnRIAFIPdHlwaW5nSW5kaWNhdG9yEjcKCnN1YnNjcmliZWQYByABKAsyFS5jaGF0LlN1'
    'YnNjcmliZWRFdmVudEgAUgpzdWJzY3JpYmVkEj0KDHVuc3Vic2NyaWJlZBgIIAEoCzIXLmNoYX'
    'QuVW5zdWJzY3JpYmVkRXZlbnRIAFIMdW5zdWJzY3JpYmVkEiUKBHBvbmcYCSABKAsyDy5jaGF0'
    'LlBvbmdFdmVudEgAUgRwb25nEigKBWVycm9yGAogASgLMhAuY2hhdC5FcnJvckV2ZW50SABSBW'
    'Vycm9yEjsKDG1lc3NhZ2Vfc2VudBgLIAEoCzIWLmNoYXQuTWVzc2FnZVNlbnRFdmVudEgAUgtt'
    'ZXNzYWdlU2VudEIHCgVldmVudA==');

@$core.Deprecated('Use newMessageEventDescriptor instead')
const NewMessageEvent$json = {
  '1': 'NewMessageEvent',
  '2': [
    {
      '1': 'message',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.chat.Message',
      '10': 'message'
    },
  ],
};

/// Descriptor for `NewMessageEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List newMessageEventDescriptor = $convert.base64Decode(
    'Cg9OZXdNZXNzYWdlRXZlbnQSJwoHbWVzc2FnZRgBIAEoCzINLmNoYXQuTWVzc2FnZVIHbWVzc2'
    'FnZQ==');

@$core.Deprecated('Use messageReadEventDescriptor instead')
const MessageReadEvent$json = {
  '1': 'MessageReadEvent',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'conversation_id', '3': 2, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'reader_id', '3': 3, '4': 1, '5': 9, '10': 'readerId'},
    {
      '1': 'read_at',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.common.Timestamp',
      '10': 'readAt'
    },
    {'1': 'message_ids', '3': 5, '4': 3, '5': 9, '10': 'messageIds'},
  ],
};

/// Descriptor for `MessageReadEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageReadEventDescriptor = $convert.base64Decode(
    'ChBNZXNzYWdlUmVhZEV2ZW50Eh0KCm1lc3NhZ2VfaWQYASABKAlSCW1lc3NhZ2VJZBInCg9jb2'
    '52ZXJzYXRpb25faWQYAiABKAlSDmNvbnZlcnNhdGlvbklkEhsKCXJlYWRlcl9pZBgDIAEoCVII'
    'cmVhZGVySWQSKgoHcmVhZF9hdBgEIAEoCzIRLmNvbW1vbi5UaW1lc3RhbXBSBnJlYWRBdBIfCg'
    'ttZXNzYWdlX2lkcxgFIAMoCVIKbWVzc2FnZUlkcw==');

@$core.Deprecated('Use conversationUpdateEventDescriptor instead')
const ConversationUpdateEvent$json = {
  '1': 'ConversationUpdateEvent',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {
      '1': 'last_message',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.chat.Message',
      '10': 'lastMessage'
    },
    {'1': 'unread_count', '3': 3, '4': 1, '5': 3, '10': 'unreadCount'},
  ],
};

/// Descriptor for `ConversationUpdateEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationUpdateEventDescriptor = $convert.base64Decode(
    'ChdDb252ZXJzYXRpb25VcGRhdGVFdmVudBInCg9jb252ZXJzYXRpb25faWQYASABKAlSDmNvbn'
    'ZlcnNhdGlvbklkEjAKDGxhc3RfbWVzc2FnZRgCIAEoCzINLmNoYXQuTWVzc2FnZVILbGFzdE1l'
    'c3NhZ2USIQoMdW5yZWFkX2NvdW50GAMgASgDUgt1bnJlYWRDb3VudA==');

@$core.Deprecated('Use unreadCountUpdateEventDescriptor instead')
const UnreadCountUpdateEvent$json = {
  '1': 'UnreadCountUpdateEvent',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'count', '3': 2, '4': 1, '5': 3, '10': 'count'},
  ],
};

/// Descriptor for `UnreadCountUpdateEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unreadCountUpdateEventDescriptor =
    $convert.base64Decode(
        'ChZVbnJlYWRDb3VudFVwZGF0ZUV2ZW50EicKD2NvbnZlcnNhdGlvbl9pZBgBIAEoCVIOY29udm'
        'Vyc2F0aW9uSWQSFAoFY291bnQYAiABKANSBWNvdW50');

@$core.Deprecated('Use userStatusEventDescriptor instead')
const UserStatusEvent$json = {
  '1': 'UserStatusEvent',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'is_online', '3': 2, '4': 1, '5': 8, '10': 'isOnline'},
    {
      '1': 'last_seen',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.common.Timestamp',
      '10': 'lastSeen'
    },
  ],
};

/// Descriptor for `UserStatusEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userStatusEventDescriptor = $convert.base64Decode(
    'Cg9Vc2VyU3RhdHVzRXZlbnQSFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklkEhsKCWlzX29ubGluZR'
    'gCIAEoCFIIaXNPbmxpbmUSLgoJbGFzdF9zZWVuGAMgASgLMhEuY29tbW9uLlRpbWVzdGFtcFII'
    'bGFzdFNlZW4=');

@$core.Deprecated('Use typingIndicatorEventDescriptor instead')
const TypingIndicatorEvent$json = {
  '1': 'TypingIndicatorEvent',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'is_typing', '3': 3, '4': 1, '5': 8, '10': 'isTyping'},
  ],
};

/// Descriptor for `TypingIndicatorEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List typingIndicatorEventDescriptor = $convert.base64Decode(
    'ChRUeXBpbmdJbmRpY2F0b3JFdmVudBInCg9jb252ZXJzYXRpb25faWQYASABKAlSDmNvbnZlcn'
    'NhdGlvbklkEhcKB3VzZXJfaWQYAiABKAlSBnVzZXJJZBIbCglpc190eXBpbmcYAyABKAhSCGlz'
    'VHlwaW5n');

@$core.Deprecated('Use subscribedEventDescriptor instead')
const SubscribedEvent$json = {
  '1': 'SubscribedEvent',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
  ],
};

/// Descriptor for `SubscribedEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subscribedEventDescriptor = $convert.base64Decode(
    'Cg9TdWJzY3JpYmVkRXZlbnQSJwoPY29udmVyc2F0aW9uX2lkGAEgASgJUg5jb252ZXJzYXRpb2'
    '5JZA==');

@$core.Deprecated('Use unsubscribedEventDescriptor instead')
const UnsubscribedEvent$json = {
  '1': 'UnsubscribedEvent',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
  ],
};

/// Descriptor for `UnsubscribedEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unsubscribedEventDescriptor = $convert.base64Decode(
    'ChFVbnN1YnNjcmliZWRFdmVudBInCg9jb252ZXJzYXRpb25faWQYASABKAlSDmNvbnZlcnNhdG'
    'lvbklk');

@$core.Deprecated('Use pongEventDescriptor instead')
const PongEvent$json = {
  '1': 'PongEvent',
};

/// Descriptor for `PongEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pongEventDescriptor =
    $convert.base64Decode('CglQb25nRXZlbnQ=');

@$core.Deprecated('Use errorEventDescriptor instead')
const ErrorEvent$json = {
  '1': 'ErrorEvent',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 9, '10': 'code'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'action', '3': 3, '4': 1, '5': 9, '10': 'action'},
  ],
};

/// Descriptor for `ErrorEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List errorEventDescriptor = $convert.base64Decode(
    'CgpFcnJvckV2ZW50EhIKBGNvZGUYASABKAlSBGNvZGUSGAoHbWVzc2FnZRgCIAEoCVIHbWVzc2'
    'FnZRIWCgZhY3Rpb24YAyABKAlSBmFjdGlvbg==');

@$core.Deprecated('Use messageSentEventDescriptor instead')
const MessageSentEvent$json = {
  '1': 'MessageSentEvent',
  '2': [
    {'1': 'client_message_id', '3': 1, '4': 1, '5': 9, '10': 'clientMessageId'},
    {
      '1': 'message',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.chat.Message',
      '10': 'message'
    },
  ],
};

/// Descriptor for `MessageSentEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageSentEventDescriptor = $convert.base64Decode(
    'ChBNZXNzYWdlU2VudEV2ZW50EioKEWNsaWVudF9tZXNzYWdlX2lkGAEgASgJUg9jbGllbnRNZX'
    'NzYWdlSWQSJwoHbWVzc2FnZRgCIAEoCzINLmNoYXQuTWVzc2FnZVIHbWVzc2FnZQ==');
