"""
Post URL configuration.
"""
from django.urls import path

from .views import (
    MyPostsView,
    PostDetailView,
    PostListCreateView,
    PostsByTypeView,
    UserPostsView,
)

urlpatterns = [
    path('', PostListCreateView.as_view(), name='post_list_create'),
    path('<uuid:id>/', PostDetailView.as_view(), name='post_detail'),
    path('me/', MyPostsView.as_view(), name='my_posts'),
    path('user/<str:username>/', UserPostsView.as_view(), name='user_posts'),
    path('type/<str:post_type>/', PostsByTypeView.as_view(), name='posts_by_type'),
]
