from django.urls import path, include
from rest_framework.routers import DefaultRouter
from chat import views

# 创建路由器并注册视图集
router = DefaultRouter()
router.register(r'chats', views.ChatViewSet)
router.register(r'messages', views.MessageViewSet)
router.register(r'members', views.ChatMemberViewSet)
router.register(r'private-chats', views.PrivateChatViewSet)
router.register(r'group-chats', views.GroupChatViewSet)
router.register(r'channels', views.ChannelViewSet)

urlpatterns = [
    path('', include(router.urls)),
    # 添加额外的自定义URL
    path('chats/<int:chat_id>/messages/', views.ChatMessagesView.as_view(), name='chat-messages'),
    path('chats/<int:chat_id>/members/', views.ChatMembersView.as_view(), name='chat-members'),
    path('user/chats/', views.UserChatsView.as_view(), name='user-chats'),
]