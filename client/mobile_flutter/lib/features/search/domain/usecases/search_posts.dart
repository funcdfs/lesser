import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../feeds/domain/entities/feed_item.dart';
import '../repositories/search_repository.dart';

/// Search posts use case
class SearchPostsUseCase {
  const SearchPostsUseCase(this._repository);

  final SearchRepository _repository;

  Future<Either<Failure, List<FeedItem>>> call(SearchPostsParams params) {
    return _repository.searchPosts(
      query: params.query,
      postType: params.postType,
      fromDate: params.fromDate,
      toDate: params.toDate,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

/// Search posts parameters
class SearchPostsParams {
  const SearchPostsParams({
    required this.query,
    this.postType,
    this.fromDate,
    this.toDate,
    this.page = 1,
    this.pageSize = 20,
  });

  final String query;
  final String? postType;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int page;
  final int pageSize;
}
