#!/bin/bash

echo "=== 启动后端服务 ==="
cd "$(dirname "$0")/../infra"
docker compose up -d

echo "后端服务启动成功！"
echo "访问地址: http://django.localhost"
echo "健康检查: http://django.localhost/health/"