# Lesser 项目综合指南

## 1. 项目架构概述

本项目采用现代化的微服务架构，使用 API Gateway（Traefik）作为所有服务的统一入口，服务间通过 gRPC 进行通信。

### 1.1 整体架构

```
Flutter / 原生客户端
   │ HTTPS / JSON
   ▼
API Gateway (Traefik)
   │ 路径分发
   ├─ /api/ → Django REST
   │          │ gRPC → Go Service / Python ML
   │          ▼
   │       Redis / PostgreSQL
   │
   ├─ /hot/ → Go Service REST/gRPC
   │          │
   │          ▼
   │       Redis / PostgreSQL
   │
   ├─ /feed/ → Rust Service REST/gRPC
   │          │
   │          ▼
   │       Redis / PostgreSQL
   │
   └─ / → 前端服务
```

### 1.2 技术栈

- **后端**: Django 5.0 + Django Ninja (异步 API, 自动生成 Swagger 文档)
- **前端**: Flutter (采用 Feature-First 结构) + Riverpod 2.0 (状态管理) + Dio (网络层)
- **API 网关**: Traefik 3.0
- **通信**: RESTful API / gRPC
- **数据库**: PostgreSQL (结构化数据) + Redis (缓存/会话)
- **其他服务**: Golang (热点服务) + Rust (Feed 服务)

## 2. 快速启动

### 2.1 后端 (Django)

```bash
cd backend/django_code
# 激活环境
source .venv/bin/activate
# 安装依赖
uv install
# 数据库迁移
python manage.py migrate
# 启动服务
python manage.py runserver
# 创建超级用户
python manage.py createsuperuser
```

- **API 文档**: [http://127.0.0.1:8000/api/docs](http://127.0.0.1:8000/api/docs)
- **管理后台**: [http://127.0.0.1:8000/admin/](http://127.0.0.1:8000/admin/)

### 2.2 前端 (Flutter)

```bash
cd frontend
# 安装依赖
flutter pub get
# 运行代码生成
flutter pub run build_runner build --delete-conflicting-outputs
# 启动应用（Chrome）
flutter run -d chrome
# 启动应用（macOS）
flutter run -d macos
# 启动应用（Android 设备）
flutter run -d <device_id>
# 启动应用（iOS 设备）
flutter run -d <device_id>
```

### 2.3 使用 Docker 启动整个项目

```bash
cd /Users/w/F/make_money_idea/lesser
# 开发环境
docker-compose -f docker-compose.dev.yml up -d
# API 网关环境
docker-compose -f docker-compose.gateway.yml up -d
```

## 3. 开发指南

### 3.1 后端开发 (Django)

#### 3.1.1 本地开发与调试

```bash
# 进入后端目录
cd backend/django_code

# 激活虚拟环境
source .venv/bin/activate

# 启动开发服务器
python manage.py runserver

# 数据库迁移
python manage.py makemigrations
python manage.py migrate
python manage.py showmigrations

# 交互式调试 (Shell)
python manage.py shell

# 健康检查
curl http://127.0.0.1:8000/health
```

#### 3.1.2 API 与文档

- **Swagger UI**: `http://127.0.0.1:8000/api/docs` (推荐，可直接测试接口)
- **Redoc**: `http://127.0.0.1:8000/api/redoc`

#### 3.1.3 代码质量控制 (Ruff)

```bash
# 代码检查 (Lint)
ruff check .

# 自动修复常见错误
ruff check . --fix

# 代码格式化 (Format)
ruff format .
```

#### 3.1.4 添加新功能

1. **定义模型**：在应用的 `models.py` 中添加新模型
2. **创建视图**：在 `views.py` 中实现业务逻辑
3. **配置路由**：在 `urls.py` 中添加路由规则
4. **数据库迁移**：运行 `makemigrations` 和 `migrate`

### 3.2 前端开发 (Flutter)

#### 3.2.1 常用命令行

```bash
# 安装依赖
flutter pub get

# 运行代码生成
flutter pub run build_runner build --delete-conflicting-outputs
flutter pub run build_runner watch

# 运行应用
flutter run -d chrome
flutter run -d macos
flutter run -d <device_id>

# 打包应用
# Android
flutter build apk
# iOS
flutter build ios
# Web
flutter build web
```

#### 3.2.2 接入新接口

1. **定义模型**：在 `domain/models/` 创建 `.dart` 文件，使用 `@freezed` 定义数据结构
2. **创建仓库**：在 `data/` 下创建仓库类，继承 `BaseRepository`，调用 `apiClient.dio`
3. **定义 Provider**：在 `presentation/providers/` 使用 `@riverpod` 定义数据流
4. **生成代码**：运行 `build_runner`
5. **UI 绑定**：在 Widget 中使用 `ref.watch(provider)`

## 4. API 网关 (Traefik) 使用指南

### 4.1 添加新功能（服务）

#### 4.1.1 创建新的后端服务

以添加一个新的 Python 推荐服务为例：

```bash
# 创建服务目录
mkdir -p /Users/w/F/make_money_idea/lesser/backend/python_recommend

# 创建服务文件
cat > /Users/w/F/make_money_idea/lesser/backend/python_recommend/main.py << 'EOF'
from fastapi import FastAPI

app = FastAPI()

@app.get("/health")
async def health_check():
    return {"status": "ok"}

@app.get("/api/recommend/{user_id}")
async def get_recommendations(user_id: int):
    # 实现推荐逻辑
    return {"user_id": user_id, "recommendations": [1, 2, 3]}
EOF

# 创建 Dockerfile
cat > /Users/w/F/make_money_idea/lesser/backend/python_recommend/Dockerfile << 'EOF'
FROM python:3.11-slim

WORKDIR /app

RUN pip install fastapi uvicorn

COPY . .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8082"]
EOF
```

#### 4.1.2 在 Docker Compose 中添加服务

修改 `docker-compose.dev.yml`，添加新服务：

```yaml
# Python推荐服务
python_recommend:
  build: ./backend/python_recommend
  restart: unless-stopped
  depends_on:
    - redis
    - postgres
  healthcheck:
    test: ["CMD", "curl", "-f", "http://localhost:8082/health"]
    interval: 10s
    timeout: 5s
    retries: 5
  networks:
    - gateway
  labels:
    - "traefik.enable=true"
    - "traefik.http.services.pythonRecommendService.loadbalancer.server.port=8082"
```

#### 4.1.3 在 Traefik 中配置路由

修改 `gateway/dynamic.yml`，添加新的服务和路由配置：

```yaml
# HTTP 服务配置
services:
  # 现有服务...
  
  # Python推荐服务
  pythonRecommendService:
    loadBalancer:
      servers:
        - url: "http://python_recommend:8082"

# 路由规则
routers:
  # 现有路由...
  
  # Python推荐服务路由
  pythonRecommendRouter:
    entryPoints:
      - websecure
    rule: "PathPrefix(`/recommend/`)"
    service: pythonRecommendService
    middlewares:
      - corsHeaders
      - compress
    tls:
      certResolver: myresolver
```

#### 4.1.4 重启服务

```bash
cd /Users/w/F/make_money_idea/lesser && docker-compose -f docker-compose.dev.yml up -d --build python_recommend
```

### 4.2 删除功能（服务）

#### 4.2.1 在 Traefik 中移除路由配置

修改 `gateway/dynamic.yml`，删除对应的服务和路由配置

#### 4.2.2 在 Docker Compose 中移除服务

修改 `docker-compose.dev.yml`，删除对应的服务配置

#### 4.2.3 停止并移除服务

```bash
cd /Users/w/F/make_money_idea/lesser && docker-compose -f docker-compose.dev.yml down python_recommend
```

#### 4.2.4 删除服务代码（可选）

```bash
rm -rf /Users/w/F/make_money_idea/lesser/backend/python_recommend
```

### 4.3 服务间使用 gRPC 通信

#### 4.3.1 定义 gRPC 协议

创建 `.proto` 文件定义服务接口：

```bash
mkdir -p /Users/w/F/make_money_idea/lesser/proto

cat > /Users/w/F/make_money_idea/lesser/proto/recommend.proto << 'EOF'
syntax = "proto3";

package recommend;

service RecommendService {
  rpc GetRecommendations (RecommendationRequest) returns (RecommendationResponse);
}

message RecommendationRequest {
  int32 user_id = 1;
  int32 limit = 2;
}

message RecommendationResponse {
  repeated int32 item_ids = 1;
  string message = 2;
}
EOF
```

## 5. 部署与生产环境

### 5.1 后端部署 (Django)

#### 5.1.1 导出依赖项

```bash
# 更新 requirements.txt
pip freeze > requirements.txt
```

#### 5.1.2 收集静态资源

```bash
# 部署前将所有静态文件收集到指定目录
python manage.py collectstatic
```

#### 5.1.3 生产服务器模拟 (Gunicorn/Uvicorn)

```bash
# 使用 WSGI (同步)
gunicorn config.wsgi:application --bind 0.0.0.0:8000

# 使用 ASGI (异步, 推荐配 Django Ninja)
uvicorn config.api:api --host 0.0.0.0 --port 8000 --reload
# 或者启动整个 Django 应用
uvicorn config.asgi:application --host 0.0.0.0 --port 8000 --reload
```

### 5.2 前端部署 (Flutter)

```bash
# Web 部署
flutter build web
# 生成的文件在 build/web 目录

# Android 部署
flutter build apk
# 生成的文件在 build/app/outputs/flutter-apk/app-release.apk

# iOS 部署
flutter build ios
# 生成的文件在 build/ios/iphoneos/Runner.app
```

## 6. 项目结构

### 6.1 后端结构

```
backend/
├── django_code/          # Django 后端
│   ├── lesser/          # 项目核心配置
│   │   ├── settings.py  # 项目配置
│   │   ├── urls.py      # 主路由
│   │   ├── asgi.py      # ASGI 入口
│   │   └── wsgi.py      # WSGI 入口
│   ├── feeds/           # 帖子应用
│   │   ├── models.py    # 数据模型
│   │   ├── views.py     # 视图逻辑
│   │   ├── urls.py      # 应用路由
│   │   └── serializers.py # 序列化器
│   ├── users/           # 用户应用
│   │   ├── models.py    # 数据模型
│   │   ├── views.py     # 视图逻辑
│   │   ├── urls.py      # 应用路由
│   │   └── serializers.py # 序列化器
│   ├── manage.py        # 管理脚本
│   └── pyproject.toml   # 项目依赖
├── golang_hot/          # Golang 热点服务
└── rust_feed/           # Rust Feed 服务
```

### 6.2 前端结构

```
frontend/
├── lib/
│   ├── app/             # 应用核心
│   │   ├── app.dart     # 应用入口
│   │   ├── app_router.dart # 路由配置
│   │   └── app_theme.dart # 主题配置
│   ├── core/            # 核心功能
│   │   ├── config/      # 配置
│   │   ├── data/        # 数据层
│   │   └── network/     # 网络层
│   ├── features/        # 功能模块
│   │   ├── auth/        # 认证
│   │   ├── chat/        # 聊天
│   │   ├── feeds/       # 帖子
│   │   └── search/      # 搜索
│   └── shared/          # 共享组件
│       ├── models/      # 数据模型
│       ├── utils/       # 工具函数
│       └── widgets/     # 自定义组件
└── main.dart            # 应用入口
```

### 6.3 网关结构

```
gateway/
├── traefik.yml          # Traefik 主配置
├── dynamic.yml          # Traefik 动态配置
└── certs/               # SSL 证书
```

## 7. 流程梳理

### 7.1 应用流程

#### 7.1.1 各层架构

1. **用户界面层**：Flutter客户端
   - 提供跨平台的用户界面
   - 实现响应式设计
   - 管理本地状态和用户交互
   - 处理网络请求和响应

2. **API网关层**：Traefik
   - 接收来自客户端的HTTPS请求
   - 根据路径进行请求分发
   - 提供负载均衡和SSL终止

3. **应用服务层**
   - **Django REST API** (`/api/`路径)：用户认证、社交功能、媒体管理
   - **Go服务** (`/hot/`路径)：内容推荐、实时动态流
   - **Rust服务** (`/feed/`路径)：Feed处理

4. **数据存储层**
   - **PostgreSQL**：存储结构化数据（用户信息、帖子、评论等）
   - **Redis**：缓存热点数据、管理会话、实时消息队列

#### 7.1.2 典型用户操作流程

**发布帖子流程**
1. 用户在Flutter客户端编写并提交帖子
2. 客户端通过HTTPS发送JSON数据到API网关
3. API网关将请求转发到Django REST API
4. Django验证用户身份和请求数据
5. Django将帖子内容存储到PostgreSQL
6. Django更新Redis中的相关计数器和缓存
7. Django通过gRPC通知Go服务更新用户动态流
8. Go服务更新推荐算法数据
9. Django返回成功响应给客户端

**内容流加载流程**
1. 用户在Flutter客户端请求内容流
2. 客户端通过HTTPS发送请求到API网关
3. API网关将请求转发到Go服务
4. Go服务查询Redis缓存获取热点内容
5. 如果缓存未命中，Go服务查询PostgreSQL
6. Go服务应用推荐算法排序内容
7. Go服务返回内容数据给客户端
8. 客户端渲染内容流

### 7.2 优化建议

1. **异步处理**：Django端尽量使用Async Views (ASGI)来调用gRPC，或者使用Celery/Task Queue异步处理非实时请求
2. **缓存策略**：优化Redis缓存策略，合理设置过期时间
3. **负载均衡**：根据服务负载情况动态调整Traefik的负载均衡策略
4. **数据分片**：对于大规模数据，考虑PostgreSQL的分片策略
5. **CDN加速**：对静态资源和媒体内容使用CDN加速

### 7.3 安全考虑

1. **HTTPS**：所有外部通信必须使用HTTPS
2. **认证授权**：实现Token Authentication机制
3. **输入验证**：所有API输入必须严格验证
4. **SQL注入防护**：使用参数化查询
5. **CSRF防护**：实现CSRF令牌机制
6. **XSS防护**：对用户输入进行过滤和转义

## 8. 开发记录

### 8.1 UI 优化建议

- 首页底部按钮对齐，数字和汉字单位之间添加空格
- 首页 item 的三个小点右侧对齐
- 优化点赞、转发、评论的 hover 动画
- 实现点赞和取消点赞动画
- 文章详情页面展示具体时间戳
- 列出书签和分享数量
- Reels 在宽屏时保持原有的最大宽度
- 宽屏左侧导航栏优化

### 8.2 "我的"界面调整

- **用户卡片**：头像、昵称、ID、简介、编辑按钮
- **统计信息**：关注、好友、粉丝数量
- **内容记录**：reels、文章发布记录、GitHub heatmap图
- **文字管理**：草稿箱、状态管理、帖子管理、专栏管理等
- **设置**：通用设置、切换账号、退出登录

### 8.3 聊天界面优化

- 优化聊天界面的图标
- 在头像基础上修改群组聊天标识
- 底部导航顺序调整：我的好友、我的粉丝、我的关注、创建群聊、创建频道、添加好友

## 9. 进阶技巧

- **代码生成**：修改任何带有 `part 'filename.g.dart'` 或 `part 'filename.freezed.dart'` 的文件后，必须运行 `build_runner`
- **网络调试**：应用集成了 `LogInterceptor`，所有 API 请求都会在控制台打印详细的 Curl 日志
- **跨域设置**：`settings.py` 中的 `CORS_ORIGIN_ALLOW_ALL = True` 确保了开发环境下前端可以轻松访问后端
- **异步处理**：使用 Django 的 Async Views 和 ASGI 提高性能
- **缓存优化**：合理使用 Redis 缓存热点数据

## 10. 联系方式与支持

如有问题或建议，请联系项目维护团队。

---

更新时间：2025-12-23