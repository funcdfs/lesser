// Notification 服务入口
// 职责：通知管理和推送
package main

import (
	"context"
	"log/slog"
	"net"
	"os"
	"os/signal"
	"syscall"

	"github.com/funcdfs/lesser/notification/internal/handler"
	"github.com/funcdfs/lesser/notification/internal/data_access"
	"github.com/funcdfs/lesser/notification/internal/logic"
	"github.com/funcdfs/lesser/notification/internal/messaging"
	pb "github.com/funcdfs/lesser/notification/gen_protos/notification"
	"github.com/funcdfs/lesser/pkg/db"
	"github.com/funcdfs/lesser/pkg/log"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

func main() {
	grpcPort := getEnv("GRPC_PORT", "50059")
	rabbitURL := getEnv("RABBITMQ_URL", "amqp://superuser:superuser@rabbitmq:5672/")

	// 初始化日志
	pkgLog := log.New("notification")

	// 数据库配置
	dbConfig := db.PostgresConfig{
		Host:     getEnv("DB_HOST", "localhost"),
		Port:     getEnv("DB_PORT", "5432"),
		User:     getEnv("DB_USER", "postgres"),
		Password: getEnv("DB_PASSWORD", "postgres"),
		DBName:   getEnv("DB_NAME", "lesser"),
		SSLMode:  getEnv("DB_SSLMODE", "disable"),
	}

	database, err := db.NewPostgresConnection(dbConfig)
	if err != nil {
		pkgLog.Fatal("连接数据库失败", slog.Any("error", err))
	}
	defer database.Close()
	pkgLog.Info("已连接到 PostgreSQL")

	// 初始化服务层
	notifRepo := data_access.NewNotificationRepository(database)
	notifSvc := logic.NewNotificationService(notifRepo)
	notifHandler := handler.NewNotificationHandler(notifSvc, pkgLog.Logger)

	// 创建 gRPC 服务器
	grpcServer := grpc.NewServer()
	pb.RegisterNotificationServiceServer(grpcServer, notifHandler)
	reflection.Register(grpcServer)

	// 监听端口
	lis, err := net.Listen("tcp", ":"+grpcPort)
	if err != nil {
		pkgLog.Fatal("监听端口失败", slog.String("port", grpcPort), slog.Any("error", err))
	}

	// 创建上下文用于优雅停机
	ctx, cancel := context.WithCancel(context.Background())

	// 启动 RabbitMQ 事件消费者
	eventWorker := messaging.NewEventWorker(notifSvc, rabbitURL, pkgLog)
	go func() {
		pkgLog.Info("启动 RabbitMQ 事件消费者")
		if err := eventWorker.Start(ctx); err != nil {
			pkgLog.Error("事件消费者启动失败", slog.Any("error", err))
		}
	}()

	// 监听系统信号
	go func() {
		sigCh := make(chan os.Signal, 1)
		signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
		<-sigCh
		pkgLog.Info("收到停机信号，正在关闭...")
		cancel()
		eventWorker.Stop()
		grpcServer.GracefulStop()
	}()

	pkgLog.Info("Notification Service 启动", slog.String("port", grpcPort))
	if err := grpcServer.Serve(lis); err != nil && ctx.Err() == nil {
		pkgLog.Fatal("gRPC 服务启动失败", slog.Any("error", err))
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
