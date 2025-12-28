import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../feeds/domain/entities/feed_item.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

/// Create post use case
class CreatePostUseCase {
  const CreatePostUseCase(this._repository);

  final PostRepository _repository;

  Future<Either<Failure, FeedItem>> call(CreatePostRequest request) {
    return _repository.createPost(request);
  }
}
