#!/bin/bash
# ============================================================================
# 开发环境初始化脚本 - Development Environment Setup Script
# ============================================================================
# 此脚本由 dev.sh init 调用，用于初始化开发环境
# ============================================================================

set -e

# ============================================================================
# 配置变量
# ============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 目录路径
INFRA_DIR="$PROJECT_ROOT/infra"
SERVICE_DIR="$PROJECT_ROOT/service"
CLIENT_DIR="$PROJECT_ROOT/client"
SCRIPTS_DIR="$PROJECT_ROOT/scripts"

# ============================================================================
# 颜色输出
# ============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }

print_separator() {
    echo -e "${DIM}────────────────────────────────────────────────────────────${NC}"
}

# ============================================================================
# 创建目录结构
# ============================================================================
create_directories() {
    log_step "创建目录结构..."
    
    # 基础设施目录
    mkdir -p "$INFRA_DIR/gateway/dynamic"
    mkdir -p "$INFRA_DIR/database"
    mkdir -p "$INFRA_DIR/cache"
    mkdir -p "$INFRA_DIR/env"
    
    # 脚本目录
    mkdir -p "$SCRIPTS_DIR/dev"
    mkdir -p "$SCRIPTS_DIR/prod"
    mkdir -p "$SCRIPTS_DIR/proto"
    
    # Proto 目录
    mkdir -p "$PROJECT_ROOT/protos/common"
    mkdir -p "$PROJECT_ROOT/protos/auth"
    mkdir -p "$PROJECT_ROOT/protos/feed"
    mkdir -p "$PROJECT_ROOT/protos/post"
    mkdir -p "$PROJECT_ROOT/protos/chat"
    mkdir -p "$PROJECT_ROOT/protos/notification"
    
    # 生成代码目录
    mkdir -p "$SERVICE_DIR/core_django/generated/protos"
    mkdir -p "$SERVICE_DIR/chat_gin/generated/protos"
    mkdir -p "$CLIENT_DIR/mobile_flutter/lib/generated/protos"
    mkdir -p "$CLIENT_DIR/web_react/src/generated/protos"
    
    log_success "目录结构已创建"
}

# ============================================================================
# 创建环境变量文件
# ============================================================================
setup_env_files() {
    log_step "配置环境变量文件..."
    
    # 创建 .env.dev 如果不存在
    if [ ! -f "$INFRA_DIR/.env.dev" ]; then
        if [ -f "$INFRA_DIR/.env.dev.example" ]; then
            cp "$INFRA_DIR/.env.dev.example" "$INFRA_DIR/.env.dev"
            log_info "已从模板创建 .env.dev"
        else
            log_warn ".env.dev.example 不存在，跳过"
        fi
    else
        log_info ".env.dev 已存在"
    fi
    
    # 创建 .env.prod.example 如果不存在
    if [ ! -f "$INFRA_DIR/.env.prod.example" ]; then
        cat > "$INFRA_DIR/.env.prod.example" << 'EOF'
# ============================================================================
# 生产环境配置模板 - Production Environment Configuration Template
# ============================================================================
# 复制此文件为 .env.prod 并填入实际值
# ============================================================================

# Database - PostgreSQL
POSTGRES_USER=lesser
POSTGRES_PASSWORD=CHANGE_ME_TO_SECURE_PASSWORD
POSTGRES_DB=lesser_db
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
DATABASE_URL=postgres://lesser:CHANGE_ME@postgres:5432/lesser_db

# Cache - Redis
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_URL=redis://redis:6379/0

# Django Core Service
DJANGO_SECRET_KEY=CHANGE_ME_TO_RANDOM_SECRET_KEY
DJANGO_DEBUG=False
DJANGO_ALLOWED_HOSTS=your-domain.com,www.your-domain.com
DJANGO_PORT=8000
DJANGO_GRPC_PORT=50051
DJANGO_SETTINGS_MODULE=config.settings.prod

# Go Chat Service
CHAT_HTTP_PORT=8080
CHAT_GRPC_PORT=50052
AUTH_GRPC_ADDR=django:50051

# JWT Configuration
JWT_SECRET_KEY=CHANGE_ME_TO_RANDOM_JWT_SECRET
JWT_ACCESS_TOKEN_LIFETIME=3600
JWT_REFRESH_TOKEN_LIFETIME=604800

# Celery Configuration
CELERY_BROKER_URL=redis://redis:6379/3
CELERY_RESULT_BACKEND=redis://redis:6379/4
EOF
        log_info "已创建 .env.prod.example"
    fi
    
    log_success "环境变量文件配置完成"
}

# ============================================================================
# 安装 Python 依赖
# ============================================================================
setup_python_deps() {
    log_step "检查 Python 依赖..."
    
    if command -v python3 &> /dev/null; then
        # 检查 grpcio-tools
        if ! python3 -c "import grpc_tools.protoc" 2>/dev/null; then
            log_info "安装 grpcio-tools..."
            pip3 install grpcio-tools --quiet 2>/dev/null || {
                log_warn "无法安装 grpcio-tools，Proto 生成可能受影响"
            }
        else
            log_info "grpcio-tools 已安装"
        fi
    else
        log_warn "Python 3 未安装，跳过 Python 依赖检查"
    fi
}

# ============================================================================
# 安装 Go 依赖
# ============================================================================
setup_go_deps() {
    log_step "检查 Go 依赖..."
    
    if command -v go &> /dev/null; then
        # 检查 protoc-gen-go
        if ! command -v protoc-gen-go &> /dev/null; then
            log_info "安装 protoc-gen-go..."
            go install google.golang.org/protobuf/cmd/protoc-gen-go@latest 2>/dev/null || {
                log_warn "无法安装 protoc-gen-go"
            }
        else
            log_info "protoc-gen-go 已安装"
        fi
        
        # 检查 protoc-gen-go-grpc
        if ! command -v protoc-gen-go-grpc &> /dev/null; then
            log_info "安装 protoc-gen-go-grpc..."
            go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest 2>/dev/null || {
                log_warn "无法安装 protoc-gen-go-grpc"
            }
        else
            log_info "protoc-gen-go-grpc 已安装"
        fi
    else
        log_warn "Go 未安装，跳过 Go 依赖检查"
    fi
}

# ============================================================================
# 安装 Flutter 依赖
# ============================================================================
setup_flutter_deps() {
    log_step "检查 Flutter 依赖..."
    
    if command -v flutter &> /dev/null; then
        local flutter_dir="$CLIENT_DIR/mobile_flutter"
        if [ -f "$flutter_dir/pubspec.yaml" ]; then
            log_info "安装 Flutter 依赖..."
            cd "$flutter_dir"
            flutter pub get --quiet 2>/dev/null || {
                log_warn "Flutter 依赖安装失败"
            }
            cd "$PROJECT_ROOT"
        fi
        
        # 检查 protoc-gen-dart
        if ! command -v protoc-gen-dart &> /dev/null; then
            log_info "安装 protoc-gen-dart..."
            dart pub global activate protoc_plugin 2>/dev/null || {
                log_warn "无法安装 protoc-gen-dart"
            }
        else
            log_info "protoc-gen-dart 已安装"
        fi
    else
        log_warn "Flutter 未安装，跳过 Flutter 依赖检查"
    fi
}

# ============================================================================
# 安装 Node.js 依赖
# ============================================================================
setup_node_deps() {
    log_step "检查 Node.js 依赖..."
    
    if command -v npm &> /dev/null; then
        local react_dir="$CLIENT_DIR/web_react"
        if [ -f "$react_dir/package.json" ]; then
            log_info "安装 React 依赖..."
            cd "$react_dir"
            npm install --quiet 2>/dev/null || {
                log_warn "React 依赖安装失败"
            }
            cd "$PROJECT_ROOT"
        fi
        
        # 检查 ts-proto
        if ! command -v protoc-gen-ts_proto &> /dev/null; then
            log_info "安装 ts-proto..."
            npm install -g ts-proto --quiet 2>/dev/null || {
                log_warn "无法安装 ts-proto"
            }
        else
            log_info "ts-proto 已安装"
        fi
    else
        log_warn "Node.js 未安装，跳过 Node.js 依赖检查"
    fi
}

# ============================================================================
# 设置 Git hooks
# ============================================================================
setup_git_hooks() {
    log_step "配置 Git hooks..."
    
    local hooks_dir="$PROJECT_ROOT/.git/hooks"
    
    if [ -d "$PROJECT_ROOT/.git" ]; then
        # 创建 pre-commit hook
        cat > "$hooks_dir/pre-commit" << 'EOF'
#!/bin/bash
# Pre-commit hook for code quality checks

# Run linting for Python files
if command -v flake8 &> /dev/null; then
    git diff --cached --name-only --diff-filter=ACM | grep '\.py$' | xargs -r flake8 --max-line-length=120
fi

# Run linting for Go files
if command -v golint &> /dev/null; then
    git diff --cached --name-only --diff-filter=ACM | grep '\.go$' | xargs -r golint
fi

exit 0
EOF
        chmod +x "$hooks_dir/pre-commit"
        log_info "已创建 pre-commit hook"
    else
        log_warn "不是 Git 仓库，跳过 Git hooks 配置"
    fi
}

# ============================================================================
# 验证配置
# ============================================================================
verify_setup() {
    log_step "验证配置..."
    
    local errors=0
    
    # 检查必要文件
    if [ ! -f "$INFRA_DIR/docker-compose.yml" ]; then
        log_warn "docker-compose.yml 不存在"
        ((errors++))
    fi
    
    if [ ! -f "$INFRA_DIR/.env.dev" ]; then
        log_warn ".env.dev 不存在"
        ((errors++))
    fi
    
    if [ $errors -eq 0 ]; then
        log_success "配置验证通过"
    else
        log_warn "发现 $errors 个问题，请检查"
    fi
}

# ============================================================================
# 主函数
# ============================================================================
main() {
    echo ""
    echo -e "${CYAN}${BOLD}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║${NC}  🔧 ${BOLD}开发环境初始化${NC}"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    create_directories
    setup_env_files
    setup_python_deps
    setup_go_deps
    setup_flutter_deps
    setup_node_deps
    setup_git_hooks
    verify_setup
    
    echo ""
    log_success "开发环境初始化完成！"
    echo ""
}

# 运行主函数
main "$@"
