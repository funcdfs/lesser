from django.db import models
from django.conf import settings

# 聊天类型枚举
class ChatType(models.TextChoices):
    PRIVATE = 'private', '私聊'
    GROUP = 'group', '群聊'
    CHANNEL = 'channel', '频道'

# 聊天基础模型
class Chat(models.Model):
    type = models.CharField(max_length=20, choices=ChatType.choices)
    name = models.CharField(max_length=100, blank=True, null=True)  # 群聊和频道的名称
    description = models.TextField(blank=True, null=True)  # 群聊和频道的描述
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        if self.type == ChatType.PRIVATE:
            return f'Private Chat'
        return self.name or f'Chat {self.id}'

# 聊天成员模型
class ChatMember(models.Model):
    chat = models.ForeignKey(Chat, on_delete=models.CASCADE, related_name='members')
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='chat_memberships')
    joined_at = models.DateTimeField(auto_now_add=True)
    is_admin = models.BooleanField(default=False)  # 群聊和频道的管理员
    is_owner = models.BooleanField(default=False)  # 群聊和频道的所有者
    last_read_at = models.DateTimeField(auto_now_add=True)  # 最后阅读消息的时间
    
    class Meta:
        unique_together = ('chat', 'user')
    
    def __str__(self):
        return f'{self.user.username} in {self.chat}'

# 消息模型
class Message(models.Model):
    chat = models.ForeignKey(Chat, on_delete=models.CASCADE, related_name='messages')
    sender = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='sent_messages')
    content = models.TextField()
    image = models.ImageField(upload_to='chat_images/', blank=True, null=True)
    video = models.FileField(upload_to='chat_videos/', blank=True, null=True)
    audio = models.FileField(upload_to='chat_audio/', blank=True, null=True)
    is_read = models.BooleanField(default=False)
    is_deleted = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['created_at']
    
    def __str__(self):
        return f'{self.sender.username} in {self.chat}: {self.content[:20]}'

# 私聊特有的模型 - 用于跟踪双方关系
class PrivateChat(models.Model):
    chat = models.OneToOneField(Chat, on_delete=models.CASCADE, related_name='private_chat')
    user1 = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='private_chats_as_user1')
    user2 = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='private_chats_as_user2')
    
    class Meta:
        unique_together = ('user1', 'user2')
    
    def __str__(self):
        return f'Private chat between {self.user1.username} and {self.user2.username}'

# 群聊特有的模型
class GroupChat(models.Model):
    chat = models.OneToOneField(Chat, on_delete=models.CASCADE, related_name='group_chat')
    max_members = models.IntegerField(default=100)
    is_public = models.BooleanField(default=False)
    avatar = models.ImageField(upload_to='group_avatars/', blank=True, null=True)
    
    def __str__(self):
        return self.chat.name or f'Group {self.chat.id}'

# 频道特有的模型
class Channel(models.Model):
    chat = models.OneToOneField(Chat, on_delete=models.CASCADE, related_name='channel')
    is_public = models.BooleanField(default=True)
    slug = models.SlugField(max_length=100, unique=True, blank=True, null=True)
    cover_image = models.ImageField(upload_to='channel_covers/', blank=True, null=True)
    subscribers_count = models.IntegerField(default=0)
    
    def __str__(self):
        return self.chat.name or f'Channel {self.chat.id}'