#!/bin/bash
# Django 服务启动脚本
# 同时启动 HTTP server 和 gRPC server

set -e

# 安装依赖
uv pip install --system --no-cache -r requirements.txt

# 运行数据库迁移
python manage.py makemigrations --noinput
python manage.py migrate --noinput

# 启动 gRPC server（后台运行）
python -m grpc_server.server &
GRPC_PID=$!
echo "gRPC server started with PID: $GRPC_PID"

# 启动 HTTP server（前台运行）
python manage.py runserver 0.0.0.0:8000

# 如果 HTTP server 退出，也停止 gRPC server
kill $GRPC_PID 2>/dev/null || true
