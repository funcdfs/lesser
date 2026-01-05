// Chat 服务入口
// 职责：实时聊天（gRPC 双向流）- 会话管理、消息收发、实时推送
package main

import (
	"context"
	"net"
	"os"
	"os/signal"
	"syscall"
	"time"

	pb "github.com/funcdfs/lesser/chat/gen_protos/chat"
	"github.com/funcdfs/lesser/chat/internal/data_access"
	"github.com/funcdfs/lesser/chat/internal/handler"
	"github.com/funcdfs/lesser/chat/internal/logic"
	"github.com/funcdfs/lesser/chat/internal/remote"
	"github.com/funcdfs/lesser/pkg/db"
	"github.com/funcdfs/lesser/pkg/log"
	"google.golang.org/grpc"
	"google.golang.org/grpc/keepalive"
	"google.golang.org/grpc/reflection"
)

func main() {
	// 初始化日志
	logger := log.New("chat")

	grpcPort := getEnv("GRPC_PORT", "50060")

	// 数据库连接（Chat 使用独立数据库 lesser_chat_db）
	dbConfig := db.PostgresConfig{
		Host:     getEnv("DB_HOST", "localhost"),
		Port:     getEnv("DB_PORT", "5432"),
		User:     getEnv("DB_USER", "postgres"),
		Password: getEnv("DB_PASSWORD", "postgres"),
		DBName:   getEnv("DB_NAME", "lesser_chat_db"),
		SSLMode:  getEnv("DB_SSLMODE", "disable"),
	}

	database, err := db.NewPostgresConnection(dbConfig)
	if err != nil {
		logger.Fatal("数据库连接失败", log.Any("error", err))
	}
	defer database.Close()
	logger.Info("数据库连接成功")

	// 初始化 Redis（可选）
	var redisClient *db.RedisClient
	redisCfg := db.RedisConfig{
		Host:     getEnv("REDIS_HOST", ""),
		Port:     getEnv("REDIS_PORT", "6379"),
		Password: getEnv("REDIS_PASSWORD", ""),
		DB:       0,
	}
	if redisCfg.Host != "" {
		redisClient, err = db.NewRedisClient(redisCfg)
		if err != nil {
			logger.Warn("Redis 连接失败，缓存功能禁用", log.Any("error", err))
		} else {
			logger.Info("Redis 连接成功")
		}
	}

	// 初始化数据访问层
	conversationDA := data_access.NewConversationDataAccess(database)
	messageDA := data_access.NewMessageDataAccess(database)

	// 初始化 Auth gRPC 客户端
	authGRPCAddr := getEnv("AUTH_GRPC_ADDR", "gateway:50053")
	authClient, err := remote.NewAuthClient(authGRPCAddr, logger)
	if err != nil {
		logger.Warn("Auth gRPC 服务连接失败", log.Any("error", err))
	} else {
		logger.Info("Auth gRPC 服务连接成功", log.String("addr", authGRPCAddr))
	}

	// 初始化用户客户端（带缓存）
	userClient := remote.NewUserClient(authClient, redisClient, logger)

	// 初始化未读数缓存服务
	var unreadCacheService *logic.UnreadCacheService
	if redisClient != nil {
		unreadCacheService = logic.NewUnreadCacheService(redisClient, messageDA)
	}

	// 初始化业务服务
	chatService := logic.NewChatService(conversationDA, messageDA, redisClient, userClient, unreadCacheService)

	// 初始化 Handler
	chatHandler := handler.NewChatHandler(chatService, logger)

	// 创建 gRPC 服务器
	grpcServer := newGRPCServer(authClient, logger)
	pb.RegisterChatServiceServer(grpcServer, chatHandler)
	reflection.Register(grpcServer)

	// 监听端口
	lis, err := net.Listen("tcp", ":"+grpcPort)
	if err != nil {
		logger.Fatal("端口监听失败", log.String("port", grpcPort), log.Any("error", err))
	}

	// 启动 gRPC 服务器
	go func() {
		logger.Info("Chat 服务已启动", log.String("port", grpcPort))
		if err := grpcServer.Serve(lis); err != nil {
			logger.Fatal("gRPC 服务异常退出", log.Any("error", err))
		}
	}()

	// 优雅关闭
	ctx, cancel := context.WithCancel(context.Background())
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)

	<-sigCh
	logger.Info("收到关闭信号，开始关闭...")
	cancel()

	// 设置关闭超时
	shutdownCtx, shutdownCancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer shutdownCancel()

	// 优雅停止 gRPC 服务器
	done := make(chan struct{})
	go func() {
		grpcServer.GracefulStop()
		close(done)
	}()

	select {
	case <-done:
		logger.Info("gRPC 服务器已停止")
	case <-shutdownCtx.Done():
		logger.Warn("gRPC 服务器停止超时，强制关闭")
		grpcServer.Stop()
	}

	// 关闭 Redis 连接
	if redisClient != nil {
		redisClient.Close()
	}

	// 关闭 Auth 客户端
	if authClient != nil {
		authClient.Close()
	}

	_ = ctx
	logger.Info("Chat 服务已正常退出")
}

// newGRPCServer 创建 gRPC 服务器
func newGRPCServer(authClient *remote.AuthClient, log *log.Logger) *grpc.Server {
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
