FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY service/post/go.mod service/post/go.sum ./service/post/
COPY service/pkg/go.mod service/pkg/go.sum ./service/pkg/
WORKDIR /app/service/post
RUN go mod download
WORKDIR /app
COPY service/post ./service/post
COPY service/pkg ./service/pkg
WORKDIR /app/service/post
RUN CGO_ENABLED=0 GOOS=linux go build -o /post-server ./cmd/server

FROM alpine:3.19
RUN apk --no-cache add ca-certificates
WORKDIR /app
COPY --from=builder /post-server .
EXPOSE 50056
CMD ["./post-server"]
