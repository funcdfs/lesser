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

	"github.com/funcdfs/lesser/comment/internal/data_access"
	"github.com/funcdfs/lesser/comment/internal/handler"
	"github.com/funcdfs/lesser/comment/internal/logic"
	"github.com/funcdfs/lesser/comment/internal/messaging"
	"github.com/funcdfs/lesser/comment/internal/remote"
	pb "github.com/funcdfs/lesser/comment/gen_protos/comment"
	"github.com/funcdfs/lesser/pkg/mq"
	"github.com/funcdfs/lesser/pkg/db"
	"github.com/funcdfs/lesser/pkg/log"
	"github.com/funcdfs/lesser/pkg/grpc/interceptor"
	"github.com/funcdfs/lesser/pkg/trace"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

func main() {
	// 初始化日志
	log := log.New("comment")

	grpcPort := getEnv("GRPC_PORT", "50055")
	contentServiceAddr := getEnv("CONTENT_SERVICE_ADDR", "content:50054")
	rabbitmqURL := getEnv("RABBITMQ_URL", "amqp://superuser:superuser@rabbitmq:5672/")

	// 初始化 OpenTelemetry
	ctx := context.Background()
	tracingCfg := trace.DefaultConfig("comment")
	shutdown, err := trace.Init(ctx, tracingCfg)
	if err != nil {
		log.Error("初始化 OpenTelemetry 失败", slog.Any("error", err))
	} else {
		defer shutdown(ctx)
		log.Info("OpenTelemetry 初始化成功", slog.String("endpoint", tracingCfg.Endpoint))
	}

	// 数据库连接
	dbConfig := db.PostgresConfig{
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

	database, err := db.NewPostgresConnection(dbConfig)
	if err != nil {
		log.Fatal("数据库连接失败", slog.Any("error", err))
	}
	defer database.Close()
	log.Info("数据库连接成功", slog.String("db", dbConfig.DBName))

	// 初始化 Content Service 客户端
	contentClient, err := remote.NewContentServiceClient(contentServiceAddr, log)
	if err != nil {
		log.Fatal("连接 Content Service 失败", slog.Any("error", err))
	}
	defer contentClient.Close()
	log.Info("已连接 Content Service", slog.String("addr", contentServiceAddr))

	// 初始化各层
	commentRepo := data_access.NewCommentRepository(database)
	commentSvc := logic.NewCommentService(commentRepo, contentClient)

	// 初始化 RabbitMQ Publisher（用于发送通知事件）
	var publisher *mq.Publisher
	publisher = mq.NewPublisher(rabbitmqURL, log)
	if err := publisher.Connect(); err != nil {
		log.Warn("RabbitMQ 连接失败，通知功能将不可用", slog.Any("error", err))
		publisher = nil
	} else {
		defer publisher.Close()
		log.Info("RabbitMQ Publisher 已连接")
	}

	// 初始化 messaging 层并注入
	if publisher != nil {
		eventPublisher := messaging.NewEventPublisher(publisher)
		commentSvc.SetPublisher(eventPublisher)
	}

	commentHandler := handler.NewCommentHandler(commentSvc, log.Logger)

	// 创建 gRPC 服务器（带拦截器）
	grpcServer := grpc.NewServer(
		grpc.ChainUnaryInterceptor(
			interceptor.RecoveryInterceptor(log),
			interceptor.TraceInterceptor(),
			interceptor.LoggingInterceptor(log),
		),
	)
	pb.RegisterCommentServiceServer(grpcServer, commentHandler)
	reflection.Register(grpcServer)

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
		grpcServer.GracefulStop()
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
