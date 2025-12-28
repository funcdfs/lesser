"""
Notification views.
"""
from django.shortcuts import get_object_or_404
from rest_framework import generics, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Notification
from .serializers import NotificationCountSerializer, NotificationSerializer


class NotificationListView(generics.ListAPIView):
    """List user's notifications."""

    serializer_class = NotificationSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = Notification.objects.filter(
            user=self.request.user
        ).select_related('actor')

        # Filter by type
        notification_type = self.request.query_params.get('type')
        if notification_type:
            queryset = queryset.filter(type=notification_type)

        # Filter by read status
        is_read = self.request.query_params.get('is_read')
        if is_read is not None:
            queryset = queryset.filter(is_read=is_read.lower() == 'true')

        return queryset


class NotificationCountView(APIView):
    """Get notification counts."""

    permission_classes = [IsAuthenticated]

    def get(self, request):
        total = Notification.objects.filter(user=request.user).count()
        unread = Notification.objects.filter(user=request.user, is_read=False).count()

        serializer = NotificationCountSerializer({
            'total': total,
            'unread': unread
        })
        return Response(serializer.data)


class NotificationMarkReadView(APIView):
    """Mark notification(s) as read."""

    permission_classes = [IsAuthenticated]

    def post(self, request, notification_id=None):
        """Mark single notification as read."""
        notification = get_object_or_404(
            Notification, id=notification_id, user=request.user
        )
        notification.is_read = True
        notification.save()
        return Response({'detail': 'Notification marked as read.'})


class NotificationMarkAllReadView(APIView):
    """Mark all notifications as read."""

    permission_classes = [IsAuthenticated]

    def post(self, request):
        """Mark all notifications as read."""
        count = Notification.objects.filter(
            user=request.user, is_read=False
        ).update(is_read=True)
        return Response({'detail': f'{count} notifications marked as read.'})


class NotificationDeleteView(APIView):
    """Delete a notification."""

    permission_classes = [IsAuthenticated]

    def delete(self, request, notification_id):
        """Delete a notification."""
        notification = get_object_or_404(
            Notification, id=notification_id, user=request.user
        )
        notification.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


class NotificationClearAllView(APIView):
    """Clear all notifications."""

    permission_classes = [IsAuthenticated]

    def delete(self, request):
        """Delete all notifications."""
        count, _ = Notification.objects.filter(user=request.user).delete()
        return Response({'detail': f'{count} notifications deleted.'})
