.PHONY: build run test clean proto docker-build docker-run

# Go parameters
GOCMD=go
GOBUILD=$(GOCMD) build
GOTEST=$(GOCMD) test
GOCLEAN=$(GOCMD) clean
GOGET=$(GOCMD) get
GOMOD=$(GOCMD) mod

# Binary name
BINARY_NAME=chat-server
BINARY_PATH=bin/$(BINARY_NAME)

# Docker
DOCKER_IMAGE=lesser/chat-service
DOCKER_TAG=latest

# Build the application
build:
	$(GOBUILD) -o $(BINARY_PATH) -v ./cmd/server

# Run the application
run:
	$(GOCMD) run ./cmd/server

# Run tests
test:
	$(GOTEST) -v ./...

# Run tests with coverage
test-coverage:
	$(GOTEST) -v -coverprofile=coverage.out ./...
	$(GOCMD) tool cover -html=coverage.out -o coverage.html

# Clean build artifacts
clean:
	$(GOCLEAN)
	rm -rf bin/
	rm -f coverage.out coverage.html

# Download dependencies
deps:
	$(GOMOD) download
	$(GOMOD) tidy

# Generate proto files
proto:
	protoc --go_out=. --go_opt=paths=source_relative \
		--go-grpc_out=. --go-grpc_opt=paths=source_relative \
		../../protos/common/common.proto \
		../../protos/chat/chat.proto

# Build Docker image
docker-build:
	docker build -t $(DOCKER_IMAGE):$(DOCKER_TAG) .

# Run Docker container
docker-run:
	docker run -p 8080:8080 -p 50052:50052 $(DOCKER_IMAGE):$(DOCKER_TAG)

# Lint the code
lint:
	golangci-lint run ./...

# Format the code
fmt:
	$(GOCMD) fmt ./...

# Verify dependencies
verify:
	$(GOMOD) verify

# Help
help:
	@echo "Available targets:"
	@echo "  build         - Build the application"
	@echo "  run           - Run the application"
	@echo "  test          - Run tests"
	@echo "  test-coverage - Run tests with coverage"
	@echo "  clean         - Clean build artifacts"
	@echo "  deps          - Download dependencies"
	@echo "  proto         - Generate proto files"
	@echo "  docker-build  - Build Docker image"
	@echo "  docker-run    - Run Docker container"
	@echo "  lint          - Lint the code"
	@echo "  fmt           - Format the code"
