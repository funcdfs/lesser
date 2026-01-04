// Interaction 服务入口
// 职责：点赞、收藏、转发等交互功能
package main

import (
	"context"
	"log/slog"
	"net"
	"os"
	"os/signal"
	"syscall"

	"github.com/funcdfs/lesser/interaction/internal/remote"
	"github.com/funcdfs/lesser/interaction/internal/handler"
	"github.com/funcdfs/lesser/interaction/internal/data_access"
	"github.com/funcdfs/lesser/interaction/internal/logic"
	"github.com/funcdfs/lesser/interaction/internal/messaging"
	pb "github.com/funcdfs/lesser/interaction/gen_protos/interaction"
	"github.com/funcdfs/lesser/pkg/broker"
	"github.com/funcdfs/lesser/pkg/database"
	"github.com/funcdfs/lesser/pkg/logger"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

func main() {
	log := initLogger()
	pkgLog := logger.New("interaction")

	grpcPort := getEnv("GRPC_PORT", "50056")
	contentServiceAddr := getEnv("CONTENT_SERVICE_ADDR", "content:50054")
	rabbitmqURL := getEnv("RABBITMQ_URL", "amqp://superuser:superuser@rabbitmq:5672/")

	// 数据库连接
	dbConfig := database.Config{
		Host:     getEnv("DB_HOST", "localhost"),
		Port:     getEnv("DB_PORT", "5432"),
		User:     getEnv("DB_USER", "postgres"),
		Password: getEnv("DB_PASSWORD", "postgres"),
		DBName:   getEnv("DB_NAME", "lesser_db"),
		SSLMode:  getEnv("DB_SSLMODE", "disable"),
	}

	db, err := database.NewConnection(dbConfig)
	if err != nil {
		log.Error("数据库连接失败", slog.Any("error", err))
		os.Exit(1)
	}
	defer db.Close()
	log.Info("数据库连接成功", slog.String("db", dbConfig.DBName))

	// 初始化 Content Service 客户端
	contentClient, err := remote.NewContentServiceClient(contentServiceAddr)
	if err != nil {
		log.Error("连接 Content Service 失败", slog.Any("error", err))
		os.Exit(1)
	}
	defer contentClient.Close()
	log.Info("已连接 Content Service", slog.String("addr", contentServiceAddr))

	// 初始化 RabbitMQ Publisher（可选，失败不影响主流程）
	var publisher *broker.Publisher
	publisher = broker.NewPublisher(rabbitmqURL, pkgLog)
	if err := publisher.Connect(); err != nil {
		log.Warn("RabbitMQ 连接失败，事件通知将被禁用", slog.Any("error", err))
		publisher = nil
	} else {
		defer publisher.Close()
		log.Info("RabbitMQ Publisher 已连接")
	}

	// 初始化各层
	likeRepo := data_access.NewLikeRepository(db)
	bookmarkRepo := data_access.NewBookmarkRepository(db)
	repostRepo := data_access.NewRepostRepository(db)

	interactionSvc := logic.NewInteractionService(likeRepo, bookmarkRepo, repostRepo, contentClient)

	// 初始化 messaging 层并注入
	if publisher != nil {
		eventPublisher := messaging.NewEventPublisher(publisher)
		interactionSvc.SetPublisher(eventPublisher)
	}

	interactionHandler := handler.NewInteractionHandler(interactionSvc, log)

	// 创建 gRPC 服务器
	grpcServer := grpc.NewServer()
	pb.RegisterInteractionServiceServer(grpcServer, interactionHandler)
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

	log.Info("Interaction 服务已启动", slog.String("port", grpcPort))
	if err := grpcServer.Serve(lis); err != nil && ctx.Err() == nil {
		log.Error("gRPC 服务异常退出", slog.Any("error", err))
		os.Exit(1)
	}
}

func initLogger() *slog.Logger {
	var h slog.Handler
	if os.Getenv("ENV") == "production" {
		h = slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelInfo, AddSource: true})
	} else {
		h = slog.NewTextHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelDebug, AddSource: true})
	}
	return slog.New(h).With(slog.String("service", "interaction"))
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
