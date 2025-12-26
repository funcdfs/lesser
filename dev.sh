#!/bin/bash
# Lesser 项目开发脚本
# 用法: ./dev.sh [命令]

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 加载环境变量
if [ -f "$PROJECT_ROOT/.env.dev" ]; then
    export $(grep -v '^#' "$PROJECT_ROOT/.env.dev" | grep -v '^$' | xargs)
fi

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${CYAN}ℹ $1${NC}"; }
log_success() { echo -e "${GREEN}✓ $1${NC}"; }
log_warn() { echo -e "${YELLOW}⚠ $1${NC}"; }
log_error() { echo -e "${RED}✗ $1${NC}"; }

COMPOSE_FILE="$PROJECT_ROOT/infra/docker-compose.yml"

# 命令函数
cmd_start() {
    local target="${1:-all}"
    case "$target" in
        db)
            log_info "启动数据库服务..."
            docker-compose -f "$COMPOSE_FILE" up -d postgres redis
            ;;
        django)
            log_info "启动 Django + 数据库..."
            docker-compose -f "$COMPOSE_FILE" up -d postgres redis django
            sleep 3
            docker exec django python manage.py migrate 2>/dev/null || true
            ;;
        gateway)
            log_info "启动网关服务..."
            docker-compose -f "$COMPOSE_FILE" up -d etcd apisix apisix-dashboard
            sleep 5
            cmd_routes
            ;;
        all|"")
            log_info "启动所有服务..."
            docker-compose -f "$COMPOSE_FILE" up -d
            sleep 5
            # 修复 PostgreSQL 密码问题
            docker exec postgres psql -U funcdfs -d lesser_db -c "ALTER USER funcdfs WITH PASSWORD 'fw142857';" 2>/dev/null || true
            sleep 2
            docker exec django python manage.py migrate 2>/dev/null || true
            docker exec django python manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='funcdfs').exists():
    User.objects.create_superuser('funcdfs', 'funcdfs@localhost', 'fw142857')
" 2>/dev/null || true
            # 配置 APISIX 路由
            cmd_routes
            ;;
        *)
            log_error "未知目标: $target"
            echo "可用: db, django, gateway, all"
            exit 1
            ;;
    esac
    log_success "启动完成"
    cmd_status
}

cmd_stop() {
    log_info "停止所有服务..."
    docker-compose -f "$COMPOSE_FILE" down
    log_success "已停止"
}

cmd_restart() {
    local service="${1:-django}"
    log_info "重启 $service..."
    docker-compose -f "$COMPOSE_FILE" restart "$service"
    log_success "$service 已重启"
}

cmd_logs() {
    local service="${1:-django}"
    docker-compose -f "$COMPOSE_FILE" logs -f "$service"
}

cmd_status() {
    echo ""
    docker-compose -f "$COMPOSE_FILE" ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
    echo ""
    echo "服务地址:"
    echo "  Django Admin:     http://localhost:8001/admin/"
    echo "  APISIX Dashboard: http://localhost:9000/"
    echo "  APISIX Gateway:   http://localhost:9080/"
    echo ""
    echo "管理员: funcdfs / fw142857"
}

cmd_clean() {
    log_warn "将删除所有数据！"
    read -p "确认? (yes/no): " confirm
    if [ "$confirm" = "yes" ]; then
        docker-compose -f "$COMPOSE_FILE" down -v
        log_success "已清理"
    else
        log_info "已取消"
    fi
}

cmd_reset() {
    log_info "重置数据库..."
    docker exec django python manage.py flush --no-input 2>/dev/null || true
    docker exec django python manage.py migrate 2>/dev/null || true
    docker exec django python manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
User.objects.create_superuser('funcdfs', 'funcdfs@localhost', 'fw142857')
" 2>/dev/null || true
    log_success "数据库已重置"
}

cmd_routes() {
    log_info "配置 APISIX 路由..."
    
    # 等待 APISIX 启动
    local max_attempts=30
    local attempt=0
    while [ $attempt -lt $max_attempts ]; do
        if curl -s -o /dev/null -w "%{http_code}" "http://localhost:9180/apisix/admin/routes" \
            -H "X-API-KEY: fw142857" 2>/dev/null | grep -q "200\|404"; then
            break
        fi
        attempt=$((attempt + 1))
        log_info "等待 APISIX 启动... ($attempt/$max_attempts)"
        sleep 2
    done
    
    if [ $attempt -eq $max_attempts ]; then
        log_error "APISIX 未能在预期时间内启动"
        exit 1
    fi
    
    # 执行路由配置脚本
    bash "$PROJECT_ROOT/infra/apisix/setup_routes.sh"
    log_success "APISIX 路由配置完成"
}

cmd_shell() {
    local target="${1:-django}"
    case "$target" in
        django)
            docker exec -it django python manage.py shell
            ;;
        db)
            docker exec -it postgres psql -U funcdfs -d lesser_db
            ;;
        *)
            docker exec -it "$target" /bin/sh
            ;;
    esac
}

cmd_help() {
    cat << 'EOF'
Lesser 开发脚本

用法: ./dev.sh [命令] [参数]

启动命令:
  start [target]    启动服务
                    target: all(默认), db, django, gateway
  stop              停止所有服务
  restart [svc]     重启服务 (默认: django)
  status            查看状态

日志和调试:
  logs [svc]        查看日志 (默认: django)
  shell [target]    进入 shell (django/db)

数据管理:
  clean             删除所有数据和容器
  reset             重置数据库(保留结构)

网关配置:
  routes            配置 APISIX 路由 (用户认证等)

示例:
  ./dev.sh                  # 启动所有
  ./dev.sh start db         # 只启动数据库
  ./dev.sh start django     # 启动 Django + 数据库
  ./dev.sh routes           # 配置 APISIX 路由
  ./dev.sh logs             # 查看 Django 日志
  ./dev.sh shell db         # 进入数据库
EOF
}

# 主入口
case "${1:-start}" in
    start)   cmd_start "${2:-}" ;;
    stop)    cmd_stop ;;
    restart) cmd_restart "${2:-django}" ;;
    logs)    cmd_logs "${2:-django}" ;;
    status)  cmd_status ;;
    clean)   cmd_clean ;;
    reset)   cmd_reset ;;
    routes)  cmd_routes ;;
    shell)   cmd_shell "${2:-django}" ;;
    help|-h) cmd_help ;;
    *)
        log_error "未知命令: $1"
        cmd_help
        exit 1
        ;;
esac
