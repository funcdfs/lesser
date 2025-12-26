// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatUser {

/// 用户 ID
 String get id;/// 用户名
 String get username;/// 用户头像 URL
@JsonKey(name: 'avatar_url') String? get avatarUrl;/// 是否在线
@JsonKey(name: 'is_online') bool get isOnline;/// 最后在线时间
@JsonKey(name: 'last_seen') DateTime? get lastSeen;
/// Create a copy of ChatUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatUserCopyWith<ChatUser> get copyWith => _$ChatUserCopyWithImpl<ChatUser>(this as ChatUser, _$identity);

  /// Serializes this ChatUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatUser&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.lastSeen, lastSeen) || other.lastSeen == lastSeen));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,avatarUrl,isOnline,lastSeen);

@override
String toString() {
  return 'ChatUser(id: $id, username: $username, avatarUrl: $avatarUrl, isOnline: $isOnline, lastSeen: $lastSeen)';
}


}

/// @nodoc
abstract mixin class $ChatUserCopyWith<$Res>  {
  factory $ChatUserCopyWith(ChatUser value, $Res Function(ChatUser) _then) = _$ChatUserCopyWithImpl;
@useResult
$Res call({
 String id, String username,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'is_online') bool isOnline,@JsonKey(name: 'last_seen') DateTime? lastSeen
});




}
/// @nodoc
class _$ChatUserCopyWithImpl<$Res>
    implements $ChatUserCopyWith<$Res> {
  _$ChatUserCopyWithImpl(this._self, this._then);

  final ChatUser _self;
  final $Res Function(ChatUser) _then;

/// Create a copy of ChatUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? avatarUrl = freezed,Object? isOnline = null,Object? lastSeen = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,lastSeen: freezed == lastSeen ? _self.lastSeen : lastSeen // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatUser].
extension ChatUserPatterns on ChatUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatUser value)  $default,){
final _that = this;
switch (_that) {
case _ChatUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatUser value)?  $default,){
final _that = this;
switch (_that) {
case _ChatUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String username, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'is_online')  bool isOnline, @JsonKey(name: 'last_seen')  DateTime? lastSeen)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatUser() when $default != null:
return $default(_that.id,_that.username,_that.avatarUrl,_that.isOnline,_that.lastSeen);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String username, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'is_online')  bool isOnline, @JsonKey(name: 'last_seen')  DateTime? lastSeen)  $default,) {final _that = this;
switch (_that) {
case _ChatUser():
return $default(_that.id,_that.username,_that.avatarUrl,_that.isOnline,_that.lastSeen);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String username, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'is_online')  bool isOnline, @JsonKey(name: 'last_seen')  DateTime? lastSeen)?  $default,) {final _that = this;
switch (_that) {
case _ChatUser() when $default != null:
return $default(_that.id,_that.username,_that.avatarUrl,_that.isOnline,_that.lastSeen);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatUser implements ChatUser {
  const _ChatUser({required this.id, required this.username, @JsonKey(name: 'avatar_url') this.avatarUrl, @JsonKey(name: 'is_online') this.isOnline = false, @JsonKey(name: 'last_seen') this.lastSeen});
  factory _ChatUser.fromJson(Map<String, dynamic> json) => _$ChatUserFromJson(json);

/// 用户 ID
@override final  String id;
/// 用户名
@override final  String username;
/// 用户头像 URL
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;
/// 是否在线
@override@JsonKey(name: 'is_online') final  bool isOnline;
/// 最后在线时间
@override@JsonKey(name: 'last_seen') final  DateTime? lastSeen;

/// Create a copy of ChatUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatUserCopyWith<_ChatUser> get copyWith => __$ChatUserCopyWithImpl<_ChatUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatUser&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.lastSeen, lastSeen) || other.lastSeen == lastSeen));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,avatarUrl,isOnline,lastSeen);

@override
String toString() {
  return 'ChatUser(id: $id, username: $username, avatarUrl: $avatarUrl, isOnline: $isOnline, lastSeen: $lastSeen)';
}


}

/// @nodoc
abstract mixin class _$ChatUserCopyWith<$Res> implements $ChatUserCopyWith<$Res> {
  factory _$ChatUserCopyWith(_ChatUser value, $Res Function(_ChatUser) _then) = __$ChatUserCopyWithImpl;
@override @useResult
$Res call({
 String id, String username,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'is_online') bool isOnline,@JsonKey(name: 'last_seen') DateTime? lastSeen
});




}
/// @nodoc
class __$ChatUserCopyWithImpl<$Res>
    implements _$ChatUserCopyWith<$Res> {
  __$ChatUserCopyWithImpl(this._self, this._then);

  final _ChatUser _self;
  final $Res Function(_ChatUser) _then;

/// Create a copy of ChatUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? avatarUrl = freezed,Object? isOnline = null,Object? lastSeen = freezed,}) {
  return _then(_ChatUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,lastSeen: freezed == lastSeen ? _self.lastSeen : lastSeen // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
