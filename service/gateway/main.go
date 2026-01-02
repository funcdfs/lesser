package main

import (
	"context"
	"log"
	"net"
	"os"
	"os/signal"
	"strconv"
	"syscall"

	"github.com/lesser/gateway/internal/server"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

func main() {
	// 配置
	grpcPort := getEnv("GRPC_PORT", "50053")

	// Service 地址配置
	config := server.GatewayConfig{
		AuthServiceAddr:         getEnv("AUTH_SERVICE_ADDR", "auth:50054"),
		UserServiceAddr:         getEnv("USER_SERVICE_ADDR", "user:50055"),
		PostServiceAddr:         getEnv("POST_SERVICE_ADDR", "post:50056"),
		FeedServiceAddr:         getEnv("FEED_SERVICE_ADDR", "feed:50057"),
		ChatServiceAddr:         getEnv("CHAT_SERVICE_ADDR", "chat:50052"),
		SearchServiceAddr:       getEnv("SEARCH_SERVICE_ADDR", "search:50058"),
		NotificationServiceAddr: getEnv("NOTIFICATION_SERVICE_ADDR", "notification:50059"),
		RateLimitRate:           getEnvFloat("RATE_LIMIT_RATE", 100),
		RateLimitBurst:          getEnvInt("RATE_LIMIT_BURST", 200),
	}

	// 创建 Gateway 服务器
	gatewayServer, err := server.NewGatewayServer(config)
	if err != nil {
		log.Fatalf("Failed to create gateway server: %v", err)
	}

	// 启动 Gateway（初始化 JWT 验签器等）
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	if err := gatewayServer.Start(ctx); err != nil {
		log.Fatalf("Failed to start gateway: %v", err)
	}

	// 创建 gRPC 服务器（带认证拦截器）
	grpcServer := grpc.NewServer(
		grpc.UnaryInterceptor(gatewayServer.AuthInterceptor()),
		grpc.StreamInterceptor(gatewayServer.StreamAuthInterceptor()),
	)

	server.RegisterGatewayServer(grpcServer, gatewayServer)
	
	// 注册 Auth 代理服务
	authConn := gatewayServer.GetRouter().GetAuthConn()
	if authConn != nil {
		server.RegisterAuthProxyServer(grpcServer, authConn)
	} else {
		log.Println("[Gateway] Warning: Auth service not available, auth proxy not registered")
	}
	
	// 注册 Search 代理服务
	searchConn := gatewayServer.GetRouter().GetSearchConn()
	if searchConn != nil {
		server.RegisterSearchProxyServer(grpcServer, searchConn)
	} else {
		log.Println("[Gateway] Warning: Search service not available, search proxy not registered")
	}
	
	reflection.Register(grpcServer)

	// 监听端口
	lis, err := net.Listen("tcp", ":"+grpcPort)
	if err != nil {
		log.Fatalf("Failed to listen: %v", err)
	}

	// 优雅关闭
	go func() {
		sigCh := make(chan os.Signal, 1)
		signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
		<-sigCh
		log.Println("Shutting down...")
		cancel()
		grpcServer.GracefulStop()
		gatewayServer.Stop()
	}()

	log.Printf("Gateway server listening on :%s", grpcPort)
	log.Printf("Connected services: Auth=%s, User=%s, Post=%s, Feed=%s, Chat=%s, Search=%s, Notification=%s",
		config.AuthServiceAddr, config.UserServiceAddr, config.PostServiceAddr,
		config.FeedServiceAddr, config.ChatServiceAddr, config.SearchServiceAddr,
		config.NotificationServiceAddr)

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

func getEnvInt(key string, defaultValue int) int {
	if value := os.Getenv(key); value != "" {
		if i, err := strconv.Atoi(value); err == nil {
			return i
		}
	}
	return defaultValue
}

func getEnvFloat(key string, defaultValue float64) float64 {
	if value := os.Getenv(key); value != "" {
		if f, err := strconv.ParseFloat(value, 64); err == nil {
			return f
		}
	}
	return defaultValue
}
