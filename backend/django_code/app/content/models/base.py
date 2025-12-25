from django.db import models
from django.conf import settings

# 获取用户模型
User = settings.AUTH_USER_MODEL

class ContentImage(models.Model):
    """内容图片模型"""
    image = models.ImageField(upload_to='content/images/')
    uploaded_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"Image {self.id} uploaded at {self.uploaded_at}"

class BaseContent(models.Model):
    """基础内容模型"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='%(class)ss')
    images = models.ManyToManyField(ContentImage, related_name='%(class)ss', blank=True)
    is_published = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        abstract = True
        ordering = ['-created_at']

class ContentInteraction(models.Model):
    """内容交互模型"""
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        abstract = True
        unique_together = ('user', 'content')

class ContentComment(ContentInteraction):
    """内容评论模型"""
    content = models.ForeignKey(BaseContent, on_delete=models.CASCADE, related_name='comments')
    text = models.TextField()
    
    def __str__(self):
        return f"Comment by {self.user} on {self.content}"

class ContentLike(ContentInteraction):
    """内容点赞模型"""
    content = models.ForeignKey(BaseContent, on_delete=models.CASCADE, related_name='likes')
    
    def __str__(self):
        return f"Like by {self.user} on {self.content}"

class ContentBookmark(ContentInteraction):
    """内容收藏模型"""
    content = models.ForeignKey(BaseContent, on_delete=models.CASCADE, related_name='bookmarks')
    
    def __str__(self):
        return f"Bookmark by {self.user} on {self.content}"

class ContentRepost(ContentInteraction):
    """内容转发模型"""
    content = models.ForeignKey(BaseContent, on_delete=models.CASCADE, related_name='reposts')
    
    def __str__(self):
        return f"Repost by {self.user} on {self.content}"