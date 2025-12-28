#!/bin/bash
# Proto Code Generation Script
# Generates code for Python, Go, Dart, and TypeScript from .proto files

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PROTO_DIR="$PROJECT_ROOT/protos"

# Output directories
PYTHON_OUT="$PROJECT_ROOT/service/core_django/generated/protos"
GO_OUT="$PROJECT_ROOT/service/chat_gin/generated/protos"
DART_OUT="$PROJECT_ROOT/client/mobile_flutter/lib/generated/protos"
TS_OUT="$PROJECT_ROOT/client/web_react/src/generated/protos"

# Proto files to generate
PROTO_FILES=(
    "common/common.proto"
    "auth/auth.proto"
    "post/post.proto"
    "feed/feed.proto"
    "chat/chat.proto"
    "notification/notification.proto"
)

# Check if a command exists
check_command() {
    if ! command -v "$1" &> /dev/null; then
        return 1
    fi
    return 0
}

# Check dependencies
check_dependencies() {
    log_step "Checking dependencies..."
    
    local missing=()
    
    if ! check_command protoc; then
        missing+=("protoc (Protocol Buffers compiler)")
    fi
    
    if [ ${#missing[@]} -gt 0 ]; then
        log_error "Missing required dependencies:"
        for dep in "${missing[@]}"; do
            echo "  - $dep"
        done
        echo ""
        echo "Installation instructions:"
        echo "  macOS:   brew install protobuf"
        echo "  Ubuntu:  apt-get install -y protobuf-compiler"
        echo "  Windows: choco install protoc"
        exit 1
    fi
    
    log_info "All core dependencies are installed"
}

# Create output directories
create_directories() {
    log_step "Creating output directories..."
    
    mkdir -p "$PYTHON_OUT"
    mkdir -p "$GO_OUT"
    mkdir -p "$DART_OUT"
    mkdir -p "$TS_OUT"
    
    log_info "Output directories created"
}

# Generate Python code
generate_python() {
    log_step "Generating Python code..."
    
    if ! check_command grpc_tools_protoc && ! python3 -c "import grpc_tools.protoc" 2>/dev/null; then
        log_warn "grpcio-tools not installed. Install with: pip install grpcio-tools"
        log_warn "Skipping Python generation"
        return
    fi
    
    # Create __init__.py files
    touch "$PYTHON_OUT/__init__.py"
    
    for proto in "${PROTO_FILES[@]}"; do
        local proto_path="$PROTO_DIR/$proto"
        local proto_name=$(basename "$proto" .proto)
        local proto_dir=$(dirname "$proto")
        
        if [ -f "$proto_path" ]; then
            mkdir -p "$PYTHON_OUT/$proto_dir"
            touch "$PYTHON_OUT/$proto_dir/__init__.py"
            
            python3 -m grpc_tools.protoc \
                -I"$PROTO_DIR" \
                --python_out="$PYTHON_OUT" \
                --grpc_python_out="$PYTHON_OUT" \
                --pyi_out="$PYTHON_OUT" \
                "$proto_path" 2>/dev/null || {
                    # Fallback to protoc if grpc_tools fails
                    protoc \
                        -I"$PROTO_DIR" \
                        --python_out="$PYTHON_OUT" \
                        "$proto_path"
                }
            
            log_info "  Generated: $proto"
        else
            log_warn "  Not found: $proto_path"
        fi
    done
    
    log_info "Python code generation complete"
}

# Generate Go code
generate_go() {
    log_step "Generating Go code..."
    
    if ! check_command protoc-gen-go; then
        log_warn "protoc-gen-go not installed. Install with:"
        log_warn "  go install google.golang.org/protobuf/cmd/protoc-gen-go@latest"
        log_warn "  go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest"
        log_warn "Skipping Go generation"
        return
    fi
    
    for proto in "${PROTO_FILES[@]}"; do
        local proto_path="$PROTO_DIR/$proto"
        local proto_dir=$(dirname "$proto")
        
        if [ -f "$proto_path" ]; then
            mkdir -p "$GO_OUT/$proto_dir"
            
            protoc \
                -I"$PROTO_DIR" \
                --go_out="$GO_OUT" \
                --go_opt=paths=source_relative \
                --go-grpc_out="$GO_OUT" \
                --go-grpc_opt=paths=source_relative \
                "$proto_path" 2>/dev/null || {
                    # Fallback without grpc if plugin not available
                    protoc \
                        -I"$PROTO_DIR" \
                        --go_out="$GO_OUT" \
                        --go_opt=paths=source_relative \
                        "$proto_path"
                }
            
            log_info "  Generated: $proto"
        else
            log_warn "  Not found: $proto_path"
        fi
    done
    
    log_info "Go code generation complete"
}

# Generate Dart code
generate_dart() {
    log_step "Generating Dart code..."
    
    if ! check_command protoc-gen-dart; then
        log_warn "protoc-gen-dart not installed. Install with:"
        log_warn "  dart pub global activate protoc_plugin"
        log_warn "Skipping Dart generation"
        return
    fi
    
    for proto in "${PROTO_FILES[@]}"; do
        local proto_path="$PROTO_DIR/$proto"
        local proto_dir=$(dirname "$proto")
        
        if [ -f "$proto_path" ]; then
            mkdir -p "$DART_OUT/$proto_dir"
            
            protoc \
                -I"$PROTO_DIR" \
                --dart_out=grpc:"$DART_OUT" \
                "$proto_path"
            
            log_info "  Generated: $proto"
        else
            log_warn "  Not found: $proto_path"
        fi
    done
    
    log_info "Dart code generation complete"
}

# Generate TypeScript code
generate_typescript() {
    log_step "Generating TypeScript code..."
    
    # Check for ts-proto or grpc-web plugin
    local ts_plugin=""
    
    if check_command protoc-gen-ts_proto; then
        ts_plugin="ts_proto"
    elif check_command protoc-gen-grpc-web; then
        ts_plugin="grpc-web"
    else
        log_warn "No TypeScript protoc plugin found. Install one of:"
        log_warn "  npm install -g ts-proto"
        log_warn "  or download protoc-gen-grpc-web from:"
        log_warn "  https://github.com/grpc/grpc-web/releases"
        log_warn "Skipping TypeScript generation"
        return
    fi
    
    for proto in "${PROTO_FILES[@]}"; do
        local proto_path="$PROTO_DIR/$proto"
        local proto_dir=$(dirname "$proto")
        
        if [ -f "$proto_path" ]; then
            mkdir -p "$TS_OUT/$proto_dir"
            
            if [ "$ts_plugin" = "ts_proto" ]; then
                protoc \
                    -I"$PROTO_DIR" \
                    --plugin=protoc-gen-ts_proto="$(which protoc-gen-ts_proto)" \
                    --ts_proto_out="$TS_OUT" \
                    --ts_proto_opt=outputServices=grpc-js \
                    --ts_proto_opt=esModuleInterop=true \
                    "$proto_path"
            else
                protoc \
                    -I"$PROTO_DIR" \
                    --js_out=import_style=commonjs:"$TS_OUT" \
                    --grpc-web_out=import_style=typescript,mode=grpcwebtext:"$TS_OUT" \
                    "$proto_path"
            fi
            
            log_info "  Generated: $proto"
        else
            log_warn "  Not found: $proto_path"
        fi
    done
    
    log_info "TypeScript code generation complete"
}

# Clean generated files
clean() {
    log_step "Cleaning generated files..."
    
    rm -rf "$PYTHON_OUT"/*
    rm -rf "$GO_OUT"/*
    rm -rf "$DART_OUT"/*
    rm -rf "$TS_OUT"/*
    
    log_info "Generated files cleaned"
}

# Show help
show_help() {
    echo "Proto Code Generation Script"
    echo ""
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  all         Generate code for all languages (default)"
    echo "  python      Generate Python code only"
    echo "  go          Generate Go code only"
    echo "  dart        Generate Dart code only"
    echo "  typescript  Generate TypeScript code only"
    echo "  clean       Remove all generated files"
    echo "  check       Check dependencies only"
    echo "  help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0              # Generate all"
    echo "  $0 all          # Generate all"
    echo "  $0 python       # Generate Python only"
    echo "  $0 go dart      # Generate Go and Dart"
    echo "  $0 clean        # Clean generated files"
}

# Main function
main() {
    echo "========================================"
    echo "  Proto Code Generation"
    echo "========================================"
    echo ""
    
    # Default to generating all if no arguments
    if [ $# -eq 0 ]; then
        set -- "all"
    fi
    
    # Process commands
    for cmd in "$@"; do
        case "$cmd" in
            all)
                check_dependencies
                create_directories
                generate_python
                generate_go
                generate_dart
                generate_typescript
                ;;
            python)
                check_dependencies
                create_directories
                generate_python
                ;;
            go)
                check_dependencies
                create_directories
                generate_go
                ;;
            dart)
                check_dependencies
                create_directories
                generate_dart
                ;;
            typescript|ts)
                check_dependencies
                create_directories
                generate_typescript
                ;;
            clean)
                clean
                ;;
            check)
                check_dependencies
                ;;
            help|--help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown command: $cmd"
                show_help
                exit 1
                ;;
        esac
    done
    
    echo ""
    log_info "Proto generation complete!"
    echo ""
    echo "Output directories:"
    echo "  Python:     $PYTHON_OUT"
    echo "  Go:         $GO_OUT"
    echo "  Dart:       $DART_OUT"
    echo "  TypeScript: $TS_OUT"
}

# Run main function
main "$@"
