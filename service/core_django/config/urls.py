"""
URL configuration for core_django project.
"""
from django.contrib import admin
from django.urls import include, path
from core.views import health_check, hello

urlpatterns = [
    path('admin/', admin.site.urls),
    # Health check
    path('api/v1/health/', health_check, name='health_check'),
    # Hello endpoint
    path('api/v1/hello/', hello, name='hello'),
    # API v1
    path('api/v1/auth/', include('apps.users.urls')),
    path('api/v1/posts/', include('apps.posts.urls')),
    path('api/v1/feeds/', include('apps.feeds.urls')),
    path('api/v1/search/', include('apps.search.urls')),
    path('api/v1/notifications/', include('apps.notifications.urls')),
]
