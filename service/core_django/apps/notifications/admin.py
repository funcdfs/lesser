"""
Notification admin configuration.
"""
from django.contrib import admin

from .models import Notification


@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = ['id', 'user', 'type', 'actor', 'is_read', 'created_at']
    list_filter = ['type', 'is_read', 'created_at']
    search_fields = ['user__username', 'actor__username', 'message']
    ordering = ['-created_at']
    readonly_fields = ['id', 'created_at']
