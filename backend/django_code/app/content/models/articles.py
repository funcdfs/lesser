from django.db import models
from .base import BaseContent

class Article(BaseContent):
    """文章模型"""
    title = models.CharField(max_length=200)
    content = models.TextField()
    column_title = models.CharField(max_length=100, blank=True, null=True)
    reading_time = models.IntegerField(help_text="预计阅读时间（分钟）", blank=True, null=True)
    is_published = models.BooleanField(default=True)
    
    def __str__(self):
        return f"Article {self.id}: {self.title} by {self.user} at {self.created_at}"