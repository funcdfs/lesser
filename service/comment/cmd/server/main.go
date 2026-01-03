// Comment 服务入口
// 职责：评论系统（CRUD、嵌套回复、评论计数）
package main

import (
	"context"
	"log/slog"
	"net"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/funcdfs/lesser/comment/internal/client"
	"github.com/funcdfs/lesser/comment/internal/handler"
	"github.com/funcdfs/lesser/comment/internal/repository"
	"github.com/funcdfs/lesser/comment/internal/service"
	pb "github.com/funcdfs/lesser/comment/proto/comment"
	"github.com/funcdfs/lesser/pkg/broker"
	"github.com/funcdfs/lesser/pkg/database"
	"github.com/funcdfs/lesser/pkg/grpcserver"
	"github.com/funcdfs/lesser/pkg/logger"
)

func main() {
	// 初始化日志
	log := logger.New("comment")

	grpcPort := getEnv("GRPC_PORT", "50061")
	contentServiceAddr := getEnv("CONTENT_SERVICE_ADDR", "content:50056")
	rabbitmqURL := getEnv("RABBITMQ_URL", "")

	// 数据库连接
	dbConfig := database.Config{
		Host:            getEnv("DB_HOST", "localhost"),
		Port:            getEnv("DB_PORT", "5432"),
		User:            getEnv("DB_USER", "postgres"),
		Password:        getEnv("DB_PASSWORD", "postgres"),
		DBName:          getEnv("DB_NAME", "lesser_db"),
		SSLMode:         getEnv("DB_SSLMODE", "disable"),
		MaxOpenConns:    25,
		MaxIdleConns:    10,
		ConnMaxLifetime: time.Hour,
	}

	db, err := database.NewConnection(dbConfig)
	if err != nil {
		log.Fatal("数据库连接失败", slog.Any("error", err))
	}
	defer db.Close()
	log.Info("数据库连接成功", slog.String("db", dbConfig.DBName))

	// 初始化 Content Service 客户端
	contentClient, err := client.NewContentServiceClient(contentServiceAddr)
	if err != nil {
		log.Fatal("连接 Content Service 失败", slog.Any("error", err))
	}
	defer contentClient.Close()
	log.Info("已连接 Content Service", slog.String("addr", contentServiceAddr))

	// 初始化各层
	commentRepo := repository.NewCommentRepository(db)
	commentSvc := service.NewCommentService(commentRepo, contentClient)

	// 可选：初始化 RabbitMQ Publisher（用于发送通知事件）
	if rabbitmqURL != "" {
		publisher := broker.NewPublisher(rabbitmqURL, log)
		if err := publisher.Connect(); err != nil {
			log.Warn("RabbitMQ 连接失败，通知功能将不可用", slog.Any("error", err))
		} else {
			commentSvc.SetPublisher(publisher)
			defer publisher.Close()
			log.Info("RabbitMQ Publisher 已连接")
		}
	}

	commentHandler := handler.NewCommentHandler(commentSvc, log.Logger)

	// 创建 gRPC 服务器（使用 pkg/grpcserver）
	serverConfig := grpcserver.Config{
		Port:              50061,
		EnableReflection:  true,
		EnableHealthCheck: true,
	}
	server := grpcserver.New(log, grpcserver.WithConfig(serverConfig))
	grpcServer := server.Build(nil, nil)

	// 注册服务
	pb.RegisterCommentServiceServer(grpcServer, commentHandler)

	// 监听端口
	lis, err := net.Listen("tcp", ":"+grpcPort)
	if err != nil {
		log.Fatal("端口监听失败", slog.String("port", grpcPort), slog.Any("error", err))
	}

	// 优雅关闭
	ctx, cancel := context.WithCancel(context.Background())
	go func() {
		sigCh := make(chan os.Signal, 1)
		signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
		<-sigCh
		log.Info("收到关闭信号，开始关闭...")
		cancel()
		server.StopWithTimeout(10 * time.Second)
	}()

	log.Info("Comment 服务已启动", slog.String("port", grpcPort))
	if err := grpcServer.Serve(lis); err != nil && ctx.Err() == nil {
		log.Fatal("gRPC 服务异常退出", slog.Any("error", err))
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
