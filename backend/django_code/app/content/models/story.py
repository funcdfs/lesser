from django.db import models
from .base import BaseContent

class Story(BaseContent):
    """故事模型"""
    title = models.CharField(max_length=200, blank=True, null=True)
    description = models.TextField(blank=True, null=True)
    video_url = models.URLField(blank=True, null=True)
    duration = models.IntegerField(help_text="故事持续时间（小时）", default=24)
    
    def __str__(self):
        return f"Story {self.id} by {self.user} at {self.created_at}"