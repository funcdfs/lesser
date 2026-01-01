package main

import (
	"context"
	"log"
	"net"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/lesser/chat/internal/config"
	"github.com/lesser/chat/internal/handler/ws"
	"github.com/lesser/chat/internal/model"
	"github.com/lesser/chat/internal/repository"
	"github.com/lesser/chat/internal/server"
	"github.com/lesser/chat/internal/service"
	"github.com/lesser/chat/pkg/cache"
	"github.com/lesser/chat/pkg/database"
	"github.com/lesser/chat/pkg/logger"
)

func main() {
	logger.Init()

	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("加载配置失败: %v", err)
	}

	// 初始化数据库
	db, err := database.NewPostgres(cfg.DatabaseURL)
	if err != nil {
		log.Fatalf("连接数据库失败: %v", err)
	}
	log.Println("已连接到 PostgreSQL")

	if err := database.AutoMigrate(db, &model.Conversation{}, &model.ConversationMember{}, &model.Message{}); err != nil {
		log.Fatalf("数据库迁移失败: %v", err)
	}
	log.Println("数据库表结构迁移完成")

	// 初始化 Redis
	redisClient, err := cache.NewRedis(cfg.RedisURL)
	if err != nil {
		log.Printf("警告: 连接 Redis 失败: %v", err)
	} else {
		log.Println("已连接到 Redis")
	}

	// 初始化仓库层
	conversationRepo := repository.NewConversationRepository(db)
	messageRepo := repository.NewMessageRepository(db)

	// 初始化 Auth gRPC 客户端
	var authClient *service.AuthClient
	authClient, err = service.NewAuthClient(cfg.AuthGRPCAddr)
	if err != nil {
		log.Printf("警告: 连接 Auth gRPC 服务失败: %v", err)
	} else {
		log.Printf("已连接到 Auth gRPC 服务: %s", cfg.AuthGRPCAddr)
	}

	userClient := service.NewUserClient(authClient, redisClient)

	var unreadCacheService *service.UnreadCacheService
	if redisClient != nil {
		unreadCacheService = service.NewUnreadCacheService(redisClient, messageRepo)
	}

	chatService := service.NewChatService(conversationRepo, messageRepo, redisClient, userClient, unreadCacheService)

	// 初始化 WebSocket Hub
	hub := ws.NewHub(chatService, cfg)
	go hub.Run()

	// 初始化 WebSocket HTTP 服务器（仅 /ws/chat 和 /health）
	wsServer := server.NewWSServer(cfg, hub)

	// 初始化 gRPC 服务器
	grpcServer := server.NewGRPCServer(chatService, authClient, hub)

	// 启动 gRPC
	grpcListener, err := net.Listen("tcp", ":"+cfg.GRPCPort)
	if err != nil {
		log.Fatalf("监听 gRPC 端口失败: %v", err)
	}
	go func() {
		log.Printf("gRPC 服务器启动于端口 %s", cfg.GRPCPort)
		if err := grpcServer.Serve(grpcListener); err != nil {
			log.Fatalf("gRPC 服务启动失败: %v", err)
		}
	}()

	// 启动 WebSocket HTTP 服务器
	go func() {
		log.Printf("WebSocket 服务器启动于端口 %s", cfg.WSPort)
		if err := wsServer.Start(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("WebSocket 服务启动失败: %v", err)
		}
	}()

	// 优雅关闭
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	log.Println("正在关闭服务器...")

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	grpcServer.GracefulStop()
	log.Println("gRPC 服务器已停止")

	if err := wsServer.Shutdown(ctx); err != nil {
		log.Printf("WebSocket 服务器强制关闭: %v", err)
	}
	log.Println("WebSocket 服务器已停止")

	sqlDB, _ := db.DB()
	if sqlDB != nil {
		sqlDB.Close()
	}

	if redisClient != nil {
		redisClient.Close()
	}

	if authClient != nil {
		authClient.Close()
	}

	log.Println("服务器已正常退出")
}
