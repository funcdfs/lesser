# 统一环境配置 (.env.dev) 使用指南

## 概述

Lesser 项目使用统一的环境配置文件 `.env.dev` 来管理所有服务的配置参数，包括：

- **PostgreSQL** 数据库配置
- **Redis** 缓存配置
- **Django** 应用配置
- **APISIX** API 网关配置
- **etcd** 配置中心
- **Flutter** 应用配置

这种统一配置方式确保了整个开发环境的一致性和可维护性。

---

## 文件位置

- **主配置文件**：`/.env.dev`（项目根目录）
- **infra 副本**：`/infra/.env.dev`（Docker Compose 使用，可选）

> ✅ **推荐**：只在项目根目录维护一个 `.env.dev` 文件

---

## 快速开始

### 1. 使用统一启动脚本

```bash
# 自动加载 .env.dev 并启动所有服务
./dev.sh start

# 查看日志
./dev.sh logs

# 停止服务
./dev.sh stop
```

### 2. 配置文件示例

`.env.dev` 文件包含以下配置类别：

```bash
# 数据库配置
POSTGRES_USER=funcdfs
POSTGRES_PASSWORD=fw142857
POSTGRES_DB=lesser_db
POSTGRES_PORT=5432

# Redis 配置
REDIS_PASSWORD=fw142857
REDIS_PORT=6379

# Django 应用配置
DJANGO_SECRET_KEY=your-secret-key
DJANGO_DEBUG=True
DJANGO_ALLOWED_HOSTS=*

# API 配置（用于 Flutter）
API_BASE_URL=http://localhost:9080/api
API_TIMEOUT=30000

# APISIX 网关配置
APISIX_HTTP_PORT=9080
APISIX_ADMIN_PORT=9180

# 其他服务配置
ETCD_PORT=2379
```

---

## 工作流程

### 启动服务的完整流程

```
./dev.sh start
  ↓
  加载 /.env.dev
  ↓
  传递给 scripts/dev.sh
  ↓
  传递给 docker-compose.yml
  ↓
  各服务使用配置启动
  │
  ├─ PostgreSQL: 使用 POSTGRES_USER, POSTGRES_PASSWORD 等
  ├─ Redis: 使用 REDIS_PASSWORD, REDIS_PORT
  ├─ Django: 使用 DJANGO_DEBUG, POSTGRES_HOST, REDIS_HOST 等
  ├─ APISIX: 使用 APISIX_HTTP_PORT, ETCD_HOST 等
  └─ Flutter: 使用 API_BASE_URL, API_TIMEOUT 等
```

---

## 各服务的配置说明

### PostgreSQL

| 参数 | 说明 | 默认值 | 来源 |
|------|------|-------|------|
| `POSTGRES_USER` | 数据库用户名 | `funcdfs` | `.env.dev` |
| `POSTGRES_PASSWORD` | 数据库密码 | `fw142857` | `.env.dev` |
| `POSTGRES_DB` | 数据库名 | `lesser_db` | `.env.dev` |
| `POSTGRES_PORT` | 数据库端口 | `5432` | `.env.dev` |
| `POSTGRES_HOST` | 主机名 | `postgres` | Docker 环境变量 |

**在 docker-compose.yml 中的使用**：

```yaml
services:
  postgres:
    env_file:
      - .env.dev
    environment:
      POSTGRES_USER: ${POSTGRES_USER:-funcdfs}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-secret}
      POSTGRES_DB: ${POSTGRES_DB:-lesser_db}
    ports:
      - "${POSTGRES_PORT:-5432}:5432"
```

### Redis

| 参数 | 说明 | 默认值 |
|------|------|-------|
| `REDIS_PASSWORD` | Redis 密码 | `fw142857` |
| `REDIS_PORT` | Redis 端口 | `6379` |
| `REDIS_HOST` | Redis 主机名 | `redis` |

### Django

| 参数 | 说明 | 默认值 | 用途 |
|------|------|-------|------|
| `DJANGO_SECRET_KEY` | Django 密钥 | 见 .env.dev | 安全加密 |
| `DJANGO_DEBUG` | 调试模式 | `True` | 开发环境设置 |
| `DJANGO_ALLOWED_HOSTS` | 允许的主机 | `*` | CORS 配置 |
| `DJANGO_LOG_LEVEL` | 日志级别 | `INFO` | 日志控制 |

**在 settings.py 中的使用**：

```python
# 自动加载 .env.dev
from dotenv import load_dotenv
load_dotenv('.env.dev')

DEBUG = os.environ.get('DJANGO_DEBUG', 'False').lower() in ('true', '1', 'yes')
SECRET_KEY = os.environ.get('DJANGO_SECRET_KEY', 'default-key')
ALLOWED_HOSTS = os.environ.get('DJANGO_ALLOWED_HOSTS', '*').split(',')
```

### APISIX 网关

| 参数 | 说明 | 默认值 |
|------|------|-------|
| `APISIX_HTTP_PORT` | HTTP 端口 | `9080` |
| `APISIX_HTTPS_PORT` | HTTPS 端口 | `9443` |
| `APISIX_ADMIN_PORT` | 管理 API 端口 | `9180` |
| `APISIX_GATEWAY_URL` | 网关地址 | `http://localhost:9080` |

### etcd 配置中心

| 参数 | 说明 | 默认值 |
|------|------|-------|
| `ETCD_HOST` | etcd 主机名 | `etcd` |
| `ETCD_PORT` | etcd 端口 | `2379` |
| `ETCD_ENDPOINTS` | etcd 连接地址 | `http://etcd:2379` |

### Flutter 应用

| 参数 | 说明 | 默认值 | 用途 |
|------|------|-------|------|
| `API_BASE_URL` | API 基础地址 | `http://localhost:9080/api` | API 客户端配置 |
| `API_TIMEOUT` | API 超时时间（ms） | `30000` | 网络超时控制 |
| `IS_PRODUCTION` | 是否生产环境 | `false` | 环境标识 |

**在 constants.dart 中的使用**：

```dart
static const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:9080/api',
);
```

**构建时传入参数**：

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:9080/api
```

---

## 实际例子

### 场景 1：本地开发环境

```bash
# .env.dev 配置
API_BASE_URL=http://localhost:9080/api
DJANGO_DEBUG=True
POSTGRES_PASSWORD=fw142857

# 运行启动脚本
./dev.sh start

# 所有服务自动读取这些配置启动
```

### 场景 2：修改数据库密码

```bash
# 编辑 .env.dev
POSTGRES_PASSWORD=my-new-secure-password

# 重启服务
./dev.sh restart postgres

# Django 会自动使用新密码连接
```

### 场景 3：切换 API 地址

```bash
# 开发环境：使用本地网关
API_BASE_URL=http://localhost:9080/api

# 生产环境：使用生产网关
API_BASE_URL=https://api.production.com
```

---

## 常见问题

### Q1: 如何在 Docker 容器内访问 .env.dev？

A: Docker Compose 使用 `env_file` 指令自动注入环境变量：

```yaml
services:
  django:
    env_file:
      - .env.dev
    environment:
      # 可覆盖或补充 env_file 中的配置
      DEBUG: ${DJANGO_DEBUG:-True}
```

### Q2: 如何在本地开发时加载 .env.dev？

A: 

**Django**：
```python
from dotenv import load_dotenv
load_dotenv('.env.dev')
```

**Flutter**：
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: '.env.dev');
  runApp(const MyApp());
}
```

### Q3: .env.dev 应该提交到 Git 吗？

A: **不应该**。建议做法：

```bash
# 在 .gitignore 中添加
echo ".env.dev" >> .gitignore
echo ".env.prod" >> .gitignore

# 提供模板文件
cp .env.dev .env.example
git add .env.example
```

### Q4: 如何在生产环境中使用不同的配置？

A: 创建 `.env.prod` 文件：

```bash
# .env.prod
API_BASE_URL=https://api.production.com
DJANGO_DEBUG=False
DJANGO_SECRET_KEY=your-production-secret-key
```

然后在启动脚本中选择：

```bash
# 开发环境
./dev.sh start  # 使用 .env.dev

# 生产环境（需修改脚本）
./dev.sh start --prod  # 使用 .env.prod
```

### Q5: 如何验证配置是否正确加载？

A: 

**Django**：
```bash
python manage.py shell
>>> import os
>>> print(os.environ.get('DJANGO_DEBUG'))
>>> print(os.environ.get('POSTGRES_HOST'))
```

**Flutter**：
```dart
import 'package:lesser/core/config/environment_config.dart';

EnvironmentConfig.printAllEnv();  // 打印所有环境变量
print(EnvironmentConfig.getApiBaseUrl());  // 检查 API 地址
```

---

## 环境变量优先级

对于所有服务，环境变量的加载优先级如下：

1. **系统环境变量** - 最高优先级（已设置的环境变量不会被覆盖）
2. **`dev.sh` 导出的环境变量** - 从 `.env.dev` 加载
3. **docker-compose.yml 中的 `env_file`** - Docker 容器内加载
4. **docker-compose.yml 中的 `environment`** - 覆盖或补充 env_file
5. **代码中的硬编码默认值** - 最低优先级

**示例**：

```bash
# 系统环境变量（优先级最高）
export POSTGRES_PASSWORD=system-password

# .env.dev 中的值（会被忽略）
POSTGRES_PASSWORD=env-dev-password

# 结果：使用 system-password
```

---

## 最佳实践

### ✅ 应该做

- ✓ 在项目根目录保持一个主 `.env.dev` 文件
- ✓ 为所有需要的配置提供合理的默认值
- ✓ 使用注释清楚地标记每个配置的用途
- ✓ 在 `.gitignore` 中忽略 `.env.dev` 和 `.env.prod`
- ✓ 提供 `.env.example` 模板文件供新开发者参考
- ✓ 在敏感配置前使用 `#` 添加说明注释
- ✓ 定期审查和更新配置文档

### ❌ 不应该做

- ✗ 将 `.env.dev` 提交到 Git
- ✗ 在代码中硬编码配置值
- ✗ 在 `.env.dev` 中保存真实的生产密钥
- ✗ 为不同的开发者创建多个版本的 `.env.dev`
- ✗ 忘记更新文档

---

## 快速命令参考

```bash
# 启动所有服务（自动加载 .env.dev）
./dev.sh start

# 查看日志
./dev.sh logs              # 查看所有日志
./dev.sh logs django       # 查看 Django 日志

# 重启特定服务
./dev.sh restart django
./dev.sh restart postgres

# 停止所有服务
./dev.sh stop

# 清理并重启（危险！）
./dev.sh clean

# 显示帮助
./dev.sh help
```

---

## 相关文件

- 主配置：`/.env.dev`
- 启动脚本：`/dev.sh`
- Docker 配置：`/infra/docker-compose.yml`
- Django 设置：`/backend/django_code/lesser_root_folder/settings.py`
- Flutter 常量：`/frontend/lib/core/config/constants.dart`
- Flutter 环境管理：`/frontend/lib/core/config/environment_config.dart`

---

## 更新日志

| 日期 | 变更 | 说明 |
|------|------|------|
| 2024-12-26 | 初始创建 | 统一环境配置文档 |

