FROM golang:1.25-alpine AS build

WORKDIR /app
COPY go.mod go.sum* ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o golang_hot

FROM alpine:3.19
WORKDIR /app
COPY --from=build /app/golang_hot .
RUN apk add --no-cache curl
EXPOSE 8080
CMD ["./golang_hot"]