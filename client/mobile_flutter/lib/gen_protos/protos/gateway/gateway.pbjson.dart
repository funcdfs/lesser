// This is a generated file - do not edit.
//
// Generated from gateway/gateway.proto.

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

@$core.Deprecated('Use healthRequestDescriptor instead')
const HealthRequest$json = {
  '1': 'HealthRequest',
};

/// Descriptor for `HealthRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List healthRequestDescriptor =
    $convert.base64Decode('Cg1IZWFsdGhSZXF1ZXN0');

@$core.Deprecated('Use healthResponseDescriptor instead')
const HealthResponse$json = {
  '1': 'HealthResponse',
  '2': [
    {'1': 'healthy', '3': 1, '4': 1, '5': 8, '10': 'healthy'},
    {
      '1': 'services',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.gateway.HealthResponse.ServicesEntry',
      '10': 'services'
    },
  ],
  '3': [HealthResponse_ServicesEntry$json],
};

@$core.Deprecated('Use healthResponseDescriptor instead')
const HealthResponse_ServicesEntry$json = {
  '1': 'ServicesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.gateway.ServiceStatus',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

/// Descriptor for `HealthResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List healthResponseDescriptor = $convert.base64Decode(
    'Cg5IZWFsdGhSZXNwb25zZRIYCgdoZWFsdGh5GAEgASgIUgdoZWFsdGh5EkEKCHNlcnZpY2VzGA'
    'IgAygLMiUuZ2F0ZXdheS5IZWFsdGhSZXNwb25zZS5TZXJ2aWNlc0VudHJ5UghzZXJ2aWNlcxpT'
    'Cg1TZXJ2aWNlc0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5EiwKBXZhbHVlGAIgASgLMhYuZ2F0ZX'
    'dheS5TZXJ2aWNlU3RhdHVzUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use serviceStatusDescriptor instead')
const ServiceStatus$json = {
  '1': 'ServiceStatus',
  '2': [
    {'1': 'healthy', '3': 1, '4': 1, '5': 8, '10': 'healthy'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'latency_ms', '3': 3, '4': 1, '5': 3, '10': 'latencyMs'},
  ],
};

/// Descriptor for `ServiceStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List serviceStatusDescriptor = $convert.base64Decode(
    'Cg1TZXJ2aWNlU3RhdHVzEhgKB2hlYWx0aHkYASABKAhSB2hlYWx0aHkSGAoHbWVzc2FnZRgCIA'
    'EoCVIHbWVzc2FnZRIdCgpsYXRlbmN5X21zGAMgASgDUglsYXRlbmN5TXM=');
