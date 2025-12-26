#!/bin/bash

# 查看服务日志脚本
#
# 查看 Docker 容器的实时日志输出
# 按 Ctrl+C 停止查看

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
INFRA_DIR="$PROJECT_ROOT/infra"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

source "$UTILS_DIR/colors.sh"

show_logs() {
    local service="${1:-all}"
    local docker_compose_file="$INFRA_DIR/docker-compose.yml"
    
    print_section "查看服务日志"
    
    cd "$INFRA_DIR"
    
    case "$service" in
        django)
            print_info "显示 Django 日志（Ctrl+C 停止）..."
            docker-compose -f "$docker_compose_file" logs -f django
            ;;
        postgres)
            print_info "显示 PostgreSQL 日志（Ctrl+C 停止）..."
            docker-compose -f "$docker_compose_file" logs -f postgres
            ;;
        redis)
            print_info "显示 Redis 日志（Ctrl+C 停止）..."
            docker-compose -f "$docker_compose_file" logs -f redis
            ;;
        apisix)
            print_info "显示 APISIX 日志（Ctrl+C 停止）..."
            docker-compose -f "$docker_compose_file" logs -f apisix
            ;;
        etcd)
            print_info "显示 etcd 日志（Ctrl+C 停止）..."
            docker-compose -f "$docker_compose_file" logs -f etcd
            ;;
        all|"")
            print_info "显示所有服务日志（Ctrl+C 停止）..."
            docker-compose -f "$docker_compose_file" logs -f
            ;;
        *)
            print_error "未知的服务: $service"
            echo "可用的服务: django, postgres, redis, apisix, etcd, all"
            return 1
            ;;
    esac
}

export -f show_logs
