from django.db import models
from .base import BaseContent

class Reel(BaseContent):
    """短视频模型"""
    title = models.CharField(max_length=200, blank=True, null=True)
    description = models.TextField(blank=True, null=True)
    video_url = models.URLField()
    duration = models.IntegerField(help_text="视频时长（秒）")
    is_published = models.BooleanField(default=True)
    
    def __str__(self):
        return f"Reel {self.id} by {self.user} at {self.created_at}"