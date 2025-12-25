from django.db import models
from .base import BaseContent

class Post(BaseContent):
    """帖子模型"""
    content = models.TextField()
    is_published = models.BooleanField(default=True)
    
    def __str__(self):
        return f"Post {self.id} by {self.user} at {self.created_at}"