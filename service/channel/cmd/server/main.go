// Package main Channel 服务入口
// 职责：广播频道管理、内容发布、订阅管理
package main

import (
	"context"
	"log/slog"
	"net"
	"os"
	"os/signal"
	"strconv"
	"syscall"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/keepalive"
	"google.golang.org/grpc/reflection"

	pb "github.com/funcdfs/lesser/channel/gen_protos/channel"
	"github.com/funcdfs/lesser/channel/internal/data_access"
	"github.com/funcdfs/lesser/channel/internal/handler"
	"github.com/funcdfs/lesser/channel/internal/logic"
	"github.com/funcdfs/lesser/channel/internal/remote"
	"github.com/funcdfs/lesser/pkg/db"
	"github.com/funcdfs/lesser/pkg/log"
)

func main() {
	logger := log.New("channel")
	grpcPort := getEnvInt("GRPC_PORT", 50062)

	dbConfig := db.PostgresConfigFromEnv()
	pgDB, err := db.NewPostgresConnection(dbConfig)
	if err != nil {
		logger.Fatal("数据库连接失败", slog.Any("error", err))
	}
	defer pgDB.Close()
	logger.Info("数据库连接成功")

	var redisClient *db.RedisClient
	redisHost := getEnv("REDIS_HOST", "")
	if redisHost != "" {
		redisCfg := db.RedisConfig{
			Host:     redisHost,
			Port:     getEnv("REDIS_PORT", "6379"),
			Password: getEnv("REDIS_PASSWORD", ""),
			DB:       0,
		}
		redisClient, err = db.NewRedisClient(redisCfg)
		if err != nil {
			logger.Warn("Redis 连接失败", slog.Any("error", err))
		} else {
			logger.Info("Redis 连接成功")
		}
	}

	// 初始化 Auth gRPC 客户端
	authGRPCAddr := getEnv("AUTH_GRPC_ADDR", "auth:50052")
	authClient, err := remote.NewAuthClient(authGRPCAddr, logger)
	if err != nil {
		logger.Warn("Auth gRPC 服务连接失败", slog.Any("error", err))
	} else {
		logger.Info("Auth gRPC 服务连接成功", slog.String("addr", authGRPCAddr))
	}

	channelDA := data_access.NewChannelDataAccess(pgDB)
	subscriptionDA := data_access.NewSubscriptionDataAccess(pgDB)
	postDA := data_access.NewPostDataAccess(pgDB)

	userServiceAddr := getEnv("USER_SERVICE_ADDR", "user:50053")
	userClient, err := remote.NewUserClient(userServiceAddr, logger)
	if err != nil {
		logger.Warn("User 服务连接失败", slog.Any("error", err))
	}

	channelService := logic.NewChannelService(logic.ChannelServiceDeps{
		ChannelDA:      channelDA,
		SubscriptionDA: subscriptionDA,
		PostDA:         postDA,
		UserClient:       userClient,
		RedisClient:      redisClient,
		Logger:           logger,
	})

	streamManager := handler.NewStreamManager(redisClient)
	channelHandler := handler.NewChannelHandler(channelService, streamManager, logger)

	// 创建 gRPC 服务器（带认证拦截器）
	grpcServer := newGRPCServer(authClient, logger)
	pb.RegisterChannelServiceServer(grpcServer, channelHandler)
	reflection.Register(grpcServer)

	addr := ":" + strconv.Itoa(grpcPort)
	lis, err := net.Listen("tcp", addr)
	if err != nil {
		logger.Fatal("端口监听失败", slog.Any("error", err))
	}

	ctx, cancel := context.WithCancel(context.Background())
	go func() {
		sigCh := make(chan os.Signal, 1)
		signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
		<-sigCh
		logger.Info("收到关闭信号")
		cancel()
		grpcServer.GracefulStop()
		if redisClient != nil {
			redisClient.Close()
		}
		if userClient != nil {
			userClient.Close()
		}
		if authClient != nil {
			authClient.Close()
		}
	}()

	logger.Info("Channel 服务已启动", slog.Int("port", grpcPort))
	if err := grpcServer.Serve(lis); err != nil && ctx.Err() == nil {
		logger.Fatal("gRPC 服务异常退出", slog.Any("error", err))
	}
}

// newGRPCServer 创建 gRPC 服务器（带认证和日志拦截器）
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

// getEnv 获取环境变量，如果不存在则返回默认值
func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

// getEnvInt 获取整数类型的环境变量，如果不存在或解析失败则返回默认值
func getEnvInt(key string, defaultValue int) int {
	if value := os.Getenv(key); value != "" {
		if intValue, err := strconv.Atoi(value); err == nil {
			return intValue
		}
	}
	return defaultValue
}
