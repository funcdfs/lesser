#!/bin/bash

# 数据库查询和管理脚本
#
# 连接 PostgreSQL 容器执行数据库操作
#   - 连接数据库交互终端
#   - 查看数据库和表
#   - 执行 SQL 查询
#   - 创建数据库备份

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/../utils"

source "$UTILS_DIR/colors.sh"

# 连接到 PostgreSQL
psql_connect() {
    print_subsection "连接到 PostgreSQL..."
    
    # 使用 Docker 进行连接
    docker exec -it lesser-postgres psql -U postgres -d postgres
}

# 列出所有数据库
psql_list_databases() {
    print_subsection "数据库列表:"
    docker exec lesser-postgres psql -U postgres -d postgres -c "\l"
}

# 列出指定数据库中的表
psql_list_tables() {
    local database="${1:-postgres}"
    print_subsection "数据库 '$database' 的表:"
    docker exec lesser-postgres psql -U postgres -d "$database" -c "\dt"
}

# 执行 SQL 查询
psql_query() {
    local database="${1:-postgres}"
    local query="${2:-}"
    
    if [ -z "$query" ]; then
        print_error "请提供 SQL 查询"
        return 1
    fi
    
    docker exec lesser-postgres psql -U postgres -d "$database" -c "$query"
}

# 导出数据库备份
psql_backup() {
    local database="${1:-postgres}"
    local backup_file="${2:-./backup_${database}_$(date +%Y%m%d_%H%M%S).sql}"
    
    print_subsection "备份数据库 '$database' 到 $backup_file..."
    docker exec lesser-postgres pg_dump -U postgres "$database" > "$backup_file"
    print_success "备份完成: $backup_file"
}

export -f psql_connect psql_list_databases psql_list_tables psql_query psql_backup
