#!/bin/bash
#
# DEPRECATED: 此脚本已被 scripts/dev/start.sh 取代
# 保留备用，使用时请改用 ./dev.sh start
#
# 快速启动脚本 - APISIX 版本（旧版）
#
# 一键启动项目的所有服务
#
# 用法:
#   ./apisix-start.sh [环境] [命令]
#
# 环境:
#   dev      开发环境（默认）
#   prod     生产环境
#
# 命令:
#   up       启动所有服务
#   down     停止所有服务
#   logs     查看所有服务日志
#   help     显示帮助信息

set -e

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
INFRA_DIR="$PROJECT_ROOT/infra"

# 默认值
ENV="${1:-dev}"
COMMAND="${2:-up}"
COMPOSE_FILE="docker-compose.yml"

# 色彩输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# 显示帮助信息
show_help() {
    cat << EOF
用法: ./start.sh [环境] [命令]

环境:
  dev      开发环境（默认）
  prod     生产环境

命令:
  up       启动所有服务
  down     停止所有服务
  logs     查看所有服务日志
  ps       查看运行状态
  help     显示此帮助信息

示例:
  # 启动开发环境
  ./start.sh dev up

  # 查看生产环境日志
  ./start.sh prod logs

  # 停止所有服务
  ./start.sh down
EOF
}

# 选择 Compose 文件
select_compose_file() {
    case "$ENV" in
        dev)
            COMPOSE_FILE="docker-compose.yml"
            log_info "使用开发环境配置"
            ;;
        prod)
            COMPOSE_FILE="docker-compose.prod.yml"
            log_info "使用生产环境配置"
            ;;
        *)
            log_error "未知的环境: $ENV"
            exit 1
            ;;
    esac
}

# 启动服务
start_services() {
    log_info "启动 Lesser 项目服务..."
    cd "$INFRA_DIR"
    docker-compose -f "$COMPOSE_FILE" up -d
    log_info "服务启动完成"
    
    # 显示访问地址
    log_info "访问地址:"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  APISIX Dashboard:  http://localhost:9000/"
    echo -e "  APISIX 网关:       http://localhost:9080/"
    echo -e "  Django API (直接): http://localhost:8001/"
    echo -e "  etcd API:          http://localhost:2379/"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# 停止服务
stop_services() {
    log_info "停止 Lesser 项目服务..."
    cd "$INFRA_DIR"
    docker-compose -f "$COMPOSE_FILE" down
    log_info "服务已停止"
}

# 查看日志
view_logs() {
    log_info "显示日志，按 Ctrl+C 退出..."
    cd "$INFRA_DIR"
    docker-compose -f "$COMPOSE_FILE" logs -f
}

# 查看状态
show_status() {
    log_info "服务运行状态:"
    cd "$INFRA_DIR"
    docker-compose -f "$COMPOSE_FILE" ps
}

# 主函数
main() {
    case "$COMMAND" in
        up)
            select_compose_file
            start_services
            ;;
        down)
            select_compose_file
            stop_services
            ;;
        logs)
            select_compose_file
            view_logs
            ;;
        ps)
            select_compose_file
            show_status
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "未知的命令: $COMMAND"
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main
