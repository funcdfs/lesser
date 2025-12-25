from rest_framework import viewsets, generics, views
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from chat.models import (
    Chat, ChatType, ChatMember, Message, 
    PrivateChat, GroupChat, Channel
)
from chat.serializers import (
    ChatSerializer, ChatMemberSerializer, MessageSerializer,
    PrivateChatSerializer, GroupChatSerializer, ChannelSerializer
)
from django.contrib.auth import get_user_model

User = get_user_model()

# 基础视图集
class ChatViewSet(viewsets.ModelViewSet):
    queryset = Chat.objects.all()
    serializer_class = ChatSerializer
    permission_classes = [IsAuthenticated]

class MessageViewSet(viewsets.ModelViewSet):
    queryset = Message.objects.all()
    serializer_class = MessageSerializer
    permission_classes = [IsAuthenticated]

class ChatMemberViewSet(viewsets.ModelViewSet):
    queryset = ChatMember.objects.all()
    serializer_class = ChatMemberSerializer
    permission_classes = [IsAuthenticated]

class PrivateChatViewSet(viewsets.ModelViewSet):
    queryset = PrivateChat.objects.all()
    serializer_class = PrivateChatSerializer
    permission_classes = [IsAuthenticated]

class GroupChatViewSet(viewsets.ModelViewSet):
    queryset = GroupChat.objects.all()
    serializer_class = GroupChatSerializer
    permission_classes = [IsAuthenticated]

class ChannelViewSet(viewsets.ModelViewSet):
    queryset = Channel.objects.all()
    serializer_class = ChannelSerializer
    permission_classes = [IsAuthenticated]

# 自定义视图
class ChatMessagesView(views.APIView):
    permission_classes = [IsAuthenticated]
    
    def get(self, request, chat_id):
        messages = Message.objects.filter(chat_id=chat_id)
        serializer = MessageSerializer(messages, many=True)
        return Response(serializer.data)

class ChatMembersView(views.APIView):
    permission_classes = [IsAuthenticated]
    
    def get(self, request, chat_id):
        members = ChatMember.objects.filter(chat_id=chat_id)
        serializer = ChatMemberSerializer(members, many=True)
        return Response(serializer.data)

class UserChatsView(views.APIView):
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        # 获取当前用户参与的所有聊天
        user_chats = Chat.objects.filter(members__user=request.user)
        serializer = ChatSerializer(user_chats, many=True)
        return Response(serializer.data)