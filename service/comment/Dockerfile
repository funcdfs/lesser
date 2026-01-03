# Comment Service - Production Dockerfile
FROM golang:1.23-alpine AS builder

WORKDIR /app

COPY comment/go.mod comment/go.sum ./comment/
COPY pkg/go.mod pkg/go.sum ./pkg/

RUN cd comment && go mod download

COPY comment/ ./comment/
COPY pkg/ ./pkg/

RUN cd comment && CGO_ENABLED=0 GOOS=linux go build -o /comment ./cmd/server

FROM alpine:latest

RUN apk --no-cache add ca-certificates tzdata
ENV TZ=Asia/Shanghai

COPY --from=builder /comment /comment

EXPOSE 50061

CMD ["/comment"]
