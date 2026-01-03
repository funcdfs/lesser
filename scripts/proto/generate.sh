#!/bin/bash
# Proto 代码生成脚本
# 用法: ./generate.sh [target]
# target: all, go, dart (默认 all)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PROTO_DIR="$PROJECT_ROOT/protos"

TARGET="${1:-all}"

echo "📦 Proto 代码生成"
echo "项目根目录: $PROJECT_ROOT"
echo "Proto 目录: $PROTO_DIR"
echo "目标: $TARGET"
echo ""

# 检查 protoc 是否安装
if ! command -v protoc &> /dev/null; then
    echo "❌ protoc 未安装"
    echo "请安装 Protocol Buffers 编译器:"
    echo "  macOS: brew install protobuf"
    echo "  Linux: apt-get install protobuf-compiler"
    exit 1
fi

# 生成 Go 代码
generate_go() {
    echo "🔧 生成 Go 代码..."
    
    # 检查 protoc-gen-go 是否安装
    if ! command -v protoc-gen-go &> /dev/null; then
        echo "安装 protoc-gen-go..."
        go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
    fi
    
    if ! command -v protoc-gen-go-grpc &> /dev/null; then
        echo "安装 protoc-gen-go-grpc..."
        go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
    fi
    
    # 服务列表
    SERVICES=("gateway" "auth" "user" "post" "feed" "search" "notification" "chat")
    
    for service in "${SERVICES[@]}"; do
        SERVICE_DIR="$PROJECT_ROOT/service/$service"
        PROTO_OUT="$SERVICE_DIR/proto"
        
        # 如果服务目录存在，生成代码
        if [ -d "$SERVICE_DIR" ] || [ "$service" = "gateway" ] || [ "$service" = "chat" ]; then
            echo "  生成 $service..."
            mkdir -p "$PROTO_OUT"
            
            # 生成 common
            protoc \
                --proto_path="$PROTO_DIR" \
                --go_out="$PROTO_OUT" \
                --go_opt=paths=source_relative \
                --go-grpc_out="$PROTO_OUT" \
                --go-grpc_opt=paths=source_relative \
                "$PROTO_DIR/common/common.proto" 2>/dev/null || true
            
            # 生成服务特定的 proto
            if [ -f "$PROTO_DIR/$service/$service.proto" ]; then
                protoc \
                    --proto_path="$PROTO_DIR" \
                    --go_out="$PROTO_OUT" \
                    --go_opt=paths=source_relative \
                    --go-grpc_out="$PROTO_OUT" \
                    --go-grpc_opt=paths=source_relative \
                    "$PROTO_DIR/$service/$service.proto"
            fi
        fi
    done
    
    # Gateway 需要代理所有服务，生成额外的 proto
    echo "  生成 Gateway 代理所需的 proto..."
    GATEWAY_PROTO_OUT="$PROJECT_ROOT/service/gateway/proto"
    
    # Gateway 需要 user proto (用于 search 返回类型)
    protoc \
        --proto_path="$PROTO_DIR" \
        --go_out="$GATEWAY_PROTO_OUT" \
        --go_opt=paths=source_relative \
        --go_opt=Mcommon/common.proto=github.com/funcdfs/lesser/gateway/proto/common \
        --go-grpc_out="$GATEWAY_PROTO_OUT" \
        --go-grpc_opt=paths=source_relative \
        --go-grpc_opt=Mcommon/common.proto=github.com/funcdfs/lesser/gateway/proto/common \
        "$PROTO_DIR/user/user.proto" 2>/dev/null || true
    
    # Gateway 需要 post proto (用于 search 返回类型)
    protoc \
        --proto_path="$PROTO_DIR" \
        --go_out="$GATEWAY_PROTO_OUT" \
        --go_opt=paths=source_relative \
        --go_opt=Mcommon/common.proto=github.com/funcdfs/lesser/gateway/proto/common \
        --go-grpc_out="$GATEWAY_PROTO_OUT" \
        --go-grpc_opt=paths=source_relative \
        --go-grpc_opt=Mcommon/common.proto=github.com/funcdfs/lesser/gateway/proto/common \
        "$PROTO_DIR/post/post.proto" 2>/dev/null || true
    
    # Gateway 需要 search proto
    protoc \
        --proto_path="$PROTO_DIR" \
        --go_out="$GATEWAY_PROTO_OUT" \
        --go_opt=paths=source_relative \
        --go_opt=Mcommon/common.proto=github.com/funcdfs/lesser/gateway/proto/common \
        --go_opt=Muser/user.proto=github.com/funcdfs/lesser/gateway/proto/user \
        --go_opt=Mpost/post.proto=github.com/funcdfs/lesser/gateway/proto/post \
        --go-grpc_out="$GATEWAY_PROTO_OUT" \
        --go-grpc_opt=paths=source_relative \
        --go-grpc_opt=Mcommon/common.proto=github.com/funcdfs/lesser/gateway/proto/common \
        --go-grpc_opt=Muser/user.proto=github.com/funcdfs/lesser/gateway/proto/user \
        --go-grpc_opt=Mpost/post.proto=github.com/funcdfs/lesser/gateway/proto/post \
        "$PROTO_DIR/search/search.proto" 2>/dev/null || true
    
    echo "✅ Go 代码生成完成"
}


# 生成 Dart 代码
generate_dart() {
    echo "🔧 生成 Dart 代码..."
    
    DART_OUT="$PROJECT_ROOT/client/mobile_flutter/lib/generated/protos"
    
    # 检查 protoc-gen-dart 是否安装
    if ! command -v protoc-gen-dart &> /dev/null; then
        echo "安装 protoc-gen-dart..."
        dart pub global activate protoc_plugin
    fi
    
    # 清理旧的生成代码
    rm -rf "$DART_OUT"
    mkdir -p "$DART_OUT"
    
    # Proto 文件列表
    PROTOS=(
        "common/common.proto"
        "auth/auth.proto"
        "user/user.proto"
        "post/post.proto"
        "feed/feed.proto"
        "search/search.proto"
        "notification/notification.proto"
        "chat/chat.proto"
        "gateway/gateway.proto"
    )
    
    for proto in "${PROTOS[@]}"; do
        if [ -f "$PROTO_DIR/$proto" ]; then
            echo "  生成 $proto..."
            protoc \
                --proto_path="$PROTO_DIR" \
                --dart_out=grpc:"$DART_OUT" \
                "$PROTO_DIR/$proto"
        fi
    done
    
    echo "✅ Dart 代码生成完成"
}

# 根据目标执行生成
case "$TARGET" in
    all)
        generate_go
        generate_dart
        ;;
    go)
        generate_go
        ;;
    dart)
        generate_dart
        ;;
    *)
        echo "❌ 未知目标: $TARGET"
        echo "支持的目标: all, go, dart"
        exit 1
        ;;
esac

echo ""
echo "🎉 Proto 代码生成完成!"
