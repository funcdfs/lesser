// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_filter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SearchFilter _$SearchFilterFromJson(
  Map<String, dynamic> json,
) => _SearchFilter(
  type:
      $enumDecodeNullable(_$SearchTypeEnumMap, json['type']) ?? SearchType.all,
  sortBy:
      $enumDecodeNullable(_$SortByEnumMap, json['sortBy']) ?? SortBy.relevance,
);

Map<String, dynamic> _$SearchFilterToJson(_SearchFilter instance) =>
    <String, dynamic>{
      'type': _$SearchTypeEnumMap[instance.type]!,
      'sortBy': _$SortByEnumMap[instance.sortBy]!,
    };

const _$SearchTypeEnumMap = {
  SearchType.all: 'all',
  SearchType.users: 'users',
  SearchType.posts: 'posts',
  SearchType.tags: 'tags',
};

const _$SortByEnumMap = {
  SortBy.relevance: 'relevance',
  SortBy.time: 'time',
  SortBy.popularity: 'popularity',
};
