// Package app 提供应用生命周期管理
// 统一管理所有组件的启动和关闭顺序
package app

import (
	"context"
	"database/sql"
	"fmt"
	"log/slog"
	"os"
	"os/signal"
	"sync"
	"syscall"
	"time"

	"github.com/funcdfs/lesser/pkg/db"
	"github.com/funcdfs/lesser/pkg/grpc/client"
	"github.com/funcdfs/lesser/pkg/log"
	"github.com/funcdfs/lesser/pkg/mq"
)

// Component 可管理的组件接口
type Component interface {
	// Start 启动组件
	Start(ctx context.Context) error
	// Stop 停止组件
	Stop() error
	// Name 组件名称
	Name() string
}

// App 应用实例，管理所有组件的生命周期
type App struct {
	name       string
	log        *log.Logger
	db         *sql.DB
	worker     *mq.Worker
	cache      *db.RedisClient
	grpcPool   *client.Pool
	components []Component
	mu         sync.Mutex
}

// Config 应用配置
type Config struct {
	// Name 应用名称
	Name string
	// RabbitMQURL RabbitMQ 连接地址
	RabbitMQURL string
	// Database 数据库配置
	Database db.PostgresConfig
	// Redis Redis 配置
	Redis db.RedisConfig
	// EnableRedis 是否启用 Redis
	EnableRedis bool
	// EnableGRPC 是否启用 gRPC 客户端连接池
	EnableGRPC bool
}

// ConfigFromEnv 从环境变量读取配置
func ConfigFromEnv(name string) Config {
	// 检查是否启用 Redis（如果设置了 REDIS_URL 或 REDIS_HOST）
	enableRedis := getEnv("REDIS_URL", "") != "" || getEnv("REDIS_HOST", "") != ""

	return Config{
		Name:        name,
		RabbitMQURL: getEnv("RABBITMQ_URL", "amqp://guest:guest@localhost:5672/"),
		Database: db.PostgresConfig{
			Host:     getEnv("DB_HOST", "localhost"),
			Port:     getEnv("DB_PORT", "5432"),
			User:     getEnv("DB_USER", "postgres"),
			Password: getEnv("DB_PASSWORD", "postgres"),
			DBName:   getEnv("DB_NAME", "lesser"),
			SSLMode:  getEnv("DB_SSLMODE", "disable"),
		},
		Redis:       db.RedisConfigFromEnv(),
		EnableRedis: enableRedis,
	}
}

// New 创建新的 App 实例
func New(cfg Config) (*App, error) {
	logger := log.New(cfg.Name)

	// 初始化数据库
	database, err := db.NewPostgresConnection(cfg.Database)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to database: %w", err)
	}
	logger.Info("connected to PostgreSQL")

	// 初始化 Worker
	worker := mq.NewWorker(cfg.RabbitMQURL, logger)

	app := &App{
		name:     cfg.Name,
		log:      logger,
		db:       database,
		worker:   worker,
		grpcPool: client.NewPool(logger),
	}

	// 初始化 Redis（如果启用）
	if cfg.EnableRedis {
		redisClient, err := db.NewRedisClient(cfg.Redis)
		if err != nil {
			// Redis 连接失败不阻止应用启动，只记录警告
			logger.Warn("failed to connect to Redis, cache disabled", slog.Any("error", err))
		} else {
			app.cache = redisClient
			logger.Info("connected to Redis")
		}
	}

	return app, nil
}

// DB 返回数据库连接
func (a *App) DB() *sql.DB {
	return a.db
}

// Worker 返回 Broker Worker
func (a *App) Worker() *mq.Worker {
	return a.worker
}

// Logger 返回日志实例
func (a *App) Logger() *log.Logger {
	return a.log
}

// Cache 返回 Redis 客户端
func (a *App) Cache() *db.RedisClient {
	return a.cache
}

// GRPCPool 返回 gRPC 连接池
func (a *App) GRPCPool() *client.Pool {
	return a.grpcPool
}

// Register 注册组件
func (a *App) Register(components ...Component) {
	a.mu.Lock()
	defer a.mu.Unlock()
	a.components = append(a.components, components...)
}

// Run 启动应用，阻塞直到收到停止信号
func (a *App) Run(ctx context.Context, brokerConfigs ...mq.Config) error {
	// 启动所有注册的组件
	for _, c := range a.components {
		a.log.Info("starting component", slog.String("component", c.Name()))
		if err := c.Start(ctx); err != nil {
			return fmt.Errorf("failed to start component %s: %w", c.Name(), err)
		}
	}

	// 如果有 broker 配置，启动 worker
	if len(brokerConfigs) > 0 {
		a.log.Info("starting broker worker")
		// Worker.Start 会阻塞直到收到停止信号
		return a.worker.Start(ctx, brokerConfigs...)
	}

	// 没有 broker 配置时，等待停止信号
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)

	select {
	case <-ctx.Done():
		a.log.Info("context cancelled")
	case sig := <-sigCh:
		a.log.Info("received signal", slog.String("signal", sig.String()))
	}

	a.Shutdown()
	return nil
}

// Shutdown 优雅关闭应用
// 使用超时保护确保关闭过程不会无限阻塞
func (a *App) Shutdown() {
	a.log.Info("shutting down application")

	// 创建带超时的 context
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	// 逆序关闭组件
	for i := len(a.components) - 1; i >= 0; i-- {
		c := a.components[i]
		a.log.Info("stopping component", slog.String("component", c.Name()))

		// 使用 goroutine 和 select 实现超时
		done := make(chan error, 1)
		go func() {
			done <- c.Stop()
		}()

		select {
		case err := <-done:
			if err != nil {
				a.log.Error("failed to stop component",
					slog.String("component", c.Name()),
					slog.Any("error", err))
			}
		case <-ctx.Done():
			a.log.Warn("component stop timeout",
				slog.String("component", c.Name()))
		}
	}

	// 关闭 gRPC 连接池
	if a.grpcPool != nil {
		a.grpcPool.Close()
		a.log.Info("grpc connections closed")
	}

	// 关闭 Redis 连接
	if a.cache != nil {
		a.cache.Close()
		a.log.Info("redis connection closed")
	}

	// 关闭数据库连接
	if a.db != nil {
		a.db.Close()
		a.log.Info("database connection closed")
	}

	// 刷新日志
	a.log.Sync()
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
