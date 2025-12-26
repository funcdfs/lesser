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

typedef FeedsRepositoryRef = AutoDisposeProviderRef<FeedsRepository>;
String _$pagedFeedsHash() => r'905bac0c5a21d0ba7c061e704b3bfb4f49700ccb';

/// See also [PagedFeeds].
@ProviderFor(PagedFeeds)
final pagedFeedsProvider =
    AutoDisposeAsyncNotifierProvider<PagedFeeds, List<Post>>.internal(
  PagedFeeds.new,
  name: r'pagedFeedsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$pagedFeedsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PagedFeeds = AutoDisposeAsyncNotifier<List<Post>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
