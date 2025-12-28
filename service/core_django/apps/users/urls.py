"""
User URL configuration.
"""
from django.urls import path

from .views import (
    ChangePasswordView,
    FollowersListView,
    FollowingListView,
    FollowView,
    FriendsListView,
    LoginView,
    LogoutView,
    RegisterView,
    TokenRefreshAPIView,
    UserDetailView,
    UserProfileView,
)

urlpatterns = [
    # Authentication
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
    path('logout/', LogoutView.as_view(), name='logout'),
    path('token/refresh/', TokenRefreshAPIView.as_view(), name='token_refresh'),
    path('password/change/', ChangePasswordView.as_view(), name='change_password'),
    # Profile
    path('me/', UserProfileView.as_view(), name='user_profile'),
    path('friends/', FriendsListView.as_view(), name='friends'),
    path('users/<str:username>/', UserDetailView.as_view(), name='user_detail'),
    # Follow
    path('users/<str:username>/follow/', FollowView.as_view(), name='follow'),
    path('users/<str:username>/followers/', FollowersListView.as_view(), name='followers'),
    path('users/<str:username>/following/', FollowingListView.as_view(), name='following'),
]
