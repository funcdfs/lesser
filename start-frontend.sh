#!/bin/bash

# 启动前端服务
echo "Starting frontend service..."

# 检查是否已经有前端服务在运行
if pgrep -f "flutter run" > /dev/null; then
    echo "Frontend service is already running."
    exit 1
fi

# 进入前端目录
cd frontend || exit 1

# 检查 SM x700 是否可用
echo "Checking if SM x700 is available..."
if flutter devices | grep -q "SM x700"; then
    echo "SM x700 is available. Starting frontend on SM x700..."
    flutter run -d "SM x700" --web-port 3001
else
    echo "SM x700 is not available. Starting frontend on Chrome..."
    flutter run -d chrome --web-port 3001
fi