#!/bin/bash
# Chat Demo Setup Script
# This script sets up the chat demo environment:
# 1. Starts all backend services
# 2. Creates test users (test1, test2) with mutual follow relationships
# 3. Runs chat integration tests
# 4. Provides instructions for frontend testing

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
INFRA_DIR="$ROOT_DIR/infra"
COMPOSE_FILE="$INFRA_DIR/docker-compose.yml"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }
log_header() { echo -e "\n${CYAN}========================================${NC}"; echo -e "${CYAN}$1${NC}"; echo -e "${CYAN}========================================${NC}\n"; }

# Check if Docker is running
check_docker() {
    if ! docker info &> /dev/null; then
        log_error "Docker is not running. Please start Docker first."
        exit 1
    fi
}

# Wait for service to be healthy
wait_for_service() {
    local service=$1
    local max_attempts=${2:-30}
    local attempt=1

    log_info "Waiting for $service to be ready..."
    while [ $attempt -le $max_attempts ]; do
        if docker compose -f "$COMPOSE_FILE" exec -T "$service" echo "ready" &> /dev/null; then
            log_info "$service is ready!"
            return 0
        fi
        echo -n "."
        sleep 2
        attempt=$((attempt + 1))
    done
    echo ""
    log_error "$service failed to start within timeout"
    return 1
}

# Wait for Django to be ready
wait_for_django() {
    local max_attempts=30
    local attempt=1

    log_info "Waiting for Django to be ready..."
    while [ $attempt -le $max_attempts ]; do
        if docker compose -f "$COMPOSE_FILE" exec -T django python -c "import django; django.setup()" &> /dev/null; then
            log_info "Django is ready!"
            return 0
        fi
        echo -n "."
        sleep 2
        attempt=$((attempt + 1))
    done
    echo ""
    log_error "Django failed to start within timeout"
    return 1
}

# Start services
start_services() {
    log_header "Starting Backend Services"
    
    cd "$INFRA_DIR"
    
    log_step "Starting Docker Compose services..."
    docker compose -f "$COMPOSE_FILE" up -d --build
    
    log_step "Waiting for services to be healthy..."
    sleep 5
    
    # Wait for database
    wait_for_service "postgres" 30
    
    # Wait for Redis
    wait_for_service "redis" 30
    
    # Wait for Django
    wait_for_django
    
    log_info "All services are running!"
}

# Run Django migrations
run_migrations() {
    log_header "Running Database Migrations"
    
    cd "$INFRA_DIR"
    docker compose -f "$COMPOSE_FILE" exec -T django python manage.py migrate --noinput
    
    log_info "Migrations completed!"
}

# Setup test users
setup_test_users() {
    log_header "Setting Up Test Users"
    
    cd "$INFRA_DIR"
    
    log_step "Creating test users (test1, test2) with mutual follow relationships..."
    docker compose -f "$COMPOSE_FILE" exec -T django python manage.py setup_test_users
    
    log_info "Test users created successfully!"
}

# Run Go chat integration tests
run_chat_tests() {
    log_header "Running Chat Integration Tests"
    
    cd "$INFRA_DIR"
    
    log_step "Running Go chat service tests..."
    docker compose -f "$COMPOSE_FILE" exec -T chat go test -v ./internal/service/... -run TestCreateConversationRequest || true
    docker compose -f "$COMPOSE_FILE" exec -T chat go test -v ./internal/service/... -run TestSendMessageRequest || true
    
    log_info "Chat tests completed!"
}

# Test API endpoints
test_api_endpoints() {
    log_header "Testing API Endpoints"
    
    log_step "Testing Django health..."
    if curl -s http://localhost:8000/api/v1/auth/login/ -X POST -H "Content-Type: application/json" -d '{}' | grep -q "email"; then
        log_info "Django API is responding!"
    else
        log_warn "Django API may not be fully ready"
    fi
    
    log_step "Testing Chat service health..."
    if curl -s http://localhost:8081/health | grep -q "healthy"; then
        log_info "Chat service is healthy!"
    else
        log_warn "Chat service may not be fully ready"
    fi
    
    log_step "Testing Chat hello endpoint..."
    if curl -s http://localhost:8081/api/v1/chat/hello | grep -q "Hello from Chat Service"; then
        log_info "Chat API is responding!"
    else
        log_warn "Chat API may not be fully ready"
    fi
}

# Login test user and get token
login_test_user() {
    log_header "Testing User Login"
    
    log_step "Logging in as test1..."
    local response=$(curl -s http://localhost:8000/api/v1/auth/login/ \
        -X POST \
        -H "Content-Type: application/json" \
        -d '{"email": "test1@example.com", "password": "testtesttest"}')
    
    if echo "$response" | grep -q "access"; then
        log_info "Login successful!"
        echo "$response" | python3 -c "import sys, json; data=json.load(sys.stdin); print(f'User ID: {data.get(\"user\", {}).get(\"id\", \"N/A\")}')"
        echo "$response" | python3 -c "import sys, json; data=json.load(sys.stdin); print(f'Access Token: {data.get(\"access\", \"N/A\")[:50]}...')"
    else
        log_warn "Login may have failed. Response: $response"
    fi
}

# Print summary
print_summary() {
    log_header "Chat Demo Setup Complete!"
    
    echo -e "${GREEN}Services Running:${NC}"
    echo "  - Django API:     http://localhost:8000"
    echo "  - Chat API:       http://localhost:8081"
    echo "  - PostgreSQL:     localhost:5432"
    echo "  - Redis:          localhost:6379"
    echo ""
    echo -e "${GREEN}Test Users:${NC}"
    echo "  - test1@example.com / testtesttest"
    echo "  - test2@example.com / testtesttest"
    echo "  - Relationship: Friends (mutual follow)"
    echo ""
    echo -e "${GREEN}API Endpoints:${NC}"
    echo "  - Login:          POST /api/v1/auth/login/"
    echo "  - Friends:        GET  /api/v1/auth/friends/"
    echo "  - Conversations:  GET  /api/v1/chat/conversations"
    echo "  - Create Conv:    POST /api/v1/chat/conversations"
    echo "  - Messages:       GET  /api/v1/chat/conversations/:id/messages"
    echo "  - Send Message:   POST /api/v1/chat/conversations/:id/messages"
    echo ""
    echo -e "${GREEN}Frontend Testing:${NC}"
    echo "  1. Start Flutter: cd client/mobile_flutter && flutter run -d chrome"
    echo "  2. Login as test1@example.com"
    echo "  3. Navigate to /chat-demo"
    echo "  4. Select test2 from friends list"
    echo "  5. Send messages!"
    echo ""
    echo -e "${CYAN}This demo shows Django + Go gRPC communication:${NC}"
    echo "  - Django handles: Users, Authentication, Follow relationships"
    echo "  - Go Chat handles: Conversations, Messages, Real-time delivery"
    echo ""
}

# Main
main() {
    log_header "Chat Integration Demo Setup"
    
    check_docker
    start_services
    run_migrations
    setup_test_users
    test_api_endpoints
    login_test_user
    run_chat_tests
    print_summary
}

# Parse arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  (default)    Run full setup"
        echo "  start        Start services only"
        echo "  users        Setup test users only"
        echo "  test         Run tests only"
        echo "  status       Show service status"
        echo ""
        exit 0
        ;;
    start)
        check_docker
        start_services
        ;;
    users)
        setup_test_users
        ;;
    test)
        test_api_endpoints
        login_test_user
        run_chat_tests
        ;;
    status)
        cd "$INFRA_DIR"
        docker compose -f "$COMPOSE_FILE" ps
        ;;
    *)
        main
        ;;
esac
