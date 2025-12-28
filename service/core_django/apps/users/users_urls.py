"""
User URLs for /api/v1/users/ endpoints.
"""
from django.urls import path

from .views import UserDetailByIdView

urlpatterns = [
    path('<uuid:id>/', UserDetailByIdView.as_view(), name='user_detail_by_id'),
]
