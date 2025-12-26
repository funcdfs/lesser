#!/bin/bash

# 诊断和日志工具脚本
#
# 提供以下功能：
#   - 查看容器日志
#   - 进入容器交互式 shell
#   - 服务健康检查
#   - 容器资源使用情况监控

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$SCRIPT_DIR"

source "$UTILS_DIR/colors.sh"

# 查看特定数量的最新日志
tail_logs() {
    local service="${1:-}"
    local lines="${2:-50}"
    
    if [ -z "$service" ]; then
        print_error "请指定服务: django, postgres, redis, apisix, etcd"
        return 1
    fi
    
    print_subsection "最新 $lines 行 $service 日志:"
    docker logs --tail "$lines" "lesser-$service" 2>&1 || docker logs --tail "$lines" "$service" 2>&1 || true
}

# 进入容器交互式 shell
shell_into_container() {
    local container="${1:-}"
    
    if [ -z "$container" ]; then
        print_error "请指定容器"
        return 1
    fi
    
    print_subsection "进入容器: $container"
    docker exec -it "$container" /bin/sh 2>/dev/null || docker exec -it "$container" /bin/bash 2>/dev/null || true
}

# 检查所有服务健康状态
health_check() {
    print_section "服务健康检查"
    
    local services=("django" "postgres" "redis" "apisix" "etcd")
    
    for service in "${services[@]}"; do
        local container="lesser-$service"
        
        if docker ps | grep -q "$container"; then
            print_success "$service: 运行中"
            
            # 特定服务的健康检查
            case "$service" in
                django)
                    if curl -s http://localhost:8000/health/ >/dev/null 2>&1; then
                        print_success "  └─ HTTP 健康检查: 通过"
                    else
                        print_warning "  └─ HTTP 健康检查: 失败"
                    fi
                    ;;
                postgres)
                    if docker exec "$container" pg_isready -h localhost -U postgres &>/dev/null; then
                        print_success "  └─ 数据库连接: 正常"
                    else
                        print_warning "  └─ 数据库连接: 失败"
                    fi
                    ;;
                redis)
                    if docker exec "$container" redis-cli ping &>/dev/null; then
                        print_success "  └─ Redis PING: 通过"
                    else
                        print_warning "  └─ Redis PING: 失败"
                    fi
                    ;;
                apisix)
                    if curl -s http://localhost:9000 >/dev/null 2>&1; then
                        print_success "  └─ APISIX 仪表盘: 可访问"
                    else
                        print_warning "  └─ APISIX 仪表盘: 无法访问"
                    fi
                    ;;
                etcd)
                    if curl -s http://localhost:2379/health >/dev/null 2>&1; then
                        print_success "  └─ etcd 健康: 正常"
                    else
                        print_warning "  └─ etcd 健康: 失败"
                    fi
                    ;;
            esac
        else
            print_warning "$service: 未运行"
        fi
    done
}

# 显示容器资源使用情况
resource_usage() {
    print_section "容器资源使用情况"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" lesser-*
}

export -f tail_logs shell_into_container health_check resource_usage
