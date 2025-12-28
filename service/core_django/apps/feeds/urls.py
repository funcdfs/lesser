"""
Feed URL configuration.
"""
from django.urls import path

from .views import (
    BookmarkListView,
    BookmarkView,
    CommentDetailView,
    CommentListCreateView,
    CommentRepliesView,
    FeedListView,
    LikeView,
    RepostView,
)

urlpatterns = [
    # Feed
    path('', FeedListView.as_view(), name='feed_list'),
    # Likes
    path('posts/<uuid:post_id>/like/', LikeView.as_view(), name='like'),
    # Bookmarks
    path('posts/<uuid:post_id>/bookmark/', BookmarkView.as_view(), name='bookmark'),
    path('bookmarks/', BookmarkListView.as_view(), name='bookmark_list'),
    # Reposts
    path('posts/<uuid:post_id>/repost/', RepostView.as_view(), name='repost'),
    # Comments
    path('posts/<uuid:post_id>/comments/', CommentListCreateView.as_view(), name='comment_list'),
    path('comments/<uuid:id>/', CommentDetailView.as_view(), name='comment_detail'),
    path('comments/<uuid:comment_id>/replies/', CommentRepliesView.as_view(), name='comment_replies'),
]
