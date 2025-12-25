from rest_framework import serializers
from django.contrib.auth import get_user_model
from chat.models import (
    Chat, ChatType, ChatMember, Message, 
    PrivateChat, GroupChat, Channel
)

User = get_user_model()

# 基础序列化器
class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'avatar']

# 聊天序列化器
class ChatSerializer(serializers.ModelSerializer):
    class Meta:
        model = Chat
        fields = ['id', 'type', 'name', 'description', 'created_at', 'updated_at']

# 聊天成员序列化器
class ChatMemberSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    chat = ChatSerializer(read_only=True)
    
    class Meta:
        model = ChatMember
        fields = ['id', 'chat', 'user', 'joined_at', 'is_admin', 'is_owner', 'last_read_at']

# 消息序列化器
class MessageSerializer(serializers.ModelSerializer):
    sender = UserSerializer(read_only=True)
    chat = ChatSerializer(read_only=True)
    
    class Meta:
        model = Message
        fields = ['id', 'chat', 'sender', 'content', 'image', 'video', 'audio', 
                  'is_read', 'is_deleted', 'created_at', 'updated_at']

# 私聊序列化器
class PrivateChatSerializer(serializers.ModelSerializer):
    chat = ChatSerializer(read_only=True)
    user1 = UserSerializer(read_only=True)
    user2 = UserSerializer(read_only=True)
    
    class Meta:
        model = PrivateChat
        fields = ['id', 'chat', 'user1', 'user2']

# 群聊序列化器
class GroupChatSerializer(serializers.ModelSerializer):
    chat = ChatSerializer(read_only=True)
    
    class Meta:
        model = GroupChat
        fields = ['id', 'chat', 'max_members', 'is_public', 'avatar']

# 频道序列化器
class ChannelSerializer(serializers.ModelSerializer):
    chat = ChatSerializer(read_only=True)
    
    class Meta:
        model = Channel
        fields = ['id', 'chat', 'is_public', 'slug', 'cover_image', 'subscribers_count']