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
	"github.com/funcdfs/lesser/chat/internal/data_access"
	"github.com/funcdfs/lesser/chat/internal/logic"
	"github.com/funcdfs/lesser/chat/internal/remote"
	pb "github.com/funcdfs/lesser/chat/gen_protos/chat"
	"github.com/funcdfs/lesser/pkg/db"
	"github.com/funcdfs/lesser/pkg/db"
	"github.com/funcdfs/lesser/pkg/log"
	"google.golang.org/grpc"
	"google.golang.org/grpc/keepalive"
	"google.golang.org/grpc/reflection"
)

func main() {
	// 初始化日志
	log := log.New("chat")
	log.SetGlobal(log)

	grpcPort := getEnv("GRPC_PORT", "50060")

	// 数据库连接（Chat 使用独立数据库 lesser_chat_db）
	dbConfig := db.Config{
		Host:     getEnv("DB_HOST", "localhost"),
		Port:     getEnv("DB_PORT", "5432"),
		User:     getEnv("DB_USER", "postgres"),
		Password: getEnv("DB_PASSWORD", "postgres"),
		DBName:   getEnv("DB_NAME", "lesser_chat_db"),
		SSLMode:  getEnv("DB_SSLMODE", "disable"),
	}

	db, err := db.NewConnection(dbConfig)
	if err != nil {
		log.Fatal("数据库连接失败", slog.Any("error", err))
	}
	defer db.Close()
	log.Info("数据库连接成功")

	// 初始化 Redis（可选）
	var redisClient *db.Client
	redisCfg := db.ConfigFromEnv()
	if redisCfg.Host != "" || redisCfg.URL != "" {
		redisClient, err = db.NewClient(redisCfg)
		if err != nil {
			log.Warn("Redis 连接失败，缓存功能禁用", slog.Any("error", err))
		} else {
			log.Info("Redis 连接成功")
		}
	}

	// 初始化仓库层
	conversationRepo := data_access.NewConversationRepository(db)
	messageRepo := data_access.NewMessageRepository(db)

	// 初始化 Auth gRPC 客户端
	authGRPCAddr := getEnv("AUTH_GRPC_ADDR", "gateway:50053")
	authClient, err := remote.NewAuthClient(authGRPCAddr, log)
	if err != nil {
		log.Warn("Auth gRPC 服务连接失败", slog.Any("error", err))
	} else {
		log.Info("Auth gRPC 服务连接成功", slog.String("addr", authGRPCAddr))
	}

	// 初始化用户客户端（带缓存）
	userClient := remote.NewUserClient(authClient, redisClient, log)

	// 初始化未读数缓存服务
	var unreadCacheService *logic.UnreadCacheService
	if redisClient != nil {
		unreadCacheService = logic.NewUnreadCacheService(redisClient, messageRepo)
	}

	// 初始化业务服务
	chatService := logic.NewChatService(conversationRepo, messageRepo, redisClient, userClient, unreadCacheService)

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
