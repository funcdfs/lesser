// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'draft.freezed.dart';
part 'draft.g.dart';

/// Draft model for storing unsaved post content
@freezed
sealed class Draft with _$Draft {
  const factory Draft({
    required String id,
    required String content,
    String? location,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Draft;

  factory Draft.fromJson(Map<String, dynamic> json) => _$DraftFromJson(json);
}
