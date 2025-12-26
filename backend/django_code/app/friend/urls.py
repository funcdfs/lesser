from django.urls import path, include
from rest_framework.routers import DefaultRouter
from friend import views

# 创建路由器并注册视图集
router = DefaultRouter()
# router.register(r'friends', views.FriendViewSet)
# router.register(r'friend-requests', views.FriendRequestViewSet)
# router.register(r'friend-suggestions', views.FriendSuggestionViewSet)
# router.register(r'nearby-people', views.NearbyPersonViewSet)
# router.register(r'mutual-friends', views.MutualFriendViewSet)
# router.register(r'social-stats', views.SocialStatsViewSet)

urlpatterns = [
    path('', include(router.urls)),
    # 添加额外的自定义URL
    # path('user/friends/', views.UserFriendsView.as_view(), name='user-friends'),
    # path('user/friend-requests/sent/', views.UserSentFriendRequestsView.as_view(), name='user-sent-friend-requests'),
    # path('user/friend-requests/received/', views.UserReceivedFriendRequestsView.as_view(), name='user-received-friend-requests'),
    # path('user/friend-suggestions/', views.UserFriendSuggestionsView.as_view(), name='user-friend-suggestions'),
    # path('user/nearby-people/', views.UserNearbyPeopleView.as_view(), name='user-nearby-people'),
    # path('users/<int:user_id>/mutual-friends/', views.MutualFriendsWithUserView.as_view(), name='mutual-friends-with-user'),
    # path('friend-requests/<int:request_id>/accept/', views.AcceptFriendRequestView.as_view(), name='accept-friend-request'),
    # path('friend-requests/<int:request_id>/reject/', views.RejectFriendRequestView.as_view(), name='reject-friend-request'),
    # path('friends/<int:friend_id>/block/', views.BlockFriendView.as_view(), name='block-friend'),
    # path('friends/<int:friend_id>/unblock/', views.UnblockFriendView.as_view(), name='unblock-friend'),
]