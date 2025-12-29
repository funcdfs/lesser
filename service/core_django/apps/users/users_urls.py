"""
用户 URL 配置，用于 /api/v1/users/ 端点。
"""
from django.urls import path

from .views import UserDetailByIdView

urlpatterns = [
    path('<uuid:id>/', UserDetailByIdView.as_view(), name='user_detail_by_id'),
]
