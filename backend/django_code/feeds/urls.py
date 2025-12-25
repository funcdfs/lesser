from django.urls import path
from .views import PostAPI

app_name = 'feeds'
urlpatterns = [
    path('', PostAPI.as_view(), name='posts'),
]