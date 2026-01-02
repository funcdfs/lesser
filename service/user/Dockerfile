FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY service/user/go.mod service/user/go.sum ./service/user/
COPY service/pkg/go.mod service/pkg/go.sum ./service/pkg/
WORKDIR /app/service/user
RUN go mod download
WORKDIR /app
COPY service/user ./service/user
COPY service/pkg ./service/pkg
WORKDIR /app/service/user
RUN CGO_ENABLED=0 GOOS=linux go build -o /user-server ./cmd/server

FROM alpine:3.19
RUN apk --no-cache add ca-certificates
WORKDIR /app
COPY --from=builder /user-server .
EXPOSE 50055
CMD ["./user-server"]
