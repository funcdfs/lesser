#!/bin/bash

# 清理所有数据脚本 - 危险操作！
#
# 永久删除：
#   - 所有 Docker 容器
#   - PostgreSQL 数据库文件
#   - Redis 数据文件
# 
# 执行前需要确认

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
INFRA_DIR="$PROJECT_ROOT/infra"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

source "$UTILS_DIR/colors.sh"

clean_all() {
    print_section "清理所有数据"
    
    print_warning "⚠️  危险操作：这将删除所有数据库数据和容器！"
    echo ""
    read -p "是否继续？请输入 'yes' 确认: " -r
    echo ""
    
    if [[ $REPLY != "yes" ]]; then
        print_info "操作已取消"
        return
    fi
    
    local docker_compose_file="$INFRA_DIR/docker-compose.yml"
    
    print_subsection "停止所有容器..."
    cd "$INFRA_DIR"
    docker-compose -f "$docker_compose_file" down 2>/dev/null || true
    
    print_subsection "删除容器和卷..."
    docker-compose -f "$docker_compose_file" down -v 2>/dev/null || true
    
    print_subsection "删除 PostgreSQL 数据..."
    local pg_data_dir="$PROJECT_ROOT/docker/postgres/data"
    if [ -d "$pg_data_dir" ]; then
        rm -rf "$pg_data_dir"/*
        print_success "PostgreSQL 数据已清理"
    fi
    
    print_subsection "删除 Redis 数据..."
    local redis_data_dir="$PROJECT_ROOT/docker/redis/data"
    if [ -d "$redis_data_dir" ]; then
        rm -rf "$redis_data_dir"/*
        print_success "Redis 数据已清理"
    fi
    
    print_success "所有数据已清理完成"
    print_info "使用 './dev.sh start' 重新初始化环境"
}

export -f clean_all
