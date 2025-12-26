// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../auth/domain/models/user.dart';
import '../../../feeds/domain/models/post.dart';

part 'search_result.freezed.dart';
part 'search_result.g.dart';

@freezed
sealed class SearchResult with _$SearchResult {
  const factory SearchResult({
    @Default([]) List<User> users,
    @Default([]) List<Post> posts,
    @Default([]) List<String> tags,
    @Default(false) @JsonKey(name: 'has_more') bool hasMore,
  }) = _SearchResult;

  factory SearchResult.fromJson(Map<String, dynamic> json) =>
      _$SearchResultFromJson(json);
}
