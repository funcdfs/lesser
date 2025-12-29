from common import common_pb2 as _common_pb2
from google.protobuf.internal import containers as _containers
from google.protobuf.internal import enum_type_wrapper as _enum_type_wrapper
from google.protobuf import descriptor as _descriptor
from google.protobuf import message as _message
from collections.abc import Iterable as _Iterable, Mapping as _Mapping
from typing import ClassVar as _ClassVar, Optional as _Optional, Union as _Union

DESCRIPTOR: _descriptor.FileDescriptor

class ConversationType(int, metaclass=_enum_type_wrapper.EnumTypeWrapper):
    __slots__ = ()
    PRIVATE: _ClassVar[ConversationType]
    GROUP: _ClassVar[ConversationType]
    CHANNEL: _ClassVar[ConversationType]
PRIVATE: ConversationType
GROUP: ConversationType
CHANNEL: ConversationType

class Conversation(_message.Message):
    __slots__ = ("id", "type", "name", "member_ids", "creator_id", "created_at", "last_message")
    ID_FIELD_NUMBER: _ClassVar[int]
    TYPE_FIELD_NUMBER: _ClassVar[int]
    NAME_FIELD_NUMBER: _ClassVar[int]
    MEMBER_IDS_FIELD_NUMBER: _ClassVar[int]
    CREATOR_ID_FIELD_NUMBER: _ClassVar[int]
    CREATED_AT_FIELD_NUMBER: _ClassVar[int]
    LAST_MESSAGE_FIELD_NUMBER: _ClassVar[int]
    id: str
    type: ConversationType
    name: str
    member_ids: _containers.RepeatedScalarFieldContainer[str]
    creator_id: str
    created_at: _common_pb2.Timestamp
    last_message: Message
    def __init__(self, id: _Optional[str] = ..., type: _Optional[_Union[ConversationType, str]] = ..., name: _Optional[str] = ..., member_ids: _Optional[_Iterable[str]] = ..., creator_id: _Optional[str] = ..., created_at: _Optional[_Union[_common_pb2.Timestamp, _Mapping]] = ..., last_message: _Optional[_Union[Message, _Mapping]] = ...) -> None: ...

class Message(_message.Message):
    __slots__ = ("id", "conversation_id", "sender_id", "content", "message_type", "created_at", "read_at")
    ID_FIELD_NUMBER: _ClassVar[int]
    CONVERSATION_ID_FIELD_NUMBER: _ClassVar[int]
    SENDER_ID_FIELD_NUMBER: _ClassVar[int]
    CONTENT_FIELD_NUMBER: _ClassVar[int]
    MESSAGE_TYPE_FIELD_NUMBER: _ClassVar[int]
    CREATED_AT_FIELD_NUMBER: _ClassVar[int]
    READ_AT_FIELD_NUMBER: _ClassVar[int]
    id: str
    conversation_id: str
    sender_id: str
    content: str
    message_type: str
    created_at: _common_pb2.Timestamp
    read_at: _common_pb2.Timestamp
    def __init__(self, id: _Optional[str] = ..., conversation_id: _Optional[str] = ..., sender_id: _Optional[str] = ..., content: _Optional[str] = ..., message_type: _Optional[str] = ..., created_at: _Optional[_Union[_common_pb2.Timestamp, _Mapping]] = ..., read_at: _Optional[_Union[_common_pb2.Timestamp, _Mapping]] = ...) -> None: ...

class ReadReceipt(_message.Message):
    __slots__ = ("message_id", "conversation_id", "reader_id", "read_at")
    MESSAGE_ID_FIELD_NUMBER: _ClassVar[int]
    CONVERSATION_ID_FIELD_NUMBER: _ClassVar[int]
    READER_ID_FIELD_NUMBER: _ClassVar[int]
    READ_AT_FIELD_NUMBER: _ClassVar[int]
    message_id: str
    conversation_id: str
    reader_id: str
    read_at: _common_pb2.Timestamp
    def __init__(self, message_id: _Optional[str] = ..., conversation_id: _Optional[str] = ..., reader_id: _Optional[str] = ..., read_at: _Optional[_Union[_common_pb2.Timestamp, _Mapping]] = ...) -> None: ...

class BatchReadReceipt(_message.Message):
    __slots__ = ("conversation_id", "reader_id", "message_ids", "read_at")
    CONVERSATION_ID_FIELD_NUMBER: _ClassVar[int]
    READER_ID_FIELD_NUMBER: _ClassVar[int]
    MESSAGE_IDS_FIELD_NUMBER: _ClassVar[int]
    READ_AT_FIELD_NUMBER: _ClassVar[int]
    conversation_id: str
    reader_id: str
    message_ids: _containers.RepeatedScalarFieldContainer[str]
    read_at: _common_pb2.Timestamp
    def __init__(self, conversation_id: _Optional[str] = ..., reader_id: _Optional[str] = ..., message_ids: _Optional[_Iterable[str]] = ..., read_at: _Optional[_Union[_common_pb2.Timestamp, _Mapping]] = ...) -> None: ...

class GetConversationsRequest(_message.Message):
    __slots__ = ("user_id", "pagination")
    USER_ID_FIELD_NUMBER: _ClassVar[int]
    PAGINATION_FIELD_NUMBER: _ClassVar[int]
    user_id: str
    pagination: _common_pb2.Pagination
    def __init__(self, user_id: _Optional[str] = ..., pagination: _Optional[_Union[_common_pb2.Pagination, _Mapping]] = ...) -> None: ...

class ConversationsResponse(_message.Message):
    __slots__ = ("conversations", "pagination")
    CONVERSATIONS_FIELD_NUMBER: _ClassVar[int]
    PAGINATION_FIELD_NUMBER: _ClassVar[int]
    conversations: _containers.RepeatedCompositeFieldContainer[Conversation]
    pagination: _common_pb2.Pagination
    def __init__(self, conversations: _Optional[_Iterable[_Union[Conversation, _Mapping]]] = ..., pagination: _Optional[_Union[_common_pb2.Pagination, _Mapping]] = ...) -> None: ...

class GetConversationRequest(_message.Message):
    __slots__ = ("conversation_id",)
    CONVERSATION_ID_FIELD_NUMBER: _ClassVar[int]
    conversation_id: str
    def __init__(self, conversation_id: _Optional[str] = ...) -> None: ...

class CreateConversationRequest(_message.Message):
    __slots__ = ("type", "name", "member_ids", "creator_id")
    TYPE_FIELD_NUMBER: _ClassVar[int]
    NAME_FIELD_NUMBER: _ClassVar[int]
    MEMBER_IDS_FIELD_NUMBER: _ClassVar[int]
    CREATOR_ID_FIELD_NUMBER: _ClassVar[int]
    type: ConversationType
    name: str
    member_ids: _containers.RepeatedScalarFieldContainer[str]
    creator_id: str
    def __init__(self, type: _Optional[_Union[ConversationType, str]] = ..., name: _Optional[str] = ..., member_ids: _Optional[_Iterable[str]] = ..., creator_id: _Optional[str] = ...) -> None: ...

class GetMessagesRequest(_message.Message):
    __slots__ = ("conversation_id", "pagination")
    CONVERSATION_ID_FIELD_NUMBER: _ClassVar[int]
    PAGINATION_FIELD_NUMBER: _ClassVar[int]
    conversation_id: str
    pagination: _common_pb2.Pagination
    def __init__(self, conversation_id: _Optional[str] = ..., pagination: _Optional[_Union[_common_pb2.Pagination, _Mapping]] = ...) -> None: ...

class MessagesResponse(_message.Message):
    __slots__ = ("messages", "pagination")
    MESSAGES_FIELD_NUMBER: _ClassVar[int]
    PAGINATION_FIELD_NUMBER: _ClassVar[int]
    messages: _containers.RepeatedCompositeFieldContainer[Message]
    pagination: _common_pb2.Pagination
    def __init__(self, messages: _Optional[_Iterable[_Union[Message, _Mapping]]] = ..., pagination: _Optional[_Union[_common_pb2.Pagination, _Mapping]] = ...) -> None: ...

class SendMessageRequest(_message.Message):
    __slots__ = ("conversation_id", "sender_id", "content", "message_type")
    CONVERSATION_ID_FIELD_NUMBER: _ClassVar[int]
    SENDER_ID_FIELD_NUMBER: _ClassVar[int]
    CONTENT_FIELD_NUMBER: _ClassVar[int]
    MESSAGE_TYPE_FIELD_NUMBER: _ClassVar[int]
    conversation_id: str
    sender_id: str
    content: str
    message_type: str
    def __init__(self, conversation_id: _Optional[str] = ..., sender_id: _Optional[str] = ..., content: _Optional[str] = ..., message_type: _Optional[str] = ...) -> None: ...

class StreamRequest(_message.Message):
    __slots__ = ("user_id",)
    USER_ID_FIELD_NUMBER: _ClassVar[int]
    user_id: str
    def __init__(self, user_id: _Optional[str] = ...) -> None: ...

class MarkAsReadRequest(_message.Message):
    __slots__ = ("message_id", "user_id")
    MESSAGE_ID_FIELD_NUMBER: _ClassVar[int]
    USER_ID_FIELD_NUMBER: _ClassVar[int]
    message_id: str
    user_id: str
    def __init__(self, message_id: _Optional[str] = ..., user_id: _Optional[str] = ...) -> None: ...

class MarkConversationAsReadRequest(_message.Message):
    __slots__ = ("conversation_id", "user_id")
    CONVERSATION_ID_FIELD_NUMBER: _ClassVar[int]
    USER_ID_FIELD_NUMBER: _ClassVar[int]
    conversation_id: str
    user_id: str
    def __init__(self, conversation_id: _Optional[str] = ..., user_id: _Optional[str] = ...) -> None: ...

class GetUnreadCountsRequest(_message.Message):
    __slots__ = ("user_id", "conversation_ids")
    USER_ID_FIELD_NUMBER: _ClassVar[int]
    CONVERSATION_IDS_FIELD_NUMBER: _ClassVar[int]
    user_id: str
    conversation_ids: _containers.RepeatedScalarFieldContainer[str]
    def __init__(self, user_id: _Optional[str] = ..., conversation_ids: _Optional[_Iterable[str]] = ...) -> None: ...

class UnreadCount(_message.Message):
    __slots__ = ("conversation_id", "count")
    CONVERSATION_ID_FIELD_NUMBER: _ClassVar[int]
    COUNT_FIELD_NUMBER: _ClassVar[int]
    conversation_id: str
    count: int
    def __init__(self, conversation_id: _Optional[str] = ..., count: _Optional[int] = ...) -> None: ...

class GetUnreadCountsResponse(_message.Message):
    __slots__ = ("unread_counts",)
    UNREAD_COUNTS_FIELD_NUMBER: _ClassVar[int]
    unread_counts: _containers.RepeatedCompositeFieldContainer[UnreadCount]
    def __init__(self, unread_counts: _Optional[_Iterable[_Union[UnreadCount, _Mapping]]] = ...) -> None: ...

class ReadReceiptNotification(_message.Message):
    __slots__ = ("type", "message_id", "conversation_id", "reader_id", "read_at", "message_ids")
    TYPE_FIELD_NUMBER: _ClassVar[int]
    MESSAGE_ID_FIELD_NUMBER: _ClassVar[int]
    CONVERSATION_ID_FIELD_NUMBER: _ClassVar[int]
    READER_ID_FIELD_NUMBER: _ClassVar[int]
    READ_AT_FIELD_NUMBER: _ClassVar[int]
    MESSAGE_IDS_FIELD_NUMBER: _ClassVar[int]
    type: str
    message_id: str
    conversation_id: str
    reader_id: str
    read_at: _common_pb2.Timestamp
    message_ids: _containers.RepeatedScalarFieldContainer[str]
    def __init__(self, type: _Optional[str] = ..., message_id: _Optional[str] = ..., conversation_id: _Optional[str] = ..., reader_id: _Optional[str] = ..., read_at: _Optional[_Union[_common_pb2.Timestamp, _Mapping]] = ..., message_ids: _Optional[_Iterable[str]] = ...) -> None: ...
