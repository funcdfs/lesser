// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Comment {

 String get id;@JsonKey(name: 'post_id') String get postId;@JsonKey(name: 'user_id') String get userId; String get username; String get content;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'likes_count') int get likesCount;@JsonKey(name: 'avatar_url') String get avatarUrl;@JsonKey(name: 'is_liked') bool get isLiked;@JsonKey(name: 'reply_count') int get replyCount;@JsonKey(name: 'is_from_author') bool get isFromAuthor;@JsonKey(name: 'is_verified') bool get isVerified;
/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommentCopyWith<Comment> get copyWith => _$CommentCopyWithImpl<Comment>(this as Comment, _$identity);

  /// Serializes this Comment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Comment&&(identical(other.id, id) || other.id == id)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.content, content) || other.content == content)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isLiked, isLiked) || other.isLiked == isLiked)&&(identical(other.replyCount, replyCount) || other.replyCount == replyCount)&&(identical(other.isFromAuthor, isFromAuthor) || other.isFromAuthor == isFromAuthor)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,postId,userId,username,content,createdAt,likesCount,avatarUrl,isLiked,replyCount,isFromAuthor,isVerified);

@override
String toString() {
  return 'Comment(id: $id, postId: $postId, userId: $userId, username: $username, content: $content, createdAt: $createdAt, likesCount: $likesCount, avatarUrl: $avatarUrl, isLiked: $isLiked, replyCount: $replyCount, isFromAuthor: $isFromAuthor, isVerified: $isVerified)';
}


}

/// @nodoc
abstract mixin class $CommentCopyWith<$Res>  {
  factory $CommentCopyWith(Comment value, $Res Function(Comment) _then) = _$CommentCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'post_id') String postId,@JsonKey(name: 'user_id') String userId, String username, String content,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'likes_count') int likesCount,@JsonKey(name: 'avatar_url') String avatarUrl,@JsonKey(name: 'is_liked') bool isLiked,@JsonKey(name: 'reply_count') int replyCount,@JsonKey(name: 'is_from_author') bool isFromAuthor,@JsonKey(name: 'is_verified') bool isVerified
});




}
/// @nodoc
class _$CommentCopyWithImpl<$Res>
    implements $CommentCopyWith<$Res> {
  _$CommentCopyWithImpl(this._self, this._then);

  final Comment _self;
  final $Res Function(Comment) _then;

/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? postId = null,Object? userId = null,Object? username = null,Object? content = null,Object? createdAt = null,Object? likesCount = null,Object? avatarUrl = null,Object? isLiked = null,Object? replyCount = null,Object? isFromAuthor = null,Object? isVerified = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,isLiked: null == isLiked ? _self.isLiked : isLiked // ignore: cast_nullable_to_non_nullable
as bool,replyCount: null == replyCount ? _self.replyCount : replyCount // ignore: cast_nullable_to_non_nullable
as int,isFromAuthor: null == isFromAuthor ? _self.isFromAuthor : isFromAuthor // ignore: cast_nullable_to_non_nullable
as bool,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Comment].
extension CommentPatterns on Comment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Comment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Comment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Comment value)  $default,){
final _that = this;
switch (_that) {
case _Comment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Comment value)?  $default,){
final _that = this;
switch (_that) {
case _Comment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'post_id')  String postId, @JsonKey(name: 'user_id')  String userId,  String username,  String content, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'likes_count')  int likesCount, @JsonKey(name: 'avatar_url')  String avatarUrl, @JsonKey(name: 'is_liked')  bool isLiked, @JsonKey(name: 'reply_count')  int replyCount, @JsonKey(name: 'is_from_author')  bool isFromAuthor, @JsonKey(name: 'is_verified')  bool isVerified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Comment() when $default != null:
return $default(_that.id,_that.postId,_that.userId,_that.username,_that.content,_that.createdAt,_that.likesCount,_that.avatarUrl,_that.isLiked,_that.replyCount,_that.isFromAuthor,_that.isVerified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'post_id')  String postId, @JsonKey(name: 'user_id')  String userId,  String username,  String content, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'likes_count')  int likesCount, @JsonKey(name: 'avatar_url')  String avatarUrl, @JsonKey(name: 'is_liked')  bool isLiked, @JsonKey(name: 'reply_count')  int replyCount, @JsonKey(name: 'is_from_author')  bool isFromAuthor, @JsonKey(name: 'is_verified')  bool isVerified)  $default,) {final _that = this;
switch (_that) {
case _Comment():
return $default(_that.id,_that.postId,_that.userId,_that.username,_that.content,_that.createdAt,_that.likesCount,_that.avatarUrl,_that.isLiked,_that.replyCount,_that.isFromAuthor,_that.isVerified);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'post_id')  String postId, @JsonKey(name: 'user_id')  String userId,  String username,  String content, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'likes_count')  int likesCount, @JsonKey(name: 'avatar_url')  String avatarUrl, @JsonKey(name: 'is_liked')  bool isLiked, @JsonKey(name: 'reply_count')  int replyCount, @JsonKey(name: 'is_from_author')  bool isFromAuthor, @JsonKey(name: 'is_verified')  bool isVerified)?  $default,) {final _that = this;
switch (_that) {
case _Comment() when $default != null:
return $default(_that.id,_that.postId,_that.userId,_that.username,_that.content,_that.createdAt,_that.likesCount,_that.avatarUrl,_that.isLiked,_that.replyCount,_that.isFromAuthor,_that.isVerified);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Comment implements Comment {
  const _Comment({required this.id, @JsonKey(name: 'post_id') required this.postId, @JsonKey(name: 'user_id') required this.userId, required this.username, required this.content, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'likes_count') this.likesCount = 0, @JsonKey(name: 'avatar_url') this.avatarUrl = '', @JsonKey(name: 'is_liked') this.isLiked = false, @JsonKey(name: 'reply_count') this.replyCount = 0, @JsonKey(name: 'is_from_author') this.isFromAuthor = false, @JsonKey(name: 'is_verified') this.isVerified = false});
  factory _Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);

@override final  String id;
@override@JsonKey(name: 'post_id') final  String postId;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  String username;
@override final  String content;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'likes_count') final  int likesCount;
@override@JsonKey(name: 'avatar_url') final  String avatarUrl;
@override@JsonKey(name: 'is_liked') final  bool isLiked;
@override@JsonKey(name: 'reply_count') final  int replyCount;
@override@JsonKey(name: 'is_from_author') final  bool isFromAuthor;
@override@JsonKey(name: 'is_verified') final  bool isVerified;

/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommentCopyWith<_Comment> get copyWith => __$CommentCopyWithImpl<_Comment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Comment&&(identical(other.id, id) || other.id == id)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.content, content) || other.content == content)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isLiked, isLiked) || other.isLiked == isLiked)&&(identical(other.replyCount, replyCount) || other.replyCount == replyCount)&&(identical(other.isFromAuthor, isFromAuthor) || other.isFromAuthor == isFromAuthor)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,postId,userId,username,content,createdAt,likesCount,avatarUrl,isLiked,replyCount,isFromAuthor,isVerified);

@override
String toString() {
  return 'Comment(id: $id, postId: $postId, userId: $userId, username: $username, content: $content, createdAt: $createdAt, likesCount: $likesCount, avatarUrl: $avatarUrl, isLiked: $isLiked, replyCount: $replyCount, isFromAuthor: $isFromAuthor, isVerified: $isVerified)';
}


}

/// @nodoc
abstract mixin class _$CommentCopyWith<$Res> implements $CommentCopyWith<$Res> {
  factory _$CommentCopyWith(_Comment value, $Res Function(_Comment) _then) = __$CommentCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'post_id') String postId,@JsonKey(name: 'user_id') String userId, String username, String content,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'likes_count') int likesCount,@JsonKey(name: 'avatar_url') String avatarUrl,@JsonKey(name: 'is_liked') bool isLiked,@JsonKey(name: 'reply_count') int replyCount,@JsonKey(name: 'is_from_author') bool isFromAuthor,@JsonKey(name: 'is_verified') bool isVerified
});




}
/// @nodoc
class __$CommentCopyWithImpl<$Res>
    implements _$CommentCopyWith<$Res> {
  __$CommentCopyWithImpl(this._self, this._then);

  final _Comment _self;
  final $Res Function(_Comment) _then;

/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? postId = null,Object? userId = null,Object? username = null,Object? content = null,Object? createdAt = null,Object? likesCount = null,Object? avatarUrl = null,Object? isLiked = null,Object? replyCount = null,Object? isFromAuthor = null,Object? isVerified = null,}) {
  return _then(_Comment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,isLiked: null == isLiked ? _self.isLiked : isLiked // ignore: cast_nullable_to_non_nullable
as bool,replyCount: null == replyCount ? _self.replyCount : replyCount // ignore: cast_nullable_to_non_nullable
as int,isFromAuthor: null == isFromAuthor ? _self.isFromAuthor : isFromAuthor // ignore: cast_nullable_to_non_nullable
as bool,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
