// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MessageSender {

/// 用户 ID
@JsonKey(name: 'user_id') String get userId;/// 用户名
 String get username;/// 用户头像 URL
@JsonKey(name: 'avatar_url') String get avatarUrl;
/// Create a copy of MessageSender
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageSenderCopyWith<MessageSender> get copyWith => _$MessageSenderCopyWithImpl<MessageSender>(this as MessageSender, _$identity);

  /// Serializes this MessageSender to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageSender&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,avatarUrl);

@override
String toString() {
  return 'MessageSender(userId: $userId, username: $username, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class $MessageSenderCopyWith<$Res>  {
  factory $MessageSenderCopyWith(MessageSender value, $Res Function(MessageSender) _then) = _$MessageSenderCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'user_id') String userId, String username,@JsonKey(name: 'avatar_url') String avatarUrl
});




}
/// @nodoc
class _$MessageSenderCopyWithImpl<$Res>
    implements $MessageSenderCopyWith<$Res> {
  _$MessageSenderCopyWithImpl(this._self, this._then);

  final MessageSender _self;
  final $Res Function(MessageSender) _then;

/// Create a copy of MessageSender
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? username = null,Object? avatarUrl = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageSender].
extension MessageSenderPatterns on MessageSender {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageSender value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageSender() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageSender value)  $default,){
final _that = this;
switch (_that) {
case _MessageSender():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageSender value)?  $default,){
final _that = this;
switch (_that) {
case _MessageSender() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId,  String username, @JsonKey(name: 'avatar_url')  String avatarUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageSender() when $default != null:
return $default(_that.userId,_that.username,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId,  String username, @JsonKey(name: 'avatar_url')  String avatarUrl)  $default,) {final _that = this;
switch (_that) {
case _MessageSender():
return $default(_that.userId,_that.username,_that.avatarUrl);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'user_id')  String userId,  String username, @JsonKey(name: 'avatar_url')  String avatarUrl)?  $default,) {final _that = this;
switch (_that) {
case _MessageSender() when $default != null:
return $default(_that.userId,_that.username,_that.avatarUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessageSender implements MessageSender {
  const _MessageSender({@JsonKey(name: 'user_id') required this.userId, required this.username, @JsonKey(name: 'avatar_url') required this.avatarUrl});
  factory _MessageSender.fromJson(Map<String, dynamic> json) => _$MessageSenderFromJson(json);

/// 用户 ID
@override@JsonKey(name: 'user_id') final  String userId;
/// 用户名
@override final  String username;
/// 用户头像 URL
@override@JsonKey(name: 'avatar_url') final  String avatarUrl;

/// Create a copy of MessageSender
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageSenderCopyWith<_MessageSender> get copyWith => __$MessageSenderCopyWithImpl<_MessageSender>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageSenderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageSender&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,avatarUrl);

@override
String toString() {
  return 'MessageSender(userId: $userId, username: $username, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class _$MessageSenderCopyWith<$Res> implements $MessageSenderCopyWith<$Res> {
  factory _$MessageSenderCopyWith(_MessageSender value, $Res Function(_MessageSender) _then) = __$MessageSenderCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'user_id') String userId, String username,@JsonKey(name: 'avatar_url') String avatarUrl
});




}
/// @nodoc
class __$MessageSenderCopyWithImpl<$Res>
    implements _$MessageSenderCopyWith<$Res> {
  __$MessageSenderCopyWithImpl(this._self, this._then);

  final _MessageSender _self;
  final $Res Function(_MessageSender) _then;

/// Create a copy of MessageSender
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? username = null,Object? avatarUrl = null,}) {
  return _then(_MessageSender(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Message {

/// 消息 ID
 String get id;/// 会话 ID
@JsonKey(name: 'conversation_id') String get conversationId;/// 发送者信息
@JsonKey(toJson: _senderToJson, fromJson: _senderFromJson) MessageSender get sender;/// 消息内容
 String get content;/// 消息类型
 MessageType get type;/// 消息状态
 MessageStatus get status;/// 发送时间
@JsonKey(name: 'sent_at') DateTime get sentAt;/// 是否已读
@JsonKey(name: 'is_read') bool get isRead;/// 是否是当前用户发送的
@JsonKey(name: 'is_from_current_user') bool get isFromCurrentUser;
/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageCopyWith<Message> get copyWith => _$MessageCopyWithImpl<Message>(this as Message, _$identity);

  /// Serializes this Message to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Message&&(identical(other.id, id) || other.id == id)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.content, content) || other.content == content)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.isFromCurrentUser, isFromCurrentUser) || other.isFromCurrentUser == isFromCurrentUser));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,conversationId,sender,content,type,status,sentAt,isRead,isFromCurrentUser);

@override
String toString() {
  return 'Message(id: $id, conversationId: $conversationId, sender: $sender, content: $content, type: $type, status: $status, sentAt: $sentAt, isRead: $isRead, isFromCurrentUser: $isFromCurrentUser)';
}


}

/// @nodoc
abstract mixin class $MessageCopyWith<$Res>  {
  factory $MessageCopyWith(Message value, $Res Function(Message) _then) = _$MessageCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'conversation_id') String conversationId,@JsonKey(toJson: _senderToJson, fromJson: _senderFromJson) MessageSender sender, String content, MessageType type, MessageStatus status,@JsonKey(name: 'sent_at') DateTime sentAt,@JsonKey(name: 'is_read') bool isRead,@JsonKey(name: 'is_from_current_user') bool isFromCurrentUser
});


$MessageSenderCopyWith<$Res> get sender;

}
/// @nodoc
class _$MessageCopyWithImpl<$Res>
    implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._self, this._then);

  final Message _self;
  final $Res Function(Message) _then;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? conversationId = null,Object? sender = null,Object? content = null,Object? type = null,Object? status = null,Object? sentAt = null,Object? isRead = null,Object? isFromCurrentUser = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as MessageSender,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MessageType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MessageStatus,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,isFromCurrentUser: null == isFromCurrentUser ? _self.isFromCurrentUser : isFromCurrentUser // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageSenderCopyWith<$Res> get sender {
  
  return $MessageSenderCopyWith<$Res>(_self.sender, (value) {
    return _then(_self.copyWith(sender: value));
  });
}
}


/// Adds pattern-matching-related methods to [Message].
extension MessagePatterns on Message {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Message value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Message() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Message value)  $default,){
final _that = this;
switch (_that) {
case _Message():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Message value)?  $default,){
final _that = this;
switch (_that) {
case _Message() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'conversation_id')  String conversationId, @JsonKey(toJson: _senderToJson, fromJson: _senderFromJson)  MessageSender sender,  String content,  MessageType type,  MessageStatus status, @JsonKey(name: 'sent_at')  DateTime sentAt, @JsonKey(name: 'is_read')  bool isRead, @JsonKey(name: 'is_from_current_user')  bool isFromCurrentUser)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Message() when $default != null:
return $default(_that.id,_that.conversationId,_that.sender,_that.content,_that.type,_that.status,_that.sentAt,_that.isRead,_that.isFromCurrentUser);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'conversation_id')  String conversationId, @JsonKey(toJson: _senderToJson, fromJson: _senderFromJson)  MessageSender sender,  String content,  MessageType type,  MessageStatus status, @JsonKey(name: 'sent_at')  DateTime sentAt, @JsonKey(name: 'is_read')  bool isRead, @JsonKey(name: 'is_from_current_user')  bool isFromCurrentUser)  $default,) {final _that = this;
switch (_that) {
case _Message():
return $default(_that.id,_that.conversationId,_that.sender,_that.content,_that.type,_that.status,_that.sentAt,_that.isRead,_that.isFromCurrentUser);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'conversation_id')  String conversationId, @JsonKey(toJson: _senderToJson, fromJson: _senderFromJson)  MessageSender sender,  String content,  MessageType type,  MessageStatus status, @JsonKey(name: 'sent_at')  DateTime sentAt, @JsonKey(name: 'is_read')  bool isRead, @JsonKey(name: 'is_from_current_user')  bool isFromCurrentUser)?  $default,) {final _that = this;
switch (_that) {
case _Message() when $default != null:
return $default(_that.id,_that.conversationId,_that.sender,_that.content,_that.type,_that.status,_that.sentAt,_that.isRead,_that.isFromCurrentUser);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Message implements Message {
  const _Message({required this.id, @JsonKey(name: 'conversation_id') required this.conversationId, @JsonKey(toJson: _senderToJson, fromJson: _senderFromJson) required this.sender, required this.content, this.type = MessageType.text, this.status = MessageStatus.sent, @JsonKey(name: 'sent_at') required this.sentAt, @JsonKey(name: 'is_read') this.isRead = false, @JsonKey(name: 'is_from_current_user') this.isFromCurrentUser = false});
  factory _Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

/// 消息 ID
@override final  String id;
/// 会话 ID
@override@JsonKey(name: 'conversation_id') final  String conversationId;
/// 发送者信息
@override@JsonKey(toJson: _senderToJson, fromJson: _senderFromJson) final  MessageSender sender;
/// 消息内容
@override final  String content;
/// 消息类型
@override@JsonKey() final  MessageType type;
/// 消息状态
@override@JsonKey() final  MessageStatus status;
/// 发送时间
@override@JsonKey(name: 'sent_at') final  DateTime sentAt;
/// 是否已读
@override@JsonKey(name: 'is_read') final  bool isRead;
/// 是否是当前用户发送的
@override@JsonKey(name: 'is_from_current_user') final  bool isFromCurrentUser;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageCopyWith<_Message> get copyWith => __$MessageCopyWithImpl<_Message>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Message&&(identical(other.id, id) || other.id == id)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.content, content) || other.content == content)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.isFromCurrentUser, isFromCurrentUser) || other.isFromCurrentUser == isFromCurrentUser));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,conversationId,sender,content,type,status,sentAt,isRead,isFromCurrentUser);

@override
String toString() {
  return 'Message(id: $id, conversationId: $conversationId, sender: $sender, content: $content, type: $type, status: $status, sentAt: $sentAt, isRead: $isRead, isFromCurrentUser: $isFromCurrentUser)';
}


}

/// @nodoc
abstract mixin class _$MessageCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$MessageCopyWith(_Message value, $Res Function(_Message) _then) = __$MessageCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'conversation_id') String conversationId,@JsonKey(toJson: _senderToJson, fromJson: _senderFromJson) MessageSender sender, String content, MessageType type, MessageStatus status,@JsonKey(name: 'sent_at') DateTime sentAt,@JsonKey(name: 'is_read') bool isRead,@JsonKey(name: 'is_from_current_user') bool isFromCurrentUser
});


@override $MessageSenderCopyWith<$Res> get sender;

}
/// @nodoc
class __$MessageCopyWithImpl<$Res>
    implements _$MessageCopyWith<$Res> {
  __$MessageCopyWithImpl(this._self, this._then);

  final _Message _self;
  final $Res Function(_Message) _then;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? conversationId = null,Object? sender = null,Object? content = null,Object? type = null,Object? status = null,Object? sentAt = null,Object? isRead = null,Object? isFromCurrentUser = null,}) {
  return _then(_Message(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as MessageSender,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MessageType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MessageStatus,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,isFromCurrentUser: null == isFromCurrentUser ? _self.isFromCurrentUser : isFromCurrentUser // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageSenderCopyWith<$Res> get sender {
  
  return $MessageSenderCopyWith<$Res>(_self.sender, (value) {
    return _then(_self.copyWith(sender: value));
  });
}
}

// dart format on
