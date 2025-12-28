"""
Post admin configuration.
"""
from django.contrib import admin

from .models import Post, PostMedia


@admin.register(Post)
class PostAdmin(admin.ModelAdmin):
    list_display = ['id', 'author', 'post_type', 'is_deleted', 'like_count', 'created_at']
    list_filter = ['post_type', 'is_deleted', 'created_at']
    search_fields = ['content', 'title', 'author__username']
    ordering = ['-created_at']
    readonly_fields = ['id', 'created_at', 'updated_at']


@admin.register(PostMedia)
class PostMediaAdmin(admin.ModelAdmin):
    list_display = ['id', 'post', 'media_type', 'order', 'created_at']
    list_filter = ['media_type', 'created_at']
    ordering = ['-created_at']
