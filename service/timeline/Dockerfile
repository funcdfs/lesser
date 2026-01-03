# Timeline Service - Production Dockerfile
FROM golang:1.23-alpine AS builder

WORKDIR /app

COPY timeline/go.mod timeline/go.sum ./timeline/
COPY pkg/go.mod pkg/go.sum ./pkg/

RUN cd timeline && go mod download

COPY timeline/ ./timeline/
COPY pkg/ ./pkg/

RUN cd timeline && CGO_ENABLED=0 GOOS=linux go build -o /timeline ./cmd/server

FROM alpine:latest

RUN apk --no-cache add ca-certificates tzdata
ENV TZ=Asia/Shanghai

COPY --from=builder /timeline /timeline

EXPOSE 50062

CMD ["/timeline"]
