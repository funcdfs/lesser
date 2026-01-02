FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY service/notification/go.mod service/notification/go.sum ./service/notification/
COPY service/pkg/go.mod service/pkg/go.sum ./service/pkg/
WORKDIR /app/service/notification
RUN go mod download
WORKDIR /app
COPY service/notification ./service/notification
COPY service/pkg ./service/pkg
WORKDIR /app/service/notification
RUN CGO_ENABLED=0 GOOS=linux go build -o /notification-server ./cmd/server

FROM alpine:3.19
RUN apk --no-cache add ca-certificates
WORKDIR /app
COPY --from=builder /notification-server .
EXPOSE 50059
CMD ["./notification-server"]
