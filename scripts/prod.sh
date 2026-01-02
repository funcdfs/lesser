#!/bin/bash
# ============================================================================
# 生产环境管理脚本 - Production Environment Management Script
# ============================================================================
# Usage: ./prod.sh <command> [options]
# Run ./prod.sh --help for full documentation
# ============================================================================

set -e

# ============================================================================
# 配置变量 - Configuration Variables
# ============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
COMPOSE_FILE="$PROJECT_ROOT/infra/docker-compose.prod.yml"
ENV_FILE="$PROJECT_ROOT/infra/env/prod.env"

# ============================================================================
# 颜色和图标 - Colors and Icons
# ============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

ICON_SUCCESS="✓"
ICON_FAIL="✗"
ICON_WARN="⚠"
ICON_INFO="ℹ"
ICON_ROCKET="🚀"
ICON_DOCKER="🐳"

# ============================================================================
# 日志函数 - Logging Functions
# ============================================================================
log_info() { echo -e "${GREEN}${ICON_INFO}${NC} $1"; }
log_warn() { echo -e "${YELLOW}${ICON_WARN}${NC} $1"; }
log_error() { echo -e "${RED}${ICON_FAIL}${NC} $1"; }
log_step() { echo -e "${BLUE}${BOLD}▶${NC} $1"; }
log_success() { echo -e "${GREEN}${ICON_SUCCESS}${NC} $1"; }

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
# 环境变量验证 - Environment Variable Validation
# ============================================================================
REQUIRED_VARS=(
    "POSTGRES_USER"
    "POSTGRES_PASSWORD"
    "POSTGRES_DB"
    "JWT_SECRET_KEY"
    "REDIS_URL"
)

validate_env() {
    print_header "环境变量验证"
    
    if [ ! -f "$ENV_FILE" ]; then
        log_error "生产环境变量文件不存在: $ENV_FILE"
        echo ""
        echo "请创建 .env.prod 文件，可参考 .env.prod.example"
        exit 1
    fi
    
    local missing=()
    local insecure=()
    
    # 加载环境变量
    set -a
    source "$ENV_FILE"
    set +a
    
    # 检查必需变量
    for var in "${REQUIRED_VARS[@]}"; do
        if [ -z "${!var}" ]; then
            missing+=("$var")
        fi
    done
    
    # 检查不安全的默认值
    if [[ "$JWT_SECRET_KEY" == *"dev"* ]] || [[ "$JWT_SECRET_KEY" == *"secret"* ]]; then
        insecure+=("JWT_SECRET_KEY (使用了不安全的默认值)")
    fi
    
    if [[ "$POSTGRES_PASSWORD" == *"dev"* ]] || [[ "$POSTGRES_PASSWORD" == "password" ]]; then
        insecure+=("POSTGRES_PASSWORD (使用了不安全的默认值)")
    fi
    
    # 报告结果
    if [ ${#missing[@]} -gt 0 ]; then
        log_error "缺少必需的环境变量:"
        for var in "${missing[@]}"; do
            echo "  - $var"
        done
        echo ""
        exit 1
    fi
    
    if [ ${#insecure[@]} -gt 0 ]; then
        log_warn "检测到不安全的配置:"
        for item in "${insecure[@]}"; do
            echo "  - $item"
        done
        echo ""
        read -p "是否继续? (y/N): " confirm
        if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
            log_info "已取消"
            exit 0
        fi
    fi
    
    log_success "环境变量验证通过"
}

# ============================================================================
# 依赖检查 - Dependency Checks
# ============================================================================
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        log_error "Docker daemon is not running"
        exit 1
    fi
    
    if ! docker compose version &> /dev/null; then
        log_error "Docker Compose is not installed"
        exit 1
    fi
}

# ============================================================================
# 服务管理 - Service Management
# ============================================================================
start_services() {
    check_docker
    validate_env
    
    print_header "${ICON_DOCKER} 启动生产环境"
    
    log_step "拉取最新镜像..."
    docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" pull
    
    log_step "启动服务..."
    docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d
    
    log_info "等待服务启动..."
    sleep 10
    
    show_status
    log_success "生产环境已启动"
}

stop_services() {
    print_header "停止生产环境"
    
    log_warn "即将停止所有生产服务"
    read -p "确定要停止吗? (y/N): " confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        log_step "停止服务..."
        docker compose -f "$COMPOSE_FILE" down
        log_success "服务已停止"
    else
        log_info "已取消"
    fi
}

restart_services() {
    print_header "重启生产环境"
    
    log_step "重启服务..."
    docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" restart
    
    sleep 5
    show_status
}

show_status() {
    print_header "服务状态"
    docker compose -f "$COMPOSE_FILE" ps
    echo ""
}

show_logs() {
    local service="$1"
    local lines="${2:-100}"
    
    if [ -z "$service" ]; then
        docker compose -f "$COMPOSE_FILE" logs -f --tail="$lines"
    else
        docker compose -f "$COMPOSE_FILE" logs -f --tail="$lines" "$service"
    fi
}

# ============================================================================
# 数据库操作 - Database Operations
# ============================================================================
db_backup() {
    print_header "数据库备份"
    
    local backup_dir="$PROJECT_ROOT/backups"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$backup_dir/backup_$timestamp.sql"
    
    mkdir -p "$backup_dir"
    
    log_step "创建备份..."
    docker compose -f "$COMPOSE_FILE" exec -T postgres pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" > "$backup_file"
    
    log_success "备份已创建: $backup_file"
}

# ============================================================================
# 部署操作 - Deployment Operations
# ============================================================================
deploy() {
    print_header "部署更新"
    
    log_step "拉取最新代码..."
    git pull origin main
    
    log_step "拉取最新镜像..."
    docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" pull
    
    log_step "重新构建..."
    docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" build
    
    log_step "重启服务..."
    docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d
    
    log_success "部署完成"
    show_status
}

# ============================================================================
# 帮助信息 - Help Information
# ============================================================================
show_help() {
    print_header "生产环境管理脚本"
    
    echo -e "${BOLD}用法:${NC} $0 <command> [options]"
    echo ""
    
    echo -e "${BOLD}${ICON_DOCKER} 服务管理:${NC}"
    print_separator
    echo -e "  ${CYAN}start${NC}                    启动生产环境"
    echo -e "  ${CYAN}stop${NC}                     停止生产环境"
    echo -e "  ${CYAN}restart${NC}                  重启服务"
    echo -e "  ${CYAN}status${NC}                   查看服务状态"
    echo -e "  ${CYAN}logs${NC} [service] [lines]   查看日志"
    echo ""
    
    echo -e "${BOLD}📦 部署操作:${NC}"
    print_separator
    echo -e "  ${CYAN}deploy${NC}                   部署更新"
    echo -e "  ${CYAN}backup${NC}                   备份数据库"
    echo ""
    
    echo -e "${BOLD}🔧 其他命令:${NC}"
    print_separator
    echo -e "  ${CYAN}validate${NC}                 验证环境变量"
    echo -e "  ${CYAN}help${NC}, ${CYAN}--help${NC}             显示帮助信息"
    echo ""
    
    echo -e "${BOLD}⚠ 注意事项:${NC}"
    print_separator
    echo -e "  1. 确保 .env.prod 文件存在且配置正确"
    echo -e "  2. 生产环境密钥必须使用安全的随机值"
    echo -e "  3. 建议在部署前先备份数据库"
    echo ""
}

# ============================================================================
# 主命令处理 - Main Command Handler
# ============================================================================
case "$1" in
    start)
        start_services
        ;;
    
    stop)
        stop_services
        ;;
    
    restart)
        restart_services
        ;;
    
    status|ps)
        show_status
        ;;
    
    logs)
        show_logs "$2" "$3"
        ;;
    
    deploy)
        deploy
        ;;
    
    backup)
        db_backup
        ;;
    
    validate)
        validate_env
        ;;
    
    help|--help|-h|"")
        show_help
        ;;
    
    *)
        log_error "未知命令: $1"
        echo ""
        echo -e "运行 ${CYAN}./prod.sh --help${NC} 查看可用命令"
        exit 1
        ;;
esac
