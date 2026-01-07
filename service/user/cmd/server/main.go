// Package main 用户服务入口
package main

import (
	"context"
	"net"
	"os"
	"os/signal"
	"strconv"
	"syscall"

	"github.com/funcdfs/lesser/pkg/db"
	"github.com/funcdfs/lesser/pkg/log"
	"github.com/funcdfs/lesser/pkg/mq"
	pb "github.com/funcdfs/lesser/user/gen_protos/user"
	"github.com/funcdfs/lesser/user/internal/data_access"
	"github.com/funcdfs/lesser/user/internal/handler"
	"github.com/funcdfs/lesser/user/internal/logic"
	"github.com/funcdfs/lesser/user/internal/messaging"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

func main() {
	// 初始化日志
	logger := log.New("user-service")
	logger.Info("用户服务启动中...")

	// 读取配置
	grpcPort := getEnvInt("GRPC_PORT", 50053)
	rabbitMQURL := getEnv("RABBITMQ_URL", "amqp://funcdfs:fw142857@rabbitmq:5672/")

	// 初始化数据库连接
	dbConfig := db.PostgresConfigFromEnv()
	pgDB, err := db.NewPostgresConnection(dbConfig)
	if err != nil {
		logger.Error("数据库连接失败", log.Any("error", err))
		os.Exit(1)
	}
	defer pgDB.Close()
	logger.Info("数据库连接成功", log.String("host", dbConfig.Host))

	// 初始化 RabbitMQ Publisher（可选，失败不影响服务启动）
	var publisher *mq.Publisher
	publisher = mq.NewPublisher(rabbitMQURL, logger)
	if err := publisher.Connect(); err != nil {
		logger.Warn("RabbitMQ 连接失败，事件通知功能将不可用", log.Any("error", err))
		publisher = nil
	} else {
		defer publisher.Close()
		logger.Info("RabbitMQ 连接成功")
	}

	// 初始化数据访问层
	userDA := data_access.NewUserDataAccess(pgDB)
	followDA := data_access.NewFollowDataAccess(pgDB)
	blockDA := data_access.NewBlockDataAccess(pgDB)
	settingsDA := data_access.NewSettingsDataAccess(pgDB)

	// 初始化服务层
	userSvc := logic.NewUserService(pgDB, logger, userDA, followDA, blockDA, settingsDA)

	// 初始化 messaging 层并注入
	if publisher != nil {
		eventPublisher := messaging.NewEventPublisher(publisher)
		userSvc.SetPublisher(eventPublisher)
	}

	// 初始化处理器
	userHandler := handler.NewUserHandler(userSvc, logger)

	// 创建 gRPC 服务器（简化版，不使用 pkg/grpcserver）
	grpcServer := grpc.NewServer()
	pb.RegisterUserServiceServer(grpcServer, userHandler)
	reflection.Register(grpcServer)

	// 监听端口
	addr := ":" + strconv.Itoa(grpcPort)
	lis, err := net.Listen("tcp", addr)
	if err != nil {
		logger.Error("端口监听失败", log.Int("port", grpcPort), log.Any("error", err))
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

	logger.Info("User 服务已启动", log.Int("port", grpcPort))
	if err := grpcServer.Serve(lis); err != nil && ctx.Err() == nil {
		logger.Error("gRPC 服务异常退出", log.Any("error", err))
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
