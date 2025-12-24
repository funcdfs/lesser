from django.db import models

class Post(models.Model):
    username = models.CharField(max_length=100)
    content = models.TextField()
    likes = models.IntegerField(default=0)
    location = models.CharField(max_length=200, blank=True, null=True)
    images_json = models.JSONField(default=list, blank=True)
    comments_count = models.IntegerField(default=0)
    reposts_count = models.IntegerField(default=0)
    bookmarks_count = models.IntegerField(default=0)
    shares_count = models.IntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.username}: {self.content[:30]}..."
