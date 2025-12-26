#!/bin/bash

# Docker 镜像源自动配置脚本
#
# 支持操作系统：macOS 和 Linux
# 自动配置国内镜像源以加速 Docker 镜像下载
#
# 用法:
#   bash scripts/utils/setup-docker-mirrors.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/colors.sh"

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    print_error "Docker 未安装，请先安装 Docker"
    exit 1
fi

print_section "Docker 镜像源配置"

# 检查操作系统
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    print_info "检测到 macOS 系统"
    
    # Docker Desktop 配置文件位置
    DOCKER_CONFIG="$HOME/Library/Group Containers/group.com.docker/com.docker.driver.amd64/etc/daemon.json"
    
    if [ ! -f "$DOCKER_CONFIG" ]; then
        # 尝试备用位置
        DOCKER_CONFIG="$HOME/.docker/daemon.json"
    fi
    
    print_info "Docker 配置文件: $DOCKER_CONFIG"
    
    # 创建配置目录
    mkdir -p "$(dirname "$DOCKER_CONFIG")"
    
    # 检查是否已有配置
    if [ -f "$DOCKER_CONFIG" ]; then
        print_info "发现现有配置文件，将备份为 daemon.json.bak"
        cp "$DOCKER_CONFIG" "${DOCKER_CONFIG}.bak"
    fi
    
    # 创建新配置
    cat > "$DOCKER_CONFIG" << 'EOF'
{
  "registry-mirrors": [
    "https://docker.1ms.run",
    "https://dockerhub.azk8s.cn",
    "https://reg-mirror.qiniu.com",
    "https://mirror.ccs.tencentyun.com"
  ],
  "builder": {
    "gc": {
      "enabled": true,
      "defaultKeepStorage": "100gb"
    }
  }
}
EOF
    
    print_success "Docker 配置已更新"
    print_warning "请重启 Docker Desktop 使配置生效"
    print_info "操作步骤:"
    echo "  1. 在菜单栏点击 Docker 图标"
    echo "  2. 选择 Quit Docker Desktop"
    echo "  3. 再次点击 Docker 图标启动"
    
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    print_info "检测到 Linux 系统"
    
    DOCKER_CONFIG="/etc/docker/daemon.json"
    
    if [ ! -w /etc/docker ]; then
        print_error "需要 sudo 权限修改 /etc/docker/daemon.json"
        print_info "请运行: sudo bash $0"
        exit 1
    fi
    
    # 创建配置目录
    mkdir -p /etc/docker
    
    # 检查是否已有配置
    if [ -f "$DOCKER_CONFIG" ]; then
        print_info "发现现有配置文件，将备份为 daemon.json.bak"
        cp "$DOCKER_CONFIG" "${DOCKER_CONFIG}.bak"
    fi
    
    # 创建新配置
    cat > "$DOCKER_CONFIG" << 'EOF'
{
  "registry-mirrors": [
    "https://docker.1ms.run",
    "https://dockerhub.azk8s.cn",
    "https://reg-mirror.qiniu.com",
    "https://mirror.ccs.tencentyun.com"
  ],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF
    
    print_success "Docker 配置已更新"
    print_info "重启 Docker 服务..."
    
    if command -v systemctl &> /dev/null; then
        systemctl restart docker
    elif command -v service &> /dev/null; then
        service docker restart
    else
        print_warning "无法自动重启 Docker，请手动执行: systemctl restart docker"
    fi
    
    print_success "Docker 已重启"
    
else
    print_error "不支持的操作系统: $OSTYPE"
    exit 1
fi

print_subsection "验证配置"
docker info | grep -A 5 "Registry Mirrors" || print_warning "未找到镜像源配置"

print_success "Docker 镜像源配置完成！"
echo ""
echo "现在可以运行以下命令："
echo "  ./dev.sh    # 启动完整后端环境"
echo ""
