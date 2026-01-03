# ============================================================================
# 通用生产环境 Dockerfile
# 使用方式: docker build --build-arg SERVICE_NAME=auth --build-arg GRPC_PORT=50054 .
# Context: service/ 目录
# ============================================================================

FROM golang:1.25.5-alpine AS builder

WORKDIR /app

# 安装必要工具
RUN apk add --no-cache git ca-certificates tzdata

# 服务名称参数
ARG SERVICE_NAME

# 复制 go.mod 和 go.sum
COPY ${SERVICE_NAME}/go.mod ${SERVICE_NAME}/go.sum ./${SERVICE_NAME}/
COPY pkg/go.mod pkg/go.sum ./pkg/

# 下载依赖
WORKDIR /app/${SERVICE_NAME}
RUN go mod download

# 复制源代码
WORKDIR /app
COPY pkg/ ./pkg/
COPY ${SERVICE_NAME}/ ./${SERVICE_NAME}/

# 构建二进制文件
# 大多数服务入口在 ./cmd/server，gateway 在 .
WORKDIR /app/${SERVICE_NAME}
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o /server ./cmd/server 2>/dev/null || \
    CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o /server .

# ============================================================================
# 运行镜像
# ============================================================================
FROM alpine:3.19

RUN apk --no-cache add ca-certificates tzdata
ENV TZ=Asia/Shanghai

WORKDIR /app

COPY --from=builder /server .

# 端口参数
ARG GRPC_PORT
EXPOSE ${GRPC_PORT}

CMD ["./server"]
