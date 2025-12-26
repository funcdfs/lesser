#!/bin/bash
# APISIX 路由配置脚本
# 用途: 配置用户认证相关的 API 路由
# 用法: ./setup_routes.sh
#
# 此脚本通过 APISIX Admin API 配置以下路由:
#   - /api/users/* -> Django 后端
#
# 前置条件:
#   - APISIX 和 etcd 服务已启动
#   - Django 后端服务已启动

set -euo pipefail

# 配置
APISIX_ADMIN_URL="${APISIX_ADMIN_URL:-http://localhost:9180}"
APISIX_ADMIN_KEY="${APISIX_ADMIN_KEY:-fw142857}"
DJANGO_UPSTREAM="${DJANGO_UPSTREAM:-django:8000}"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${YELLOW}ℹ $1${NC}"; }
log_success() { echo -e "${GREEN}✓ $1${NC}"; }
log_error() { echo -e "${RED}✗ $1${NC}"; }

# 检查 APISIX 是否可用
check_apisix() {
    log_info "检查 APISIX Admin API..."
    if ! curl -s -o /dev/null -w "%{http_code}" "${APISIX_ADMIN_URL}/apisix/admin/routes" \
        -H "X-API-KEY: ${APISIX_ADMIN_KEY}" | grep -q "200\|404"; then
        log_error "无法连接到 APISIX Admin API: ${APISIX_ADMIN_URL}"
        exit 1
    fi
    log_success "APISIX Admin API 可用"
}

# 创建 Django 上游服务
create_upstream() {
    log_info "创建 Django 上游服务..."
    
    curl -s -X PUT "${APISIX_ADMIN_URL}/apisix/admin/upstreams/1" \
        -H "X-API-KEY: ${APISIX_ADMIN_KEY}" \
        -H "Content-Type: application/json" \
        -d '{
            "name": "django-backend",
            "desc": "Django REST API 后端服务",
            "type": "roundrobin",
            "nodes": {
                "'"${DJANGO_UPSTREAM}"'": 1
            },
            "timeout": {
                "connect": 6,
                "send": 6,
                "read": 6
            },
            "keepalive_pool": {
                "size": 320,
                "idle_timeout": 60,
                "requests": 1000
            }
        }' > /dev/null
    
    log_success "Django 上游服务已创建"
}

# 创建用户认证路由 (最小化配置)
create_user_routes() {
    log_info "创建用户认证路由..."
    
    # 路由: /api/users/* -> Django 后端
    # 启用 CORS 插件以支持跨域请求
    curl -s -X PUT "${APISIX_ADMIN_URL}/apisix/admin/routes/1" \
        -H "X-API-KEY: ${APISIX_ADMIN_KEY}" \
        -H "Content-Type: application/json" \
        -d '{
            "name": "user-auth-routes",
            "desc": "用户认证相关路由 (register, login, logout, profile)",
            "uri": "/api/users/*",
            "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
            "upstream_id": 1,
            "plugins": {
                "cors": {
                    "allow_origins": "*",
                    "allow_methods": "GET,POST,PUT,DELETE,OPTIONS",
                    "allow_headers": "Authorization,Content-Type,Accept,Origin,X-Requested-With",
                    "expose_headers": "*",
                    "max_age": 3600,
                    "allow_credential": false
                }
            },
            "status": 1
        }' > /dev/null
    
    log_success "用户认证路由已创建"
}

# 创建健康检查路由
create_health_route() {
    log_info "创建健康检查路由..."
    
    curl -s -X PUT "${APISIX_ADMIN_URL}/apisix/admin/routes/2" \
        -H "X-API-KEY: ${APISIX_ADMIN_KEY}" \
        -H "Content-Type: application/json" \
        -d '{
            "name": "health-check",
            "desc": "健康检查路由",
            "uri": "/health/*",
            "methods": ["GET"],
            "upstream_id": 1,
            "status": 1
        }' > /dev/null
    
    log_success "健康检查路由已创建"
}

# 验证路由配置
verify_routes() {
    log_info "验证路由配置..."
    
    echo ""
    echo "已配置的路由:"
    curl -s "${APISIX_ADMIN_URL}/apisix/admin/routes" \
        -H "X-API-KEY: ${APISIX_ADMIN_KEY}" | \
        python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    routes = data.get('list', data.get('node', {}).get('nodes', []))
    if isinstance(routes, dict):
        routes = [{'value': v, 'key': k} for k, v in routes.items()]
    for route in routes:
        r = route.get('value', route)
        print(f\"  - {r.get('name', 'unnamed')}: {r.get('uri', 'N/A')} -> upstream_id={r.get('upstream_id', 'N/A')}\")
except Exception as e:
    print(f'  解析失败: {e}')
" 2>/dev/null || echo "  (无法解析响应)"
    
    echo ""
    log_success "路由配置完成"
}

# 显示测试命令
show_test_commands() {
    echo ""
    echo "测试命令:"
    echo "  # 健康检查"
    echo "  curl http://localhost:9080/health/"
    echo ""
    echo "  # 用户注册"
    echo "  curl -X POST http://localhost:9080/api/users/register/ \\"
    echo "    -H 'Content-Type: application/json' \\"
    echo "    -d '{\"username\":\"testuser\",\"email\":\"test@example.com\",\"password\":\"testpass123\",\"password1\":\"testpass123\",\"password2\":\"testpass123\"}'"
    echo ""
    echo "  # 用户登录"
    echo "  curl -X POST http://localhost:9080/api/users/login/ \\"
    echo "    -H 'Content-Type: application/json' \\"
    echo "    -d '{\"username\":\"testuser\",\"password\":\"testpass123\"}'"
    echo ""
}

# 主函数
main() {
    echo "=========================================="
    echo "APISIX 用户认证路由配置"
    echo "=========================================="
    echo ""
    
    check_apisix
    create_upstream
    create_user_routes
    create_health_route
    verify_routes
    show_test_commands
    
    echo "=========================================="
    echo "配置完成！"
    echo "=========================================="
}

main "$@"
