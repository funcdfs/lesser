#!/bin/bash

# 重启指定服务脚本
#
# 支持重启单个 Docker 容器
# 服务名: django|postgres|redis|apisix|etcd

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
INFRA_DIR="$PROJECT_ROOT/infra"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

source "$UTILS_DIR/colors.sh"

restart_service() {
    local service="${1:-}"
    
    if [ -z "$service" ]; then
        print_error "请指定要重启的服务"
        echo "可用的服务: django, postgres, redis, apisix, etcd"
        return 1
    fi
    
    print_section "重启服务: $service"
    
    local docker_compose_file="$INFRA_DIR/docker-compose.yml"
    
    # 映射服务名称
    local container_name
    case "$service" in
        django)
            container_name="lesser-django"
            ;;
        postgres)
            container_name="lesser-postgres"
            ;;
        redis)
            container_name="lesser-redis"
            ;;
        apisix)
            container_name="lesser-apisix"
            ;;
        etcd)
            container_name="lesser-etcd"
            ;;
        *)
            print_error "未知的服务: $service"
            echo "可用的服务: django, postgres, redis, apisix, etcd"
            return 1
            ;;
    esac
    
    # 检查容器是否存在
    if ! docker ps -a | grep -q "$container_name"; then
        print_error "容器不存在: $container_name"
        return 1
    fi
    
    print_info "重启容器: $container_name"
    docker restart "$container_name"
    
    # 等待容器完全启动
    sleep 2
    
    # 验证容器状态
    if docker ps | grep -q "$container_name"; then
        print_success "服务 '$service' 已重启"
    else
        print_error "服务 '$service' 重启失败"
        return 1
    fi
}

export -f restart_service
