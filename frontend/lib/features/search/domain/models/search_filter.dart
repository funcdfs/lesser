import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_filter.freezed.dart';
part 'search_filter.g.dart';

enum SearchType { all, users, posts, tags }

enum SortBy { relevance, time, popularity }

@freezed
sealed class SearchFilter with _$SearchFilter {
  const factory SearchFilter({
    @Default(SearchType.all) SearchType type,
    @Default(SortBy.relevance) SortBy sortBy,
  }) = _SearchFilter;

  factory SearchFilter.fromJson(Map<String, dynamic> json) =>
      _$SearchFilterFromJson(json);
}
