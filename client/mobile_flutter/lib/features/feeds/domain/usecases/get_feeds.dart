import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/feed_item.dart';
import '../repositories/feed_repository.dart';

/// Get feeds use case
class GetFeedsUseCase {
  const GetFeedsUseCase(this._repository);

  final FeedRepository _repository;

  Future<Either<Failure, List<FeedItem>>> call(GetFeedsParams params) {
    return _repository.getFeeds(
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

/// Get feeds parameters
class GetFeedsParams {
  const GetFeedsParams({
    this.page = 1,
    this.pageSize = 20,
  });

  final int page;
  final int pageSize;
}
