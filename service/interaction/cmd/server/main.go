// Interaction 服务入口
// 职责：点赞、收藏、转发等交互功能
package main

import (
	"context"
	
	"net"
	"os"
	"os/signal"
	"syscall"

	pb "github.com/funcdfs/lesser/interaction/gen_protos/interaction"
	"github.com/funcdfs/lesser/interaction/internal/data_access"
	"github.com/funcdfs/lesser/interaction/internal/handler"
	"github.com/funcdfs/lesser/interaction/internal/logic"
	"github.com/funcdfs/lesser/interaction/internal/messaging"
	"github.com/funcdfs/lesser/interaction/internal/remote"
	"github.com/funcdfs/lesser/pkg/db"
	"github.com/funcdfs/lesser/pkg/log"
	"github.com/funcdfs/lesser/pkg/mq"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

func main() {
	pkgLog := log.New("interaction")

	grpcPort := getEnv("GRPC_PORT", "50056")
	contentServiceAddr := getEnv("CONTENT_SERVICE_ADDR", "content:50054")
	rabbitmqURL := getEnv("RABBITMQ_URL", "amqp://funcdfs:fw142857@rabbitmq:5672/")

	// 数据库连接
	dbConfig := db.PostgresConfig{
		Host:     getEnv("DB_HOST", "localhost"),
		Port:     getEnv("DB_PORT", "5432"),
		User:     getEnv("DB_USER", "postgres"),
		Password: getEnv("DB_PASSWORD", "postgres"),
		DBName:   getEnv("DB_NAME", "lesser_db"),
		SSLMode:  getEnv("DB_SSLMODE", "disable"),
	}

	database, err := db.NewPostgresConnection(dbConfig)
	if err != nil {
		pkgLog.Error("数据库连接失败", log.Any("error", err))
		os.Exit(1)
	}
	defer database.Close()
	pkgLog.Info("数据库连接成功", log.String("db", dbConfig.DBName))

	// 初始化 Content Service 客户端
	contentClient, err := remote.NewContentServiceClient(contentServiceAddr, pkgLog)
	if err != nil {
		pkgLog.Error("连接 Content Service 失败", log.Any("error", err))
		os.Exit(1)
	}
	defer contentClient.Close()
	pkgLog.Info("已连接 Content Service", log.String("addr", contentServiceAddr))

	// 初始化 RabbitMQ Publisher（可选，失败不影响主流程）
	var publisher *mq.Publisher
	publisher = mq.NewPublisher(rabbitmqURL, pkgLog)
	if err := publisher.Connect(); err != nil {
		pkgLog.Warn("RabbitMQ 连接失败，事件通知将被禁用", log.Any("error", err))
		publisher = nil
	} else {
		defer publisher.Close()
		pkgLog.Info("RabbitMQ Publisher 已连接")
	}

	// 初始化各层
	likeDA := data_access.NewLikeDataAccess(database)
	bookmarkDA := data_access.NewBookmarkDataAccess(database)
	repostDA := data_access.NewRepostDataAccess(database)

	interactionSvc := logic.NewInteractionService(likeDA, bookmarkDA, repostDA, contentClient)

	// 初始化 messaging 层并注入
	if publisher != nil {
		eventPublisher := messaging.NewEventPublisher(publisher)
		interactionSvc.SetPublisher(eventPublisher)
	}

	interactionHandler := handler.NewInteractionHandler(interactionSvc, pkgLog)

	// 创建 gRPC 服务器
	grpcServer := grpc.NewServer()
	pb.RegisterInteractionServiceServer(grpcServer, interactionHandler)
	reflection.Register(grpcServer)

	// 监听端口
	lis, err := net.Listen("tcp", ":"+grpcPort)
	if err != nil {
		pkgLog.Error("端口监听失败", log.String("port", grpcPort), log.Any("error", err))
		os.Exit(1)
	}

	// 优雅关闭
	ctx, cancel := context.WithCancel(context.Background())
	go func() {
		sigCh := make(chan os.Signal, 1)
		signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
		<-sigCh
		pkgLog.Info("收到关闭信号，开始关闭...")
		cancel()
		grpcServer.GracefulStop()
	}()

	pkgLog.Info("Interaction 服务已启动", log.String("port", grpcPort))
	if err := grpcServer.Serve(lis); err != nil && ctx.Err() == nil {
		pkgLog.Error("gRPC 服务异常退出", log.Any("error", err))
		os.Exit(1)
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
