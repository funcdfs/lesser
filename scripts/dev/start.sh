#!/bin/bash

# 启动完整后端环境脚本
#
# 依次启动以下服务：
#   - PostgreSQL 数据库
#   - Redis 缓存
#   - Django 应用服务
#   - APISIX API 网关
#   - etcd 配置中心

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
INFRA_DIR="$PROJECT_ROOT/infra"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

# 导入工具函数
source "$UTILS_DIR/colors.sh"

# 颜色变量
export DOCKER_COMPOSE_FILE="$INFRA_DIR/docker-compose.yml"

start_services() {
    print_section "Lesser 后端环境启动"
    
    # 检查依赖
    print_subsection "检查依赖"
    check_dependencies
    
    # 启动 Docker Compose
    print_subsection "启动 Docker 服务"
    start_docker_services
    
    # 初始化数据库
    print_subsection "初始化数据库"
    init_database
    
    # 显示启动完成信息
    print_success "所有服务已启动！"
    print_startup_info
    
    # 显示日志
    print_subsection "实时日志（Ctrl+C 停止查看）"
    show_startup_logs
}

check_dependencies() {
    local missing_deps=()
    
    # 检查 Docker
    if ! command -v docker &> /dev/null; then
        missing_deps+=("docker")
    fi
    
    # 检查 Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        missing_deps+=("docker-compose")
    fi
    
    # 检查 Python（用于管理 Django）
    if ! command -v python3 &> /dev/null; then
        missing_deps+=("python3")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_error "缺少必需的依赖: ${missing_deps[*]}"
        exit 1
    fi
    
    print_success "所有依赖检查通过"
}

start_docker_services() {
    cd "$INFRA_DIR"
    
    # 检查是否已有运行中的容器
    local running_services=$(docker-compose -f "$DOCKER_COMPOSE_FILE" ps --services --filter "status=running" 2>/dev/null | wc -l)
    
    if [ "$running_services" -gt 0 ]; then
        print_info "检测到已有 $running_services 个运行中的服务，准备重启..."
        docker-compose -f "$DOCKER_COMPOSE_FILE" restart
    else
        # 检查是否存在已停止的容器
        local stopped_containers=$(docker-compose -f "$DOCKER_COMPOSE_FILE" ps --services --filter "status=exited" 2>/dev/null | wc -l)
        
        if [ "$stopped_containers" -gt 0 ]; then
            print_info "检测到 $stopped_containers 个已停止的容器，重新启动..."
            docker-compose -f "$DOCKER_COMPOSE_FILE" start
        else
            print_info "首次启动，拉取镜像并创建容器..."
            docker-compose -f "$DOCKER_COMPOSE_FILE" up -d
        fi
    fi
    
    # 等待服务就绪
    wait_for_services
    print_success "Docker 服务启动成功"
}

wait_for_services() {
    local max_attempts=30
    local attempt=0
    
    print_info "等待服务就绪..."
    
    # 检查容器名称是否存在（可能叫 postgres 或 lesser-postgres）
    local postgres_container=$(docker ps -a --format '{{.Names}}' | grep -E '(postgres|lesser-postgres)$' | head -1)
    
    if [ -z "$postgres_container" ]; then
        print_warning "PostgreSQL 容器未找到，跳过健康检查"
        return
    fi
    
    while [ $attempt -lt $max_attempts ]; do
        # 检查 PostgreSQL 是否就绪
        if docker exec "$postgres_container" pg_isready -U postgres &>/dev/null; then
            print_success "PostgreSQL 已就绪"
            return
        fi
        
        attempt=$((attempt + 1))
        if [ $((attempt % 10)) -eq 0 ]; then
            print_info "等待中... ($attempt/$max_attempts)"
        fi
        sleep 1
    done
    
    if [ $attempt -eq $max_attempts ]; then
        print_warning "无法连接到 PostgreSQL，继续执行..."
    fi
}

init_database() {
    # 查找 Django 容器（可能叫 django 或 lesser-django）
    local django_container=$(docker ps -a --format '{{.Names}}' | grep -E '(django|lesser-django)$' | head -1)
    
    # 检查容器是否运行
    if [ -z "$django_container" ] || ! docker ps | grep -q "$django_container"; then
        print_warning "Django 容器未运行，跳过数据库初始化"
        return
    fi
    
    print_info "运行数据库迁移..."
    if docker exec "$django_container" python manage.py migrate 2>/dev/null; then
        print_success "数据库迁移完成"
    else
        print_warning "迁移执行失败，可能是容器还未完全就绪或数据库已初始化"
    fi
    
    print_info "创建超级用户（如果不存在）..."
    docker exec "$django_container" python manage.py shell << 'EOF' 2>/dev/null || true
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@localhost', 'admin123')
    print("超级用户创建成功: admin / admin123")
else:
    print("超级用户已存在")
EOF
}

print_startup_info() {
    cat << 'EOF'

═══════════════════════════════════════════════════════════
✓ 环境启动完成！

📋 服务地址:
   
   Django API:         http://localhost:8001
   Django Admin:       http://localhost:8001/admin/
   PostgreSQL:         localhost:5432
   Redis:              localhost:6379
   APISIX Gateway:     http://localhost:9080
   APISIX Dashboard:   http://localhost:9000
   etcd:               localhost:2379

🔐 默认凭证:

   Django Admin:
     - 用户名: admin
     - 密码:   admin123
   
   PostgreSQL:
     - 用户名: funcdfs (可在 .env 修改)
     - 密码:   secret (可在 .env 修改)

💡 常用命令:

   查看所有日志:       ./dev.sh logs
   查看 Django 日志:   ./dev.sh logs django
   重启 Django:        ./dev.sh restart django
   停止所有服务:       ./dev.sh stop
   显示帮助:           ./dev.sh help

🔄 启动流程说明:

   - 首次启动: 自动拉取镜像、创建容器并启动
   - 重复启动: 复用已有容器，只进行重启（快速）
   - 如需完全重建: ./dev.sh clean 后再启动

📖 查看详细文档:     docs/快速开始.md

═══════════════════════════════════════════════════════════
EOF
}

show_startup_logs() {
    cd "$INFRA_DIR"
    docker-compose -f "$DOCKER_COMPOSE_FILE" logs -f django
}

# 导出函数供其他脚本使用
export -f start_services check_dependencies start_docker_services wait_for_services init_database print_startup_info show_startup_logs
