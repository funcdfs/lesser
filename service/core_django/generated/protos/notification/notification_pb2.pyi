from common import common_pb2 as _common_pb2
from auth import auth_pb2 as _auth_pb2
from google.protobuf.internal import containers as _containers
from google.protobuf.internal import enum_type_wrapper as _enum_type_wrapper
from google.protobuf import descriptor as _descriptor
from google.protobuf import message as _message
from collections.abc import Iterable as _Iterable, Mapping as _Mapping
from typing import ClassVar as _ClassVar, Optional as _Optional, Union as _Union

DESCRIPTOR: _descriptor.FileDescriptor

class NotificationType(int, metaclass=_enum_type_wrapper.EnumTypeWrapper):
    __slots__ = ()
    LIKE: _ClassVar[NotificationType]
    COMMENT: _ClassVar[NotificationType]
    REPLY: _ClassVar[NotificationType]
    BOOKMARK: _ClassVar[NotificationType]
    MENTION: _ClassVar[NotificationType]
    FOLLOW: _ClassVar[NotificationType]
    REPOST: _ClassVar[NotificationType]
LIKE: NotificationType
COMMENT: NotificationType
REPLY: NotificationType
BOOKMARK: NotificationType
MENTION: NotificationType
FOLLOW: NotificationType
REPOST: NotificationType

class Notification(_message.Message):
    __slots__ = ("id", "user_id", "type", "actor", "target_type", "target_id", "preview_text", "is_read", "created_at")
    ID_FIELD_NUMBER: _ClassVar[int]
    USER_ID_FIELD_NUMBER: _ClassVar[int]
    TYPE_FIELD_NUMBER: _ClassVar[int]
    ACTOR_FIELD_NUMBER: _ClassVar[int]
    TARGET_TYPE_FIELD_NUMBER: _ClassVar[int]
    TARGET_ID_FIELD_NUMBER: _ClassVar[int]
    PREVIEW_TEXT_FIELD_NUMBER: _ClassVar[int]
    IS_READ_FIELD_NUMBER: _ClassVar[int]
    CREATED_AT_FIELD_NUMBER: _ClassVar[int]
    id: str
    user_id: str
    type: NotificationType
    actor: _auth_pb2.User
    target_type: str
    target_id: str
    preview_text: str
    is_read: bool
    created_at: _common_pb2.Timestamp
    def __init__(self, id: _Optional[str] = ..., user_id: _Optional[str] = ..., type: _Optional[_Union[NotificationType, str]] = ..., actor: _Optional[_Union[_auth_pb2.User, _Mapping]] = ..., target_type: _Optional[str] = ..., target_id: _Optional[str] = ..., preview_text: _Optional[str] = ..., is_read: bool = ..., created_at: _Optional[_Union[_common_pb2.Timestamp, _Mapping]] = ...) -> None: ...

class GetNotificationsRequest(_message.Message):
    __slots__ = ("user_id", "type", "unread_only", "pagination")
    USER_ID_FIELD_NUMBER: _ClassVar[int]
    TYPE_FIELD_NUMBER: _ClassVar[int]
    UNREAD_ONLY_FIELD_NUMBER: _ClassVar[int]
    PAGINATION_FIELD_NUMBER: _ClassVar[int]
    user_id: str
    type: NotificationType
    unread_only: bool
    pagination: _common_pb2.Pagination
    def __init__(self, user_id: _Optional[str] = ..., type: _Optional[_Union[NotificationType, str]] = ..., unread_only: bool = ..., pagination: _Optional[_Union[_common_pb2.Pagination, _Mapping]] = ...) -> None: ...

class NotificationsResponse(_message.Message):
    __slots__ = ("notifications", "pagination")
    NOTIFICATIONS_FIELD_NUMBER: _ClassVar[int]
    PAGINATION_FIELD_NUMBER: _ClassVar[int]
    notifications: _containers.RepeatedCompositeFieldContainer[Notification]
    pagination: _common_pb2.Pagination
    def __init__(self, notifications: _Optional[_Iterable[_Union[Notification, _Mapping]]] = ..., pagination: _Optional[_Union[_common_pb2.Pagination, _Mapping]] = ...) -> None: ...

class GetUnreadCountRequest(_message.Message):
    __slots__ = ("user_id",)
    USER_ID_FIELD_NUMBER: _ClassVar[int]
    user_id: str
    def __init__(self, user_id: _Optional[str] = ...) -> None: ...

class UnreadCountResponse(_message.Message):
    __slots__ = ("count", "count_by_type")
    class CountByTypeEntry(_message.Message):
        __slots__ = ("key", "value")
        KEY_FIELD_NUMBER: _ClassVar[int]
        VALUE_FIELD_NUMBER: _ClassVar[int]
        key: str
        value: int
        def __init__(self, key: _Optional[str] = ..., value: _Optional[int] = ...) -> None: ...
    COUNT_FIELD_NUMBER: _ClassVar[int]
    COUNT_BY_TYPE_FIELD_NUMBER: _ClassVar[int]
    count: int
    count_by_type: _containers.ScalarMap[str, int]
    def __init__(self, count: _Optional[int] = ..., count_by_type: _Optional[_Mapping[str, int]] = ...) -> None: ...

class MarkAsReadRequest(_message.Message):
    __slots__ = ("notification_id", "user_id")
    NOTIFICATION_ID_FIELD_NUMBER: _ClassVar[int]
    USER_ID_FIELD_NUMBER: _ClassVar[int]
    notification_id: str
    user_id: str
    def __init__(self, notification_id: _Optional[str] = ..., user_id: _Optional[str] = ...) -> None: ...

class MarkAllAsReadRequest(_message.Message):
    __slots__ = ("user_id", "type")
    USER_ID_FIELD_NUMBER: _ClassVar[int]
    TYPE_FIELD_NUMBER: _ClassVar[int]
    user_id: str
    type: NotificationType
    def __init__(self, user_id: _Optional[str] = ..., type: _Optional[_Union[NotificationType, str]] = ...) -> None: ...

class StreamNotificationsRequest(_message.Message):
    __slots__ = ("user_id",)
    USER_ID_FIELD_NUMBER: _ClassVar[int]
    user_id: str
    def __init__(self, user_id: _Optional[str] = ...) -> None: ...
