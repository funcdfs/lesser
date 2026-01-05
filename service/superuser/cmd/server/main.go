// Package main SuperUser 服务入口
// 职责：超级管理员认证、用户管理、内容管理、系统监控
package main

import (
	"context"
	"net"
	"os"
	"os/signal"
	"syscall"

	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"

	"github.com/funcdfs/lesser/pkg/db"
	"github.com/funcdfs/lesser/pkg/log"
	pb "github.com/funcdfs/lesser/superuser/gen_protos/superuser"
	"github.com/funcdfs/lesser/superuser/internal/config"
	"github.com/funcdfs/lesser/superuser/internal/crypto"
	"github.com/funcdfs/lesser/superuser/internal/data_access"
	"github.com/funcdfs/lesser/superuser/internal/handler"
	"github.com/funcdfs/lesser/superuser/internal/logic"
	"github.com/redis/go-redis/v9"
)

func main() {
	// 初始化日志
	logger := log.New("superuser")

	// 加载配置
	cfg := config.LoadFromEnv()
	logger.Info("配置已加载",
		log.String("service", cfg.ServiceName),
		log.String("port", cfg.GRPCPort))

	// 初始化数据库
	database, err := db.NewPostgresConnection(db.PostgresConfig{
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
	defer database.Close()
	logger.Info("数据库连接成功")

	// 初始化 Redis
	var redisClient *redis.Client
	if cfg.RedisURL != "" {
		opt, err := redis.ParseURL(cfg.RedisURL)
		if err != nil {
			logger.Warn("解析 Redis URL 失败", log.Any("error", err))
		} else {
			redisClient = redis.NewClient(opt)
			if err := redisClient.Ping(context.Background()).Err(); err != nil {
				logger.Warn("连接 Redis 失败", log.Any("error", err))
				redisClient = nil
			} else {
				defer redisClient.Close()
				logger.Info("Redis 连接成功")
			}
		}
	}

	// 创建数据访问层
	superUserDA := data_access.NewSuperUserDataAccess(database)
	auditLogDA := data_access.NewAuditLogDataAccess(database)
	sessionDA := data_access.NewSessionDataAccess(database)
	userDA := data_access.NewUserDataAccess(database)
	contentDA := data_access.NewContentDataAccess(database)
	systemDA := data_access.NewSystemDataAccess(database)

	// 创建密码哈希器
	passwordHasher := crypto.NewPasswordHasher(&crypto.Argon2Params{
		Memory:      cfg.Argon2Memory,
		Iterations:  cfg.Argon2Iterations,
		Parallelism: cfg.Argon2Parallelism,
		SaltLength:  cfg.Argon2SaltLength,
		KeyLength:   cfg.Argon2KeyLength,
	})

	// 创建 JWT 管理器
	jwtManager := crypto.NewJWTManager(
		cfg.JWTSecret,
		cfg.AccessTokenDuration,
		cfg.RefreshTokenDuration,
	)

	// 初始化默认超级管理员
	if err := initDefaultSuperUser(context.Background(), superUserDA, passwordHasher, cfg, logger); err != nil {
		logger.Error("初始化默认超级管理员失败", log.Any("error", err))
		os.Exit(1)
	}

	// 创建服务
	superUserService := logic.NewSuperUserService(logic.ServiceDeps{
		SuperUserDA:  superUserDA,
		AuditLogDA:   auditLogDA,
		SessionDA:    sessionDA,
		UserDA:       userDA,
		ContentDA:    contentDA,
		SystemDA:     systemDA,
		PasswordHasher: passwordHasher,
		JWTManager:     jwtManager,
		RedisClient:    redisClient,
		Config:         cfg,
		Logger:         logger,
	})

	// 创建 gRPC 处理器
	superUserHandler := handler.NewSuperUserHandler(superUserService, logger)

	// 创建 gRPC 服务器
	grpcServer := grpc.NewServer()
	pb.RegisterSuperUserServiceServer(grpcServer, superUserHandler)
	reflection.Register(grpcServer)

	// 监听端口
	lis, err := net.Listen("tcp", ":"+cfg.GRPCPort)
	if err != nil {
		logger.Error("监听端口失败", log.String("port", cfg.GRPCPort), log.Any("error", err))
		os.Exit(1)
	}

	// 优雅关闭
	go gracefulShutdown(grpcServer, logger)

	logger.Info("SuperUser 服务已启动", log.String("port", cfg.GRPCPort))
	if err := grpcServer.Serve(lis); err != nil {
		logger.Error("gRPC 服务异常退出", log.Any("error", err))
		os.Exit(1)
	}
}

// initDefaultSuperUser 初始化默认超级管理员
func initDefaultSuperUser(ctx context.Context, da data_access.SuperUserDataAccess, hasher *crypto.PasswordHasher, cfg *config.Config, logger *log.Logger) error {
	// 检查是否已存在
	exists, err := da.ExistsByUsername(ctx, cfg.DefaultUsername)
	if err != nil {
		return err
	}
	if exists {
		logger.Info("默认超级管理员已存在", log.String("username", cfg.DefaultUsername))

		// 更新密码（确保密码是最新的哈希）
		su, err := da.GetByUsername(ctx, cfg.DefaultUsername)
		if err != nil {
			return err
		}

		// 检查密码是否是占位符
		if su.Password == "$placeholder$" {
			hashedPassword, err := hasher.Hash(cfg.DefaultPassword)
			if err != nil {
				return err
			}
			su.Password = hashedPassword
			if err := da.Update(ctx, su); err != nil {
				return err
			}
			logger.Info("已更新默认超级管理员密码")
		}
		return nil
	}

	// 创建默认超级管理员
	hashedPassword, err := hasher.Hash(cfg.DefaultPassword)
	if err != nil {
		return err
	}

	su := &data_access.SuperUser{
		Username:    cfg.DefaultUsername,
		Email:       cfg.DefaultEmail,
		Password:    hashedPassword,
		DisplayName: cfg.DefaultDisplayName,
		IsActive:    true,
	}

	if err := da.Create(ctx, su); err != nil {
		return err
	}

	logger.Info("已创建默认超级管理员",
		log.String("username", cfg.DefaultUsername),
		log.String("email", cfg.DefaultEmail))

	return nil
}

// gracefulShutdown 优雅关闭
func gracefulShutdown(grpcServer *grpc.Server, logger *log.Logger) {
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
	<-sigCh

	logger.Info("收到关闭信号，开始关闭...")
	grpcServer.GracefulStop()
	logger.Info("服务已关闭")
}
