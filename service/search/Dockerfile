FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY service/search/go.mod service/search/go.sum ./service/search/
COPY service/pkg/go.mod service/pkg/go.sum ./service/pkg/
WORKDIR /app/service/search
RUN go mod download
WORKDIR /app
COPY service/search ./service/search
COPY service/pkg ./service/pkg
WORKDIR /app/service/search
RUN CGO_ENABLED=0 GOOS=linux go build -o /search-server ./cmd/server

FROM alpine:3.19
RUN apk --no-cache add ca-certificates
WORKDIR /app
COPY --from=builder /search-server .
EXPOSE 50058
CMD ["./search-server"]
