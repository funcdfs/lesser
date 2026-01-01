package main

import (
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/lesser/auth_worker/internal/broker"
	"github.com/lesser/auth_worker/internal/database"
	"github.com/lesser/auth_worker/internal/worker"
)

func main() {
	// 配置
	rabbitURL := getEnv("RABBITMQ_URL", "amqp://guest:guest@localhost:5672/")
	dbHost := getEnv("DB_HOST", "localhost")
	dbPort := getEnv("DB_PORT", "5432")
	dbUser := getEnv("DB_USER", "postgres")
	dbPassword := getEnv("DB_PASSWORD", "postgres")
	dbName := getEnv("DB_NAME", "lesser")
	jwtSecret := getEnv("JWT_SECRET", "your-secret-key")

	// 连接 PostgreSQL
	dbConfig := database.Config{
		Host:     dbHost,
		Port:     dbPort,
		User:     dbUser,
		Password: dbPassword,
		DBName:   dbName,
	}
	db, err := database.NewConnection(dbConfig)
	if err != nil {
		log.Fatalf("Failed to connect to PostgreSQL: %v", err)
	}
	defer db.Close()
	log.Println("Connected to PostgreSQL")

	// 确保用户表存在
	if err := database.EnsureUsersTable(db); err != nil {
		log.Fatalf("Failed to ensure users table: %v", err)
	}
	log.Println("Users table ready")

	// 连接 RabbitMQ
	rabbitConn, err := broker.NewConnection(rabbitURL)
	if err != nil {
		log.Fatalf("Failed to connect to RabbitMQ: %v", err)
	}
	defer rabbitConn.Close()
	log.Println("Connected to RabbitMQ")

	// 创建 Auth Worker
	authWorker := worker.NewAuthWorker(db, rabbitConn, jwtSecret)

	// 启动消费者
	if err := authWorker.Start(); err != nil {
		log.Fatalf("Failed to start auth worker: %v", err)
	}

	log.Println("Auth Worker started, waiting for messages...")

	// 优雅关闭
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
	<-sigCh

	log.Println("Shutting down Auth Worker...")
	authWorker.Stop()
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
