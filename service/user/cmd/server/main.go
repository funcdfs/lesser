// Package main 用户服务入口
package main

import (
	"context"
	"log/slog"
	"net"
	"os"
	"os/signal"
	"strconv"
	"syscall"

	"github.com/funcdfs/lesser/pkg/broker"
	"github.com/funcdfs/lesser/pkg/database"
	"github.com/funcdfs/lesser/pkg/logger"
	"github.com/funcdfs/lesser/user/internal/handler"
	"github.com/funcdfs/lesser/user/internal/data_access"
	"github.com/funcdfs/lesser/user/internal/logic"
	"github.com/funcdfs/lesser/user/internal/messaging"
	pb "github.com/funcdfs/lesser/user/gen_protos/user"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

func main() {
	// 初始化日志
	log := logger.New("user-service")
	log.Info("用户服务启动中...")

	// 读取配置
	grpcPort := getEnvInt("GRPC_PORT", 50053)
	rabbitMQURL := getEnv("RABBITMQ_URL", "amqp://superuser:superuser@rabbitmq:5672/")

	// 初始化数据库连接
	dbConfig := database.ConfigFromEnv()
	db, err := database.NewConnection(dbConfig)
	if err != nil {
		log.Error("数据库连接失败", slog.Any("error", err))
		os.Exit(1)
	}
	defer db.Close()
	log.Info("数据库连接成功", slog.String("host", dbConfig.Host))

	// 初始化 RabbitMQ Publisher（可选，失败不影响服务启动）
	var publisher *broker.Publisher
	publisher = broker.NewPublisher(rabbitMQURL, log)
	if err := publisher.Connect(); err != nil {
		log.Warn("RabbitMQ 连接失败，事件通知功能将不可用", slog.Any("error", err))
		publisher = nil
	} else {
		defer publisher.Close()
		log.Info("RabbitMQ 连接成功")
	}

	// 初始化仓库层
	userRepo := data_access.NewUserRepository(db)
	followRepo := data_access.NewFollowRepository(db)
	blockRepo := data_access.NewBlockRepository(db)
	settingsRepo := data_access.NewSettingsRepository(db)

	// 初始化服务层
	userSvc := logic.NewUserService(db, log, userRepo, followRepo, blockRepo, settingsRepo)

	// 初始化 messaging 层并注入
	if publisher != nil {
		eventPublisher := messaging.NewEventPublisher(publisher)
		userSvc.SetPublisher(eventPublisher)
	}

	// 初始化处理器
	userHandler := handler.NewUserHandler(userSvc, log)

	// 创建 gRPC 服务器（简化版，不使用 pkg/grpcserver）
	grpcServer := grpc.NewServer()
	pb.RegisterUserServiceServer(grpcServer, userHandler)
	reflection.Register(grpcServer)

	// 监听端口
	addr := ":" + strconv.Itoa(grpcPort)
	lis, err := net.Listen("tcp", addr)
	if err != nil {
		log.Error("端口监听失败", slog.Int("port", grpcPort), slog.Any("error", err))
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

	log.Info("User 服务已启动", slog.Int("port", grpcPort))
	if err := grpcServer.Serve(lis); err != nil && ctx.Err() == nil {
		log.Error("gRPC 服务异常退出", slog.Any("error", err))
		os.Exit(1)
	}
}

// getEnv 获取环境变量，如果不存在则返回默认值
func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

// getEnvInt 获取整数环境变量
func getEnvInt(key string, defaultValue int) int {
	if value := os.Getenv(key); value != "" {
		if i, err := strconv.Atoi(value); err == nil {
			return i
		}
	}
	return defaultValue
}
