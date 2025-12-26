# APISIX 快速参考指南

## 目录结构

```
infra/
├── docker-compose.yml              # 开发环境完整配置
├── docker-compose.prod.yml         # 生产环境配置
├── .env.example                    # 开发环境变量示例
├── .env.prod.example               # 生产环境变量示例
├── init-apisix-routes.sh          # APISIX 路由初始化脚本
├── apisix/
│   ├── config.yaml                # 开发 APISIX 配置
│   ├── config.prod.yaml           # 生产 APISIX 配置
│   ├── dashboard_conf.yaml        # 开发 Dashboard 配置
│   ├── dashboard_conf.prod.yaml   # 生产 Dashboard 配置
│   └── nginx.conf                 # (可选) NGINX 配置
├── traefik/                       # (废弃) Traefik 配置已删除
├── etcd/                          # etcd 配置
└── postgres/
    └── data/                      # PostgreSQL 数据
```

## 开发环境快速开始

### 1. 启动服务

```bash
cd infra

# 启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps
```

### 2. 初始化路由

```bash
# 等待 APISIX 完全启动（约 10 秒）
./init-apisix-routes.sh
```

### 3. 验证服务

```bash
# 测试网关
curl http://localhost:9080/health

# 测试 API
curl http://localhost:9080/api/your-endpoint

# 查看 Dashboard
open http://localhost:9000
```

## 生产环境部署

### 1. 准备环境

```bash
cd infra

# 复制环境配置
cp .env.prod.example .env.prod

# 编辑配置文件
nano .env.prod  # 修改敏感信息

# 生成强密钥
openssl rand -hex 32  # 用于 APISIX_ADMIN_KEY
```

### 2. 启动服务

```bash
# 启动生产环境
docker-compose -f docker-compose.prod.yml up -d

# 初始化路由
./init-apisix-routes.sh
```

### 3. 验证部署

```bash
# 查看所有服务
docker-compose -f docker-compose.prod.yml ps

# 查看日志
docker-compose -f docker-compose.prod.yml logs -f

# 健康检查
curl http://localhost:9080/health
```

## 常用命令

### 查看日志

```bash
# 所有服务日志
docker-compose logs -f

# 特定服务日志
docker-compose logs -f apisix
docker-compose logs -f django
docker-compose logs -f postgres
docker-compose logs -f redis

# 查看最后 100 行
docker-compose logs --tail=100
```

### 重启服务

```bash
# 重启所有服务
docker-compose restart

# 重启特定服务
docker-compose restart apisix
docker-compose restart django

# 完全重建
docker-compose up -d --force-recreate
```

### 进入容器

```bash
# 进入 Django 容器
docker-compose exec django bash

# 进入 PostgreSQL 容器
docker-compose exec postgres psql -U funcdfs -d lesser_db

# 进入 Redis 容器
docker-compose exec redis redis-cli
```

### 清理资源

```bash
# 停止服务
docker-compose down

# 删除所有数据（危险！）
docker-compose down -v

# 清理未使用的镜像和卷
docker system prune -a --volumes
```

## APISIX 管理 API

### 常用端点

| 方法 | 端点 | 说明 |
|-----|------|------|
| GET | `/apisix/admin/routes` | 列出所有路由 |
| POST | `/apisix/admin/routes` | 创建路由 |
| GET | `/apisix/admin/routes/{id}` | 获取路由详情 |
| PUT | `/apisix/admin/routes/{id}` | 更新路由 |
| DELETE | `/apisix/admin/routes/{id}` | 删除路由 |
| GET | `/apisix/admin/upstreams` | 列出上游 |
| POST | `/apisix/admin/upstreams` | 创建上游 |
| GET | `/apisix/admin/plugins` | 列出所有插件 |

### 示例请求

```bash
# 查看所有路由
curl -H "X-API-Key: edd1c9f034335f136f87ad84b625c8f1" \
  http://localhost:9180/apisix/admin/routes

# 创建新路由
curl -X POST http://localhost:9180/apisix/admin/routes \
  -H "X-API-Key: edd1c9f034335f136f87ad84b625c8f1" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "my-route",
    "uri": "/my-api/*",
    "upstream": {
      "type": "roundrobin",
      "nodes": {
        "backend:8000": 100
      }
    }
  }'

# 删除路由
curl -X DELETE http://localhost:9180/apisix/admin/routes/1 \
  -H "X-API-Key: edd1c9f034335f136f87ad84b625c8f1"
```

## Dashboard 使用

### 访问

- URL: http://localhost:9000/
- 默认用户: `admin`
- 默认密码: `admin`

### 功能

1. **路由管理**
   - 创建、编辑、删除路由
   - 配置上游和负载均衡
   - 实时预览配置

2. **插件管理**
   - 启用/禁用插件
   - 配置插件参数
   - 查看插件文档

3. **认证管理**
   - API Key 认证
   - JWT 认证
   - OAuth 2.0 集成

4. **监控**
   - 实时请求统计
   - 性能指标
   - 错误日志

## 性能监控

### Prometheus 指标

APISIX 暴露的指标地址：http://localhost:9091/metrics

主要指标：
- `apisix_http_status`: HTTP 状态码计数
- `apisix_http_latency`: 请求延迟
- `apisix_upstream_latency`: 上游延迟
- `apisix_nginx_http_requests_total`: 总请求数

### 导入 Grafana

1. 添加 Prometheus 数据源
2. 导入 APISIX Dashboard ID: 3688

## 故障排查

### APISIX 不响应

```bash
# 检查 APISIX 日志
docker-compose logs apisix

# 检查 etcd 连接
docker-compose logs etcd

# 重启服务
docker-compose restart apisix
```

### 路由不工作

```bash
# 验证路由是否存在
curl -H "X-API-Key: edd1c9f034335f136f87ad84b625c8f1" \
  http://localhost:9180/apisix/admin/routes

# 查看路由详情
curl -H "X-API-Key: edd1c9f034335f136f87ad84b625c8f1" \
  http://localhost:9180/apisix/admin/routes/route-id

# 测试上游连接
docker-compose exec apisix curl http://django:8000/health
```

### 数据库连接失败

```bash
# 检查 PostgreSQL 状态
docker-compose ps postgres

# 查看 PostgreSQL 日志
docker-compose logs postgres

# 测试数据库连接
docker-compose exec postgres psql -U funcdfs -d lesser_db -c "SELECT 1"
```

## 安全建议

1. **修改默认密码**
   - APISIX Admin API 密钥
   - Dashboard 用户密码
   - PostgreSQL 数据库密码
   - Redis 密码（如果启用）

2. **网络隔离**
   - 使用防火墙限制访问
   - 配置 VPN 或堡垒机
   - 限制管理 API 访问来源

3. **HTTPS 配置**
   - 配置 SSL 证书
   - 启用 HTTPS 端口 (9443)
   - 配置 HTTP → HTTPS 重定向

4. **定期备份**
   - 备份 PostgreSQL 数据
   - 备份 etcd 数据
   - 备份 APISIX 配置

## 相关文档

- [APISIX 官方文档](https://apisix.apache.org/docs)
- [APISIX 插件列表](https://apisix.apache.org/docs/apisix/plugins/api-breaker)
- [etcd 官方文档](https://etcd.io/docs)
- [Docker 官方文档](https://docs.docker.com)

## 获取帮助

- 查看日志：`docker-compose logs [service]`
- 进入容器：`docker-compose exec [service] bash`
- 检查网络：`docker-compose exec [service] ping [host]`
- 查看资源：`docker stats`
