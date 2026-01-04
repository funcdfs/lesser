// Content 服务入口
// 职责：内容创作（CRUD）- Story/Short/Article
package main

import (
	"context"
	"log/slog"
	"net"
	"os"
	"os/signal"
	"syscall"

	"github.com/funcdfs/lesser/content/internal/data_access"
	"github.com/funcdfs/lesser/content/internal/handler"
	"github.com/funcdfs/lesser/content/internal/logic"
	"github.com/funcdfs/lesser/content/internal/messaging"
	pb "github.com/funcdfs/lesser/content/gen_protos/content"
	"github.com/funcdfs/lesser/pkg/broker"
	"github.com/funcdfs/lesser/pkg/database"
	"github.com/funcdfs/lesser/pkg/logger"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

func main() {
	// 初始化日志
	log := logger.New("content")

	grpcPort := getEnv("GRPC_PORT", "50056")
	rabbitmqURL := getEnv("RABBITMQ_URL", "amqp://superuser:superuser@rabbitmq:5672/")

	// 数据库连接
	dbConfig := database.Config{
		Host:     getEnv("DB_HOST", "localhost"),
		Port:     getEnv("DB_PORT", "5432"),
		User:     getEnv("DB_USER", "postgres"),
		Password: getEnv("DB_PASSWORD", "postgres"),
		DBName:   getEnv("DB_NAME", "lesser_content_db"),
		SSLMode:  getEnv("DB_SSLMODE", "disable"),
	}

	db, err := database.NewConnection(dbConfig)
	if err != nil {
		log.Error("数据库连接失败", slog.Any("error", err))
		os.Exit(1)
	}
	defer db.Close()
	log.Info("数据库连接成功", slog.String("db", dbConfig.DBName))

	// 初始化 RabbitMQ Publisher（用于发送搜索索引事件和 @ 提及事件）
	var publisher *broker.Publisher
	publisher = broker.NewPublisher(rabbitmqURL, log)
	if err := publisher.Connect(); err != nil {
		log.Warn("RabbitMQ 连接失败，搜索索引和通知功能将不可用", slog.Any("error", err))
		publisher = nil
	} else {
		defer publisher.Close()
		log.Info("RabbitMQ Publisher 已连接")
	}

	// 初始化各层
	contentRepo := data_access.NewContentRepository(db)
	contentSvc := logic.NewContentService(contentRepo)

	// 初始化 messaging 层并注入
	if publisher != nil {
		eventPublisher := messaging.NewEventPublisher(publisher)
		contentSvc.SetPublisher(eventPublisher)
	}

	contentHandler := handler.NewContentHandler(contentSvc, log.Logger)

	// 创建 gRPC 服务器
	grpcServer := grpc.NewServer()
	pb.RegisterContentServiceServer(grpcServer, contentHandler)
	reflection.Register(grpcServer)

	// 监听端口
	lis, err := net.Listen("tcp", ":"+grpcPort)
	if err != nil {
		log.Error("端口监听失败", slog.String("port", grpcPort), slog.Any("error", err))
		os.Exit(1)
	}

	// 优雅关闭
	ctx, cancel := context.WithCancel(context.Background())
	go func() {
		sigCh := make(chan os.Signal, 1)
		signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
		<-sigCh
		log.Info("收到关闭信号，开始关闭...")
		cancel()
		grpcServer.GracefulStop()
	}()

	log.Info("Content 服务已启动", slog.String("port", grpcPort))
	if err := grpcServer.Serve(lis); err != nil && ctx.Err() == nil {
		log.Error("gRPC 服务异常退出", slog.Any("error", err))
		os.Exit(1)
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
