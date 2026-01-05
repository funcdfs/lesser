// Content 服务入口
// 职责：内容创作（CRUD）- Story/Short/Article
package main

import (
	"context"
	"net"
	"os"
	"os/signal"
	"syscall"
	"time"

	pb "github.com/funcdfs/lesser/content/gen_protos/content"
	"github.com/funcdfs/lesser/content/internal/data_access"
	"github.com/funcdfs/lesser/content/internal/handler"
	"github.com/funcdfs/lesser/content/internal/logic"
	"github.com/funcdfs/lesser/content/internal/messaging"
	"github.com/funcdfs/lesser/pkg/db"
	"github.com/funcdfs/lesser/pkg/grpc/interceptor"
	"github.com/funcdfs/lesser/pkg/log"
	"github.com/funcdfs/lesser/pkg/mq"
	"github.com/funcdfs/lesser/pkg/trace"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

func main() {
	// 初始化日志
	logger := log.New("content")

	grpcPort := getEnv("GRPC_PORT", "50054")
	rabbitmqURL := getEnv("RABBITMQ_URL", "amqp://superuser:superuser@rabbitmq:5672/")

	// 初始化 OpenTelemetry
	ctx := context.Background()
	tracingCfg := trace.DefaultConfig("content")
	shutdown, err := trace.Init(ctx, tracingCfg)
	if err != nil {
		logger.Error("初始化 OpenTelemetry 失败", log.Any("error", err))
	} else {
		defer shutdown(ctx)
		logger.Info("OpenTelemetry 初始化成功", log.String("endpoint", tracingCfg.Endpoint))
	}

	// 数据库连接
	dbConfig := db.PostgresConfig{
		Host:            getEnv("DB_HOST", "localhost"),
		Port:            getEnv("DB_PORT", "5432"),
		User:            getEnv("DB_USER", "postgres"),
		Password:        getEnv("DB_PASSWORD", "postgres"),
		DBName:          getEnv("DB_NAME", "lesser_content_db"),
		SSLMode:         getEnv("DB_SSLMODE", "disable"),
		MaxOpenConns:    25,
		MaxIdleConns:    10,
		ConnMaxLifetime: time.Hour,
	}

	database, err := db.NewPostgresConnection(dbConfig)
	if err != nil {
		logger.Fatal("数据库连接失败", log.Any("error", err))
	}
	defer database.Close()
	logger.Info("数据库连接成功", log.String("db", dbConfig.DBName))

	// 初始化 RabbitMQ Publisher（用于发送搜索索引事件和 @ 提及事件）
	var publisher *mq.Publisher
	publisher = mq.NewPublisher(rabbitmqURL, logger)
	if err := publisher.Connect(); err != nil {
		logger.Warn("RabbitMQ 连接失败，搜索索引和通知功能将不可用", log.Any("error", err))
		publisher = nil
	} else {
		defer publisher.Close()
		logger.Info("RabbitMQ Publisher 已连接")
	}

	// 初始化各层
	contentDA := data_access.NewContentDataAccess(database, logger)
	contentSvc := logic.NewContentService(contentDA, logger)

	// 初始化 messaging 层并注入
	if publisher != nil {
		eventPublisher := messaging.NewEventPublisher(publisher)
		contentSvc.SetPublisher(eventPublisher)
	}

	contentHandler := handler.NewContentHandler(contentSvc, logger)

	// 创建 gRPC 服务器（带拦截器）
	grpcServer := grpc.NewServer(
		grpc.ChainUnaryInterceptor(
			interceptor.RecoveryInterceptor(logger),
			interceptor.TraceInterceptor(),
			interceptor.LoggingInterceptor(logger),
		),
	)
	pb.RegisterContentServiceServer(grpcServer, contentHandler)
	reflection.Register(grpcServer)

	// 监听端口
	lis, err := net.Listen("tcp", ":"+grpcPort)
	if err != nil {
		logger.Error("端口监听失败", log.String("port", grpcPort), log.Any("error", err))
		os.Exit(1)
	}

	// 优雅关闭
	ctx, cancel := context.WithCancel(context.Background())
	go func() {
		sigCh := make(chan os.Signal, 1)
		signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
		<-sigCh
		logger.Info("收到关闭信号，开始关闭...")
		cancel()
		grpcServer.GracefulStop()
	}()

	logger.Info("Content 服务已启动", log.String("port", grpcPort))
	if err := grpcServer.Serve(lis); err != nil && ctx.Err() == nil {
		logger.Fatal("gRPC 服务异常退出", log.Any("error", err))
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
