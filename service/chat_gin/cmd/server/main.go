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
	grpchandler "github.com/lesser/chat/internal/handler/grpc"
	"github.com/lesser/chat/internal/handler/ws"
	"github.com/lesser/chat/internal/model"
	"github.com/lesser/chat/internal/repository"
	"github.com/lesser/chat/internal/server"
	"github.com/lesser/chat/internal/service"
	"github.com/lesser/chat/pkg/cache"
	"github.com/lesser/chat/pkg/database"
	"google.golang.org/grpc"
)

func main() {
	// 加载配置
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("加载配置失败: %v", err)
	}

	// 初始化数据库连接
	db, err := database.NewPostgres(cfg.DatabaseURL)
	if err != nil {
		log.Fatalf("连接数据库失败: %v", err)
	}
	log.Println("已连接到 PostgreSQL")

	// 自动迁移数据库表结构
	if err := database.AutoMigrate(db, &model.Conversation{}, &model.ConversationMember{}, &model.Message{}); err != nil {
		log.Fatalf("数据库迁移失败: %v", err)
	}
	log.Println("数据库表结构迁移完成")

	// 初始化 Redis 缓存
	redisClient, err := cache.NewRedis(cfg.RedisURL)
	if err != nil {
		log.Printf("警告: 连接 Redis 失败: %v", err)
		// 继续运行，但处于降级模式（无缓存）
	} else {
		log.Println("已连接到 Redis")
	}

	// 初始化数据仓库层
	conversationRepo := repository.NewConversationRepository(db)
	messageRepo := repository.NewMessageRepository(db)

	// 初始化用户服务客户端（用于从 Django 获取用户信息）
	userClient := service.NewUserClient("http://django:8000")

	// 初始化业务服务层
	chatService := service.NewChatService(conversationRepo, messageRepo, redisClient, userClient)

	// 初始化 WebSocket 连接管理中心
	hub := ws.NewHub(chatService)
	go hub.Run()

	// 初始化 HTTP 服务器
	httpServer := server.NewHTTPServer(cfg, chatService, hub)

	// 初始化 gRPC 服务器
	grpcServer := grpc.NewServer()
	chatGRPCHandler := grpchandler.NewChatHandler(chatService)
	chatGRPCHandler.Register(grpcServer)

	// 启动 gRPC 服务器
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

	// 启动 HTTP 服务器
	go func() {
		log.Printf("HTTP 服务器启动于端口 %s", cfg.HTTPPort)
		if err := httpServer.Start(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("HTTP 服务启动失败: %v", err)
		}
	}()

	// 等待中断信号
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	log.Println("正在关闭服务器...")

	// 优雅关闭
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// 停止 gRPC 服务器
	grpcServer.GracefulStop()
	log.Println("gRPC 服务器已停止")

	// 停止 HTTP 服务器
	if err := httpServer.Shutdown(ctx); err != nil {
		log.Printf("HTTP 服务器强制关闭: %v", err)
	}
	log.Println("HTTP 服务器已停止")

	// 关闭数据库连接
	sqlDB, _ := db.DB()
	if sqlDB != nil {
		sqlDB.Close()
	}
	log.Println("数据库连接已关闭")

	// 关闭 Redis 连接
	if redisClient != nil {
		redisClient.Close()
	}
	log.Println("Redis 连接已关闭")

	log.Println("服务器已正常退出")
}
