#!/bin/bash

# Lesser 项目启动脚本 - 命令分发器
#
# 分发各类启动、停止、日志、清理命令到对应的子脚本
#
# 用法:
#   ./dev.sh [命令] [参数]
#
# 命令:
#   start          启动完整后端环境（默认）
#   stop           停止所有服务
#   restart <svc>  重启服务（django|postgres|redis|apisix|etcd）
#   logs [svc]     查看日志（django|postgres|redis|apisix|etcd|all）
#   clean          清理所有数据（危险操作）
#   help           显示帮助信息

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
INFRA_DIR="$PROJECT_ROOT/infra"

# 导入工具函数
source "$SCRIPT_DIR/utils/colors.sh"

# 默认命令
COMMAND="${1:-start}"

# 获取子命令参数
SUBCOMMAND="${2:-}"

case "$COMMAND" in
    start)
        source "$SCRIPT_DIR/dev/start.sh"
        start_services
        ;;
    stop)
        source "$SCRIPT_DIR/dev/stop.sh"
        stop_services
        ;;
    restart)
        if [ -z "$SUBCOMMAND" ]; then
            print_error "请指定要重启的服务: django|postgres|redis|apisix|etcd"
            exit 1
        fi
        source "$SCRIPT_DIR/dev/restart.sh"
        restart_service "$SUBCOMMAND"
        ;;
    logs)
        source "$SCRIPT_DIR/dev/logs.sh"
        show_logs "$SUBCOMMAND"
        ;;
    clean)
        source "$SCRIPT_DIR/dev/clean.sh"
        clean_all
        ;;
    help|--help|-h)
        cat << 'EOF'
Lesser 项目启动脚本

用法:
  ./dev.sh [命令] [参数]

命令:
  start              启动完整后端环境（默认）
                     使用: ./dev.sh start

  stop               停止所有服务
                     使用: ./dev.sh stop

  restart <服务>    重启指定服务
                     服务: django|postgres|redis|apisix|etcd
                     使用: ./dev.sh restart django

  logs [服务]       查看服务日志
                     服务: django|postgres|redis|apisix|etcd|all（默认all）
                     使用: ./dev.sh logs django

  clean              清理所有数据并重新初始化（危险！）
                     使用: ./dev.sh clean

  help               显示本帮助信息

示例:
  # 启动完整环境
  ./dev.sh

  # 查看 Django 日志
  ./dev.sh logs django

  # 重启 Django 服务
  ./dev.sh restart django

  # 停止所有服务
  ./dev.sh stop

快速参考:
  启动:         ./dev.sh
  查看日志:     ./dev.sh logs
  重启服务:     ./dev.sh restart django
  停止服务:     ./dev.sh stop
EOF
        ;;
    *)
        print_error "未知命令: $COMMAND"
        echo "使用 './dev.sh help' 查看帮助"
        exit 1
        ;;
esac
