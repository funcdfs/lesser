// Gateway 服务入口
// 职责：JWT 验签、限流、路由转发
package main

import (
	"context"
	"net"
	"os"
	"os/signal"
	"strconv"
	"syscall"

	"go.uber.org/zap"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"

	"github.com/funcdfs/lesser/gateway/internal/server"
)

func main() {
	// 初始化日志
	log := initLogger()
	defer log.Sync()

	// 加载配置
	cfg := loadConfig()

	// 创建 Gateway 服务器
	gatewayServer, err := server.NewGatewayServer(cfg, log)
	if err != nil {
		log.Fatal("创建 Gateway 服务器失败", zap.Error(err))
	}

	// 启动 Gateway
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	if err := gatewayServer.Start(ctx); err != nil {
		log.Fatal("启动 Gateway 失败", zap.Error(err))
	}

	// 创建 gRPC 服务器
	grpcServer := grpc.NewServer(
		grpc.UnaryInterceptor(gatewayServer.AuthInterceptor()),
		grpc.StreamInterceptor(gatewayServer.StreamAuthInterceptor()),
	)

	// 注册服务
	server.RegisterGatewayServer(grpcServer, gatewayServer)
	registerProxyServices(grpcServer, gatewayServer, log)
	reflection.Register(grpcServer)

	// 监听端口
	grpcPort := getEnv("GRPC_PORT", "50053")
	lis, err := net.Listen("tcp", ":"+grpcPort)
	if err != nil {
		log.Fatal("监听端口失败", zap.String("port", grpcPort), zap.Error(err))
	}

	// 优雅关闭
	go gracefulShutdown(cancel, grpcServer, gatewayServer, log)

	log.Info("Gateway 服务已启动",
		zap.String("port", grpcPort),
		zap.String("auth", cfg.AuthServiceAddr),
		zap.String("user", cfg.UserServiceAddr),
		zap.String("post", cfg.PostServiceAddr),
		zap.String("feed", cfg.FeedServiceAddr),
		zap.String("chat", cfg.ChatServiceAddr),
		zap.String("search", cfg.SearchServiceAddr),
		zap.String("notification", cfg.NotificationServiceAddr))

	if err := grpcServer.Serve(lis); err != nil {
		log.Fatal("gRPC 服务异常退出", zap.Error(err))
	}
}

// initLogger 初始化日志
func initLogger() *zap.Logger {
	var log *zap.Logger
	var err error

	if os.Getenv("ENV") == "production" {
		log, err = zap.NewProduction()
	} else {
		log, err = zap.NewDevelopment()
	}

	if err != nil {
		panic("初始化日志失败: " + err.Error())
	}
	return log.Named("gateway")
}

// loadConfig 加载配置
func loadConfig() server.Config {
	return server.Config{
		AuthServiceAddr:         getEnv("AUTH_SERVICE_ADDR", "auth:50054"),
		UserServiceAddr:         getEnv("USER_SERVICE_ADDR", "user:50055"),
		PostServiceAddr:         getEnv("POST_SERVICE_ADDR", "post:50056"),
		FeedServiceAddr:         getEnv("FEED_SERVICE_ADDR", "feed:50057"),
		ChatServiceAddr:         getEnv("CHAT_SERVICE_ADDR", "chat:50052"),
		SearchServiceAddr:       getEnv("SEARCH_SERVICE_ADDR", "search:50058"),
		NotificationServiceAddr: getEnv("NOTIFICATION_SERVICE_ADDR", "notification:50059"),
		RateLimitRate:           getEnvFloat("RATE_LIMIT_RATE", 100),
		RateLimitBurst:          getEnvInt("RATE_LIMIT_BURST", 200),
	}
}

// registerProxyServices 注册代理服务
func registerProxyServices(grpcServer *grpc.Server, gatewayServer *server.GatewayServer, log *zap.Logger) {
	router := gatewayServer.GetRouter()

	// 注册 Auth 代理
	if authConn := router.GetAuthConn(); authConn != nil {
		server.RegisterAuthProxyServer(grpcServer, authConn, log)
	} else {
		log.Warn("Auth 服务不可用，代理未注册")
	}

	// 注册 Search 代理
	if searchConn := router.GetSearchConn(); searchConn != nil {
		server.RegisterSearchProxyServer(grpcServer, searchConn, log)
	} else {
		log.Warn("Search 服务不可用，代理未注册")
	}
}

// gracefulShutdown 优雅关闭
func gracefulShutdown(cancel context.CancelFunc, grpcServer *grpc.Server, gatewayServer *server.GatewayServer, log *zap.Logger) {
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
	<-sigCh

	log.Info("收到关闭信号，开始关闭...")
	cancel()
	grpcServer.GracefulStop()
	gatewayServer.Stop()
}

// 环境变量辅助函数
func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func getEnvInt(key string, defaultValue int) int {
	if value := os.Getenv(key); value != "" {
		if i, err := strconv.Atoi(value); err == nil {
			return i
		}
	}
	return defaultValue
}

func getEnvFloat(key string, defaultValue float64) float64 {
	if value := os.Getenv(key); value != "" {
		if f, err := strconv.ParseFloat(value, 64); err == nil {
			return f
		}
	}
	return defaultValue
}
