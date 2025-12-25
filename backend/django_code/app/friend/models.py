from django.db import models
from django.conf import settings

# 好友请求状态枚举
class FriendRequestStatus(models.TextChoices):
    PENDING = 'pending', '待处理'
    ACCEPTED = 'accepted', '已接受'
    REJECTED = 'rejected', '已拒绝'
    BLOCKED = 'blocked', '已屏蔽'

# 好友关系模型
class Friend(models.Model):
    user1 = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='friends_as_user1')
    user2 = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='friends_as_user2')
    created_at = models.DateTimeField(auto_now_add=True)
    is_blocked = models.BooleanField(default=False)
    blocked_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, blank=True, null=True, related_name='blocked_friendships')
    
    class Meta:
        unique_together = ('user1', 'user2')
    
    def __str__(self):
        return f'{self.user1.username} and {self.user2.username} are friends'

# 好友请求模型
class FriendRequest(models.Model):
    sender = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='sent_friend_requests')
    receiver = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='received_friend_requests')
    status = models.CharField(max_length=20, choices=FriendRequestStatus.choices, default=FriendRequestStatus.PENDING)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    message = models.CharField(max_length=200, blank=True, null=True)  # 附加消息
    
    class Meta:
        unique_together = ('sender', 'receiver')
    
    def __str__(self):
        return f'{self.sender.username} -> {self.receiver.username}: {self.status}'

# 好友推荐模型 - 用于存储系统推荐的好友
class FriendSuggestion(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='friend_suggestions')
    suggested_user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='suggested_to')
    score = models.FloatField(default=0.0)  # 推荐分数，越高越匹配
    reason = models.TextField(blank=True, null=True)  # 推荐理由
    created_at = models.DateTimeField(auto_now_add=True)
    is_viewed = models.BooleanField(default=False)
    
    class Meta:
        unique_together = ('user', 'suggested_user')
    
    def __str__(self):
        return f'Suggest {self.suggested_user.username} to {self.user.username}'

# 附近的人模型 - 用于存储用户位置信息
class NearbyPerson(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='nearby_info')
    latitude = models.DecimalField(max_digits=9, decimal_places=6)  # 纬度
    longitude = models.DecimalField(max_digits=9, decimal_places=6)  # 经度
    accuracy = models.FloatField(default=0.0)  # 位置精度（米）
    last_updated = models.DateTimeField(auto_now=True)
    is_sharing_location = models.BooleanField(default=True)  # 是否分享位置
    
    def __str__(self):
        return f'{self.user.username} at ({self.latitude}, {self.longitude})'

# 共同好友关系模型 - 用于缓存计算结果，提高查询性能
class MutualFriend(models.Model):
    user1 = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='mutual_friends_as_user1')
    user2 = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='mutual_friends_as_user2')
    mutual_count = models.IntegerField(default=0)  # 共同好友数量
    last_calculated = models.DateTimeField(auto_now=True)
    
    class Meta:
        unique_together = ('user1', 'user2')
    
    def __str__(self):
        return f'{self.mutual_count} mutual friends between {self.user1.username} and {self.user2.username}'

# 社交关系统计模型 - 用于跟踪用户的社交数据
class SocialStats(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='social_stats')
    friends_count = models.IntegerField(default=0)
    sent_requests_count = models.IntegerField(default=0)
    received_requests_count = models.IntegerField(default=0)
    mutual_friends_count = models.IntegerField(default=0)
    
    def __str__(self):
        return f'Social stats for {self.user.username}'