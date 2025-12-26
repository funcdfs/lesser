#!/bin/bash

# 颜色输出和日志工具库
#
# 提供彩色输出函数，供其他脚本调用
# 所有函数使用 export 声明以供 source 加载

# 定义颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 打印成功信息
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# 打印错误信息
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# 打印警告信息
print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# 打印信息
print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

# 打印分组标题
print_section() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

# 打印子标题
print_subsection() {
    echo -e "${CYAN}─ $1${NC}"
}

export -f print_success print_error print_warning print_info print_section print_subsection
