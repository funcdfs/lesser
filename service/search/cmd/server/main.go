// Search 服务入口
// 职责：内容/用户/评论搜索，支持关键词和语义搜索
package main

import (
	"context"
	"log/slog"
	"net"
	"os"
	"os/signal"
	"syscall"

	"github.com/funcdfs/lesser/pkg/database"
	"github.com/funcdfs/lesser/pkg/logger"
	"github.com/funcdfs/lesser/search/internal/data_access"
	"github.com/funcdfs/lesser/search/internal/handler"
	"github.com/funcdfs/lesser/search/internal/logic"
	"github.com/funcdfs/lesser/search/internal/messaging"
	pb "github.com/funcdfs/lesser/search/gen_protos/search"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

func main() {
	// 初始化日志
	log := logger.New("search")

	grpcPort := getEnv("GRPC_PORT", "50058")
	rabbitURL := getEnv("RABBITMQ_URL", "amqp://superuser:superuser@rabbitmq:5672/")

	// 数据库配置
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
		log.Fatal("数据库连接失败", slog.Any("error", err))
	}
	defer db.Close()
	log.Info("数据库连接成功", slog.String("db", dbConfig.DBName))

	// 初始化服务层
	searchRepo := data_access.NewSearchRepository(db)
	searchSvc := logic.NewSearchService(searchRepo)
	searchHandler := handler.NewSearchHandler(searchSvc)

	// 创建 gRPC 服务器
	grpcServer := grpc.NewServer()
	pb.RegisterSearchServiceServer(grpcServer, searchHandler)
	reflection.Register(grpcServer)

	// 监听端口
	lis, err := net.Listen("tcp", ":"+grpcPort)
	if err != nil {
		log.Fatal("端口监听失败", slog.String("port", grpcPort), slog.Any("error", err))
	}

	// 创建上下文用于优雅停机
	ctx, cancel := context.WithCancel(context.Background())

	// 启动 RabbitMQ 事件消费者（消费内容索引事件）
	eventWorker := messaging.NewEventWorker(searchSvc, rabbitURL, log)
	go func() {
		log.Info("启动 RabbitMQ 事件消费者（内容索引）")
		if err := eventWorker.Start(ctx); err != nil {
			log.Error("事件消费者启动失败", slog.Any("error", err))
		}
	}()

	// 监听系统信号
	go func() {
		sigCh := make(chan os.Signal, 1)
		signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
		<-sigCh
		log.Info("收到停机信号，正在关闭...")
		cancel()
		eventWorker.Stop()
		grpcServer.GracefulStop()
	}()

	log.Info("Search 服务已启动", slog.String("port", grpcPort))
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
