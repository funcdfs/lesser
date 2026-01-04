// This is a generated file - do not edit.
//
// Generated from notification/notification.proto.

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

@$core.Deprecated('Use notificationTypeDescriptor instead')
const NotificationType$json = {
  '1': 'NotificationType',
  '2': [
    {'1': 'NOTIFICATION_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'LIKE', '2': 1},
    {'1': 'COMMENT', '2': 2},
    {'1': 'REPLY', '2': 3},
    {'1': 'BOOKMARK', '2': 4},
    {'1': 'MENTION', '2': 5},
    {'1': 'FOLLOW', '2': 6},
    {'1': 'REPOST', '2': 7},
  ],
};

/// Descriptor for `NotificationType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List notificationTypeDescriptor = $convert.base64Decode(
    'ChBOb3RpZmljYXRpb25UeXBlEiEKHU5PVElGSUNBVElPTl9UWVBFX1VOU1BFQ0lGSUVEEAASCA'
    'oETElLRRABEgsKB0NPTU1FTlQQAhIJCgVSRVBMWRADEgwKCEJPT0tNQVJLEAQSCwoHTUVOVElP'
    'ThAFEgoKBkZPTExPVxAGEgoKBlJFUE9TVBAH');

@$core.Deprecated('Use notificationDescriptor instead')
const Notification$json = {
  '1': 'Notification',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {
      '1': 'type',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.notification.NotificationType',
      '10': 'type'
    },
    {'1': 'actor_id', '3': 4, '4': 1, '5': 9, '10': 'actorId'},
    {'1': 'target_type', '3': 5, '4': 1, '5': 9, '10': 'targetType'},
    {'1': 'target_id', '3': 6, '4': 1, '5': 9, '10': 'targetId'},
    {'1': 'message', '3': 7, '4': 1, '5': 9, '10': 'message'},
    {'1': 'is_read', '3': 8, '4': 1, '5': 8, '10': 'isRead'},
    {
      '1': 'created_at',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.common.Timestamp',
      '10': 'createdAt'
    },
  ],
};

/// Descriptor for `Notification`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationDescriptor = $convert.base64Decode(
    'CgxOb3RpZmljYXRpb24SDgoCaWQYASABKAlSAmlkEhcKB3VzZXJfaWQYAiABKAlSBnVzZXJJZB'
    'IyCgR0eXBlGAMgASgOMh4ubm90aWZpY2F0aW9uLk5vdGlmaWNhdGlvblR5cGVSBHR5cGUSGQoI'
    'YWN0b3JfaWQYBCABKAlSB2FjdG9ySWQSHwoLdGFyZ2V0X3R5cGUYBSABKAlSCnRhcmdldFR5cG'
    'USGwoJdGFyZ2V0X2lkGAYgASgJUgh0YXJnZXRJZBIYCgdtZXNzYWdlGAcgASgJUgdtZXNzYWdl'
    'EhcKB2lzX3JlYWQYCCABKAhSBmlzUmVhZBIwCgpjcmVhdGVkX2F0GAkgASgLMhEuY29tbW9uLl'
    'RpbWVzdGFtcFIJY3JlYXRlZEF0');

@$core.Deprecated('Use listNotificationsRequestDescriptor instead')
const ListNotificationsRequest$json = {
  '1': 'ListNotificationsRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'unread_only', '3': 2, '4': 1, '5': 8, '10': 'unreadOnly'},
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

/// Descriptor for `ListNotificationsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listNotificationsRequestDescriptor = $convert.base64Decode(
    'ChhMaXN0Tm90aWZpY2F0aW9uc1JlcXVlc3QSFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklkEh8KC3'
    'VucmVhZF9vbmx5GAIgASgIUgp1bnJlYWRPbmx5EjIKCnBhZ2luYXRpb24YAyABKAsyEi5jb21t'
    'b24uUGFnaW5hdGlvblIKcGFnaW5hdGlvbg==');

@$core.Deprecated('Use listNotificationsResponseDescriptor instead')
const ListNotificationsResponse$json = {
  '1': 'ListNotificationsResponse',
  '2': [
    {
      '1': 'notifications',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.notification.Notification',
      '10': 'notifications'
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

/// Descriptor for `ListNotificationsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listNotificationsResponseDescriptor = $convert.base64Decode(
    'ChlMaXN0Tm90aWZpY2F0aW9uc1Jlc3BvbnNlEkAKDW5vdGlmaWNhdGlvbnMYASADKAsyGi5ub3'
    'RpZmljYXRpb24uTm90aWZpY2F0aW9uUg1ub3RpZmljYXRpb25zEjIKCnBhZ2luYXRpb24YAiAB'
    'KAsyEi5jb21tb24uUGFnaW5hdGlvblIKcGFnaW5hdGlvbg==');

@$core.Deprecated('Use readNotificationRequestDescriptor instead')
const ReadNotificationRequest$json = {
  '1': 'ReadNotificationRequest',
  '2': [
    {'1': 'notification_id', '3': 1, '4': 1, '5': 9, '10': 'notificationId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `ReadNotificationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List readNotificationRequestDescriptor =
    $convert.base64Decode(
        'ChdSZWFkTm90aWZpY2F0aW9uUmVxdWVzdBInCg9ub3RpZmljYXRpb25faWQYASABKAlSDm5vdG'
        'lmaWNhdGlvbklkEhcKB3VzZXJfaWQYAiABKAlSBnVzZXJJZA==');

@$core.Deprecated('Use readAllNotificationsRequestDescriptor instead')
const ReadAllNotificationsRequest$json = {
  '1': 'ReadAllNotificationsRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `ReadAllNotificationsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List readAllNotificationsRequestDescriptor =
    $convert.base64Decode(
        'ChtSZWFkQWxsTm90aWZpY2F0aW9uc1JlcXVlc3QSFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklk');

@$core.Deprecated('Use getUnreadCountRequestDescriptor instead')
const GetUnreadCountRequest$json = {
  '1': 'GetUnreadCountRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `GetUnreadCountRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getUnreadCountRequestDescriptor =
    $convert.base64Decode(
        'ChVHZXRVbnJlYWRDb3VudFJlcXVlc3QSFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklk');

@$core.Deprecated('Use unreadCountResponseDescriptor instead')
const UnreadCountResponse$json = {
  '1': 'UnreadCountResponse',
  '2': [
    {'1': 'count', '3': 1, '4': 1, '5': 5, '10': 'count'},
  ],
};

/// Descriptor for `UnreadCountResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unreadCountResponseDescriptor =
    $convert.base64Decode(
        'ChNVbnJlYWRDb3VudFJlc3BvbnNlEhQKBWNvdW50GAEgASgFUgVjb3VudA==');

@$core.Deprecated('Use createNotificationRequestDescriptor instead')
const CreateNotificationRequest$json = {
  '1': 'CreateNotificationRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {
      '1': 'type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.notification.NotificationType',
      '10': 'type'
    },
    {'1': 'actor_id', '3': 3, '4': 1, '5': 9, '10': 'actorId'},
    {'1': 'target_type', '3': 4, '4': 1, '5': 9, '10': 'targetType'},
    {'1': 'target_id', '3': 5, '4': 1, '5': 9, '10': 'targetId'},
    {'1': 'message', '3': 6, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `CreateNotificationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createNotificationRequestDescriptor = $convert.base64Decode(
    'ChlDcmVhdGVOb3RpZmljYXRpb25SZXF1ZXN0EhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBIyCg'
    'R0eXBlGAIgASgOMh4ubm90aWZpY2F0aW9uLk5vdGlmaWNhdGlvblR5cGVSBHR5cGUSGQoIYWN0'
    'b3JfaWQYAyABKAlSB2FjdG9ySWQSHwoLdGFyZ2V0X3R5cGUYBCABKAlSCnRhcmdldFR5cGUSGw'
    'oJdGFyZ2V0X2lkGAUgASgJUgh0YXJnZXRJZBIYCgdtZXNzYWdlGAYgASgJUgdtZXNzYWdl');
