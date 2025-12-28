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
	// Load configuration
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}

	// Initialize database
	db, err := database.NewPostgres(cfg.DatabaseURL)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	log.Println("Connected to PostgreSQL")

	// Auto-migrate database schema
	if err := database.AutoMigrate(db, &model.Conversation{}, &model.ConversationMember{}, &model.Message{}); err != nil {
		log.Fatalf("Failed to auto-migrate database: %v", err)
	}
	log.Println("Database schema migrated")

	// Initialize Redis
	redisClient, err := cache.NewRedis(cfg.RedisURL)
	if err != nil {
		log.Printf("Warning: Failed to connect to Redis: %v", err)
		// Continue without Redis (degraded mode)
	} else {
		log.Println("Connected to Redis")
	}

	// Initialize repositories
	conversationRepo := repository.NewConversationRepository(db)
	messageRepo := repository.NewMessageRepository(db)

	// Initialize services
	chatService := service.NewChatService(conversationRepo, messageRepo, redisClient)

	// Initialize WebSocket hub
	hub := ws.NewHub(chatService)
	go hub.Run()

	// Initialize HTTP server
	httpServer := server.NewHTTPServer(cfg, chatService, hub)

	// Initialize gRPC server
	grpcServer := grpc.NewServer()
	chatGRPCHandler := grpchandler.NewChatHandler(chatService)
	chatGRPCHandler.Register(grpcServer)

	// Start gRPC server
	grpcListener, err := net.Listen("tcp", ":"+cfg.GRPCPort)
	if err != nil {
		log.Fatalf("Failed to listen on gRPC port: %v", err)
	}
	go func() {
		log.Printf("gRPC server starting on port %s", cfg.GRPCPort)
		if err := grpcServer.Serve(grpcListener); err != nil {
			log.Fatalf("Failed to serve gRPC: %v", err)
		}
	}()

	// Start HTTP server
	go func() {
		log.Printf("HTTP server starting on port %s", cfg.HTTPPort)
		if err := httpServer.Start(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Failed to start HTTP server: %v", err)
		}
	}()

	// Wait for interrupt signal
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	log.Println("Shutting down servers...")

	// Graceful shutdown
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// Stop gRPC server
	grpcServer.GracefulStop()
	log.Println("gRPC server stopped")

	// Stop HTTP server
	if err := httpServer.Shutdown(ctx); err != nil {
		log.Printf("HTTP server forced to shutdown: %v", err)
	}
	log.Println("HTTP server stopped")

	// Close database connection
	sqlDB, _ := db.DB()
	if sqlDB != nil {
		sqlDB.Close()
	}
	log.Println("Database connection closed")

	// Close Redis connection
	if redisClient != nil {
		redisClient.Close()
	}
	log.Println("Redis connection closed")

	log.Println("Server exited properly")
}
