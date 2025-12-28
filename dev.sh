#!/bin/bash
# ============================================================================
# 开发环境管理脚本 - Development Environment Management Script
# ============================================================================
# Usage: ./dev.sh <command> [subcommand] [options]
# Run ./dev.sh --help for full documentation
# ============================================================================

set -e

# ============================================================================
# 配置变量 - Configuration Variables
# ============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/infra/docker-compose.yml"
COMPOSE_PROD_FILE="$SCRIPT_DIR/infra/docker-compose.prod.yml"

# 环境变量文件统一放在 infra/env/ 目录下
ENV_DIR="$SCRIPT_DIR/infra/env"
ENV_FILE="$ENV_DIR/dev.env"
ENV_PROD_FILE="$ENV_DIR/prod.env"
ENV_DEV_EXAMPLE="$ENV_DIR/dev.env.example"
ENV_PROD_EXAMPLE="$ENV_DIR/prod.env.example"

# 兼容旧位置 (如果新位置不存在，尝试旧位置)
if [ ! -f "$ENV_FILE" ] && [ -f "$SCRIPT_DIR/infra/.env.dev" ]; then
    ENV_FILE="$SCRIPT_DIR/infra/.env.dev"
fi

# 客户端目录
FLUTTER_DIR="$SCRIPT_DIR/client/mobile_flutter"
REACT_DIR="$SCRIPT_DIR/client/web_react"

# 脚本目录
PROTO_SCRIPT="$SCRIPT_DIR/scripts/proto/generate.sh"
SETUP_SCRIPT="$SCRIPT_DIR/scripts/dev/setup.sh"

# 默认端口
FLUTTER_WEB_PORT=${FLUTTER_WEB_PORT:-3000}
REACT_PORT=${REACT_PORT:-3001}

# ============================================================================
# 颜色和图标 - Colors and Icons
# ============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# 图标
ICON_SUCCESS="✓"
ICON_FAIL="✗"
ICON_WARN="⚠"
ICON_INFO="ℹ"
ICON_ROCKET="🚀"
ICON_DOCKER="🐳"
ICON_DB="🗄"
ICON_API="🔌"
ICON_WEB="🌐"
ICON_MOBILE="📱"
ICON_GEAR="⚙"
ICON_CHECK="✅"
ICON_CROSS="❌"

# ============================================================================
# 日志函数 - Logging Functions
# ============================================================================
log_info() { echo -e "${GREEN}${ICON_INFO}${NC} $1"; }
log_warn() { echo -e "${YELLOW}${ICON_WARN}${NC} $1"; }
log_error() { echo -e "${RED}${ICON_FAIL}${NC} $1"; }
log_step() { echo -e "${BLUE}${BOLD}▶${NC} $1"; }
log_success() { echo -e "${GREEN}${ICON_SUCCESS}${NC} $1"; }
log_debug() { 
    if [ "$DEBUG" = "true" ]; then
        echo -e "${DIM}[DEBUG]${NC} $1"
    fi
}

print_separator() {
    echo -e "${DIM}────────────────────────────────────────────────────────────${NC}"
}

print_header() {
    echo ""
    echo -e "${CYAN}${BOLD}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║${NC}  ${ICON_ROCKET} ${BOLD}$1${NC}"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ============================================================================
# 依赖检查 - Dependency Checks
# ============================================================================
check_command() {
    command -v "$1" &> /dev/null
}

check_docker() {
    if ! check_command docker; then
        log_error "Docker is not installed"
        echo "  Install: https://docs.docker.com/get-docker/"
        return 1
    fi
    
    if ! docker info &> /dev/null; then
        log_error "Docker daemon is not running"
        echo "  Please start Docker Desktop or the Docker service"
        return 1
    fi
    
    if ! docker compose version &> /dev/null; then
        log_error "Docker Compose is not installed"
        echo "  Docker Compose V2 is required (included in Docker Desktop)"
        return 1
    fi
    
    return 0
}

check_flutter() {
    if ! check_command flutter; then
        log_warn "Flutter is not installed"
        echo "  Install: https://docs.flutter.dev/get-started/install"
        return 1
    fi
    return 0
}

check_node() {
    if ! check_command node; then
        log_warn "Node.js is not installed"
        echo "  Install: https://nodejs.org/"
        return 1
    fi
    
    if ! check_command npm; then
        log_warn "npm is not installed"
        return 1
    fi
    return 0
}

check_python() {
    if ! check_command python3; then
        log_warn "Python 3 is not installed"
        return 1
    fi
    return 0
}

check_all_dependencies() {
    print_header "依赖检查"
    
    local all_ok=true
    
    echo -e "${BOLD}核心依赖:${NC}"
    print_separator
    
    if check_docker; then
        echo -e "  ${ICON_CHECK} Docker $(docker --version | cut -d' ' -f3 | tr -d ',')"
        echo -e "  ${ICON_CHECK} Docker Compose $(docker compose version --short)"
    else
        echo -e "  ${ICON_CROSS} Docker"
        all_ok=false
    fi
    
    if check_python; then
        echo -e "  ${ICON_CHECK} Python $(python3 --version | cut -d' ' -f2)"
    else
        echo -e "  ${ICON_CROSS} Python 3"
    fi
    
    echo ""
    echo -e "${BOLD}客户端依赖 (可选):${NC}"
    print_separator
    
    if check_flutter; then
        flutter_version=$(flutter --version 2>/dev/null | head -n1 | cut -d' ' -f2)
        echo -e "  ${ICON_CHECK} Flutter $flutter_version"
    else
        echo -e "  ${ICON_WARN} Flutter (未安装)"
    fi
    
    if check_node; then
        echo -e "  ${ICON_CHECK} Node.js $(node --version)"
        echo -e "  ${ICON_CHECK} npm $(npm --version)"
    else
        echo -e "  ${ICON_WARN} Node.js (未安装)"
    fi
    
    echo ""
    
    if [ "$all_ok" = false ]; then
        log_error "缺少必要依赖，请先安装"
        return 1
    fi
    
    log_success "所有核心依赖已安装"
    return 0
}

# ============================================================================
# 环境变量验证 - Environment Variable Validation
# ============================================================================
validate_env_file() {
    local env_file="$1"
    local required_vars=(
        "POSTGRES_USER"
        "POSTGRES_PASSWORD"
        "POSTGRES_DB"
        "REDIS_URL"
        "DJANGO_SECRET_KEY"
    )
    
    if [ ! -f "$env_file" ]; then
        log_error "环境变量文件不存在: $env_file"
        return 1
    fi
    
    local missing=()
    for var in "${required_vars[@]}"; do
        if ! grep -q "^${var}=" "$env_file"; then
            missing+=("$var")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        log_error "缺少必要的环境变量:"
        for var in "${missing[@]}"; do
            echo "  - $var"
        done
        return 1
    fi
    
    return 0
}

check_env() {
    # 确保 env 目录存在
    mkdir -p "$ENV_DIR"
    
    if [ ! -f "$ENV_FILE" ]; then
        log_warn "环境变量文件不存在: $ENV_FILE"
        
        # 尝试从新位置的 example 文件创建
        if [ -f "$ENV_DEV_EXAMPLE" ]; then
            log_info "从模板创建 dev.env..."
            cp "$ENV_DEV_EXAMPLE" "$ENV_FILE"
        # 兼容旧位置
        elif [ -f "$SCRIPT_DIR/infra/.env.dev.example" ]; then
            log_info "从旧模板创建 dev.env..."
            cp "$SCRIPT_DIR/infra/.env.dev.example" "$ENV_FILE"
        # 从旧的 .env.dev 迁移
        elif [ -f "$SCRIPT_DIR/infra/.env.dev" ]; then
            log_info "迁移旧的 .env.dev 到新位置..."
            cp "$SCRIPT_DIR/infra/.env.dev" "$ENV_FILE"
        else
            log_error "请先运行 ./dev.sh init 初始化环境"
            return 1
        fi
    fi
    
    validate_env_file "$ENV_FILE"
}


# ============================================================================
# 服务状态显示 - Service Status Display
# ============================================================================
show_status() {
    print_header "服务状态"
    
    echo -e "${BOLD}  服务名称          状态              端口${NC}"
    print_separator
    
    # 使用 docker compose ps --format json 获取状态
    docker compose -f "$COMPOSE_FILE" ps --format json 2>/dev/null | while read -r json_line; do
        name=$(echo "$json_line" | python3 -c "import sys,json; print(json.load(sys.stdin).get('Name',''))" 2>/dev/null)
        state=$(echo "$json_line" | python3 -c "import sys,json; print(json.load(sys.stdin).get('State',''))" 2>/dev/null)
        health=$(echo "$json_line" | python3 -c "import sys,json; print(json.load(sys.stdin).get('Health',''))" 2>/dev/null)
        
        # 解析端口
        port_str=$(echo "$json_line" | python3 -c "
import sys,json
data = json.load(sys.stdin)
publishers = data.get('Publishers', [])
if publishers:
    ports = []
    for p in publishers:
        if p.get('PublishedPort'):
            ports.append(str(p['PublishedPort']))
    print(','.join(sorted(set(ports))))
else:
    print('-')
" 2>/dev/null)
        
        # 状态显示
        if [[ "$state" == "running" ]]; then
            if [[ "$health" == "healthy" ]]; then
                status_icon="${GREEN}${ICON_SUCCESS}${NC}"
                status_text="${GREEN}运行中${NC}"
            elif [[ "$health" == "starting" ]]; then
                status_icon="${YELLOW}${ICON_WARN}${NC}"
                status_text="${YELLOW}启动中${NC}"
            else
                status_icon="${GREEN}${ICON_SUCCESS}${NC}"
                status_text="${GREEN}运行中${NC}"
            fi
        else
            status_icon="${RED}${ICON_FAIL}${NC}"
            status_text="${RED}已停止${NC}"
        fi
        
        # 服务图标
        case "$name" in
            *postgres*) svc_icon="${ICON_DB}" ;;
            *redis*) svc_icon="📦" ;;
            *django*) svc_icon="🐍" ;;
            *chat*) svc_icon="💬" ;;
            *traefik*) svc_icon="${ICON_WEB}" ;;
            *celery*) svc_icon="🔄" ;;
            *) svc_icon="${ICON_API}" ;;
        esac
        
        printf "  ${svc_icon} %-14s ${status_icon} %-12b ${DIM}ports: %s${NC}\n" "$name" "$status_text" "$port_str"
    done
    
    echo ""
}

show_urls() {
    echo -e "${BOLD}  ${ICON_WEB} 访问地址${NC}"
    print_separator
    echo -e "  ${CYAN}Gateway (统一入口)${NC}  →  http://localhost"
    echo -e "  ${CYAN}Django API${NC}          →  http://localhost:8000"
    echo -e "  ${CYAN}Chat API${NC}            →  http://localhost:8081"
    echo -e "  ${CYAN}Traefik Dashboard${NC}   →  http://localhost:8088"
    echo ""
    
    echo -e "${BOLD}  ${ICON_API} 测试端点${NC}"
    print_separator
    echo -e "  ${DIM}curl${NC} http://localhost/api/v1/hello/"
    echo -e "  ${DIM}curl${NC} http://localhost/api/v1/chat/hello"
    echo -e "  ${DIM}curl${NC} http://localhost/api/v1/health/"
    echo ""
}

# ============================================================================
# 服务连通性测试 - Service Connectivity Test
# ============================================================================
test_services() {
    print_header "服务连通性测试"
    
    local all_passed=true
    
    # 测试 Django
    echo -e "${BOLD}  🐍 Django Core Service${NC}"
    print_separator
    response=$(curl -s -w "\n%{http_code}" http://localhost:8000/api/v1/health/ 2>/dev/null || echo -e "\n000")
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "200" ]; then
        log_success "健康检查通过"
        status=$(echo "$body" | python3 -c "import sys,json; print(json.load(sys.stdin).get('status','unknown'))" 2>/dev/null || echo "unknown")
        echo -e "     状态: ${GREEN}$status${NC}"
    else
        log_error "健康检查失败 (HTTP $http_code)"
        all_passed=false
    fi
    echo ""
    
    # 测试 Chat
    echo -e "${BOLD}  💬 Chat Service (Go/Gin)${NC}"
    print_separator
    response=$(curl -s -w "\n%{http_code}" http://localhost:8081/health 2>/dev/null || echo -e "\n000")
    http_code=$(echo "$response" | tail -n1)
    
    if [ "$http_code" = "200" ]; then
        log_success "健康检查通过"
    else
        log_error "健康检查失败 (HTTP $http_code)"
        all_passed=false
    fi
    echo ""
    
    # 测试 Gateway
    echo -e "${BOLD}  ${ICON_WEB} Traefik Gateway${NC}"
    print_separator
    response=$(curl -s -w "\n%{http_code}" http://localhost/api/v1/hello/ 2>/dev/null || echo -e "\n000")
    http_code=$(echo "$response" | tail -n1)
    
    if [ "$http_code" = "200" ]; then
        log_success "网关路由正常"
    else
        log_error "网关路由失败 (HTTP $http_code)"
        all_passed=false
    fi
    echo ""
    
    # 总结
    print_separator
    if [ "$all_passed" = true ]; then
        echo -e "  ${GREEN}${BOLD}${ICON_SUCCESS} 所有服务运行正常！${NC}"
    else
        echo -e "  ${RED}${BOLD}${ICON_FAIL} 部分服务存在问题，请检查日志${NC}"
        echo -e "  ${DIM}运行 ./dev.sh logs 查看详细日志${NC}"
    fi
    echo ""
}

# ============================================================================
# 服务管理 - Service Management
# ============================================================================
start_services() {
    local target="$1"
    
    check_docker || exit 1
    check_env || exit 1
    
    print_header "${ICON_DOCKER} 启动开发环境"
    
    case "$target" in
        service|services|backend)
            log_step "启动后端服务..."
            docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d postgres redis django chat traefik
            ;;
        infra|infrastructure)
            log_step "启动基础设施..."
            docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d postgres redis traefik
            ;;
        django)
            log_step "启动 Django 服务..."
            docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d postgres redis django
            ;;
        chat)
            log_step "启动 Chat 服务..."
            docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d postgres redis chat
            ;;
        client|clients)
            start_clients
            return
            ;;
        flutter)
            start_flutter
            return
            ;;
        react)
            start_react
            return
            ;;
        all|"")
            log_step "启动所有服务..."
            docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d
            ;;
        *)
            log_error "未知目标: $target"
            echo "可用选项: service, infra, django, chat, client, flutter, react, all"
            exit 1
            ;;
    esac
    
    log_info "等待服务启动..."
    sleep 5
    show_status
    show_urls
}

stop_services() {
    local target="$1"
    
    print_header "停止服务"
    
    case "$target" in
        service|services|backend|all|"")
            log_step "停止所有后端服务..."
            docker compose -f "$COMPOSE_FILE" down
            ;;
        client|clients)
            stop_clients
            return
            ;;
        flutter)
            stop_flutter
            return
            ;;
        react)
            stop_react
            return
            ;;
        *)
            log_step "停止 $target 服务..."
            docker compose -f "$COMPOSE_FILE" stop "$target"
            ;;
    esac
    
    log_success "服务已停止"
}

restart_services() {
    local target="$1"
    
    print_header "重启服务"
    
    if [ -z "$target" ]; then
        log_step "重启所有服务..."
        docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" restart
    else
        log_step "重启 $target 服务..."
        docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" restart "$target"
    fi
    
    sleep 3
    show_status
}

show_logs() {
    local target="$1"
    local lines="${2:-100}"
    
    if [ -z "$target" ]; then
        docker compose -f "$COMPOSE_FILE" logs -f --tail="$lines"
    else
        docker compose -f "$COMPOSE_FILE" logs -f --tail="$lines" "$target"
    fi
}


# ============================================================================
# 客户端管理 - Client Management
# ============================================================================
start_flutter() {
    if ! check_flutter; then
        log_error "Flutter 未安装，无法启动"
        exit 1
    fi
    
    if [ ! -d "$FLUTTER_DIR" ]; then
        log_error "Flutter 项目目录不存在: $FLUTTER_DIR"
        exit 1
    fi
    
    print_header "${ICON_MOBILE} 启动 Flutter Web 客户端"
    
    cd "$FLUTTER_DIR"
    log_step "安装依赖..."
    flutter pub get
    
    log_step "启动 Flutter Web (端口: $FLUTTER_WEB_PORT)..."
    flutter run -d chrome --web-port="$FLUTTER_WEB_PORT" &
    
    log_info "Flutter Web 客户端启动中: http://localhost:$FLUTTER_WEB_PORT"
    cd "$SCRIPT_DIR"
}

stop_flutter() {
    log_step "停止 Flutter 进程..."
    pkill -f "flutter run" 2>/dev/null || true
    pkill -f "dart.*flutter" 2>/dev/null || true
    log_success "Flutter 进程已停止"
}

start_react() {
    if ! check_node; then
        log_error "Node.js 未安装，无法启动"
        exit 1
    fi
    
    if [ ! -d "$REACT_DIR" ]; then
        log_warn "React 项目目录不存在: $REACT_DIR"
        log_info "跳过 React 客户端启动"
        return
    fi
    
    if [ ! -f "$REACT_DIR/package.json" ]; then
        log_warn "React 项目未初始化 (缺少 package.json)"
        return
    fi
    
    print_header "${ICON_WEB} 启动 React Web 客户端"
    
    cd "$REACT_DIR"
    log_step "安装依赖..."
    npm install
    
    log_step "启动 React (端口: $REACT_PORT)..."
    PORT="$REACT_PORT" npm run dev &
    
    log_info "React Web 客户端启动中: http://localhost:$REACT_PORT"
    cd "$SCRIPT_DIR"
}

stop_react() {
    log_step "停止 React 进程..."
    pkill -f "next dev" 2>/dev/null || true
    pkill -f "npm run dev" 2>/dev/null || true
    log_success "React 进程已停止"
}

start_clients() {
    print_header "启动客户端"
    
    start_flutter &
    start_react &
    
    wait
    
    echo ""
    echo -e "${BOLD}  ${ICON_WEB} 客户端地址${NC}"
    print_separator
    echo -e "  ${CYAN}Flutter Web${NC}  →  http://localhost:$FLUTTER_WEB_PORT"
    echo -e "  ${CYAN}React Web${NC}    →  http://localhost:$REACT_PORT"
    echo ""
}

stop_clients() {
    print_header "停止客户端"
    stop_flutter
    stop_react
}

# ============================================================================
# 数据库操作 - Database Operations
# ============================================================================
db_migrate() {
    print_header "数据库迁移"
    log_step "执行迁移..."
    docker compose -f "$COMPOSE_FILE" exec django python manage.py migrate
    log_success "迁移完成"
}

db_makemigrations() {
    local app="$1"
    print_header "生成迁移文件"
    log_step "生成迁移..."
    docker compose -f "$COMPOSE_FILE" exec django python manage.py makemigrations $app
    log_success "迁移文件已生成"
}

db_shell() {
    log_step "进入 PostgreSQL..."
    docker compose -f "$COMPOSE_FILE" exec postgres psql -U lesser -d lesser_db
}

db_reset() {
    print_header "重置数据库"
    log_warn "这将删除所有数据！"
    read -p "确定要重置数据库吗? (y/N): " confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        log_step "停止服务..."
        docker compose -f "$COMPOSE_FILE" stop django chat
        
        log_step "删除数据库..."
        docker compose -f "$COMPOSE_FILE" exec postgres dropdb -U lesser lesser_db --if-exists
        docker compose -f "$COMPOSE_FILE" exec postgres createdb -U lesser lesser_db
        
        log_step "重启服务..."
        docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d django chat
        
        sleep 5
        db_migrate
        
        log_success "数据库已重置"
    else
        log_info "取消重置"
    fi
}

# ============================================================================
# 构建操作 - Build Operations
# ============================================================================
build_services() {
    local target="$1"
    print_header "构建镜像"
    
    if [ -z "$target" ]; then
        log_step "构建所有镜像..."
        docker compose -f "$COMPOSE_FILE" build
    else
        log_step "构建 $target 镜像..."
        docker compose -f "$COMPOSE_FILE" build "$target"
    fi
    
    log_success "构建完成"
}

rebuild_services() {
    local target="$1"
    print_header "重新构建并启动"
    
    if [ -z "$target" ]; then
        log_step "重新构建所有镜像..."
        docker compose -f "$COMPOSE_FILE" build --no-cache
    else
        log_step "重新构建 $target 镜像..."
        docker compose -f "$COMPOSE_FILE" build --no-cache "$target"
    fi
    
    docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d
    show_status
}

# ============================================================================
# 清理操作 - Cleanup Operations
# ============================================================================
clean_all() {
    print_header "清理环境"
    log_warn "这将删除所有容器、数据卷和生成的文件！"
    read -p "确定要清理吗? (y/N): " confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        log_step "停止并删除容器..."
        docker compose -f "$COMPOSE_FILE" down -v --remove-orphans
        
        log_step "清理 Docker 缓存..."
        docker system prune -f
        
        log_success "清理完成"
    else
        log_info "取消清理"
    fi
}

clean_containers() {
    print_header "清理容器"
    docker compose -f "$COMPOSE_FILE" down --remove-orphans
    log_success "容器已清理"
}

clean_volumes() {
    print_header "清理数据卷"
    log_warn "这将删除所有数据！"
    read -p "确定要清理数据卷吗? (y/N): " confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        docker compose -f "$COMPOSE_FILE" down -v
        log_success "数据卷已清理"
    else
        log_info "取消清理"
    fi
}

# ============================================================================
# 初始化 - Initialization
# ============================================================================
init_environment() {
    print_header "${ICON_GEAR} 初始化开发环境"
    
    # 检查依赖
    check_all_dependencies || exit 1
    
    # 确保 env 目录存在
    mkdir -p "$ENV_DIR"
    
    # 创建环境变量文件
    log_step "配置环境变量..."
    if [ ! -f "$ENV_FILE" ]; then
        if [ -f "$ENV_DEV_EXAMPLE" ]; then
            cp "$ENV_DEV_EXAMPLE" "$ENV_FILE"
            log_info "已创建 $ENV_FILE"
        elif [ -f "$SCRIPT_DIR/infra/.env.dev.example" ]; then
            cp "$SCRIPT_DIR/infra/.env.dev.example" "$ENV_FILE"
            log_info "已从旧模板创建 $ENV_FILE"
        elif [ -f "$SCRIPT_DIR/infra/.env.dev" ]; then
            # 迁移旧的环境变量文件
            cp "$SCRIPT_DIR/infra/.env.dev" "$ENV_FILE"
            log_info "已迁移旧的 .env.dev 到 $ENV_FILE"
        fi
    else
        log_info "环境变量文件已存在: $ENV_FILE"
    fi
    
    # 运行 setup 脚本
    if [ -f "$SETUP_SCRIPT" ]; then
        log_step "运行初始化脚本..."
        bash "$SETUP_SCRIPT"
    fi
    
    # 生成 Proto 代码
    if [ -f "$PROTO_SCRIPT" ]; then
        log_step "生成 Proto 代码..."
        bash "$PROTO_SCRIPT" all
    fi
    
    # 构建镜像
    log_step "构建 Docker 镜像..."
    docker compose -f "$COMPOSE_FILE" build
    
    log_success "初始化完成！"
    echo ""
    echo -e "${BOLD}下一步:${NC}"
    echo -e "  1. 运行 ${CYAN}./dev.sh start${NC} 启动所有服务"
    echo -e "  2. 运行 ${CYAN}./dev.sh migrate${NC} 执行数据库迁移"
    echo -e "  3. 运行 ${CYAN}./dev.sh test${NC} 测试服务连通性"
    echo ""
}

# ============================================================================
# Proto 生成 - Proto Generation
# ============================================================================
generate_proto() {
    local target="$1"
    
    if [ ! -f "$PROTO_SCRIPT" ]; then
        log_error "Proto 生成脚本不存在: $PROTO_SCRIPT"
        exit 1
    fi
    
    if [ -z "$target" ]; then
        bash "$PROTO_SCRIPT" all
    else
        bash "$PROTO_SCRIPT" "$target"
    fi
}

# ============================================================================
# 进入容器 - Enter Container
# ============================================================================
enter_container() {
    local target="$1"
    
    case "$target" in
        django|python)
            log_step "进入 Django 容器 (Python shell)..."
            docker compose -f "$COMPOSE_FILE" exec django python manage.py shell
            ;;
        chat|go)
            log_step "进入 Chat 容器..."
            docker compose -f "$COMPOSE_FILE" exec chat sh
            ;;
        postgres|postgresql|db)
            log_step "进入 PostgreSQL (psql)..."
            docker compose -f "$COMPOSE_FILE" exec postgres psql -U lesser -d lesser_db
            ;;
        redis|cache)
            log_step "进入 Redis (redis-cli)..."
            docker compose -f "$COMPOSE_FILE" exec redis redis-cli
            ;;
        traefik|gateway)
            log_step "进入 Traefik 容器..."
            docker compose -f "$COMPOSE_FILE" exec traefik sh
            ;;
        *)
            echo -e "${BOLD}用法:${NC} $0 enter <service>"
            echo ""
            echo -e "${BOLD}可用服务:${NC}"
            print_separator
            echo -e "  ${CYAN}django${NC}, ${CYAN}python${NC}      进入 Django Python shell"
            echo -e "  ${CYAN}chat${NC}, ${CYAN}go${NC}            进入 Chat 容器 (sh)"
            echo -e "  ${CYAN}postgres${NC}, ${CYAN}db${NC}        进入 PostgreSQL (psql)"
            echo -e "  ${CYAN}redis${NC}, ${CYAN}cache${NC}        进入 Redis (redis-cli)"
            echo -e "  ${CYAN}traefik${NC}, ${CYAN}gateway${NC}    进入 Traefik 容器 (sh)"
            echo ""
            ;;
    esac
}


# ============================================================================
# 帮助信息 - Help Information
# ============================================================================
show_help() {
    print_header "开发环境管理脚本"
    
    echo -e "${BOLD}用法:${NC} $0 <command> [subcommand] [options]"
    echo ""
    
    echo -e "${BOLD}${ICON_ROCKET} 快速开始:${NC}"
    print_separator
    echo -e "  ${CYAN}init${NC}                     初始化开发环境 (首次使用)"
    echo -e "  ${CYAN}start${NC}                    启动所有服务"
    echo -e "  ${CYAN}stop${NC}                     停止所有服务"
    echo -e "  ${CYAN}status${NC}                   查看服务状态"
    echo ""
    
    echo -e "${BOLD}${ICON_DOCKER} 服务管理:${NC}"
    print_separator
    echo -e "  ${CYAN}start${NC} [target]           启动服务"
    echo -e "      ${DIM}target: service, infra, django, chat, client, flutter, react, all${NC}"
    echo -e "  ${CYAN}stop${NC} [target]            停止服务"
    echo -e "      ${DIM}target: service, client, flutter, react, <service-name>${NC}"
    echo -e "  ${CYAN}restart${NC} [service]        重启服务"
    echo -e "  ${CYAN}logs${NC} [service] [lines]   查看日志 (默认 100 行)"
    echo -e "  ${CYAN}ps${NC}, ${CYAN}status${NC}              查看服务状态"
    echo -e "  ${CYAN}test${NC}                     测试服务连通性"
    echo ""
    
    echo -e "${BOLD}${ICON_DB} 数据库操作:${NC}"
    print_separator
    echo -e "  ${CYAN}migrate${NC}                  执行数据库迁移"
    echo -e "  ${CYAN}makemigrations${NC} [app]     生成迁移文件"
    echo -e "  ${CYAN}createsuperuser${NC}          创建超级用户"
    echo -e "  ${CYAN}db:shell${NC}                 进入 PostgreSQL shell"
    echo -e "  ${CYAN}db:reset${NC}                 重置数据库 (危险)"
    echo ""
    
    echo -e "${BOLD}${ICON_GEAR} 开发调试:${NC}"
    print_separator
    echo -e "  ${CYAN}enter${NC} <service>          进入容器"
    echo -e "      ${DIM}service: django, chat, postgres, redis, traefik${NC}"
    echo -e "  ${CYAN}shell${NC}                    Django Python shell"
    echo -e "  ${CYAN}bash${NC} [service]           进入容器 sh (默认 django)"
    echo ""
    
    echo -e "${BOLD}${ICON_API} 构建部署:${NC}"
    print_separator
    echo -e "  ${CYAN}build${NC} [service]          构建镜像"
    echo -e "  ${CYAN}rebuild${NC} [service]        重新构建并启动 (无缓存)"
    echo -e "  ${CYAN}proto${NC} [target]           生成 Proto 代码"
    echo -e "      ${DIM}target: all, python, go, dart, typescript${NC}"
    echo ""
    
    echo -e "${BOLD}🧹 清理操作:${NC}"
    print_separator
    echo -e "  ${CYAN}clean${NC}                    清理所有容器和数据"
    echo -e "  ${CYAN}clean:containers${NC}         仅清理容器"
    echo -e "  ${CYAN}clean:volumes${NC}            清理数据卷 (危险)"
    echo ""
    
    echo -e "${BOLD}📋 其他命令:${NC}"
    print_separator
    echo -e "  ${CYAN}check${NC}                    检查依赖"
    echo -e "  ${CYAN}env${NC}                      显示环境变量"
    echo -e "  ${CYAN}urls${NC}                     显示访问地址"
    echo -e "  ${CYAN}help${NC}, ${CYAN}--help${NC}, ${CYAN}-h${NC}        显示帮助信息"
    echo ""
    
    echo -e "${BOLD}📝 示例:${NC}"
    print_separator
    echo -e "  ${DIM}# 首次使用${NC}"
    echo -e "  ./dev.sh init"
    echo ""
    echo -e "  ${DIM}# 启动后端服务${NC}"
    echo -e "  ./dev.sh start service"
    echo ""
    echo -e "  ${DIM}# 启动 Flutter 客户端${NC}"
    echo -e "  ./dev.sh start flutter"
    echo ""
    echo -e "  ${DIM}# 查看 Django 日志${NC}"
    echo -e "  ./dev.sh logs django"
    echo ""
    echo -e "  ${DIM}# 进入数据库${NC}"
    echo -e "  ./dev.sh enter db"
    echo ""
    
    echo -e "${BOLD}🔧 环境变量:${NC}"
    print_separator
    echo -e "  ${CYAN}FLUTTER_WEB_PORT${NC}         Flutter Web 端口 (默认: 3000)"
    echo -e "  ${CYAN}REACT_PORT${NC}               React 端口 (默认: 3001)"
    echo -e "  ${CYAN}DEBUG${NC}                    启用调试输出 (true/false)"
    echo ""
}

show_start_help() {
    echo -e "${BOLD}用法:${NC} $0 start [target]"
    echo ""
    echo -e "${BOLD}可用目标:${NC}"
    print_separator
    echo -e "  ${CYAN}(空)${NC}, ${CYAN}all${NC}              启动所有服务"
    echo -e "  ${CYAN}service${NC}, ${CYAN}services${NC}      启动后端服务 (Django, Chat, 基础设施)"
    echo -e "  ${CYAN}infra${NC}                    仅启动基础设施 (PostgreSQL, Redis, Traefik)"
    echo -e "  ${CYAN}django${NC}                   启动 Django 服务"
    echo -e "  ${CYAN}chat${NC}                     启动 Chat 服务"
    echo -e "  ${CYAN}client${NC}, ${CYAN}clients${NC}        启动所有客户端"
    echo -e "  ${CYAN}flutter${NC}                  启动 Flutter Web 客户端"
    echo -e "  ${CYAN}react${NC}                    启动 React Web 客户端"
    echo ""
}

show_stop_help() {
    echo -e "${BOLD}用法:${NC} $0 stop [target]"
    echo ""
    echo -e "${BOLD}可用目标:${NC}"
    print_separator
    echo -e "  ${CYAN}(空)${NC}, ${CYAN}all${NC}              停止所有后端服务"
    echo -e "  ${CYAN}client${NC}, ${CYAN}clients${NC}        停止所有客户端"
    echo -e "  ${CYAN}flutter${NC}                  停止 Flutter 客户端"
    echo -e "  ${CYAN}react${NC}                    停止 React 客户端"
    echo -e "  ${CYAN}<service-name>${NC}           停止指定服务"
    echo ""
}

show_logs_help() {
    echo -e "${BOLD}用法:${NC} $0 logs [service] [lines]"
    echo ""
    echo -e "${BOLD}参数:${NC}"
    print_separator
    echo -e "  ${CYAN}service${NC}                  服务名称 (可选，默认全部)"
    echo -e "  ${CYAN}lines${NC}                    显示行数 (可选，默认 100)"
    echo ""
    echo -e "${BOLD}可用服务:${NC}"
    print_separator
    echo -e "  django, chat, postgres, redis, traefik, celery, celery-beat"
    echo ""
    echo -e "${BOLD}示例:${NC}"
    print_separator
    echo -e "  ./dev.sh logs              ${DIM}# 查看所有日志${NC}"
    echo -e "  ./dev.sh logs django       ${DIM}# 查看 Django 日志${NC}"
    echo -e "  ./dev.sh logs chat 50      ${DIM}# 查看 Chat 最近 50 行日志${NC}"
    echo ""
}

show_env() {
    print_header "环境变量"
    
    if [ -f "$ENV_FILE" ]; then
        echo -e "${BOLD}开发环境 ($ENV_FILE):${NC}"
        print_separator
        grep -v "^#" "$ENV_FILE" | grep -v "^$" | while read -r line; do
            key=$(echo "$line" | cut -d'=' -f1)
            value=$(echo "$line" | cut -d'=' -f2-)
            # 隐藏敏感信息
            if [[ "$key" == *"PASSWORD"* ]] || [[ "$key" == *"SECRET"* ]]; then
                echo -e "  ${CYAN}$key${NC}=${DIM}********${NC}"
            else
                echo -e "  ${CYAN}$key${NC}=$value"
            fi
        done
    else
        log_warn "环境变量文件不存在: $ENV_FILE"
        echo ""
        echo -e "请运行 ${CYAN}./dev.sh init${NC} 初始化环境"
    fi
    echo ""
}

# ============================================================================
# 主命令处理 - Main Command Handler
# ============================================================================
main() {
    case "$1" in
        # 初始化
        init)
            init_environment
            ;;
        
        # 服务管理
        start)
            if [ "$2" = "--help" ] || [ "$2" = "-h" ]; then
                show_start_help
            else
                start_services "$2"
            fi
            ;;
        
        stop)
            if [ "$2" = "--help" ] || [ "$2" = "-h" ]; then
                show_stop_help
            else
                stop_services "$2"
            fi
            ;;
        
        restart)
            restart_services "$2"
            ;;
        
        logs)
            if [ "$2" = "--help" ] || [ "$2" = "-h" ]; then
                show_logs_help
            else
                show_logs "$2" "$3"
            fi
            ;;
        
        ps|status)
            show_status
            show_urls
            ;;
        
        test)
            test_services
            ;;
        
        # 数据库操作
        migrate)
            db_migrate
            ;;
        
        makemigrations)
            db_makemigrations "$2"
            ;;
        
        createsuperuser)
            print_header "创建超级用户"
            docker compose -f "$COMPOSE_FILE" exec django python manage.py createsuperuser
            ;;
        
        db:shell)
            db_shell
            ;;
        
        db:reset)
            db_reset
            ;;
        
        # 开发调试
        enter)
            enter_container "$2"
            ;;
        
        shell)
            docker compose -f "$COMPOSE_FILE" exec django python manage.py shell
            ;;
        
        bash)
            service="${2:-django}"
            docker compose -f "$COMPOSE_FILE" exec "$service" sh
            ;;
        
        # 构建部署
        build)
            build_services "$2"
            ;;
        
        rebuild)
            rebuild_services "$2"
            ;;
        
        proto)
            generate_proto "$2"
            ;;
        
        # 清理操作
        clean)
            clean_all
            ;;
        
        clean:containers)
            clean_containers
            ;;
        
        clean:volumes)
            clean_volumes
            ;;
        
        # 其他命令
        check)
            check_all_dependencies
            ;;
        
        env)
            show_env
            ;;
        
        urls)
            show_urls
            ;;
        
        help|--help|-h|"")
            show_help
            ;;
        
        *)
            log_error "未知命令: $1"
            echo ""
            echo -e "运行 ${CYAN}./dev.sh --help${NC} 查看可用命令"
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@"
