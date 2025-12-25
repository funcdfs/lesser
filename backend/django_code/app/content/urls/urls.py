from django.urls import path, include
from rest_framework.routers import DefaultRouter
from content.views import (
    ReelViewSet, PostViewSet, ArticleViewSet, DraftViewSet, StoryViewSet, ColumnViewSet,
    ContentCommentViewSet, ContentLikeViewSet, ContentBookmarkViewSet, ContentRepostViewSet
)

router = DefaultRouter()
router.register(r'reels', ReelViewSet, basename='reel')
router.register(r'posts', PostViewSet, basename='post')
router.register(r'articles', ArticleViewSet, basename='article')
router.register(r'drafts', DraftViewSet, basename='draft')
router.register(r'stories', StoryViewSet, basename='story')
router.register(r'columns', ColumnViewSet, basename='column')
router.register(r'comments', ContentCommentViewSet, basename='comment')
router.register(r'likes', ContentLikeViewSet, basename='like')
router.register(r'bookmarks', ContentBookmarkViewSet, basename='bookmark')
router.register(r'reposts', ContentRepostViewSet, basename='repost')

urlpatterns = [
    path('', include(router.urls)),
    # 用户内容路由
    path('user/<int:user_id>/reels/', ReelViewSet.as_view({'get': 'list'}), name='user-reels'),
    path('user/<int:user_id>/posts/', PostViewSet.as_view({'get': 'list'}), name='user-posts'),
    path('user/<int:user_id>/articles/', ArticleViewSet.as_view({'get': 'list'}), name='user-articles'),
    path('user/<int:user_id>/drafts/', DraftViewSet.as_view({'get': 'list'}), name='user-drafts'),
    path('user/<int:user_id>/stories/', StoryViewSet.as_view({'get': 'list'}), name='user-stories'),
    path('user/<int:user_id>/columns/', ColumnViewSet.as_view({'get': 'list'}), name='user-columns'),
    # 专栏文章路由
    path('column/<str:column_title>/articles/', ArticleViewSet.as_view({'get': 'list'}), name='column-articles'),
]