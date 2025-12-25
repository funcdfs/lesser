#!/bin/bash
"""
启动 Polls gRPC 服务器
"""

# 进入项目根目录
cd "$(dirname "$(dirname "$(realpath "$0")")")"

# 激活虚拟环境
source .venv/bin/activate

# 设置 Django 环境变量
export DJANGO_SETTINGS_MODULE=lesser.settings

# 运行 gRPC 服务器
python polls/polls_grpc_service.py