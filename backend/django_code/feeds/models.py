from django.db import models
from django.contrib.auth.models import User

class Post(models.Model):
    content = models.TextField()
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    location = models.CharField(max_length=255, blank=True, null=True)
    likes = models.IntegerField(default=0)
    comments_count = models.IntegerField(default=0)
    reposts_count = models.IntegerField(default=0)
    bookmarks_count = models.IntegerField(default=0)
    shares_count = models.IntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f'{self.user.username}: {self.content[:20]}'