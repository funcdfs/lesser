package main

import (
	"context"
	"log"
	"net"
	"os"
	"os/signal"
	"syscall"

	"github.com/lesser/auth/internal/handler"
	"github.com/lesser/auth/internal/repository"
	"github.com/lesser/auth/internal/service"
	pb "github.com/lesser/auth/proto/auth"
	"github.com/lesser/pkg/database"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

func main() {
	// 配置
	grpcPort := getEnv("GRPC_PORT", "50054")
	jwtSecret := getEnv("JWT_SECRET", "your-secret-key")

	// 数据库配置
	dbConfig := database.Config{
		Host:     getEnv("DB_HOST", "localhost"),
		Port:     getEnv("DB_PORT", "5432"),
		User:     getEnv("DB_USER", "postgres"),
		Password: getEnv("DB_PASSWORD", "postgres"),
		DBName:   getEnv("DB_NAME", "lesser"),
		SSLMode:  getEnv("DB_SSLMODE", "disable"),
	}

	// 连接数据库
	db, err := database.NewConnection(dbConfig)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer db.Close()
	log.Println("Connected to PostgreSQL")

	// 创建 Repository
	userRepo := repository.NewUserRepository(db)
	banRepo := repository.NewBanRepository(db)

	// 创建 Service
	authSvc := service.NewAuthService(userRepo, banRepo, jwtSecret)

	// 创建 gRPC Handler
	authHandler := handler.NewAuthHandler(authSvc)

	// 创建 gRPC 服务器
	grpcServer := grpc.NewServer()
	pb.RegisterAuthServiceServer(grpcServer, authHandler)
	reflection.Register(grpcServer)

	// 监听端口
	lis, err := net.Listen("tcp", ":"+grpcPort)
	if err != nil {
		log.Fatalf("Failed to listen: %v", err)
	}

	// 优雅关闭
	ctx, cancel := context.WithCancel(context.Background())
	go func() {
		sigCh := make(chan os.Signal, 1)
		signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
		<-sigCh
		log.Println("Shutting down...")
		cancel()
		grpcServer.GracefulStop()
	}()

	log.Printf("Auth Service listening on :%s", grpcPort)
	if err := grpcServer.Serve(lis); err != nil && ctx.Err() == nil {
		log.Fatalf("Failed to serve: %v", err)
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
