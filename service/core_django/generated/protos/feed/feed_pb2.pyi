from common import common_pb2 as _common_pb2
from auth import auth_pb2 as _auth_pb2
from post import post_pb2 as _post_pb2
from google.protobuf.internal import containers as _containers
from google.protobuf import descriptor as _descriptor
from google.protobuf import message as _message
from collections.abc import Iterable as _Iterable, Mapping as _Mapping
from typing import ClassVar as _ClassVar, Optional as _Optional, Union as _Union

DESCRIPTOR: _descriptor.FileDescriptor

class FeedItem(_message.Message):
    __slots__ = ("id", "author", "post_type", "content", "media_urls", "like_count", "comment_count", "repost_count", "bookmark_count", "is_liked", "is_bookmarked", "is_reposted", "created_at")
    ID_FIELD_NUMBER: _ClassVar[int]
    AUTHOR_FIELD_NUMBER: _ClassVar[int]
    POST_TYPE_FIELD_NUMBER: _ClassVar[int]
    CONTENT_FIELD_NUMBER: _ClassVar[int]
    MEDIA_URLS_FIELD_NUMBER: _ClassVar[int]
    LIKE_COUNT_FIELD_NUMBER: _ClassVar[int]
    COMMENT_COUNT_FIELD_NUMBER: _ClassVar[int]
    REPOST_COUNT_FIELD_NUMBER: _ClassVar[int]
    BOOKMARK_COUNT_FIELD_NUMBER: _ClassVar[int]
    IS_LIKED_FIELD_NUMBER: _ClassVar[int]
    IS_BOOKMARKED_FIELD_NUMBER: _ClassVar[int]
    IS_REPOSTED_FIELD_NUMBER: _ClassVar[int]
    CREATED_AT_FIELD_NUMBER: _ClassVar[int]
    id: str
    author: _auth_pb2.User
    post_type: _post_pb2.PostType
    content: str
    media_urls: _containers.RepeatedScalarFieldContainer[str]
    like_count: int
    comment_count: int
    repost_count: int
    bookmark_count: int
    is_liked: bool
    is_bookmarked: bool
    is_reposted: bool
    created_at: _common_pb2.Timestamp
    def __init__(self, id: _Optional[str] = ..., author: _Optional[_Union[_auth_pb2.User, _Mapping]] = ..., post_type: _Optional[_Union[_post_pb2.PostType, str]] = ..., content: _Optional[str] = ..., media_urls: _Optional[_Iterable[str]] = ..., like_count: _Optional[int] = ..., comment_count: _Optional[int] = ..., repost_count: _Optional[int] = ..., bookmark_count: _Optional[int] = ..., is_liked: bool = ..., is_bookmarked: bool = ..., is_reposted: bool = ..., created_at: _Optional[_Union[_common_pb2.Timestamp, _Mapping]] = ...) -> None: ...

class Comment(_message.Message):
    __slots__ = ("id", "author", "post_id", "parent_id", "content", "reply_count", "created_at")
    ID_FIELD_NUMBER: _ClassVar[int]
    AUTHOR_FIELD_NUMBER: _ClassVar[int]
    POST_ID_FIELD_NUMBER: _ClassVar[int]
    PARENT_ID_FIELD_NUMBER: _ClassVar[int]
    CONTENT_FIELD_NUMBER: _ClassVar[int]
    REPLY_COUNT_FIELD_NUMBER: _ClassVar[int]
    CREATED_AT_FIELD_NUMBER: _ClassVar[int]
    id: str
    author: _auth_pb2.User
    post_id: str
    parent_id: str
    content: str
    reply_count: int
    created_at: _common_pb2.Timestamp
    def __init__(self, id: _Optional[str] = ..., author: _Optional[_Union[_auth_pb2.User, _Mapping]] = ..., post_id: _Optional[str] = ..., parent_id: _Optional[str] = ..., content: _Optional[str] = ..., reply_count: _Optional[int] = ..., created_at: _Optional[_Union[_common_pb2.Timestamp, _Mapping]] = ...) -> None: ...

class GetFeedRequest(_message.Message):
    __slots__ = ("user_id", "pagination")
    USER_ID_FIELD_NUMBER: _ClassVar[int]
    PAGINATION_FIELD_NUMBER: _ClassVar[int]
    user_id: str
    pagination: _common_pb2.Pagination
    def __init__(self, user_id: _Optional[str] = ..., pagination: _Optional[_Union[_common_pb2.Pagination, _Mapping]] = ...) -> None: ...

class FeedResponse(_message.Message):
    __slots__ = ("items", "pagination")
    ITEMS_FIELD_NUMBER: _ClassVar[int]
    PAGINATION_FIELD_NUMBER: _ClassVar[int]
    items: _containers.RepeatedCompositeFieldContainer[FeedItem]
    pagination: _common_pb2.Pagination
    def __init__(self, items: _Optional[_Iterable[_Union[FeedItem, _Mapping]]] = ..., pagination: _Optional[_Union[_common_pb2.Pagination, _Mapping]] = ...) -> None: ...

class LikeRequest(_message.Message):
    __slots__ = ("user_id", "post_id")
    USER_ID_FIELD_NUMBER: _ClassVar[int]
    POST_ID_FIELD_NUMBER: _ClassVar[int]
    user_id: str
    post_id: str
    def __init__(self, user_id: _Optional[str] = ..., post_id: _Optional[str] = ...) -> None: ...

class LikeResponse(_message.Message):
    __slots__ = ("like_count",)
    LIKE_COUNT_FIELD_NUMBER: _ClassVar[int]
    like_count: int
    def __init__(self, like_count: _Optional[int] = ...) -> None: ...

class RepostRequest(_message.Message):
    __slots__ = ("user_id", "post_id", "quote")
    USER_ID_FIELD_NUMBER: _ClassVar[int]
    POST_ID_FIELD_NUMBER: _ClassVar[int]
    QUOTE_FIELD_NUMBER: _ClassVar[int]
    user_id: str
    post_id: str
    quote: str
    def __init__(self, user_id: _Optional[str] = ..., post_id: _Optional[str] = ..., quote: _Optional[str] = ...) -> None: ...

class RepostResponse(_message.Message):
    __slots__ = ("repost_id", "repost_count")
    REPOST_ID_FIELD_NUMBER: _ClassVar[int]
    REPOST_COUNT_FIELD_NUMBER: _ClassVar[int]
    repost_id: str
    repost_count: int
    def __init__(self, repost_id: _Optional[str] = ..., repost_count: _Optional[int] = ...) -> None: ...

class AddCommentRequest(_message.Message):
    __slots__ = ("user_id", "post_id", "parent_id", "content")
    USER_ID_FIELD_NUMBER: _ClassVar[int]
    POST_ID_FIELD_NUMBER: _ClassVar[int]
    PARENT_ID_FIELD_NUMBER: _ClassVar[int]
    CONTENT_FIELD_NUMBER: _ClassVar[int]
    user_id: str
    post_id: str
    parent_id: str
    content: str
    def __init__(self, user_id: _Optional[str] = ..., post_id: _Optional[str] = ..., parent_id: _Optional[str] = ..., content: _Optional[str] = ...) -> None: ...

class DeleteCommentRequest(_message.Message):
    __slots__ = ("comment_id", "user_id")
    COMMENT_ID_FIELD_NUMBER: _ClassVar[int]
    USER_ID_FIELD_NUMBER: _ClassVar[int]
    comment_id: str
    user_id: str
    def __init__(self, comment_id: _Optional[str] = ..., user_id: _Optional[str] = ...) -> None: ...

class GetCommentsRequest(_message.Message):
    __slots__ = ("post_id", "parent_id", "pagination")
    POST_ID_FIELD_NUMBER: _ClassVar[int]
    PARENT_ID_FIELD_NUMBER: _ClassVar[int]
    PAGINATION_FIELD_NUMBER: _ClassVar[int]
    post_id: str
    parent_id: str
    pagination: _common_pb2.Pagination
    def __init__(self, post_id: _Optional[str] = ..., parent_id: _Optional[str] = ..., pagination: _Optional[_Union[_common_pb2.Pagination, _Mapping]] = ...) -> None: ...

class CommentsResponse(_message.Message):
    __slots__ = ("comments", "pagination")
    COMMENTS_FIELD_NUMBER: _ClassVar[int]
    PAGINATION_FIELD_NUMBER: _ClassVar[int]
    comments: _containers.RepeatedCompositeFieldContainer[Comment]
    pagination: _common_pb2.Pagination
    def __init__(self, comments: _Optional[_Iterable[_Union[Comment, _Mapping]]] = ..., pagination: _Optional[_Union[_common_pb2.Pagination, _Mapping]] = ...) -> None: ...

class BookmarkRequest(_message.Message):
    __slots__ = ("user_id", "post_id")
    USER_ID_FIELD_NUMBER: _ClassVar[int]
    POST_ID_FIELD_NUMBER: _ClassVar[int]
    user_id: str
    post_id: str
    def __init__(self, user_id: _Optional[str] = ..., post_id: _Optional[str] = ...) -> None: ...

class GetBookmarksRequest(_message.Message):
    __slots__ = ("user_id", "pagination")
    USER_ID_FIELD_NUMBER: _ClassVar[int]
    PAGINATION_FIELD_NUMBER: _ClassVar[int]
    user_id: str
    pagination: _common_pb2.Pagination
    def __init__(self, user_id: _Optional[str] = ..., pagination: _Optional[_Union[_common_pb2.Pagination, _Mapping]] = ...) -> None: ...
