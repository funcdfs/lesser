// Search 服务入口
// 职责：内容/用户/评论搜索，支持关键词和语义搜索
package main

import (
	"context"
	"net"
	"os"
	"os/signal"
	"syscall"

	"github.com/funcdfs/lesser/pkg/db"
	"github.com/funcdfs/lesser/pkg/grpc/interceptor"
	"github.com/funcdfs/lesser/pkg/log"
	"github.com/funcdfs/lesser/pkg/trace"
	pb "github.com/funcdfs/lesser/search/gen_protos/search"
	"github.com/funcdfs/lesser/search/internal/data_access"
	"github.com/funcdfs/lesser/search/internal/handler"
	"github.com/funcdfs/lesser/search/internal/logic"
	"github.com/funcdfs/lesser/search/internal/messaging"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

func main() {
	logger := log.New("search")

	grpcPort := getEnv("GRPC_PORT", "50058")
	rabbitURL := getEnv("RABBITMQ_URL", "amqp://funcdfs:fw142857@rabbitmq:5672/")

	// 初始化 OpenTelemetry
	ctx := context.Background()
	tracingCfg := trace.DefaultConfig("search")
	shutdown, err := trace.Init(ctx, tracingCfg)
	if err != nil {
		logger.Error("初始化 OpenTelemetry 失败", log.Any("error", err))
	} else {
		defer shutdown(ctx)
		logger.Info("OpenTelemetry 初始化成功", log.String("endpoint", tracingCfg.Endpoint))
	}

	// 数据库配置
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
		logger.Fatal("数据库连接失败", log.Any("error", err))
	}
	defer database.Close()
	logger.Info("数据库连接成功", log.String("db", dbConfig.DBName))

	// 初始化服务层
	searchDA := data_access.NewSearchDataAccess(database)
	searchSvc := logic.NewSearchService(searchDA)
	searchHandler := handler.NewSearchHandler(searchSvc, logger)

	// 创建 gRPC 服务器（带拦截器）
	grpcServer := grpc.NewServer(
		grpc.ChainUnaryInterceptor(
			interceptor.RecoveryInterceptor(logger),
			interceptor.TraceInterceptor(),
			interceptor.LoggingInterceptor(logger),
		),
	)
	pb.RegisterSearchServiceServer(grpcServer, searchHandler)
	reflection.Register(grpcServer)

	// 监听端口
	lis, err := net.Listen("tcp", ":"+grpcPort)
	if err != nil {
		logger.Fatal("端口监听失败", log.String("port", grpcPort), log.Any("error", err))
	}

	// 创建上下文用于优雅停机
	ctx, cancel := context.WithCancel(context.Background())

	// 启动 RabbitMQ 事件消费者（消费内容索引事件）
	eventWorker := messaging.NewEventWorker(searchSvc, rabbitURL, logger)
	go func() {
		logger.Info("启动 RabbitMQ 事件消费者（内容索引）")
		if err := eventWorker.Start(ctx); err != nil {
			logger.Error("事件消费者启动失败", log.Any("error", err))
		}
	}()

	// 监听系统信号
	go func() {
		sigCh := make(chan os.Signal, 1)
		signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
		<-sigCh
		logger.Info("收到停机信号，正在关闭...")
		cancel()
		eventWorker.Stop()
		grpcServer.GracefulStop()
	}()

	logger.Info("Search 服务已启动", log.String("port", grpcPort))
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
