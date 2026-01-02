FROM golang:1.21-alpine AS builder

WORKDIR /app

# 复制 go.mod 和 go.sum
COPY service/auth/go.mod service/auth/go.sum ./service/auth/
COPY service/pkg/go.mod service/pkg/go.sum ./service/pkg/

# 下载依赖
WORKDIR /app/service/auth
RUN go mod download

# 复制源代码
WORKDIR /app
COPY service/auth ./service/auth
COPY service/pkg ./service/pkg

# 构建
WORKDIR /app/service/auth
RUN CGO_ENABLED=0 GOOS=linux go build -o /auth-server ./cmd/server

# 运行镜像
FROM alpine:3.19

RUN apk --no-cache add ca-certificates

WORKDIR /app

COPY --from=builder /auth-server .

EXPOSE 50054

CMD ["./auth-server"]
