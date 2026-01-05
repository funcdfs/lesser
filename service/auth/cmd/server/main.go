// Package main Auth 服务入口
// 职责：用户认证、Token 管理、封禁管理
package main

import (
	"context"
	"net"
	"os"
	"os/signal"
	"syscall"

	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"

	pb "github.com/funcdfs/lesser/auth/gen_protos/auth"
	"github.com/funcdfs/lesser/auth/internal/config"
	"github.com/funcdfs/lesser/auth/internal/crypto"
	"github.com/funcdfs/lesser/auth/internal/data_access"
	"github.com/funcdfs/lesser/auth/internal/handler"
	"github.com/funcdfs/lesser/auth/internal/logic"
	"github.com/funcdfs/lesser/pkg/db"
	"github.com/funcdfs/lesser/pkg/log"
)

func main() {
	// 初始化日志
	logger := log.New("auth")

	// 加载配置
	cfg := config.LoadFromEnv()
	logger.Info("配置已加载",
		log.String("service", cfg.ServiceName),
		log.String("port", cfg.GRPCPort))

	// 初始化数据库
	pgDB, err := db.NewPostgresConnection(db.PostgresConfig{
		Host:     cfg.DBHost,
		Port:     cfg.DBPort,
		User:     cfg.DBUser,
		Password: cfg.DBPassword,
		DBName:   cfg.DBName,
		SSLMode:  cfg.DBSSLMode,
	})
	if err != nil {
		logger.Error("连接数据库失败", log.Any("error", err))
		os.Exit(1)
	}
	defer pgDB.Close()
	logger.Info("数据库连接成功")

	// 初始化 Redis（可选）
	var redisClient *db.RedisClient
	if cfg.RedisURL != "" {
		redisClient, err = db.NewRedisClient(db.RedisConfig{URL: cfg.RedisURL})
		if err != nil {
			logger.Warn("连接 Redis 失败，部分功能将不可用", log.Any("error", err))
		} else {
			defer redisClient.Close()
			logger.Info("Redis 连接成功")
		}
	}

	// 创建数据访问层
	var userDA data_access.UserDataAccess = data_access.NewUserDataAccess(pgDB)
	var banDA data_access.BanDataAccess = data_access.NewBanDataAccess(pgDB)

	// 创建 Redis 数据访问（如果可用）
	var tokenBlacklist data_access.TokenBlacklistDataAccess
	var banCache *data_access.BanCache
	var loginAttemptCache *data_access.LoginAttemptCache
	if redisClient != nil {
		tokenBlacklist = data_access.NewTokenBlacklistDataAccess(redisClient)
		banCache = data_access.NewBanCache(redisClient, cfg.BanCacheTTL)
		loginAttemptCache = data_access.NewLoginAttemptCache(redisClient, cfg.LoginLockoutTime)
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
		logger.Error("创建 JWT 管理器失败", log.Any("error", err))
		os.Exit(1)
	}

	// 启动 JWT 密钥轮换
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	jwtManager.Start(ctx)

	// 创建服务
	authService := logic.NewAuthService(logic.AuthServiceDeps{
		UserDA:          userDA,
		BanDA:           banDA,
		TokenBlacklist:    tokenBlacklist,
		BanCache:          banCache,
		LoginAttemptCache: loginAttemptCache,
		PasswordHasher:    passwordHasher,
		PasswordValidator: passwordValidator,
		JWTManager:        jwtManager,
		Config:            cfg,
		Logger:            logger,
	})

	// 创建 gRPC 处理器
	authHandler := handler.NewAuthHandler(authService, logger)

	// 创建 gRPC 服务器
	grpcServer := grpc.NewServer()
	pb.RegisterAuthServiceServer(grpcServer, authHandler)
	reflection.Register(grpcServer)

	// 监听端口
	lis, err := net.Listen("tcp", ":"+cfg.GRPCPort)
	if err != nil {
		logger.Error("监听端口失败", log.String("port", cfg.GRPCPort), log.Any("error", err))
		os.Exit(1)
	}

	// 优雅关闭
	go gracefulShutdown(cancel, grpcServer, jwtManager, logger)

	logger.Info("Auth 服务已启动", log.String("port", cfg.GRPCPort))
	if err := grpcServer.Serve(lis); err != nil {
		logger.Error("gRPC 服务异常退出", log.Any("error", err))
		os.Exit(1)
	}
}

// gracefulShutdown 优雅关闭
func gracefulShutdown(cancel context.CancelFunc, grpcServer *grpc.Server, jwtManager *crypto.JWTManager, logger *log.Logger) {
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
	<-sigCh

	logger.Info("收到关闭信号，开始关闭...")
	cancel()
	jwtManager.Stop()
	grpcServer.GracefulStop()
	logger.Info("服务已关闭")
}
