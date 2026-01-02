FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY service/feed/go.mod service/feed/go.sum ./service/feed/
COPY service/pkg/go.mod service/pkg/go.sum ./service/pkg/
WORKDIR /app/service/feed
RUN go mod download
WORKDIR /app
COPY service/feed ./service/feed
COPY service/pkg ./service/pkg
WORKDIR /app/service/feed
RUN CGO_ENABLED=0 GOOS=linux go build -o /feed-server ./cmd/server

FROM alpine:3.19
RUN apk --no-cache add ca-certificates
WORKDIR /app
COPY --from=builder /feed-server .
EXPOSE 50057
CMD ["./feed-server"]
