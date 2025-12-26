#!/bin/bash

# 启动后端服务
echo "Starting backend service..."

# 检查是否已经有后端服务在运行
if pgrep -f ".venv/bin/python manage.py runserver" > /dev/null; then
    echo "Backend service is already running."
    exit 1
fi

# 进入后端目录并启动服务
cd backend/django_code || exit 1

# 使用虚拟环境中的Python
./.venv/bin/python manage.py runserver 0.0.0.0:8001