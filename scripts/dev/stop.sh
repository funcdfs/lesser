#!/bin/bash

# 停止所有后端服务脚本
#
# 停止并卸载 Docker Compose 启动的所有容器
# 数据卷保留，用于下次启动恢复

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
INFRA_DIR="$PROJECT_ROOT/infra"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

source "$UTILS_DIR/colors.sh"

stop_services() {
    print_section "停止后端服务"
    
    local docker_compose_file="$INFRA_DIR/docker-compose.yml"
    
    # 检查是否有运行中的容器
    if ! docker-compose -f "$docker_compose_file" ps --services --filter "status=running" 2>/dev/null | grep -q .; then
        print_info "没有运行中的服务"
        return
    fi
    
    print_info "停止 Docker 容器..."
    cd "$INFRA_DIR"
    docker-compose -f "$docker_compose_file" down
    
    print_success "所有服务已停止"
    print_info "数据已保留，使用 './dev.sh start' 重新启动"
}

export -f stop_services
