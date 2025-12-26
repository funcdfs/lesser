"""
项目级 URL 路由配置

此文件定义项目的全局 URL 路由。职责：
  1. 定义全局路由 (如 /admin/, /health/)
  2. 导入各 App 的 urls.py，实现功能模块的路由注册
  3. 实现 URL 前缀（如 /api/）以便版本控制

URL 路由执行流程：
  1. 浏览器请求 URL
  2. Django 根据此文件的 urlpatterns 逐行匹配
  3. 找到匹配的 path() 后，调用对应的视图或 include() 其他 urls.py
  4. 返回视图的响应

文档: https://docs.djangoproject.com/en/5.1/topics/http/urls/

示例 URL 路由规则：
  - /admin/                    -> Django 管理后台
  - /health/                   -> 健康检查（用于容器监控）
  - /api/users/                -> 用户 App 的所有路由
  - /api/content/              -> 内容 App 的所有路由
  - /api/chat/                 -> 聊天 App 的所有路由
"""

from django.contrib import admin
from django.http import HttpResponse
from django.urls import path, include
from rest_framework import routers
from rest_framework.authtoken.views import obtain_auth_token


# ============================================================================
# 健康检查端点 (用于容器和负载均衡器探活)
# ============================================================================
def health_check(request):
    """
    健康检查端点
    
    容器编排系统(Docker, Kubernetes)和负载均衡器定期调用此端点
    来检查应用是否正常运行。
    
    响应:
      - status: 200 OK (正常)
      - body: "OK"
    
    用法:
      curl http://localhost:8000/health/
    """
    return HttpResponse("OK", status=200)


# ============================================================================
# 项目级 URL 路由
# ============================================================================
urlpatterns = [
    # --------- 管理后台 ---------
    path('admin/', admin.site.urls),
    
    # --------- 健康检查 ---------
    path('health/', health_check, name='health_check'),
    
    # --------- API 路由 (所有 REST API 都在 /api/ 前缀下) ---------
    # 各 App 在其 urls.py 中定义相对路由，此处统一前缀
    
    # 用户 API
    # 路由: GET|POST /api/users/
    #       GET|PUT|DELETE /api/users/{id}/
    path('api/users/', include("users.urls")),
    path('api/content/', include("content.urls")),
    path('api/chat/', include("chat.urls")),
    path('api/friend/', include("friend.urls")),
    path('api/auth/token/', obtain_auth_token, name='api_token_auth'),
]

from debug_toolbar.toolbar import debug_toolbar_urls
urlpatterns += debug_toolbar_urls()