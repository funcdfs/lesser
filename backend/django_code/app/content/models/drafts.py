from django.db import models
from .base import BaseContent

class Draft(BaseContent):
    """草稿模型"""
    CONTENT_TYPE_CHOICES = (
        ('POST', 'Post'),
        ('REEL', 'Reel'),
        ('ARTICLE', 'Article'),
    )
    
    title = models.CharField(max_length=200, blank=True, null=True)
    content = models.TextField(blank=True, null=True)
    content_type = models.CharField(max_length=20, choices=CONTENT_TYPE_CHOICES)
    column_title = models.CharField(max_length=100, blank=True, null=True)
    is_auto_saved = models.BooleanField(default=False)
    
    def __str__(self):
        return f"Draft {self.id} ({self.content_type}) by {self.user} at {self.updated_at}"