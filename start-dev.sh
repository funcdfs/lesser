#!/bin/bash

# 启动开发环境服务（后端和前端）
echo "Starting development environment..."

# 先启动后端服务
./start-backend.sh &
BACKEND_PID=$!

echo "Backend service started with PID: $BACKEND_PID"

# 等待后端服务启动
sleep 3

# 再启动前端服务
./start-frontend.sh &
FRONTEND_PID=$!

echo "Frontend service started with PID: $FRONTEND_PID"

echo "Development environment started successfully!"