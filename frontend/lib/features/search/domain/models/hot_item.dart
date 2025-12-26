// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'hot_item.freezed.dart';
part 'hot_item.g.dart';

@freezed
sealed class HotItem with _$HotItem {
  const factory HotItem({
    required String title,
    required String author,
    required String heat,
    @JsonKey(name: 'image_url') String? imageUrl,
  }) = _HotItem;

  factory HotItem.fromJson(Map<String, dynamic> json) => _$HotItemFromJson(json);
}
