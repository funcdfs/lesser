"""
Search URL configuration.
"""
from django.urls import path

from .views import SearchAllView, SearchPostsView, SearchUsersView, TrendingView

urlpatterns = [
    path('', SearchAllView.as_view(), name='search_all'),
    path('posts/', SearchPostsView.as_view(), name='search_posts'),
    path('users/', SearchUsersView.as_view(), name='search_users'),
    path('trending/', TrendingView.as_view(), name='trending'),
]
