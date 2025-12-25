// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feeds_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$feedsRepositoryHash() => r'65b5f777901e1029ee7f1f1a6815c781b09a7b75';

/// See also [feedsRepository].
@ProviderFor(feedsRepository)
final feedsRepositoryProvider = AutoDisposeProvider<FeedsRepository>.internal(
  feedsRepository,
  name: r'feedsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$feedsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FeedsRepositoryRef = AutoDisposeProviderRef<FeedsRepository>;
String _$feedsListHash() => r'596efdc57ed71044f77d9c61433516a938b1c182';

/// See also [feedsList].
@ProviderFor(feedsList)
final feedsListProvider = AutoDisposeFutureProvider<List<Post>>.internal(
  feedsList,
  name: r'feedsListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$feedsListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FeedsListRef = AutoDisposeFutureProviderRef<List<Post>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
