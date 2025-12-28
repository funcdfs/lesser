import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../feeds/domain/entities/feed_item.dart';

/// Search repository interface
abstract class SearchRepository {
  /// Search posts
  Future<Either<Failure, List<FeedItem>>> searchPosts({
    required String query,
    String? postType,
    DateTime? fromDate,
    DateTime? toDate,
    int page = 1,
    int pageSize = 20,
  });

  /// Search users
  Future<Either<Failure, List<User>>> searchUsers({
    required String query,
    int page = 1,
    int pageSize = 20,
  });
}
