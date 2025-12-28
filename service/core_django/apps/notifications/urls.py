"""
Notification URL configuration.
"""
from django.urls import path

from .views import (
    NotificationClearAllView,
    NotificationCountView,
    NotificationDeleteView,
    NotificationListView,
    NotificationMarkAllReadView,
    NotificationMarkReadView,
)

urlpatterns = [
    path('', NotificationListView.as_view(), name='notification_list'),
    path('count/', NotificationCountView.as_view(), name='notification_count'),
    path('read-all/', NotificationMarkAllReadView.as_view(), name='notification_read_all'),
    path('clear-all/', NotificationClearAllView.as_view(), name='notification_clear_all'),
    path('<uuid:notification_id>/read/', NotificationMarkReadView.as_view(), name='notification_read'),
    path('<uuid:notification_id>/', NotificationDeleteView.as_view(), name='notification_delete'),
]
