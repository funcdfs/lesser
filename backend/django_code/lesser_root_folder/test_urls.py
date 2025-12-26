"""
Test URL configuration without debug_toolbar.
"""
from django.contrib import admin
from django.http import HttpResponse
from django.urls import path, include
from rest_framework.authtoken.views import obtain_auth_token


def health_check(request):
    return HttpResponse("OK", status=200)


urlpatterns = [
    path('admin/', admin.site.urls),
    path('health/', health_check, name='health_check'),
    path('api/users/', include("users.urls")),
    path('api/content/', include("content.urls")),
    path('api/chat/', include("chat.urls")),
    path('api/friend/', include("friend.urls")),
    path('api/auth/token/', obtain_auth_token, name='api_token_auth'),
]
