// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hot_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HotItem {

 String get title; String get author; String get heat;@JsonKey(name: 'image_url') String? get imageUrl;
/// Create a copy of HotItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HotItemCopyWith<HotItem> get copyWith => _$HotItemCopyWithImpl<HotItem>(this as HotItem, _$identity);

  /// Serializes this HotItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HotItem&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&(identical(other.heat, heat) || other.heat == heat)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,author,heat,imageUrl);

@override
String toString() {
  return 'HotItem(title: $title, author: $author, heat: $heat, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class $HotItemCopyWith<$Res>  {
  factory $HotItemCopyWith(HotItem value, $Res Function(HotItem) _then) = _$HotItemCopyWithImpl;
@useResult
$Res call({
 String title, String author, String heat,@JsonKey(name: 'image_url') String? imageUrl
});




}
/// @nodoc
class _$HotItemCopyWithImpl<$Res>
    implements $HotItemCopyWith<$Res> {
  _$HotItemCopyWithImpl(this._self, this._then);

  final HotItem _self;
  final $Res Function(HotItem) _then;

/// Create a copy of HotItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? author = null,Object? heat = null,Object? imageUrl = freezed,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,heat: null == heat ? _self.heat : heat // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HotItem].
extension HotItemPatterns on HotItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HotItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HotItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HotItem value)  $default,){
final _that = this;
switch (_that) {
case _HotItem():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HotItem value)?  $default,){
final _that = this;
switch (_that) {
case _HotItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String author,  String heat, @JsonKey(name: 'image_url')  String? imageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HotItem() when $default != null:
return $default(_that.title,_that.author,_that.heat,_that.imageUrl);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String author,  String heat, @JsonKey(name: 'image_url')  String? imageUrl)  $default,) {final _that = this;
switch (_that) {
case _HotItem():
return $default(_that.title,_that.author,_that.heat,_that.imageUrl);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String author,  String heat, @JsonKey(name: 'image_url')  String? imageUrl)?  $default,) {final _that = this;
switch (_that) {
case _HotItem() when $default != null:
return $default(_that.title,_that.author,_that.heat,_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HotItem implements HotItem {
  const _HotItem({required this.title, required this.author, required this.heat, @JsonKey(name: 'image_url') this.imageUrl});
  factory _HotItem.fromJson(Map<String, dynamic> json) => _$HotItemFromJson(json);

@override final  String title;
@override final  String author;
@override final  String heat;
@override@JsonKey(name: 'image_url') final  String? imageUrl;

/// Create a copy of HotItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HotItemCopyWith<_HotItem> get copyWith => __$HotItemCopyWithImpl<_HotItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HotItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HotItem&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&(identical(other.heat, heat) || other.heat == heat)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,author,heat,imageUrl);

@override
String toString() {
  return 'HotItem(title: $title, author: $author, heat: $heat, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$HotItemCopyWith<$Res> implements $HotItemCopyWith<$Res> {
  factory _$HotItemCopyWith(_HotItem value, $Res Function(_HotItem) _then) = __$HotItemCopyWithImpl;
@override @useResult
$Res call({
 String title, String author, String heat,@JsonKey(name: 'image_url') String? imageUrl
});




}
/// @nodoc
class __$HotItemCopyWithImpl<$Res>
    implements _$HotItemCopyWith<$Res> {
  __$HotItemCopyWithImpl(this._self, this._then);

  final _HotItem _self;
  final $Res Function(_HotItem) _then;

/// Create a copy of HotItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? author = null,Object? heat = null,Object? imageUrl = freezed,}) {
  return _then(_HotItem(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,heat: null == heat ? _self.heat : heat // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
