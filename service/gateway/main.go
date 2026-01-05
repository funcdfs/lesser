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

	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"

	"github.com/funcdfs/lesser/gateway/internal/server"
	"github.com/funcdfs/lesser/pkg/log"
)

func main() {
	// 初始化日志
	logger := log.New("gateway")
	log.SetGlobal(logger)

	// 加载配置
	cfg := loadConfig()

	// 创建 Gateway 服务器
	gatewayServer, err := server.NewGatewayServer(cfg, logger)
	if err != nil {
		logger.Error("创建 Gateway 服务器失败", log.Any("error", err))
		os.Exit(1)
	}

	// 启动 Gateway
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	if err := gatewayServer.Start(ctx); err != nil {
		logger.Error("启动 Gateway 失败", log.Any("error", err))
		os.Exit(1)
	}

	// 创建 gRPC 服务器
	grpcServer := grpc.NewServer(
		grpc.UnaryInterceptor(gatewayServer.AuthInterceptor()),
		grpc.StreamInterceptor(gatewayServer.StreamAuthInterceptor()),
	)

	// 注册服务
	server.RegisterGatewayServer(grpcServer, gatewayServer)
	registerProxyServices(grpcServer, gatewayServer, logger)
	reflection.Register(grpcServer)

	// 监听端口
	grpcPort := getEnv("GRPC_PORT", "50051")
	lis, err := net.Listen("tcp", ":"+grpcPort)
	if err != nil {
		logger.Error("监听端口失败", log.String("port", grpcPort), log.Any("error", err))
		os.Exit(1)
	}

	// 优雅关闭
	go gracefulShutdown(cancel, grpcServer, gatewayServer, logger)

	logger.Info("Gateway 服务已启动",
		log.String("port", grpcPort),
		log.String("auth", cfg.AuthServiceAddr),
		log.String("user", cfg.UserServiceAddr),
		log.String("content", cfg.ContentServiceAddr),
		log.String("interaction", cfg.InteractionServiceAddr),
		log.String("comment", cfg.CommentServiceAddr),
		log.String("timeline", cfg.TimelineServiceAddr),
		log.String("chat", cfg.ChatServiceAddr),
		log.String("channel", cfg.ChannelServiceAddr),
		log.String("search", cfg.SearchServiceAddr),
		log.String("notification", cfg.NotificationServiceAddr))

	if err := grpcServer.Serve(lis); err != nil {
		logger.Error("gRPC 服务异常退出", log.Any("error", err))
		os.Exit(1)
	}
}

// loadConfig 加载配置
func loadConfig() server.Config {
	return server.Config{
		AuthServiceAddr:         getEnv("AUTH_SERVICE_ADDR", "auth:50052"),
		UserServiceAddr:         getEnv("USER_SERVICE_ADDR", "user:50053"),
		ContentServiceAddr:      getEnv("CONTENT_SERVICE_ADDR", "content:50054"),
		CommentServiceAddr:      getEnv("COMMENT_SERVICE_ADDR", "comment:50055"),
		InteractionServiceAddr:  getEnv("INTERACTION_SERVICE_ADDR", "interaction:50056"),
		TimelineServiceAddr:     getEnv("TIMELINE_SERVICE_ADDR", "timeline:50057"),
		SearchServiceAddr:       getEnv("SEARCH_SERVICE_ADDR", "search:50058"),
		NotificationServiceAddr: getEnv("NOTIFICATION_SERVICE_ADDR", "notification:50059"),
		ChatServiceAddr:         getEnv("CHAT_SERVICE_ADDR", "chat:50060"),
		ChannelServiceAddr:      getEnv("CHANNEL_SERVICE_ADDR", "channel:50062"),
		RateLimitRate:           getEnvFloat("RATE_LIMIT_RATE", 100),
		RateLimitBurst:          getEnvInt("RATE_LIMIT_BURST", 200),
	}
}

// registerProxyServices 注册代理服务
func registerProxyServices(grpcServer *grpc.Server, gatewayServer *server.GatewayServer, logger *log.Logger) {
	router := gatewayServer.GetRouter()

	// 注册 Auth 代理
	if authConn := router.GetAuthConn(); authConn != nil {
		server.RegisterAuthProxyServer(grpcServer, authConn, logger)
	} else {
		logger.Warn("Auth 服务不可用，代理未注册")
	}

	// 注册 User 代理
	if userConn := router.GetUserConn(); userConn != nil {
		server.RegisterUserProxyServer(grpcServer, userConn, logger)
	} else {
		logger.Warn("User 服务不可用，代理未注册")
	}

	// 注册 Content 代理
	if contentConn := router.GetContentConn(); contentConn != nil {
		server.RegisterContentProxyServer(grpcServer, contentConn, logger)
	} else {
		logger.Warn("Content 服务不可用，代理未注册")
	}

	// 注册 Interaction 代理
	if interactionConn := router.GetInteractionConn(); interactionConn != nil {
		server.RegisterInteractionProxyServer(grpcServer, interactionConn, logger)
	} else {
		logger.Warn("Interaction 服务不可用，代理未注册")
	}

	// 注册 Comment 代理
	if commentConn := router.GetCommentConn(); commentConn != nil {
		server.RegisterCommentProxyServer(grpcServer, commentConn, logger)
	} else {
		logger.Warn("Comment 服务不可用，代理未注册")
	}

	// 注册 Timeline 代理
	if timelineConn := router.GetTimelineConn(); timelineConn != nil {
		server.RegisterTimelineProxyServer(grpcServer, timelineConn, logger)
	} else {
		logger.Warn("Timeline 服务不可用，代理未注册")
	}

	// 注册 Search 代理
	if searchConn := router.GetSearchConn(); searchConn != nil {
		server.RegisterSearchProxyServer(grpcServer, searchConn, logger)
	} else {
		logger.Warn("Search 服务不可用，代理未注册")
	}

	// 注册 Notification 代理
	if notificationConn := router.GetNotificationConn(); notificationConn != nil {
		server.RegisterNotificationProxyServer(grpcServer, notificationConn, logger)
	} else {
		logger.Warn("Notification 服务不可用，代理未注册")
	}
}

// gracefulShutdown 优雅关闭
func gracefulShutdown(cancel context.CancelFunc, grpcServer *grpc.Server, gatewayServer *server.GatewayServer, logger *log.Logger) {
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
	<-sigCh

	logger.Info("收到关闭信号，开始关闭...")
	cancel()
	grpcServer.GracefulStop()
	gatewayServer.Stop()
}

// ---- 环境变量辅助函数 ----

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
