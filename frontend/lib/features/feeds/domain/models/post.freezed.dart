// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Post {

 String get id; String get username; String get content;@JsonKey(name: 'created_at') String get createdAt; int get likes; String? get location;@JsonKey(name: 'image_urls') List<String> get imageUrls;@JsonKey(name: 'comments_count') int get commentsCount;@JsonKey(name: 'reposts_count') int get repostsCount;@JsonKey(name: 'bookmarks_count') int get bookmarksCount;@JsonKey(name: 'shares_count') int get sharesCount;@JsonKey(name: 'is_liked') bool get isLiked;
/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostCopyWith<Post> get copyWith => _$PostCopyWithImpl<Post>(this as Post, _$identity);

  /// Serializes this Post to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Post&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.content, content) || other.content == content)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.likes, likes) || other.likes == likes)&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other.imageUrls, imageUrls)&&(identical(other.commentsCount, commentsCount) || other.commentsCount == commentsCount)&&(identical(other.repostsCount, repostsCount) || other.repostsCount == repostsCount)&&(identical(other.bookmarksCount, bookmarksCount) || other.bookmarksCount == bookmarksCount)&&(identical(other.sharesCount, sharesCount) || other.sharesCount == sharesCount)&&(identical(other.isLiked, isLiked) || other.isLiked == isLiked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,content,createdAt,likes,location,const DeepCollectionEquality().hash(imageUrls),commentsCount,repostsCount,bookmarksCount,sharesCount,isLiked);

@override
String toString() {
  return 'Post(id: $id, username: $username, content: $content, createdAt: $createdAt, likes: $likes, location: $location, imageUrls: $imageUrls, commentsCount: $commentsCount, repostsCount: $repostsCount, bookmarksCount: $bookmarksCount, sharesCount: $sharesCount, isLiked: $isLiked)';
}


}

/// @nodoc
abstract mixin class $PostCopyWith<$Res>  {
  factory $PostCopyWith(Post value, $Res Function(Post) _then) = _$PostCopyWithImpl;
@useResult
$Res call({
 String id, String username, String content,@JsonKey(name: 'created_at') String createdAt, int likes, String? location,@JsonKey(name: 'image_urls') List<String> imageUrls,@JsonKey(name: 'comments_count') int commentsCount,@JsonKey(name: 'reposts_count') int repostsCount,@JsonKey(name: 'bookmarks_count') int bookmarksCount,@JsonKey(name: 'shares_count') int sharesCount,@JsonKey(name: 'is_liked') bool isLiked
});




}
/// @nodoc
class _$PostCopyWithImpl<$Res>
    implements $PostCopyWith<$Res> {
  _$PostCopyWithImpl(this._self, this._then);

  final Post _self;
  final $Res Function(Post) _then;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? content = null,Object? createdAt = null,Object? likes = null,Object? location = freezed,Object? imageUrls = null,Object? commentsCount = null,Object? repostsCount = null,Object? bookmarksCount = null,Object? sharesCount = null,Object? isLiked = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,likes: null == likes ? _self.likes : likes // ignore: cast_nullable_to_non_nullable
as int,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,imageUrls: null == imageUrls ? _self.imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,commentsCount: null == commentsCount ? _self.commentsCount : commentsCount // ignore: cast_nullable_to_non_nullable
as int,repostsCount: null == repostsCount ? _self.repostsCount : repostsCount // ignore: cast_nullable_to_non_nullable
as int,bookmarksCount: null == bookmarksCount ? _self.bookmarksCount : bookmarksCount // ignore: cast_nullable_to_non_nullable
as int,sharesCount: null == sharesCount ? _self.sharesCount : sharesCount // ignore: cast_nullable_to_non_nullable
as int,isLiked: null == isLiked ? _self.isLiked : isLiked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Post].
extension PostPatterns on Post {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Post value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Post() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Post value)  $default,){
final _that = this;
switch (_that) {
case _Post():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Post value)?  $default,){
final _that = this;
switch (_that) {
case _Post() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String username,  String content, @JsonKey(name: 'created_at')  String createdAt,  int likes,  String? location, @JsonKey(name: 'image_urls')  List<String> imageUrls, @JsonKey(name: 'comments_count')  int commentsCount, @JsonKey(name: 'reposts_count')  int repostsCount, @JsonKey(name: 'bookmarks_count')  int bookmarksCount, @JsonKey(name: 'shares_count')  int sharesCount, @JsonKey(name: 'is_liked')  bool isLiked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that.id,_that.username,_that.content,_that.createdAt,_that.likes,_that.location,_that.imageUrls,_that.commentsCount,_that.repostsCount,_that.bookmarksCount,_that.sharesCount,_that.isLiked);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String username,  String content, @JsonKey(name: 'created_at')  String createdAt,  int likes,  String? location, @JsonKey(name: 'image_urls')  List<String> imageUrls, @JsonKey(name: 'comments_count')  int commentsCount, @JsonKey(name: 'reposts_count')  int repostsCount, @JsonKey(name: 'bookmarks_count')  int bookmarksCount, @JsonKey(name: 'shares_count')  int sharesCount, @JsonKey(name: 'is_liked')  bool isLiked)  $default,) {final _that = this;
switch (_that) {
case _Post():
return $default(_that.id,_that.username,_that.content,_that.createdAt,_that.likes,_that.location,_that.imageUrls,_that.commentsCount,_that.repostsCount,_that.bookmarksCount,_that.sharesCount,_that.isLiked);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String username,  String content, @JsonKey(name: 'created_at')  String createdAt,  int likes,  String? location, @JsonKey(name: 'image_urls')  List<String> imageUrls, @JsonKey(name: 'comments_count')  int commentsCount, @JsonKey(name: 'reposts_count')  int repostsCount, @JsonKey(name: 'bookmarks_count')  int bookmarksCount, @JsonKey(name: 'shares_count')  int sharesCount, @JsonKey(name: 'is_liked')  bool isLiked)?  $default,) {final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that.id,_that.username,_that.content,_that.createdAt,_that.likes,_that.location,_that.imageUrls,_that.commentsCount,_that.repostsCount,_that.bookmarksCount,_that.sharesCount,_that.isLiked);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Post implements Post {
  const _Post({required this.id, required this.username, required this.content, @JsonKey(name: 'created_at') required this.createdAt, this.likes = 0, this.location, @JsonKey(name: 'image_urls') final  List<String> imageUrls = const [], @JsonKey(name: 'comments_count') this.commentsCount = 0, @JsonKey(name: 'reposts_count') this.repostsCount = 0, @JsonKey(name: 'bookmarks_count') this.bookmarksCount = 0, @JsonKey(name: 'shares_count') this.sharesCount = 0, @JsonKey(name: 'is_liked') this.isLiked = false}): _imageUrls = imageUrls;
  factory _Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

@override final  String id;
@override final  String username;
@override final  String content;
@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey() final  int likes;
@override final  String? location;
 final  List<String> _imageUrls;
@override@JsonKey(name: 'image_urls') List<String> get imageUrls {
  if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imageUrls);
}

@override@JsonKey(name: 'comments_count') final  int commentsCount;
@override@JsonKey(name: 'reposts_count') final  int repostsCount;
@override@JsonKey(name: 'bookmarks_count') final  int bookmarksCount;
@override@JsonKey(name: 'shares_count') final  int sharesCount;
@override@JsonKey(name: 'is_liked') final  bool isLiked;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostCopyWith<_Post> get copyWith => __$PostCopyWithImpl<_Post>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Post&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.content, content) || other.content == content)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.likes, likes) || other.likes == likes)&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other._imageUrls, _imageUrls)&&(identical(other.commentsCount, commentsCount) || other.commentsCount == commentsCount)&&(identical(other.repostsCount, repostsCount) || other.repostsCount == repostsCount)&&(identical(other.bookmarksCount, bookmarksCount) || other.bookmarksCount == bookmarksCount)&&(identical(other.sharesCount, sharesCount) || other.sharesCount == sharesCount)&&(identical(other.isLiked, isLiked) || other.isLiked == isLiked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,content,createdAt,likes,location,const DeepCollectionEquality().hash(_imageUrls),commentsCount,repostsCount,bookmarksCount,sharesCount,isLiked);

@override
String toString() {
  return 'Post(id: $id, username: $username, content: $content, createdAt: $createdAt, likes: $likes, location: $location, imageUrls: $imageUrls, commentsCount: $commentsCount, repostsCount: $repostsCount, bookmarksCount: $bookmarksCount, sharesCount: $sharesCount, isLiked: $isLiked)';
}


}

/// @nodoc
abstract mixin class _$PostCopyWith<$Res> implements $PostCopyWith<$Res> {
  factory _$PostCopyWith(_Post value, $Res Function(_Post) _then) = __$PostCopyWithImpl;
@override @useResult
$Res call({
 String id, String username, String content,@JsonKey(name: 'created_at') String createdAt, int likes, String? location,@JsonKey(name: 'image_urls') List<String> imageUrls,@JsonKey(name: 'comments_count') int commentsCount,@JsonKey(name: 'reposts_count') int repostsCount,@JsonKey(name: 'bookmarks_count') int bookmarksCount,@JsonKey(name: 'shares_count') int sharesCount,@JsonKey(name: 'is_liked') bool isLiked
});




}
/// @nodoc
class __$PostCopyWithImpl<$Res>
    implements _$PostCopyWith<$Res> {
  __$PostCopyWithImpl(this._self, this._then);

  final _Post _self;
  final $Res Function(_Post) _then;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? content = null,Object? createdAt = null,Object? likes = null,Object? location = freezed,Object? imageUrls = null,Object? commentsCount = null,Object? repostsCount = null,Object? bookmarksCount = null,Object? sharesCount = null,Object? isLiked = null,}) {
  return _then(_Post(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,likes: null == likes ? _self.likes : likes // ignore: cast_nullable_to_non_nullable
as int,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,imageUrls: null == imageUrls ? _self._imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,commentsCount: null == commentsCount ? _self.commentsCount : commentsCount // ignore: cast_nullable_to_non_nullable
as int,repostsCount: null == repostsCount ? _self.repostsCount : repostsCount // ignore: cast_nullable_to_non_nullable
as int,bookmarksCount: null == bookmarksCount ? _self.bookmarksCount : bookmarksCount // ignore: cast_nullable_to_non_nullable
as int,sharesCount: null == sharesCount ? _self.sharesCount : sharesCount // ignore: cast_nullable_to_non_nullable
as int,isLiked: null == isLiked ? _self.isLiked : isLiked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
