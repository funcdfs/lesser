"""Django settings for lesser_root_folder project.

生成时间: Django 5.1.2
文档: https://docs.djangoproject.com/en/5.1/topics/settings/

此文件包含所有项目级配置，分为以下部分：
  1. 环境配置加载（从 .env.dev 或 .env.prod）
  2. 基础配置 (SECRET_KEY, DEBUG, ALLOWED_HOSTS)
  3. 应用配置 (INSTALLED_APPS, MIDDLEWARE)
  4. URL & 模板配置
  5. 数据库配置
  6. 认证和权限
  7. 第三方库配置 (DRF, CORS 等)
  8. 国际化和时区
  9. 静态文件配置

重要提示:
  - 所有配置从环境变量读取，由 .env.dev 统一管理
  - 敏感信息(SECRET_KEY, 密码)不要硬编码
  - 生产环境必须设置 DEBUG = False
  - 生产环境要设置真实的 ALLOWED_HOSTS
"""

import os
import sys
from pathlib import Path

# ============================================================================
# 环境变量加载（仅在非 Docker 环境下）
# ============================================================================
# 说明：
#   - 在 Docker 中，env_file 会自动注入环境变量，此代码不会执行
#   - 在本地开发中，此代码确保加载项目根目录的 .env.dev
#
# 使用 python-dotenv 库加载 .env 文件
try:
    from dotenv import load_dotenv
    
    # 尝试从项目根目录加载 .env.dev（相对于 manage.py 所在目录向上两层）
    env_path = Path(__file__).resolve().parent.parent.parent.parent / '.env.dev'
    
    if env_path.exists():
        load_dotenv(env_path)
        print(f"✓ 已加载环境配置: {env_path}")
    else:
        # 如果找不到 .env.dev，尝试查找 .env
        env_path_fallback = Path(__file__).resolve().parent.parent.parent.parent / '.env'
        if env_path_fallback.exists():
            load_dotenv(env_path_fallback)
            print(f"✓ 已加载环境配置: {env_path_fallback}")
except ImportError:
    # 如果没有安装 python-dotenv，跳过此步骤（Docker 环境已通过 env_file 注入）
    pass

# ============================================================================
# 基础路径配置
# ============================================================================
BASE_DIR = Path(__file__).resolve().parent.parent
sys.path.append(os.path.join(BASE_DIR, 'app'))


# ============================================================================
# 基础配置 - 安全和调试相关
# ============================================================================

# ⚠️  SECURITY WARNING: 从环境变量读取（由 .env.dev 提供）
SECRET_KEY = os.environ.get(
    'DJANGO_SECRET_KEY',
    'django-insecure-72c10ff#d^2wmf%17^3%*y!+a3jeb6mr&5+rd-3g7g12t&e=ad'
)

# ⚠️  SECURITY WARNING: 从环境变量读取（开发环境默认 True，生产环境应为 False）
DEBUG = os.environ.get('DJANGO_DEBUG', 'False').lower() in ('true', '1', 'yes')

# 允许的主机/域名白名单 (从环境变量读取，生产环境需要配置真实域名)
ALLOWED_HOSTS = os.environ.get('DJANGO_ALLOWED_HOSTS', '*').split(',')
ALLOWED_HOSTS = [host.strip() for host in ALLOWED_HOSTS]  # 去除空格


# ============================================================================
# 应用定义 - 项目包含的 Django 应用
# ============================================================================

INSTALLED_APPS = [
    # --------- Django 核心应用 ---------
    "django.contrib.admin",           # 管理后台
    "django.contrib.auth",            # 用户认证系统
    "django.contrib.contenttypes",    # 内容类型框架
    "django.contrib.sessions",        # 会话管理
    "django.contrib.messages",        # 消息框架
    "django.contrib.staticfiles",     # 静态文件处理
    
    # --------- 第三方库 ---------
    "rest_framework",                 # Django REST Framework (API)
    "rest_framework.authtoken",       # Token 认证
    "corsheaders",                    # 跨域资源共享 (CORS)
    "debug_toolbar",                  # 调试工具栏 (开发用)
    
    # --------- 项目应用 (按功能领域) ---------
    "users.apps.UsersConfig",         # 用户管理
    "content.apps.ContentConfig",     # 内容管理 (文章、笔记等)
    "chat.apps.ChatConfig",           # 聊天通讯
    "friend.apps.FriendConfig",       # 好友关系
]


# ============================================================================
# 中间件配置 - 请求和响应的预处理和后处理
# ============================================================================
# 中间件执行顺序很重要，按从上到下的顺序执行

MIDDLEWARE = [
    # --------- 安全和请求处理 ---------
    'django.middleware.security.SecurityMiddleware',      # 安全头
    'django.contrib.sessions.middleware.SessionMiddleware',  # 会话管理
    'corsheaders.middleware.CorsMiddleware',              # CORS (必须在 CommonMiddleware 前)
    'django.middleware.common.CommonMiddleware',          # 通用处理 (URL 规范化等)
    'django.middleware.csrf.CsrfViewMiddleware',          # CSRF 防护
    
    # --------- 认证和内容处理 ---------
    'django.contrib.auth.middleware.AuthenticationMiddleware',  # 用户认证
    'django.contrib.messages.middleware.MessageMiddleware',     # 消息框架
    
    # --------- 安全和调试 ---------
    'django.middleware.clickjacking.XFrameOptionsMiddleware',  # 点击劫持防护
    "debug_toolbar.middleware.DebugToolbarMiddleware",   # 调试工具栏 (开发用)
]


# ============================================================================
# URL 和模板配置
# ============================================================================

# 项目级 URL 配置文件位置
ROOT_URLCONF = 'lesser_root_folder.urls'

# 模板引擎配置 (用于 Django Admin 等)
TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,  # 自动寻找 app 下的 templates/
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

# ASGI 应用配置 (异步支持，WebSocket 等)
ASGI_APPLICATION = 'lesser_root_folder.asgi.application'


# ============================================================================
# 数据库配置
# ============================================================================
# 使用 PostgreSQL，连接信息从环境变量读取（由 .env.dev 提供）

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",     # PostgreSQL 数据库引擎
        "NAME": os.environ.get("POSTGRES_DB", "lesser_db"),       # 数据库名
        "USER": os.environ.get("POSTGRES_USER", "funcdfs"),        # 用户名
        "PASSWORD": os.environ.get("POSTGRES_PASSWORD", "fw142857"),  # 密码
        "HOST": os.environ.get("POSTGRES_HOST", "postgres"),       # 主机 (Docker 用服务名)
        "PORT": os.environ.get("POSTGRES_PORT", "5432"),           # 端口
    }
}

# Debug Toolbar 内部 IP (开发用)
INTERNAL_IPS = [
    "127.0.0.1",
]


# ============================================================================
# 认证和权限配置
# ============================================================================

# 自定义用户模型指定
AUTH_USER_MODEL = 'users.CustomUser'

# 密码验证器 (强度检查)
AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]


# ============================================================================
# 跨域资源共享 (CORS) 配置
# ============================================================================
# 注意: 开发环境允许所有来源，生产环境应该限制

CORS_ALLOW_ALL_ORIGINS = True
CORS_ALLOW_CREDENTIALS = True


# ============================================================================
# Django REST Framework (DRF) 配置
# ============================================================================
# REST API 的全局配置

REST_FRAMEWORK = {
    # 认证方式 (按顺序尝试)
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.TokenAuthentication',        # Token 认证
        'rest_framework.authentication.SessionAuthentication',      # Session 认证
        'rest_framework.authentication.BasicAuthentication',        # Basic Auth
    ],
    
    # 默认权限检查 (所有视图都要求认证)
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    
    # 分页配置
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
    
    # 过滤和排序
    'DEFAULT_FILTER_BACKENDS': [
        'rest_framework.filters.SearchFilter',
        'rest_framework.filters.OrderingFilter',
    ],
}


# ============================================================================
# 国际化和时区配置
# ============================================================================

LANGUAGE_CODE = 'zh-hans'      # 中文 (简体)
TIME_ZONE = 'Asia/Shanghai'    # 上海时区
USE_I18N = True                # 启用国际化
USE_TZ = True                  # 使用时区感知时间


# ============================================================================
# 静态文件配置 (CSS, JavaScript, 图片等)
# ============================================================================

STATIC_URL = '/static/'