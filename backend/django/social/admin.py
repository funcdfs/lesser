from django.contrib import admin
from .models import Post

@admin.register(Post)
class PostAdmin(admin.ModelAdmin):
    list_display = ('username', 'content_snippet', 'likes', 'created_at')
    list_filter = ('created_at', 'username')
    search_fields = ('username', 'content')

    def content_snippet(self, obj):
        return obj.content[:50]
    content_snippet.short_description = 'Content'
