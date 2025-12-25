from django.db import models
from django.conf import settings

# 获取用户模型
User = settings.AUTH_USER_MODEL

class Column(models.Model):
    """专栏模型"""
    title = models.CharField(max_length=100, unique=True)
    description = models.TextField(blank=True, null=True)
    creator = models.ForeignKey(User, on_delete=models.CASCADE, related_name='columns')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"Column {self.title} by {self.creator}"