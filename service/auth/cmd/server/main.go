// Package main Auth 服务入口
// 职责：用户认证、Token 管理、封禁管理
package main

import (
	"context"
	"log/slog"
	"net"
	"os"
	"os/signal"
	"syscall"

	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"

	"github.com/funcdfs/lesser/auth/internal/config"
	"github.com/funcdfs/lesser/auth/internal/crypto"
	"github.com/funcdfs/lesser/auth/internal/handler"
	"github.com/funcdfs/lesser/auth/internal/repository"
	"github.com/funcdfs/lesser/auth/internal/repository/postgres"
	redisRepo "github.com/funcdfs/lesser/auth/internal/repository/redis"
	"github.com/funcdfs/lesser/auth/internal/service"
	pb "github.com/funcdfs/lesser/auth/proto/auth"
	"github.com/funcdfs/lesser/pkg/cache"
	"github.com/funcdfs/lesser/pkg/database"
)

func main() {
	// 初始化日志
	log := initLogger()

	// 加载配置
	cfg := config.LoadFromEnv()
	log.Info("配置已加载",
		slog.String("service", cfg.ServiceName),
		slog.String("port", cfg.GRPCPort))

	// 初始化数据库
	db, err := database.NewConnection(database.Config{
		Host:     cfg.DBHost,
		Port:     cfg.DBPort,
		User:     cfg.DBUser,
		Password: cfg.DBPassword,
		DBName:   cfg.DBName,
		SSLMode:  cfg.DBSSLMode,
	})
	if err != nil {
		log.Error("连接数据库失败", slog.Any("error", err))
		os.Exit(1)
	}
	defer db.Close()
	log.Info("数据库连接成功")

	// 初始化 Redis（可选）
	var redisClient *cache.Client
	if cfg.RedisURL != "" {
		redisClient, err = cache.NewClient(cache.Config{URL: cfg.RedisURL})
		if err != nil {
			log.Warn("连接 Redis 失败，部分功能将不可用", slog.Any("error", err))
		} else {
			defer redisClient.Close()
			log.Info("Redis 连接成功")
		}
	}

	// 创建仓库
	var userRepo repository.UserRepository = postgres.NewUserRepository(db)
	var banRepo repository.BanRepository = postgres.NewBanRepository(db)

	// 创建 Redis 仓库（如果可用）
	var tokenBlacklist repository.TokenBlacklistRepository
	var banCache *redisRepo.BanCache
	var loginAttemptCache *redisRepo.LoginAttemptCache
	if redisClient != nil {
		tokenBlacklist = redisRepo.NewTokenBlacklistRepository(redisClient)
		banCache = redisRepo.NewBanCache(redisClient, cfg.BanCacheTTL)
		loginAttemptCache = redisRepo.NewLoginAttemptCache(redisClient, cfg.LoginLockoutTime)
	}

	// 创建密码哈希器
	passwordHasher := crypto.NewPasswordHasher(&crypto.Argon2Params{
		Memory:      cfg.Argon2Memory,
		Iterations:  cfg.Argon2Iterations,
		Parallelism: cfg.Argon2Parallelism,
		SaltLength:  cfg.Argon2SaltLength,
		KeyLength:   cfg.Argon2KeyLength,
	})

	// 创建密码验证器
	passwordValidator := crypto.NewPasswordValidator(
		cfg.PasswordMinLength,
		cfg.PasswordRequireNum,
		cfg.PasswordRequireMix,
	)

	// 创建 JWT 管理器
	jwtManager, err := crypto.NewJWTManager(crypto.JWTManagerConfig{
		HMACSecret:           cfg.JWTSecret,
		KeySize:              cfg.RSAKeySize,
		AccessTokenDuration:  cfg.AccessTokenDuration,
		RefreshTokenDuration: cfg.RefreshTokenDuration,
		KeyRotationInterval:  cfg.KeyRotationInterval,
	})
	if err != nil {
		log.Error("创建 JWT 管理器失败", slog.Any("error", err))
		os.Exit(1)
	}

	// 启动 JWT 密钥轮换
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	jwtManager.Start(ctx)

	// 创建服务
	authService := service.NewAuthService(service.AuthServiceDeps{
		UserRepo:          userRepo,
		BanRepo:           banRepo,
		TokenBlacklist:    tokenBlacklist,
		BanCache:          banCache,
		LoginAttemptCache: loginAttemptCache,
		PasswordHasher:    passwordHasher,
		PasswordValidator: passwordValidator,
		JWTManager:        jwtManager,
		Config:            cfg,
		Logger:            log,
	})

	// 创建 gRPC 处理器
	authHandler := handler.NewAuthHandler(authService, log)

	// 创建 gRPC 服务器
	grpcServer := grpc.NewServer()
	pb.RegisterAuthServiceServer(grpcServer, authHandler)
	reflection.Register(grpcServer)

	// 监听端口
	lis, err := net.Listen("tcp", ":"+cfg.GRPCPort)
	if err != nil {
		log.Error("监听端口失败", slog.String("port", cfg.GRPCPort), slog.Any("error", err))
		os.Exit(1)
	}

	// 优雅关闭
	go gracefulShutdown(cancel, grpcServer, jwtManager, log)

	log.Info("Auth 服务已启动", slog.String("port", cfg.GRPCPort))
	if err := grpcServer.Serve(lis); err != nil {
		log.Error("gRPC 服务异常退出", slog.Any("error", err))
		os.Exit(1)
	}
}

// initLogger 初始化日志
func initLogger() *slog.Logger {
	var handler slog.Handler

	if os.Getenv("ENV") == "production" {
		handler = slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
			Level:     slog.LevelInfo,
			AddSource: true,
		})
	} else {
		handler = slog.NewTextHandler(os.Stdout, &slog.HandlerOptions{
			Level:     slog.LevelDebug,
			AddSource: true,
		})
	}

	return slog.New(handler).With(slog.String("service", "auth"))
}

// gracefulShutdown 优雅关闭
func gracefulShutdown(cancel context.CancelFunc, grpcServer *grpc.Server, jwtManager *crypto.JWTManager, log *slog.Logger) {
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
	<-sigCh

	log.Info("收到关闭信号，开始关闭...")
	cancel()
	jwtManager.Stop()
	grpcServer.GracefulStop()
	log.Info("服务已关闭")
}
