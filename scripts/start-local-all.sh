#!/bin/bash

echo "=== 启动所有服务 ==="

# 启动后端服务
cd "$(dirname "$0")/../infra"
echo "正在启动后端服务..."
docker compose up -d

# 返回脚本所在目录
cd "$(dirname "$0")"

# 启动前端服务
echo "正在启动前端服务..."
bash start-frontend.sh