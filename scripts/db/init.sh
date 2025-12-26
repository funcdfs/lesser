#!/bin/bash

# 数据库初始化脚本
#
# 执行以下操作：
#   1. 等待 Django 容器就绪
#   2. 运行数据库迁移
#   3. 创建默认超级用户 (admin/admin123)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
INFRA_DIR="$PROJECT_ROOT/infra"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/../utils"

source "$UTILS_DIR/colors.sh"

init_database() {
    print_section "初始化数据库"
    
    local django_container="lesser-django"
    local max_attempts=30
    local attempt=0
    
    # 等待 Django 容器就绪
    print_subsection "等待 Django 容器就绪..."
    while [ $attempt -lt $max_attempts ]; do
        if docker exec "$django_container" python manage.py check &>/dev/null; then
            print_success "Django 已就绪"
            break
        fi
        attempt=$((attempt + 1))
        if [ $attempt -eq $max_attempts ]; then
            print_error "Django 容器无响应，初始化失败"
            return 1
        fi
        sleep 1
    done
    
    # 运行迁移
    print_subsection "运行数据库迁移..."
    docker exec "$django_container" python manage.py migrate 2>/dev/null
    print_success "数据库迁移完成"
    
    # 创建默认用户
    print_subsection "创建默认用户..."
    docker exec -it "$django_container" python manage.py shell << 'EOF' 2>/dev/null || print_warning "用户创建或已存在"
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@localhost', 'admin123')
    print("\n✓ 超级用户创建成功")
    print("  用户名: admin")
    print("  密码:   admin123")
else:
    print("\n✓ 超级用户已存在")
EOF
    
    # 收集静态文件（如果需要）
    print_subsection "收集静态文件..."
    docker exec "$django_container" python manage.py collectstatic --noinput 2>/dev/null || true
    
    print_success "数据库初始化完成"
}

reset_database() {
    print_section "重置数据库（删除所有数据）"
    
    print_warning "⚠️  这个操作将删除所有数据库内容！"
    read -p "是否继续？请输入 'yes' 确认: " -r
    echo ""
    
    if [[ $REPLY != "yes" ]]; then
        print_info "操作已取消"
        return
    fi
    
    local django_container="lesser-django"
    
    print_subsection "删除所有数据库..."
    docker exec "$django_container" python manage.py flush --no-input 2>/dev/null
    
    print_subsection "重新运行迁移..."
    docker exec "$django_container" python manage.py migrate 2>/dev/null
    
    print_subsection "创建默认用户..."
    docker exec -it "$django_container" python manage.py shell << 'EOF' 2>/dev/null
from django.contrib.auth import get_user_model
User = get_user_model()
User.objects.create_superuser('admin', 'admin@localhost', 'admin123')
print("\n✓ 数据库已重置，默认用户已创建")
EOF
    
    print_success "数据库重置完成"
}

export -f init_database reset_database
