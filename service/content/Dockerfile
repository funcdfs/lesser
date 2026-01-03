FROM golang:1.24-alpine AS builder
WORKDIR /app
COPY service/content/go.mod service/content/go.sum ./service/content/
COPY service/pkg/go.mod service/pkg/go.sum ./service/pkg/
WORKDIR /app/service/content
RUN go mod download
WORKDIR /app
COPY service/content ./service/content
COPY service/pkg ./service/pkg
WORKDIR /app/service/content
RUN CGO_ENABLED=0 GOOS=linux go build -o /content-server ./cmd/server

FROM alpine:3.19
RUN apk --no-cache add ca-certificates
WORKDIR /app
COPY --from=builder /content-server .
EXPOSE 50056
CMD ["./content-server"]
