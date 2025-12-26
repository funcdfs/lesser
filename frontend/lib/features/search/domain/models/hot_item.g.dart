// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hot_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HotItem _$HotItemFromJson(Map<String, dynamic> json) => _HotItem(
  title: json['title'] as String,
  author: json['author'] as String,
  heat: json['heat'] as String,
  imageUrl: json['image_url'] as String?,
);

Map<String, dynamic> _$HotItemToJson(_HotItem instance) => <String, dynamic>{
  'title': instance.title,
  'author': instance.author,
  'heat': instance.heat,
  'image_url': instance.imageUrl,
};
