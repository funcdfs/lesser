"""
Notification serializers.
"""
from rest_framework import serializers

from apps.users.serializers import UserMinimalSerializer

from .models import Notification


class NotificationSerializer(serializers.ModelSerializer):
    """Notification serializer."""

    actor = UserMinimalSerializer(read_only=True)

    class Meta:
        model = Notification
        fields = [
            'id', 'type', 'actor', 'target_type', 'target_id',
            'message', 'is_read', 'created_at'
        ]
        read_only_fields = ['id', 'type', 'actor', 'target_type', 'target_id', 'message', 'created_at']


class NotificationCountSerializer(serializers.Serializer):
    """Notification count serializer."""

    total = serializers.IntegerField()
    unread = serializers.IntegerField()
