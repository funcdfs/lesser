from common import common_pb2 as _common_pb2
from auth import auth_pb2 as _auth_pb2
from google.protobuf.internal import containers as _containers
from google.protobuf.internal import enum_type_wrapper as _enum_type_wrapper
from google.protobuf import descriptor as _descriptor
from google.protobuf import message as _message
from collections.abc import Iterable as _Iterable, Mapping as _Mapping
from typing import ClassVar as _ClassVar, Optional as _Optional, Union as _Union

DESCRIPTOR: _descriptor.FileDescriptor

class PostType(int, metaclass=_enum_type_wrapper.EnumTypeWrapper):
    __slots__ = ()
    SHORT: _ClassVar[PostType]
    STORY: _ClassVar[PostType]
    COLUMN: _ClassVar[PostType]
SHORT: PostType
STORY: PostType
COLUMN: PostType

class Post(_message.Message):
    __slots__ = ("id", "author", "post_type", "content", "media_urls", "expires_at", "like_count", "comment_count", "repost_count", "bookmark_count", "created_at", "updated_at")
    ID_FIELD_NUMBER: _ClassVar[int]
    AUTHOR_FIELD_NUMBER: _ClassVar[int]
    POST_TYPE_FIELD_NUMBER: _ClassVar[int]
    CONTENT_FIELD_NUMBER: _ClassVar[int]
    MEDIA_URLS_FIELD_NUMBER: _ClassVar[int]
    EXPIRES_AT_FIELD_NUMBER: _ClassVar[int]
    LIKE_COUNT_FIELD_NUMBER: _ClassVar[int]
    COMMENT_COUNT_FIELD_NUMBER: _ClassVar[int]
    REPOST_COUNT_FIELD_NUMBER: _ClassVar[int]
    BOOKMARK_COUNT_FIELD_NUMBER: _ClassVar[int]
    CREATED_AT_FIELD_NUMBER: _ClassVar[int]
    UPDATED_AT_FIELD_NUMBER: _ClassVar[int]
    id: str
    author: _auth_pb2.User
    post_type: PostType
    content: str
    media_urls: _containers.RepeatedScalarFieldContainer[str]
    expires_at: _common_pb2.Timestamp
    like_count: int
    comment_count: int
    repost_count: int
    bookmark_count: int
    created_at: _common_pb2.Timestamp
    updated_at: _common_pb2.Timestamp
    def __init__(self, id: _Optional[str] = ..., author: _Optional[_Union[_auth_pb2.User, _Mapping]] = ..., post_type: _Optional[_Union[PostType, str]] = ..., content: _Optional[str] = ..., media_urls: _Optional[_Iterable[str]] = ..., expires_at: _Optional[_Union[_common_pb2.Timestamp, _Mapping]] = ..., like_count: _Optional[int] = ..., comment_count: _Optional[int] = ..., repost_count: _Optional[int] = ..., bookmark_count: _Optional[int] = ..., created_at: _Optional[_Union[_common_pb2.Timestamp, _Mapping]] = ..., updated_at: _Optional[_Union[_common_pb2.Timestamp, _Mapping]] = ...) -> None: ...

class CreatePostRequest(_message.Message):
    __slots__ = ("author_id", "post_type", "content", "media_urls")
    AUTHOR_ID_FIELD_NUMBER: _ClassVar[int]
    POST_TYPE_FIELD_NUMBER: _ClassVar[int]
    CONTENT_FIELD_NUMBER: _ClassVar[int]
    MEDIA_URLS_FIELD_NUMBER: _ClassVar[int]
    author_id: str
    post_type: PostType
    content: str
    media_urls: _containers.RepeatedScalarFieldContainer[str]
    def __init__(self, author_id: _Optional[str] = ..., post_type: _Optional[_Union[PostType, str]] = ..., content: _Optional[str] = ..., media_urls: _Optional[_Iterable[str]] = ...) -> None: ...

class GetPostRequest(_message.Message):
    __slots__ = ("post_id",)
    POST_ID_FIELD_NUMBER: _ClassVar[int]
    post_id: str
    def __init__(self, post_id: _Optional[str] = ...) -> None: ...

class UpdatePostRequest(_message.Message):
    __slots__ = ("post_id", "author_id", "content", "media_urls")
    POST_ID_FIELD_NUMBER: _ClassVar[int]
    AUTHOR_ID_FIELD_NUMBER: _ClassVar[int]
    CONTENT_FIELD_NUMBER: _ClassVar[int]
    MEDIA_URLS_FIELD_NUMBER: _ClassVar[int]
    post_id: str
    author_id: str
    content: str
    media_urls: _containers.RepeatedScalarFieldContainer[str]
    def __init__(self, post_id: _Optional[str] = ..., author_id: _Optional[str] = ..., content: _Optional[str] = ..., media_urls: _Optional[_Iterable[str]] = ...) -> None: ...

class DeletePostRequest(_message.Message):
    __slots__ = ("post_id", "author_id")
    POST_ID_FIELD_NUMBER: _ClassVar[int]
    AUTHOR_ID_FIELD_NUMBER: _ClassVar[int]
    post_id: str
    author_id: str
    def __init__(self, post_id: _Optional[str] = ..., author_id: _Optional[str] = ...) -> None: ...

class GetUserPostsRequest(_message.Message):
    __slots__ = ("user_id", "post_type", "pagination")
    USER_ID_FIELD_NUMBER: _ClassVar[int]
    POST_TYPE_FIELD_NUMBER: _ClassVar[int]
    PAGINATION_FIELD_NUMBER: _ClassVar[int]
    user_id: str
    post_type: PostType
    pagination: _common_pb2.Pagination
    def __init__(self, user_id: _Optional[str] = ..., post_type: _Optional[_Union[PostType, str]] = ..., pagination: _Optional[_Union[_common_pb2.Pagination, _Mapping]] = ...) -> None: ...

class GetPostsByTypeRequest(_message.Message):
    __slots__ = ("post_type", "pagination")
    POST_TYPE_FIELD_NUMBER: _ClassVar[int]
    PAGINATION_FIELD_NUMBER: _ClassVar[int]
    post_type: PostType
    pagination: _common_pb2.Pagination
    def __init__(self, post_type: _Optional[_Union[PostType, str]] = ..., pagination: _Optional[_Union[_common_pb2.Pagination, _Mapping]] = ...) -> None: ...

class PostsResponse(_message.Message):
    __slots__ = ("posts", "pagination")
    POSTS_FIELD_NUMBER: _ClassVar[int]
    PAGINATION_FIELD_NUMBER: _ClassVar[int]
    posts: _containers.RepeatedCompositeFieldContainer[Post]
    pagination: _common_pb2.Pagination
    def __init__(self, posts: _Optional[_Iterable[_Union[Post, _Mapping]]] = ..., pagination: _Optional[_Union[_common_pb2.Pagination, _Mapping]] = ...) -> None: ...
