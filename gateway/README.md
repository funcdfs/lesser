# Traefik Gateway 配置

本目录包含 Traefik 网关的配置文件，用于管理 Lesser 项目的所有服务的流量。

## 目录结构

```
gateway/
├── docker-compose.yml      # Traefik 服务的基本配置
├── traefik.yml             # Traefik 主配置文件
├── dynamic.yml             # Traefik 动态配置文件（路由规则、中间件）
├── certs/                  # SSL 证书目录
├── acme.json               # ACME 证书存储文件
└── README.md               # 本说明文件
```

## 配置说明

### traefik.yml
主配置文件，包含以下主要配置：
- 全局设置
- 日志配置
- 入口点配置（HTTP 和 HTTPS）
- API 和仪表盘配置
- 提供商配置（Docker 和文件）
- 证书解析器配置

### dynamic.yml
动态配置文件，包含以下主要配置：
- HTTP 中间件（CORS、压缩、速率限制等）
- 后端服务配置（Django、Golang、Rust、前端）
- 路由规则

## 启动方式

### 方式一：仅启动网关（与现有服务一起使用）

1. 确保已创建 `gateway_network` 网络：
```bash
docker network create gateway_network
```

2. 启动 Traefik 网关：
```bash
cd gateway
docker-compose up -d
```

3. 确保现有服务连接到 `gateway_network` 网络

### 方式二：使用整合的 docker-compose.gateway.yml

1. 在项目根目录下启动所有服务（包括网关）：
```bash
docker-compose -f docker-compose.gateway.yml up -d
```

## 访问服务

- Traefik 仪表盘：`http://localhost:8080`
- 前端服务：`https://localhost/`
- Django 后端：`https://localhost/api/`
- Golang 热点服务：`https://localhost/hot/`
- Rust Feed 服务：`https://localhost/feed/`

## 配置修改

### 添加新服务

1. 在 `dynamic.yml` 的 `http.services` 部分添加新服务配置
2. 在 `http.routers` 部分添加相应的路由规则
3. 重启 Traefik 服务：
```bash
docker-compose -f docker-compose.gateway.yml restart traefik
```

### 修改中间件

在 `dynamic.yml` 的 `http.middlewares` 部分修改或添加中间件配置，然后重启 Traefik 服务。

## 注意事项

1. 首次启动时，Traefik 会自动为配置的域名申请 SSL 证书（Let's Encrypt）
2. `acme.json` 文件必须具有 600 权限，否则证书申请会失败
3. 在生产环境中，建议关闭 Traefik 仪表盘的不安全访问，配置适当的认证
4. 请根据实际需求调整速率限制、CORS 等中间件配置

## 参考文档

- [Traefik 官方文档](https://doc.traefik.io/traefik/)
- [Traefik GitHub 仓库](https://github.com/traefik/traefik)