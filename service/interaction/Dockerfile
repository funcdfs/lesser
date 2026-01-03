# Interaction Service - Production Dockerfile
FROM golang:1.23-alpine AS builder

WORKDIR /app

# 复制依赖文件
COPY interaction/go.mod interaction/go.sum ./interaction/
COPY pkg/go.mod pkg/go.sum ./pkg/

# 下载依赖
RUN cd interaction && go mod download

# 复制源码
COPY interaction/ ./interaction/
COPY pkg/ ./pkg/

# 构建
RUN cd interaction && CGO_ENABLED=0 GOOS=linux go build -o /interaction ./cmd/server

# 运行镜像
FROM alpine:latest

RUN apk --no-cache add ca-certificates tzdata
ENV TZ=Asia/Shanghai

COPY --from=builder /interaction /interaction

EXPOSE 50060

CMD ["/interaction"]
