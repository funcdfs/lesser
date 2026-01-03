// Chat 服务入口
// 职责：实时聊天（gRPC 双向流）- 会话管理、消息收发、实时推送
package main

import (
	"context"
	"log/slog"
	"net"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/funcdfs/lesser/chat/internal/handler"
	"github.com/funcdfs/lesser/chat/internal/repository"
	"github.com/funcdfs/lesser/chat/internal/service"
	pb "github.com/funcdfs/lesser/chat/proto/chat"
	"github.com/funcdfs/lesser/pkg/cache"
	"github.com/funcdfs/lesser/pkg/database"
	"github.com/funcdfs/lesser/pkg/logger"
	"google.golang.org/grpc"
	"google.golang.org/grpc/keepalive"
	"google.golang.org/grpc/reflection"
)

func main() {
	// 初始化日志
	log := logger.New("chat")
	logger.SetGlobal(log)

	grpcPort := getEnv("GRPC_PORT", "50052")

	// 数据库连接（Chat 使用独立数据库 lesser_chat_db）
	// 优先使用 DATABASE_URL，否则使用分离的配置
	var dbConfig database.Config
	if dbURL := getEnv("DATABASE_URL", ""); dbURL != "" {
		dbConfig = database.Config{DSN: dbURL}
	} else {
		dbConfig = database.Config{
			Host:     getEnv("DB_HOST", "localhost"),
			Port:     getEnv("DB_PORT", "5432"),
			User:     getEnv("DB_USER", "postgres"),
			Password: getEnv("DB_PASSWORD", "postgres"),
			DBName:   getEnv("DB_NAME", "lesser_chat_db"),
			SSLMode:  getEnv("DB_SSLMODE", "disable"),
		}
	}

	db, err := database.NewConnection(dbConfig)
	if err != nil {
		log.Fatal("数据库连接失败", slog.Any("error", err))
	}
	defer db.Close()
	log.Info("数据库连接成功")

	// 初始化 Redis（可选）
	var redisClient *cache.Client
	redisCfg := cache.ConfigFromEnv()
	if redisCfg.Host != "" || redisCfg.URL != "" {
		redisClient, err = cache.NewClient(redisCfg)
		if err != nil {
			log.Warn("Redis 连接失败，缓存功能禁用", slog.Any("error", err))
		} else {
			log.Info("Redis 连接成功")
		}
	}

	// 初始化仓库层
	conversationRepo := repository.NewConversationRepository(db)
	messageRepo := repository.NewMessageRepository(db)

	// 初始化 Auth gRPC 客户端
	authGRPCAddr := getEnv("AUTH_GRPC_ADDR", "gateway:50053")
	authClient, err := service.NewAuthClient(authGRPCAddr)
	if err != nil {
		log.Warn("Auth gRPC 服务连接失败", slog.Any("error", err))
	} else {
		log.Info("Auth gRPC 服务连接成功", slog.String("addr", authGRPCAddr))
	}

	// 初始化用户客户端（带缓存）
	userClient := service.NewUserClient(authClient, redisClient)

	// 初始化未读数缓存服务
	var unreadCacheService *service.UnreadCacheService
	if redisClient != nil {
		unreadCacheService = service.NewUnreadCacheService(redisClient, messageRepo)
	}

	// 初始化业务服务
	chatService := service.NewChatService(conversationRepo, messageRepo, redisClient, userClient, unreadCacheService)

	// 初始化 Handler
	chatHandler := handler.NewChatHandler(chatService, log)

	// 创建 gRPC 服务器
	grpcServer := newGRPCServer(authClient, log)
	pb.RegisterChatServiceServer(grpcServer, chatHandler)
	reflection.Register(grpcServer)

	// 监听端口
	lis, err := net.Listen("tcp", ":"+grpcPort)
	if err != nil {
		log.Fatal("端口监听失败", slog.String("port", grpcPort), slog.Any("error", err))
	}

	// 启动 gRPC 服务器
	go func() {
		log.Info("Chat 服务已启动", slog.String("port", grpcPort))
		if err := grpcServer.Serve(lis); err != nil {
			log.Fatal("gRPC 服务异常退出", slog.Any("error", err))
		}
	}()

	// 优雅关闭
	ctx, cancel := context.WithCancel(context.Background())
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)

	<-sigCh
	log.Info("收到关闭信号，开始关闭...")
	cancel()

	grpcServer.GracefulStop()
	log.Info("gRPC 服务器已停止")

	// 关闭 Redis 连接
	if redisClient != nil {
		redisClient.Close()
	}

	// 关闭 Auth 客户端
	if authClient != nil {
		authClient.Close()
	}

	_ = ctx
	log.Info("Chat 服务已正常退出")
}

// newGRPCServer 创建 gRPC 服务器
func newGRPCServer(authClient *service.AuthClient, log *logger.Logger) *grpc.Server {
	keepalivePolicy := keepalive.EnforcementPolicy{
		MinTime:             10 * time.Second,
		PermitWithoutStream: true,
	}

	keepaliveParams := keepalive.ServerParameters{
		MaxConnectionIdle:     5 * time.Minute,
		MaxConnectionAge:      30 * time.Minute,
		MaxConnectionAgeGrace: 10 * time.Second,
		Time:                  30 * time.Second,
		Timeout:               10 * time.Second,
	}

	return grpc.NewServer(
		grpc.KeepaliveEnforcementPolicy(keepalivePolicy),
		grpc.KeepaliveParams(keepaliveParams),
		grpc.MaxRecvMsgSize(4*1024*1024),
		grpc.MaxSendMsgSize(4*1024*1024),
		grpc.MaxConcurrentStreams(100),
		grpc.ChainUnaryInterceptor(
			authUnaryInterceptor(authClient),
			loggingUnaryInterceptor(log),
		),
		grpc.StreamInterceptor(loggingStreamInterceptor(log)),
	)
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
