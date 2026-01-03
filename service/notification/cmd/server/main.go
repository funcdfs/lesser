package main

import (
	"context"
	"log"
	"log/slog"
	"net"
	"os"
	"os/signal"
	"syscall"

	"github.com/funcdfs/lesser/notification/internal/handler"
	"github.com/funcdfs/lesser/notification/internal/repository"
	"github.com/funcdfs/lesser/notification/internal/service"
	"github.com/funcdfs/lesser/notification/internal/worker"
	pb "github.com/funcdfs/lesser/notification/proto/notification"
	"github.com/funcdfs/lesser/pkg/database"
	"github.com/funcdfs/lesser/pkg/logger"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

func main() {
	grpcPort := getEnv("GRPC_PORT", "50059")
	rabbitURL := getEnv("RABBITMQ_URL", "amqp://superuser:superuser@rabbitmq:5672/")

	// 初始化日志
	appLogger := logger.New("notification")

	// 数据库配置
	dbConfig := database.Config{
		Host:     getEnv("DB_HOST", "localhost"),
		Port:     getEnv("DB_PORT", "5432"),
		User:     getEnv("DB_USER", "postgres"),
		Password: getEnv("DB_PASSWORD", "postgres"),
		DBName:   getEnv("DB_NAME", "lesser"),
		SSLMode:  getEnv("DB_SSLMODE", "disable"),
	}

	db, err := database.NewConnection(dbConfig)
	if err != nil {
		log.Fatalf("连接数据库失败: %v", err)
	}
	defer db.Close()
	appLogger.Info("已连接到 PostgreSQL")

	// 初始化服务层
	notifRepo := repository.NewNotificationRepository(db)
	notifSvc := service.NewNotificationService(notifRepo)
	notifHandler := handler.NewNotificationHandler(notifSvc)

	// 创建 gRPC 服务器
	grpcServer := grpc.NewServer()
	pb.RegisterNotificationServiceServer(grpcServer, notifHandler)
	reflection.Register(grpcServer)

	// 监听端口
	lis, err := net.Listen("tcp", ":"+grpcPort)
	if err != nil {
		log.Fatalf("监听端口失败: %v", err)
	}

	// 创建上下文用于优雅停机
	ctx, cancel := context.WithCancel(context.Background())

	// 启动 RabbitMQ 事件消费者
	eventWorker := worker.NewEventWorker(notifSvc, rabbitURL, appLogger)
	go func() {
		appLogger.Info("启动 RabbitMQ 事件消费者")
		if err := eventWorker.Start(ctx); err != nil {
			appLogger.Error("事件消费者启动失败", slog.Any("error", err))
		}
	}()

	// 监听系统信号
	go func() {
		sigCh := make(chan os.Signal, 1)
		signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
		<-sigCh
		appLogger.Info("收到停机信号，正在关闭...")
		cancel()
		eventWorker.Stop()
		grpcServer.GracefulStop()
	}()

	appLogger.Info("Notification Service 启动", slog.String("port", grpcPort))
	if err := grpcServer.Serve(lis); err != nil && ctx.Err() == nil {
		log.Fatalf("gRPC 服务启动失败: %v", err)
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
