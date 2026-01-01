package main

import (
	"log"
	"net"
	"os"
	"os/signal"
	"syscall"

	"github.com/lesser/gateway/internal/broker"
	"github.com/lesser/gateway/internal/server"
	"google.golang.org/grpc"
)

func main() {
	// 配置
	grpcPort := getEnv("GRPC_PORT", "50053")
	rabbitURL := getEnv("RABBITMQ_URL", "amqp://guest:guest@localhost:5672/")

	// 连接 RabbitMQ
	rabbitConn, err := broker.NewConnection(rabbitURL)
	if err != nil {
		log.Fatalf("Failed to connect to RabbitMQ: %v", err)
	}
	defer rabbitConn.Close()

	// 创建 gRPC 服务器
	lis, err := net.Listen("tcp", ":"+grpcPort)
	if err != nil {
		log.Fatalf("Failed to listen: %v", err)
	}

	grpcServer := grpc.NewServer()
	gatewayServer, err := server.NewGatewayServer(rabbitConn)
	if err != nil {
		log.Fatalf("Failed to create gateway server: %v", err)
	}
	server.RegisterGatewayServer(grpcServer, gatewayServer)

	// 优雅关闭
	go func() {
		sigCh := make(chan os.Signal, 1)
		signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
		<-sigCh
		log.Println("Shutting down...")
		grpcServer.GracefulStop()
	}()

	log.Printf("Gateway server listening on :%s", grpcPort)
	if err := grpcServer.Serve(lis); err != nil {
		log.Fatalf("Failed to serve: %v", err)
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
