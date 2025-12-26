# Django Project 架构说明

## 目录结构

```
backend/django_code/
├── lesser_root_folder/        # Django Project 项目配置
│   ├── settings.py            # 全局配置（数据库、中间件、应用等）
│   ├── urls.py                # 项目级 URL 路由分配
│   ├── wsgi.py                # WSGI 应用入口（生产部署）
│   ├── asgi.py                # ASGI 应用入口（异步支持）
│   └── __init__.py
│
├── app/                       # Django Apps 集合（功能模块）
│   ├── users/                 # 用户管理模块
│   ├── content/               # 内容（文章、笔记）管理模块
│   ├── chat/                  # 聊天通讯模块
│   ├── friend/                # 好友关系管理模块
│   └── setting_page/          # 用户设置模块
│
├── manage.py                  # Django 命令行工具
├── pyproject.toml             # 项目依赖配置（Python 3.11+ 标准）
└── Dockerfile                 # Docker 镜像定义
```

## 核心概念

### Project vs App

- **Project** (`lesser_root_folder`): 
  - Django 项目的顶级配置包
  - 全局设置和路由分配
  - 不包含业务逻辑

- **App** (`users/`, `content/`, `chat/` 等): 
  - 功能模块，包含具体业务逻辑
  - 可独立重用（如果需要迁移到其他项目）
  - 包含模型、视图、URL、序列化器等

### 启动流程

```
1. Django 进程启动
   ↓
2. 加载 lesser_root_folder/settings.py
   - 读取全局配置
   - 加载所有 INSTALLED_APPS
   ↓
3. 初始化数据库连接
   ↓
4. 根据 lesser_root_folder/urls.py 构建 URL 路由表
   - 匹配各 App 的 urls.py
   ↓
5. 启动 WSGI/ASGI 服务器监听请求
   ↓
6. 请求进来时，根据 URL 路径分配到对应 App 的视图
```

## 文件说明

### settings.py

全局应用配置文件。主要包含：

| 配置项 | 说明 |
|--------|------|
| `SECRET_KEY` | 密钥，用于加密会话、token 等 |
| `DEBUG` | 调试模式开关（生产环保必须 False） |
| `ALLOWED_HOSTS` | 允许的域名白名单 |
| `INSTALLED_APPS` | 已安装的 Django 应用列表 |
| `MIDDLEWARE` | 中间件列表（请求前置/后置处理） |
| `DATABASES` | 数据库连接配置 |
| `REST_FRAMEWORK` | DRF 框架配置 |
| `CORS_ALLOWED_ORIGINS` | 跨域资源共享白名单 |

**最佳实践**：
- 敏感信息（密钥、密码）从环境变量读取
- 按功能分组注释
- 开发/生产配置分离

### urls.py

项目级 URL 路由配置。职责：
- 定义全局路由（如 `/admin/`, `/health/`）
- 导入各 App 的 `urls.py`
- 定义 API 版本前缀（如 `/api/v1/`）

**示例**：
```python
urlpatterns = [
    path('admin/', admin.site.urls),           # Django 管理后台
    path('health/', health_check),             # 健康检查
    path('api/users/', include('users.urls')), # 用户 App 路由
    path('api/content/', include('content.urls')),
    path('api/chat/', include('chat.urls')),
]
```

### wsgi.py & asgi.py

- **wsgi.py**: WSGI 应用对象，传统 HTTP 同步处理
  - 用于生产服务器（如 Gunicorn）
  - 命令：`gunicorn lesser_root_folder.wsgi:application`

- **asgi.py**: ASGI 应用对象，支持异步处理
  - 用于 WebSocket、Server-Sent Events
  - 用于异步框架（如 Uvicorn）
  - 命令：`uvicorn lesser_root_folder.asgi:application`

## App 内部结构规范

### 标准目录结构

以 `users` app 为例：

```
users/
├── __init__.py                   # App 包初始化
├── apps.py                       # App 配置类
│
├── models/                       # 数据模型（分层）
│   ├── __init__.py
│   ├── user.py                  # User 模型
│   ├── profile.py               # UserProfile 模型
│   └── ...
│
├── serializers/                  # DRF 序列化器（分层）
│   ├── __init__.py
│   ├── user.py                  # 用户序列化器
│   └── profile.py               # 资料序列化器
│
├── views/                        # 视图/ViewSet（分层）
│   ├── __init__.py
│   ├── user.py                  # 用户视图集
│   ├── profile.py               # 资料视图集
│   └── ...
│
├── urls.py                       # App 级 URL 路由
├── permissions.py               # 权限检查类
├── filters.py                   # 过滤器定义
├── tests/                        # 测试
│   ├── test_models.py
│   ├── test_views.py
│   └── test_serializers.py
│
├── admin.py                      # Django 管理后台注册
├── migrations/                   # 数据库迁移文件
│   ├── 0001_initial.py
│   └── ...
│
# 以下为兼容旧结构（逐步迁移）
├── models.py                     # 旧文件（逐步废弃）
├── serializers.py               # 旧文件（逐步废弃）
├── views.py                     # 旧文件（逐步废弃）
└── README.md                     # App 说明文档
```

### 各文件职责

#### models/

**职责**：定义数据库模型

**注意**：
- 不包含业务逻辑，只定义数据结构
- 一个模型一个文件，便于维护
- 添加 `class Meta` 定义表名、排序等

**示例** (`models/user.py`)：
```python
"""
用户模型

定义 User 和 UserProfile 数据库表
"""

from django.db import models
from django.contrib.auth.models import AbstractUser

class User(AbstractUser):
    """
    用户模型 - 继承 Django 内置 User
    
    字段:
        username (str): 用户名，唯一标识
        email (str): 邮箱，用于登录和通知
        first_name (str): 名字
        last_name (str): 姓氏
        created_at (datetime): 创建时间，自动设置
    
    关系:
        - profile (OneToOneField): 关联用户资料
    """
    
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='创建时间')
    updated_at = models.DateTimeField(auto_now=True, verbose_name='更新时间')
    is_active = models.BooleanField(default=True, verbose_name='是否激活')
    
    class Meta:
        db_table = 'users_user'
        verbose_name = '用户'
        verbose_name_plural = '用户'
        ordering = ['-created_at']

class UserProfile(models.Model):
    """
    用户资料 - 扩展用户基本信息
    
    为了不修改 Django 内置 User 表，采用 1:1 关系扩展
    包含个性化信息（头像、简介、位置等）
    """
    
    user = models.OneToOneField(
        User, 
        on_delete=models.CASCADE, 
        related_name='profile'
    )
    avatar = models.ImageField(
        upload_to='avatars/%Y/%m/',
        null=True, 
        blank=True,
        verbose_name='头像'
    )
    bio = models.TextField(blank=True, verbose_name='个人简介')
    location = models.CharField(max_length=100, blank=True, verbose_name='位置')
    
    class Meta:
        db_table = 'users_profile'
        verbose_name = '用户资料'
        verbose_name_plural = '用户资料'
```

#### serializers/

**职责**：定义 REST API 的请求/响应格式

**注意**：
- 将数据库模型转换为 JSON/字典
- 处理输入验证
- 一个序列化器对应一个模型（或视图）

**示例** (`serializers/user.py`)：
```python
"""
用户序列化器

将 User 和 UserProfile 数据库模型转换为 JSON
"""

from rest_framework import serializers
from ..models import User, UserProfile

class UserProfileSerializer(serializers.ModelSerializer):
    """用户资料序列化器"""
    
    class Meta:
        model = UserProfile
        fields = ['id', 'avatar', 'bio', 'location']

class UserSerializer(serializers.ModelSerializer):
    """用户基本信息序列化器"""
    
    profile = UserProfileSerializer(read_only=True)
    
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'profile']
        read_only_fields = ['id', 'created_at']

class UserCreateSerializer(serializers.ModelSerializer):
    """用户创建序列化器（密码字段）"""
    
    password = serializers.CharField(write_only=True)
    password2 = serializers.CharField(write_only=True)
    
    class Meta:
        model = User
        fields = ['username', 'email', 'password', 'password2', 'first_name', 'last_name']
    
    def validate(self, attrs):
        if attrs['password'] != attrs.pop('password2'):
            raise serializers.ValidationError("密码不匹配")
        return attrs
    
    def create(self, validated_data):
        user = User.objects.create_user(**validated_data)
        return user
```

#### views/

**职责**：处理 HTTP 请求，调用模型和序列化器，返回响应

**注意**：
- 使用 DRF 的 ViewSet（自动提供 CRUD）或 APIView（自定义逻辑）
- 添加权限检查
- 按功能分文件

**示例** (`views/user.py`)：
```python
"""
用户 API 视图

处理用户相关的 HTTP 请求
- GET /api/users/           列出所有用户
- POST /api/users/          创建用户
- GET /api/users/{id}/      获取用户详情
- PUT /api/users/{id}/      更新用户
- DELETE /api/users/{id}/   删除用户
"""

from rest_framework.viewsets import ModelViewSet
from rest_framework.permissions import IsAuthenticated
from ..models import User
from ..serializers import UserSerializer, UserCreateSerializer
from ..permissions import IsOwnerOrReadOnly

class UserViewSet(ModelViewSet):
    """
    用户视图集
    
    提供 CRUD API：
    - list: 获取用户列表
    - create: 创建新用户
    - retrieve: 获取用户详情
    - update: 更新用户（全量）
    - partial_update: 更新用户（部分）
    - destroy: 删除用户
    """
    
    queryset = User.objects.all()
    permission_classes = [IsAuthenticated]
    
    def get_serializer_class(self):
        """根据操作选择不同的序列化器"""
        if self.action == 'create':
            return UserCreateSerializer
        return UserSerializer
```

#### urls.py (App 级)

**职责**：定义 App 内部的 URL 路由

**示例** (`users/urls.py`)：
```python
"""
用户 App 的 URL 路由

将 /api/users/ 下的请求分配给对应的视图
"""

from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import UserViewSet

# 使用 DefaultRouter 自动生成 CRUD 路由
router = DefaultRouter()
router.register('', UserViewSet, basename='user')

urlpatterns = [
    path('', include(router.urls)),
]

# 生成的路由：
# GET    /api/users/           -> UserViewSet.list()
# POST   /api/users/           -> UserViewSet.create()
# GET    /api/users/{id}/      -> UserViewSet.retrieve()
# PUT    /api/users/{id}/      -> UserViewSet.update()
# PATCH  /api/users/{id}/      -> UserViewSet.partial_update()
# DELETE /api/users/{id}/      -> UserViewSet.destroy()
```

## 数据流示例

### 创建用户的完整流程

```
客户端 (Flutter)
    ↓
POST /api/users/ 
{ "username": "john", "email": "john@example.com", "password": "123456" }
    ↓
APISIX 网关 (路由转发)
    ↓
Django urls.py (项目级)
  - 匹配 /api/users/ → include('users.urls')
    ↓
users/urls.py (App 级)
  - 匹配 POST → router.register() → UserViewSet
    ↓
UserViewSet.create() (views/user.py)
  - 调用 UserCreateSerializer.save()
    ↓
UserCreateSerializer.create() (serializers/user.py)
  - User.objects.create_user(**validated_data)
    ↓
User 模型 (models/user.py)
  - 密码哈希、保存到 PostgreSQL
    ↓
响应客户端
{ "id": 1, "username": "john", "email": "john@example.com", ... }
```

## 常用命令

```bash
# 创建新 App
python manage.py startapp chat

# 创建数据库迁移
python manage.py makemigrations

# 应用迁移到数据库
python manage.py migrate

# 创建超级用户
python manage.py createsuperuser

# 进入 Django shell（交互式 Python）
python manage.py shell

# 运行开发服务器
python manage.py runserver

# 运行测试
python manage.py test

# 显示 SQL 迁移预览
python manage.py sqlmigrate app_name 0001
```

## 最佳实践

✓ **应该做**：
- 在模型中添加 `verbose_name` 和 `verbose_name_plural`
- 为 App 编写 `README.md` 说明
- 为复杂逻辑添加单元测试
- 使用 `related_name` 便于反向查询
- 在序列化器中做数据验证

✗ **不应该做**：
- 在模型中包含业务逻辑（应放在 views/services）
- 在 `models.py` 中混合多个模型（分文件）
- 忽略迁移文件（应提交到 Git）
- 在生产环境设置 `DEBUG=True`
- 在代码中写死密钥和密码

