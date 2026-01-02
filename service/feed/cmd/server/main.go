package main

import (
	"context"
	"log"
	"net"
	"os"
	"os/signal"
	"syscall"

	"github.com/funcdfs/lesser/feed/internal/handler"
	"github.com/funcdfs/lesser/feed/internal/repository"
	"github.com/funcdfs/lesser/feed/internal/service"
	pb "github.com/funcdfs/lesser/feed/proto/feed"
	"github.com/funcdfs/lesser/pkg/database"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

func main() {
	grpcPort := getEnv("GRPC_PORT", "50057")

	dbConfig := database.Config{
		Host:     getEnv("DB_HOST", "localhost"),
		Port:     getEnv("DB_PORT", "5432"),
		User:     getEnv("DB_USER", "postgres"),
		Password: getEnv("DB_PASSWORD", "postgres"),
		DBName:   getEnv("DB_NAME", "lesser"),
		SSLMode:  getEnv("DB_SSLMODE", "disable"),
	}

	db, err := database.NewConnection(dbConfig)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer db.Close()
	log.Println("Connected to PostgreSQL")

	likeRepo := repository.NewLikeRepository(db)
	commentRepo := repository.NewCommentRepository(db)
	bookmarkRepo := repository.NewBookmarkRepository(db)
	feedSvc := service.NewFeedService(likeRepo, commentRepo, bookmarkRepo)
	feedHandler := handler.NewFeedHandler(feedSvc)

	grpcServer := grpc.NewServer()
	pb.RegisterFeedServiceServer(grpcServer, feedHandler)
	reflection.Register(grpcServer)

	lis, err := net.Listen("tcp", ":"+grpcPort)
	if err != nil {
		log.Fatalf("Failed to listen: %v", err)
	}

	ctx, cancel := context.WithCancel(context.Background())
	go func() {
		sigCh := make(chan os.Signal, 1)
		signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
		<-sigCh
		log.Println("Shutting down...")
		cancel()
		grpcServer.GracefulStop()
	}()

	log.Printf("Feed Service listening on :%s", grpcPort)
	if err := grpcServer.Serve(lis); err != nil && ctx.Err() == nil {
		log.Fatalf("Failed to serve: %v", err)
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
