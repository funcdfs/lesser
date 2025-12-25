"""
URL configuration for lesser project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/6.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.http import HttpResponse
from django.urls import path, include
from rest_framework import routers
from rest_framework.authtoken.views import obtain_auth_token

# Simple health check endpoint
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

from debug_toolbar.toolbar import debug_toolbar_urls
urlpatterns += debug_toolbar_urls()