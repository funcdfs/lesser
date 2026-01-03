// Package main 用户服务入口
package main

import (
	"log/slog"
	"os"
	"os/signal"
	"syscall"

	"github.com/funcdfs/lesser/pkg/broker"
	"github.com/funcdfs/lesser/pkg/config"
	"github.com/funcdfs/lesser/pkg/database"
	"github.com/funcdfs/lesser/pkg/grpcserver"
	"github.com/funcdfs/lesser/pkg/logger"
	"github.com/funcdfs/lesser/user/internal/handler"
	"github.com/funcdfs/lesser/user/internal/repository"
	"github.com/funcdfs/lesser/user/internal/service"
	pb "github.com/funcdfs/lesser/user/proto/user"
)

func main() {
	// 初始化日志
	log := logger.New("user-service")
	log.Info("用户服务启动中...")

	// 读取配置
	grpcPort := config.GetEnvInt("GRPC_PORT", 50055)
	rabbitMQURL := config.GetEnv("RABBITMQ_URL", "amqp://superuser:superuser@rabbitmq:5672/")

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
	userRepo := repository.NewUserRepository(db)
	followRepo := repository.NewFollowRepository(db)
	blockRepo := repository.NewBlockRepository(db)
	settingsRepo := repository.NewSettingsRepository(db)

	// 初始化服务层
	userSvc := service.NewUserService(db, log, userRepo, followRepo, blockRepo, settingsRepo)

	// 注入 RabbitMQ Publisher
	if publisher != nil {
		userSvc.SetPublisher(publisher)
	}

	// 初始化处理器
	userHandler := handler.NewUserHandler(userSvc, log)

	// 创建 gRPC 服务器
	serverConfig := grpcserver.Config{
		Port:              grpcPort,
		EnableReflection:  true,
		EnableHealthCheck: true,
	}
	server := grpcserver.New(log, grpcserver.WithConfig(serverConfig))

	// 构建服务器（添加默认拦截器）
	grpcServer := server.Build(nil, nil)

	// 注册服务
	pb.RegisterUserServiceServer(grpcServer, userHandler)

	// 启动服务器
	go func() {
		log.Info("gRPC 服务器启动", slog.Int("port", grpcPort))
		if err := server.Start(); err != nil {
			log.Error("gRPC 服务器启动失败", slog.Any("error", err))
			os.Exit(1)
		}
	}()

	// 优雅关闭
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Info("正在关闭服务...")
	server.Stop()
	log.Info("服务已关闭")
}
