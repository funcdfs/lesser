# Django 开发准则

本文档定义了项目中 Django 后端的开发规范，包括模型定义、路由配置、视图开发和 API Gateway 配置。所有 AI 和开发者必须遵循这些准则。

## 目录

1. [项目结构](#1-项目结构)
2. [模型定义规范](#2-模型定义规范)
3. [序列化器规范](#3-序列化器规范)
4. [视图开发规范](#4-视图开发规范)
5. [URL 路由规范](#5-url-路由规范)
6. [新增 API 完整流程](#6-新增-api-完整流程)
7. [API Gateway (APISIX) 配置](#7-api-gateway-apisix-配置)
8. [代码检查清单](#8-代码检查清单)

---

## 1. 项目结构

### 1.1 目录结构
```
backend/django_code/
├── manage.py
├── lesser_root_folder/          # 项目配置目录
│   ├── settings.py              # 全局配置
│   ├── urls.py                  # 项目级路由
│   ├── asgi.py
│   └── wsgi.py
└── app/                         # 应用目录
    ├── users/                   # 用户模块
    ├── content/                 # 内容模块
    ├── chat/                    # 聊天模块
    └── friend/                  # 好友模块
```

### 1.2 App 内部结构
每个 App 必须遵循以下结构：
```
app/{app_name}/
├── __init__.py
├── apps.py                      # App 配置
├── admin.py                     # Admin 注册
├── urls.py                      # App 级路由入口
├── models/                      # 模型目录
│   ├── __init__.py              # 导出所有模型
│   ├── base.py                  # 基础模型
│   └── {entity}.py              # 具体模型
├── serializers/                 # 序列化器目录
│   ├── __init__.py              # 导出所有序列化器
│   ├── base.py                  # 基础序列化器
│   └── {entity}.py              # 具体序列化器
├── views/                       # 视图目录
│   ├── __init__.py              # 导出所有视图
│   ├── base.py                  # 基础视图
│   └── {entity}.py              # 具体视图
├── urls/                        # URL 子目录（可选，复杂时使用）
│   ├── __init__.py
│   └── {entity}.py
├── tests/                       # 测试目录
│   ├── __init__.py
│   ├── test_models.py
│   ├── test_views.py
│   └── test_serializers.py
└── migrations/                  # 数据库迁移
```

---

## 2. 模型定义规范

### 2.1 基础模型
所有业务模型应继承基础模型：

```python
# models/base.py
from django.db import models
from django.conf import settings

User = settings.AUTH_USER_MODEL

class BaseModel(models.Model):
    """基础模型 - 所有模型的父类"""
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='创建时间')
    updated_at = models.DateTimeField(auto_now=True, verbose_name='更新时间')
    
    class Meta:
        abstract = True
        ordering = ['-created_at']


class UserOwnedModel(BaseModel):
    """用户所属模型 - 带用户外键的基础模型"""
    user = models.ForeignKey(
        User, 
        on_delete=models.CASCADE, 
        related_name='%(class)ss',
        verbose_name='用户'
    )
    
    class Meta:
        abstract = True
```

### 2.2 模型定义示例
```python
# models/posts.py
from django.db import models
from .base import UserOwnedModel

class Post(UserOwnedModel):
    """帖子模型
    
    字段说明:
        content: 帖子内容
        is_published: 是否已发布
    
    关联关系:
        user: 发布用户 (继承自 UserOwnedModel)
        images: 关联图片 (多对多)
    """
    content = models.TextField(verbose_name='内容')
    is_published = models.BooleanField(default=True, verbose_name='是否发布')
    
    class Meta:
        verbose_name = '帖子'
        verbose_name_plural = '帖子'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user', '-created_at']),
            models.Index(fields=['is_published', '-created_at']),
        ]
    
    def __str__(self):
        return f"Post {self.id} by {self.user} at {self.created_at}"
```

### 2.3 模型命名规范

| 类型 | 规范 | 示例 |
|------|------|------|
| 模型类名 | PascalCase，单数 | `Post`, `Article`, `UserProfile` |
| 字段名 | snake_case | `created_at`, `is_published` |
| related_name | 小写复数 | `posts`, `articles` |
| verbose_name | 中文 | `'帖子'`, `'创建时间'` |

### 2.4 字段类型选择

| 场景 | 字段类型 | 示例 |
|------|----------|------|
| 短文本 (<255) | CharField | `title = CharField(max_length=200)` |
| 长文本 | TextField | `content = TextField()` |
| 布尔值 | BooleanField | `is_active = BooleanField(default=True)` |
| 整数 | IntegerField | `view_count = IntegerField(default=0)` |
| 小数 | DecimalField | `price = DecimalField(max_digits=10, decimal_places=2)` |
| 日期时间 | DateTimeField | `published_at = DateTimeField(null=True)` |
| 外键 | ForeignKey | `user = ForeignKey(User, on_delete=CASCADE)` |
| 多对多 | ManyToManyField | `tags = ManyToManyField(Tag)` |
| JSON | JSONField | `metadata = JSONField(default=dict)` |

### 2.5 模型导出
```python
# models/__init__.py
from .base import BaseModel, UserOwnedModel
from .posts import Post
from .articles import Article

__all__ = ['BaseModel', 'UserOwnedModel', 'Post', 'Article']
```

---

## 3. 序列化器规范

### 3.1 基础序列化器
```python
# serializers/base.py
from rest_framework import serializers

class BaseSerializer(serializers.ModelSerializer):
    """基础序列化器"""
    
    class Meta:
        abstract = True
        fields = ['id', 'created_at', 'updated_at']
        read_only_fields = ['id', 'created_at', 'updated_at']


class UserOwnedSerializer(BaseSerializer):
    """用户所属序列化器"""
    user = serializers.PrimaryKeyRelatedField(read_only=True)
    
    class Meta(BaseSerializer.Meta):
        abstract = True
        fields = BaseSerializer.Meta.fields + ['user']
        read_only_fields = BaseSerializer.Meta.read_only_fields + ['user']
```

### 3.2 序列化器示例
```python
# serializers/posts.py
from rest_framework import serializers
from content.models import Post
from .base import UserOwnedSerializer

class PostSerializer(UserOwnedSerializer):
    """帖子序列化器"""
    # 计算字段
    likes_count = serializers.IntegerField(read_only=True)
    comments_count = serializers.IntegerField(read_only=True)
    
    class Meta(UserOwnedSerializer.Meta):
        model = Post
        fields = UserOwnedSerializer.Meta.fields + [
            'content', 
            'is_published',
            'likes_count',
            'comments_count',
        ]


class PostCreateSerializer(serializers.ModelSerializer):
    """帖子创建序列化器 - 仅包含可写字段"""
    
    class Meta:
        model = Post
        fields = ['content', 'is_published']
```

### 3.3 序列化器命名规范

| 用途 | 命名 | 示例 |
|------|------|------|
| 通用 | `{Model}Serializer` | `PostSerializer` |
| 创建 | `{Model}CreateSerializer` | `PostCreateSerializer` |
| 更新 | `{Model}UpdateSerializer` | `PostUpdateSerializer` |
| 列表 | `{Model}ListSerializer` | `PostListSerializer` |
| 详情 | `{Model}DetailSerializer` | `PostDetailSerializer` |

---

## 4. 视图开发规范

### 4.1 基础视图集
```python
# views/base.py
from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import action

class BaseViewSet(viewsets.ModelViewSet):
    """基础视图集"""
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        """子类必须实现"""
        raise NotImplementedError


class UserOwnedViewSet(BaseViewSet):
    """用户所属视图集 - 自动关联当前用户"""
    
    def perform_create(self, serializer):
        """创建时自动关联当前用户"""
        serializer.save(user=self.request.user)
    
    def get_queryset(self):
        """默认只返回当前用户的数据"""
        return super().get_queryset().filter(user=self.request.user)
```

### 4.2 视图示例
```python
# views/posts.py
from rest_framework import status
from rest_framework.decorators import action
from rest_framework.response import Response
from content.models import Post
from content.serializers import PostSerializer, PostCreateSerializer
from .base import UserOwnedViewSet

class PostViewSet(UserOwnedViewSet):
    """帖子视图集
    
    支持的操作:
        - GET    /posts/          列表
        - POST   /posts/          创建
        - GET    /posts/{id}/     详情
        - PUT    /posts/{id}/     更新
        - DELETE /posts/{id}/     删除
        - POST   /posts/{id}/publish/    发布
        - POST   /posts/{id}/unpublish/  取消发布
    """
    queryset = Post.objects.all()
    serializer_class = PostSerializer
    
    def get_serializer_class(self):
        """根据操作返回不同的序列化器"""
        if self.action == 'create':
            return PostCreateSerializer
        return PostSerializer
    
    def get_queryset(self):
        """支持按发布状态过滤"""
        queryset = super().get_queryset()
        is_published = self.request.query_params.get('is_published')
        if is_published is not None:
            queryset = queryset.filter(is_published=is_published.lower() == 'true')
        return queryset
    
    @action(detail=True, methods=['post'], url_path='publish')
    def publish(self, request, pk=None):
        """发布帖子"""
        post = self.get_object()
        post.is_published = True
        post.save()
        return Response(self.get_serializer(post).data)
    
    @action(detail=True, methods=['post'], url_path='unpublish')
    def unpublish(self, request, pk=None):
        """取消发布"""
        post = self.get_object()
        post.is_published = False
        post.save()
        return Response(self.get_serializer(post).data)
```

### 4.3 视图导出
```python
# views/__init__.py
from .base import BaseViewSet, UserOwnedViewSet
from .posts import PostViewSet
from .articles import ArticleViewSet

__all__ = ['BaseViewSet', 'UserOwnedViewSet', 'PostViewSet', 'ArticleViewSet']
```

---

## 5. URL 路由规范

### 5.1 App 级路由
```python
# {app}/urls.py
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import PostViewSet, ArticleViewSet

# 使用 DRF Router 自动生成 CRUD 路由
router = DefaultRouter()
router.register(r'posts', PostViewSet, basename='post')
router.register(r'articles', ArticleViewSet, basename='article')

urlpatterns = [
    # Router 自动生成的路由
    path('', include(router.urls)),
    
    # 自定义路由（如需要）
    path('user/<int:user_id>/posts/', 
         PostViewSet.as_view({'get': 'list'}), 
         name='user-posts'),
]
```

### 5.2 项目级路由
```python
# lesser_root_folder/urls.py
from django.urls import path, include

urlpatterns = [
    # 管理后台
    path('admin/', admin.site.urls),
    
    # 健康检查
    path('health/', health_check, name='health_check'),
    
    # API 路由 - 所有 API 在 /api/ 前缀下
    path('api/users/', include('users.urls')),
    path('api/content/', include('content.urls')),
    path('api/chat/', include('chat.urls')),
    path('api/friend/', include('friend.urls')),
    
    # Token 认证
    path('api/auth/token/', obtain_auth_token, name='api_token_auth'),
]
```

### 5.3 URL 命名规范

| 类型 | 格式 | 示例 |
|------|------|------|
| 列表 | `{model}-list` | `post-list` |
| 详情 | `{model}-detail` | `post-detail` |
| 自定义动作 | `{model}-{action}` | `post-publish` |
| 关联资源 | `{parent}-{child}` | `user-posts` |

---

## 6. 新增 API 完整流程

### 6.1 需要修改的文件清单

新增一个 API 端点需要修改以下文件：

```
📁 后端 (Django)
├── 1. app/{app}/models/{entity}.py      # 定义模型
├── 2. app/{app}/models/__init__.py      # 导出模型
├── 3. app/{app}/serializers/{entity}.py # 定义序列化器
├── 4. app/{app}/serializers/__init__.py # 导出序列化器
├── 5. app/{app}/views/{entity}.py       # 定义视图
├── 6. app/{app}/views/__init__.py       # 导出视图
├── 7. app/{app}/urls.py                 # 注册路由
├── 8. app/{app}/admin.py                # 注册 Admin（可选）
└── 9. lesser_root_folder/urls.py        # 项目路由（新 App 时）

📁 基础设施 (APISIX)
└── 10. infra/apisix/setup_routes.sh     # API Gateway 路由（新 App 时）
```

### 6.2 详细步骤

#### 步骤 1: 创建模型
```python
# app/content/models/tags.py
from django.db import models
from .base import BaseModel

class Tag(BaseModel):
    """标签模型"""
    name = models.CharField(max_length=50, unique=True, verbose_name='名称')
    slug = models.SlugField(max_length=50, unique=True, verbose_name='别名')
    
    class Meta:
        verbose_name = '标签'
        verbose_name_plural = '标签'
    
    def __str__(self):
        return self.name
```

#### 步骤 2: 导出模型
```python
# app/content/models/__init__.py
from .base import BaseModel, UserOwnedModel
from .posts import Post
from .tags import Tag  # 新增

__all__ = ['BaseModel', 'UserOwnedModel', 'Post', 'Tag']
```

#### 步骤 3: 创建序列化器
```python
# app/content/serializers/tags.py
from rest_framework import serializers
from content.models import Tag

class TagSerializer(serializers.ModelSerializer):
    class Meta:
        model = Tag
        fields = ['id', 'name', 'slug', 'created_at']
        read_only_fields = ['id', 'created_at']
```

#### 步骤 4: 导出序列化器
```python
# app/content/serializers/__init__.py
from .base import BaseSerializer
from .posts import PostSerializer
from .tags import TagSerializer  # 新增

__all__ = ['BaseSerializer', 'PostSerializer', 'TagSerializer']
```

#### 步骤 5: 创建视图
```python
# app/content/views/tags.py
from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from content.models import Tag
from content.serializers import TagSerializer

class TagViewSet(viewsets.ModelViewSet):
    """标签视图集"""
    queryset = Tag.objects.all()
    serializer_class = TagSerializer
    permission_classes = [IsAuthenticated]
```

#### 步骤 6: 导出视图
```python
# app/content/views/__init__.py
from .base import BaseViewSet
from .posts import PostViewSet
from .tags import TagViewSet  # 新增

__all__ = ['BaseViewSet', 'PostViewSet', 'TagViewSet']
```

#### 步骤 7: 注册路由
```python
# app/content/urls.py
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import PostViewSet, TagViewSet

router = DefaultRouter()
router.register(r'posts', PostViewSet, basename='post')
router.register(r'tags', TagViewSet, basename='tag')  # 新增

urlpatterns = [
    path('', include(router.urls)),
]
```

#### 步骤 8: 注册 Admin（可选）
```python
# app/content/admin.py
from django.contrib import admin
from .models import Post, Tag

@admin.register(Tag)
class TagAdmin(admin.ModelAdmin):
    list_display = ['id', 'name', 'slug', 'created_at']
    search_fields = ['name', 'slug']
    prepopulated_fields = {'slug': ('name',)}
```

#### 步骤 9: 数据库迁移
```bash
# 生成迁移文件
python manage.py makemigrations content

# 执行迁移
python manage.py migrate
```

---

## 7. API Gateway (APISIX) 配置

### 7.1 何时需要配置 APISIX

| 场景 | 是否需要配置 |
|------|-------------|
| 在现有 App 中新增 API | ❌ 不需要 |
| 新增 App（如 /api/payment/） | ✅ 需要 |
| 修改 API 前缀 | ✅ 需要 |
| 添加特殊中间件（限流等） | ✅ 需要 |

### 7.2 APISIX 路由配置

#### 配置文件位置
```
infra/apisix/
├── config.yaml              # APISIX 主配置
├── config.prod.yaml         # 生产环境配置
└── setup_routes.sh          # 路由配置脚本
```

#### 新增 App 路由
编辑 `infra/apisix/setup_routes.sh`，添加新路由：

```bash
# 创建新 App 路由
create_payment_routes() {
    log_info "创建支付路由..."
    
    curl -s -X PUT "${APISIX_ADMIN_URL}/apisix/admin/routes/10" \
        -H "X-API-KEY: ${APISIX_ADMIN_KEY}" \
        -H "Content-Type: application/json" \
        -d '{
            "name": "payment-routes",
            "desc": "支付相关路由",
            "uri": "/api/payment/*",
            "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
            "upstream_id": 1,
            "plugins": {
                "cors": {
                    "allow_origins": "*",
                    "allow_methods": "GET,POST,PUT,DELETE,OPTIONS",
                    "allow_headers": "Authorization,Content-Type,Accept",
                    "max_age": 3600
                },
                "limit-count": {
                    "count": 100,
                    "time_window": 60,
                    "rejected_code": 429
                }
            },
            "status": 1
        }' > /dev/null
    
    log_success "支付路由已创建"
}

# 在 main() 中调用
main() {
    # ... 现有代码 ...
    create_payment_routes  # 新增
}
```

### 7.3 路由 ID 分配规则

| 路由 ID | 用途 |
|---------|------|
| 1 | 用户认证 (/api/users/*) |
| 2 | 健康检查 (/health/*) |
| 3 | 内容管理 (/api/content/*) |
| 4 | 聊天 (/api/chat/*) |
| 5 | 好友 (/api/friend/*) |
| 10+ | 新增业务模块 |

### 7.4 常用 APISIX 插件配置

#### CORS 跨域
```json
{
    "cors": {
        "allow_origins": "*",
        "allow_methods": "GET,POST,PUT,DELETE,OPTIONS",
        "allow_headers": "Authorization,Content-Type,Accept",
        "max_age": 3600
    }
}
```

#### 限流
```json
{
    "limit-count": {
        "count": 100,
        "time_window": 60,
        "rejected_code": 429,
        "key": "remote_addr"
    }
}
```

#### 认证
```json
{
    "key-auth": {
        "header": "X-API-KEY"
    }
}
```

### 7.5 验证路由配置
```bash
# 执行配置脚本
cd infra/apisix
./setup_routes.sh

# 查看所有路由
curl http://localhost:9180/apisix/admin/routes \
    -H "X-API-KEY: fw142857"

# 测试新路由
curl http://localhost:9080/api/payment/orders/
```

---

## 8. 代码检查清单

### 8.1 模型检查
- [ ] 继承正确的基础模型 (BaseModel/UserOwnedModel)
- [ ] 定义 `verbose_name` 和 `verbose_name_plural`
- [ ] 定义 `__str__` 方法
- [ ] 添加必要的索引 (indexes)
- [ ] 在 `__init__.py` 中导出
- [ ] 生成并执行迁移

### 8.2 序列化器检查
- [ ] 继承正确的基础序列化器
- [ ] 定义 `read_only_fields`
- [ ] 区分读写序列化器（如需要）
- [ ] 在 `__init__.py` 中导出

### 8.3 视图检查
- [ ] 继承正确的基础视图集
- [ ] 定义 `queryset` 和 `serializer_class`
- [ ] 定义 `permission_classes`
- [ ] 实现 `get_queryset` 过滤逻辑
- [ ] 在 `__init__.py` 中导出

### 8.4 路由检查
- [ ] 在 Router 中注册 ViewSet
- [ ] 设置正确的 `basename`
- [ ] 自定义路由使用正确的 `name`

### 8.5 APISIX 检查（新 App 时）
- [ ] 在 `setup_routes.sh` 中添加路由
- [ ] 配置 CORS 插件
- [ ] 配置限流插件（如需要）
- [ ] 执行脚本并验证

---

## 9. 示例：完整的新 App 创建

### 创建 notification App

```bash
# 1. 创建 App 目录结构
mkdir -p app/notification/{models,serializers,views,tests,migrations}
touch app/notification/__init__.py
touch app/notification/apps.py
touch app/notification/admin.py
touch app/notification/urls.py
touch app/notification/{models,serializers,views}/__init__.py
```

### apps.py
```python
from django.apps import AppConfig

class NotificationConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'notification'
    verbose_name = '通知'
```

### models/notification.py
```python
from django.db import models
from django.conf import settings

User = settings.AUTH_USER_MODEL

class Notification(models.Model):
    """通知模型"""
    TYPES = [
        ('like', '点赞'),
        ('comment', '评论'),
        ('follow', '关注'),
        ('system', '系统'),
    ]
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notifications')
    type = models.CharField(max_length=20, choices=TYPES)
    title = models.CharField(max_length=200)
    content = models.TextField(blank=True)
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = '通知'
        verbose_name_plural = '通知'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user', '-created_at']),
            models.Index(fields=['user', 'is_read']),
        ]
    
    def __str__(self):
        return f"{self.type}: {self.title}"
```

### 注册到 settings.py
```python
INSTALLED_APPS = [
    # ... 现有应用 ...
    'notification.apps.NotificationConfig',  # 新增
]
```

### 注册到项目 urls.py
```python
urlpatterns = [
    # ... 现有路由 ...
    path('api/notification/', include('notification.urls')),  # 新增
]
```

### 配置 APISIX
在 `setup_routes.sh` 中添加：
```bash
create_notification_routes() {
    curl -s -X PUT "${APISIX_ADMIN_URL}/apisix/admin/routes/6" \
        -H "X-API-KEY: ${APISIX_ADMIN_KEY}" \
        -H "Content-Type: application/json" \
        -d '{
            "name": "notification-routes",
            "uri": "/api/notification/*",
            "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
            "upstream_id": 1,
            "plugins": {
                "cors": {
                    "allow_origins": "*",
                    "allow_methods": "GET,POST,PUT,DELETE,OPTIONS",
                    "allow_headers": "Authorization,Content-Type,Accept",
                    "max_age": 3600
                }
            },
            "status": 1
        }' > /dev/null
}
```

---

> 最后更新：2024年12月
> 
> 如有疑问或建议，请在项目中提出 Issue。
