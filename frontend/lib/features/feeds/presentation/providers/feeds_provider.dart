import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lesser/features/feeds/data/feeds_repository.dart';
import 'package:lesser/core/network/api_provider.dart';
import 'package:lesser/features/feeds/domain/models/post.dart';

part 'feeds_provider.g.dart';

@riverpod
FeedsRepository feedsRepository(FeedsRepositoryRef ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FeedsRepository(apiClient);
}

@riverpod
Future<List<Post>> feedsList(FeedsListRef ref) async {
  final repository = ref.watch(feedsRepositoryProvider);
  return repository.getFeeds();
}
