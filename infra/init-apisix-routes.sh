#!/bin/bash

# APISIX 初始化脚本
#
# 为 APISIX 网关初始化路由和上游配置
#
# 功能：
#   1. 创建后端服务的上游配置
#   2. 创建路由规则（Django API、WebSocket 等）
#   3. 配置 CORS 和请求 ID 插件
#
# 用法:
#   ./init-apisix-routes.sh

set -e

# APISIX 管理 API 地址
APISIX_ADMIN="http://localhost:9180"
APISIX_ADMIN_KEY="edd1c9f034335f136f87ad84b625c8f1"

# 色彩输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'  # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 等待 APISIX 启动
wait_for_apisix() {
    local max_attempts=30
    local attempt=1
    
    log_info "等待 APISIX 启动..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s -o /dev/null -w "%{http_code}" "$APISIX_ADMIN/apisix/admin/healthz" | grep -q "200"; then
            log_info "APISIX 已准备就绪"
            return 0
        fi
        
        echo -n "."
        sleep 1
        attempt=$((attempt + 1))
    done
    
    log_error "APISIX 启动超时"
    return 1
}

# 主函数
main() {
    log_info "开始初始化 APISIX 路由配置..."
    
    # 等待 APISIX 启动
    if ! wait_for_apisix; then
        log_error "APISIX 未启动，请检查日志"
        exit 1
    fi
    
    # 创建路由 - Django API
    log_info "创建 Django API 路由..."
    curl -X POST "$APISIX_ADMIN/apisix/admin/routes" \
        -H "X-API-Key: $APISIX_ADMIN_KEY" \
        -H "Content-Type: application/json" \
        -d '{
            "name": "django-api",
            "uri": "/api/*",
            "methods": ["GET", "POST", "PUT", "DELETE", "PATCH"],
            "upstream": {
                "type": "roundrobin",
                "nodes": {
                    "django:8000": 100
                }
            },
            "plugins": {
                "cors": {
                    "allow_origins": "*",
                    "allow_methods": "GET,POST,PUT,DELETE,PATCH,OPTIONS",
                    "allow_headers": "Content-Type,Authorization,X-Requested-With",
                    "expose_headers": "Content-Length,Content-Range"
                },
                "request-id": {
                    "header_name": "X-Request-ID",
                    "include_resp_header": true
                }
            }
        }' \
        -o /dev/null -w "HTTP %{http_code}\n"
    
    # 创建路由 - 健康检查
    log_info "创建健康检查路由..."
    curl -X POST "$APISIX_ADMIN/apisix/admin/routes" \
        -H "X-API-Key: $APISIX_ADMIN_KEY" \
        -H "Content-Type: application/json" \
        -d '{
            "name": "health-check",
            "uri": "/health",
            "methods": ["GET"],
            "upstream": {
                "type": "roundrobin",
                "nodes": {
                    "django:8000": 100
                }
            }
        }' \
        -o /dev/null -w "HTTP %{http_code}\n"
    
    # 创建路由 - WebSocket（可选）
    log_info "创建 WebSocket 路由..."
    curl -X POST "$APISIX_ADMIN/apisix/admin/routes" \
        -H "X-API-Key: $APISIX_ADMIN_KEY" \
        -H "Content-Type: application/json" \
        -d '{
            "name": "websocket",
            "uri": "/ws/*",
            "methods": ["GET"],
            "upstream": {
                "type": "roundrobin",
                "nodes": {
                    "django:8000": 100
                }
            },
            "plugins": {
                "proxy-rewrite": {
                    "scheme": "ws"
                }
            }
        }' \
        -o /dev/null -w "HTTP %{http_code}\n"
    
    log_info "APISIX 路由配置完成！"
    log_info "访问地址："
    log_info "  - APISIX Dashboard: http://localhost:9000/"
    log_info "  - API 网关: http://localhost:9080/"
    log_info "  - Django API: http://localhost:9080/api/"
}

# 运行主函数
main "$@"