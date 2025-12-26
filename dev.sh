#!/bin/bash

# Lesser 项目统一启动脚本 - 主入口点
#
# 委托到 scripts/dev.sh 实现，加载 .env.dev 配置文件
#
# 用法:
#   ./dev.sh [命令] [参数]
#
# 命令:
#   start    启动完整后端环境（默认）
#   stop     停止所有服务
#   logs     查看服务日志
#   help     显示帮助信息
#   restart  重启指定服务
#   clean    清理所有数据
#
# 配置:
#   - 所有配置源自 .env.dev 文件（项目根目录）
#   - 自动加载并 export 到环境变量

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$PROJECT_ROOT/scripts"

# ============================================================================
# 加载环境配置 - .env.dev 文件
# ============================================================================
ENV_FILE="$PROJECT_ROOT/.env.dev"

if [ ! -f "$ENV_FILE" ]; then
    echo "错误: .env.dev 文件不存在于 $PROJECT_ROOT"
    echo "请确保项目根目录中有 .env.dev 文件"
    exit 1
fi

# 加载 .env.dev 文件中的所有配置（export 到环境变量）
export $(grep -v '^#' "$ENV_FILE" | grep -v '^$' | xargs)

# ============================================================================
# 验证必需的脚本
# ============================================================================
if [ ! -d "$SCRIPT_DIR" ]; then
    echo "错误: scripts 目录不存在"
    exit 1
fi

if [ ! -f "$SCRIPT_DIR/dev.sh" ]; then
    echo "错误: scripts/dev.sh 脚本不存在"
    exit 1
fi

# ============================================================================
# 委托到主脚本
# ============================================================================
# 主脚本会继承所有已导出的环境变量
exec "$SCRIPT_DIR/dev.sh" "$@"
